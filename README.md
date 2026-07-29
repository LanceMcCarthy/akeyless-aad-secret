# Akeyless Azure AD Dynamic Secret Action

This GitHub Action uses Akeyless REST API to generate and fetch an Azure Active Directory dynamic secret. See 

## Inputs

- `akeyless-secret-path` (**required**): The location of the secret in your AAD secret in the Akeyless vault (ex. /path-to/my-secret)
- `akeyless-access-id` (**required**): The Akeyless access ID (ex. p-123456, found in Users & Auth Methods portal)
- `akeyless-access-key` (**required**): The API access key, visit https://docs.akeyless.io/docs/api-key for more info.
- `vault-url`: This value overrides the default vault root URL. The default value is https://api.akeyless.io.

>[!NOTE]
> This requires an Akeyless API Key Auth Method. See [Akeyless Prerequisities](#akeyless-prerequisities) for details.

## Outputs

- app-id: The value of secret.appId from the AAD dynamic secret.
- tenant-id: The value of secret.tenantId from the AAD dynamic secret.
- secret-text: The value of secret.secretText from the AAD dynamic secret.
- key-id: The value of secret.keyId from the AAD dynamic secret.
- display-name: The value of secret.displayName from the AAD dynamic secret.

## Example

```yaml
runs-on: windows-latest
name: Check for success
steps:
  - name: Checkout
    uses: actions/checkout@v3

  - name: Get AAD Secret
    id: aad-secret
    uses: LanceMcCarthy/akeyless-aad-secret@v1
    with:
      akeyless-secret-path: '/DevTools/live-azure-ad'
      akeyless-access-id: '${{ secrets.AKEYLESS_ACCESS_ID }}'
      akeyless-access-key: '${{ secrets.AKEYLESS_ACCESS_KEY }}'

  - name: Verify Output
    shell: pwsh
    run: |
      echo "${{ steps.aad-secret.outputs.app-id }}"
      echo "${{ steps.aad-secret.outputs.tenant-id }}"
      echo "${{ steps.aad-secret.outputs.secret-text }}"
      echo "${{ steps.aad-secret.outputs.key-id }}"
      echo "${{ steps.aad-secret.outputs.display-name }}"
```



## Akeyless Prerequisities

Make sure your [API Key Auth Method](https://docs.akeyless.io/docs/auth-with-api-key) is associated with an [Access Role](https://docs.akeyless.io/docs/rbac) that allowed to use the [Azure AD Target](https://docs.akeyless.io/docs/azure-targets). Once aligned, it will be allowed to generate the [Azure AD Dynamic Secrets](https://docs.akeyless.io/docs/azure-ad-dynamic-secrets).

If you want to confirm your details are correct before running this Action in your workflow, choose from one of these options.

### Local Validation - Akeyless CLI

Using the [Akeyless CLI](https://docs.akeyless.io/docs/cli).

1. Log into the CLI using the API Key auth method

```bash
akeyless configure --access-id "" --access-key "" --access-type access_key
```

2. Once the CLI is configured, confirm that Accedd ID has permissions to access the 

```bash
akeyless get-dynamic-secret-value --name "/path/to/entra-dynamic-secret"
```

If Step 2 works, then you have 100% confidence it will work in this Action, too.

### Local Validation - PowerShell Script

Using the same exact PowerShell logic this action uses.

1. Change the working directory 

```pwsh
cd ./github/testing
```

2. Invoke the ps1 script with the minimum required parameters.

```pwsh
./Get-AkeylessAadSecret.ps1 `
    -AkeylessSecretPath "/entra-id-live" `
    -AkeylessAccessId "p-nqj9gvov4nyjem" `
    -AkeylessAccessKey "hrY.....................Cc="
```
