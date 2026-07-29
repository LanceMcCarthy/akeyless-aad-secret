[CmdletBinding()]
param(
    [string]$AkeylessSecretPath = $env:AKEYLESS_SECRET_PATH,
    [string]$AkeylessAccessId = $env:AKEYLESS_ACCESS_ID,
    [string]$AkeylessAccessKey = $env:AKEYLESS_ACCESS_KEY,
    [string]$VaultUrl = $env:VAULT_URL,
    [string]$GitHubOutput = $env:GITHUB_OUTPUT
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($AkeylessSecretPath)) {
    throw "Input 'akeyless-secret-path' is required. For example, /path-to/my-secret."
}

if ([string]::IsNullOrWhiteSpace($AkeylessAccessId)) {
    throw "Input 'akeyless-access-id' is required. See https://docs.akeyless.io/docs/api-key for more information."
}

if ([string]::IsNullOrWhiteSpace($AkeylessAccessKey)) {
    throw "Input 'akeyless-access-key' is required. See https://docs.akeyless.io/docs/api-key for more information."
}

if ([string]::IsNullOrWhiteSpace($VaultUrl)) {
    $VaultUrl = 'https://api.akeyless.io'
}

$parsedVaultUri = $null
if (-not [Uri]::TryCreate($VaultUrl, [UriKind]::Absolute, [ref]$parsedVaultUri) -or $parsedVaultUri.Scheme -ne 'https') {
    throw "Input 'vault-url' must be an absolute HTTPS URL."
}

$VaultUrl = $parsedVaultUri.AbsoluteUri.TrimEnd('/')

$authBody = @{
    'access-id' = $AkeylessAccessId
    'access-key' = $AkeylessAccessKey
    'access-type' = 'access_key'
}

$authParameters = @{
    Method = 'POST'
    Uri = "$VaultUrl/auth"
    Body = ($authBody | ConvertTo-Json)
    ContentType = 'application/json'
}

try {
    $authResponse = Invoke-RestMethod @authParameters
}
catch {
    if ($null -ne $_.Exception.Response.StatusCode) {
        throw "Akeyless authentication failed (HTTP Status $($_.Exception.Response.StatusCode))"
    } else {
        throw "Akeyless authentication failed: $($_.Exception.Message)"
    }
}

$token = $authResponse.token
if ([string]::IsNullOrWhiteSpace($token)) {
    throw "Akeyless authentication succeeded but returned no token."
}

$secretBody = @{
    name = $AkeylessSecretPath
    token = $token
}

$secretParameters = @{
    Method = 'POST'
    Uri = "$VaultUrl/get-dynamic-secret-value"
    Body = ($secretBody | ConvertTo-Json)
    ContentType = 'application/json'
}

try {
    $dynamicSecret = Invoke-RestMethod @secretParameters
}
catch {
    if ($null -ne $_.Exception.Response.StatusCode) {
        throw "Akeyless dynamic secret retrieval failed with HTTP status $($_.Exception.Response.StatusCode)"
    } else {
        throw "Akeyless dynamic secret retrieval failed: $($_.Exception.Message)"
    }
}

if ($null -eq $dynamicSecret.secret) {
    Write-Output '::error::Akeyless returned no dynamic secret.'
    throw 'Akeyless returned no dynamic secret.'
}

$outputs = [ordered]@{
    'app-id' = $dynamicSecret.secret.appId
    'tenant-id' = $dynamicSecret.secret.tenantId
    'secret-text' = $dynamicSecret.secret.secretText
    'key-id' = $dynamicSecret.secret.keyId
    'display-name' = $dynamicSecret.secret.displayName
}

foreach ($output in $outputs.GetEnumerator()) {
    if ([string]::IsNullOrWhiteSpace($output.Value)) {
        Write-Output "::warning::Akeyless returned an empty '$($output.Key)' value."
    }
}

if ([string]::IsNullOrWhiteSpace($GitHubOutput)) {
    [PSCustomObject]$outputs
    return
}

foreach ($output in $outputs.GetEnumerator()) {
    Add-Content -LiteralPath $GitHubOutput -Value "$($output.Key)=$($output.Value)"
}