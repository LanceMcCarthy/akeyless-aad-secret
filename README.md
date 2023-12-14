# Akeyless Azure AD Dynamic Secret Action

This GitHub Action uses Akeyless REST API to generate and fetch an Azure Active Directory dynamic secret.

## Inputs

- `akeyless-secret-path` (**required**): The location of the secret in your AAD secret in the Akeyless vault (ex. /path-to/my-secret)
- `akeyless-access-id` (**required**): The Akeyless access ID (ex. p-123456, found in Users & Auth Methods portal)
- Auth Method (**required**): You need to choose one of the following options.
  - `repo-token` (implicit approach): This option uses the identity of the repository itself, no local secrets needed.
  - `akeyless-access-key` (explicit approach): The API access key, visit https://docs.akeyless.io/docs/api-key for more info.
- `vault-url`: This value overrides the default vault root URL. The default value is https://api.akeyless.io'.

## Outputs

- `app-id`: The value of secret.appId from the AAD dynamic secret.
- `tenant-id`: The value of secret.tenantId from the AAD dynamic secret.
- `secret-text`: The value of secret.secretText from the AAD dynamic secret.
- `key-id`: The value of secret.keyId from the AAD dynamic secret.
- `display-name`: The value of secret.displayName from the AAD dynamic secret.

## Examples

### GitHub JWT Option

This approach uses GitHub JWT authentication. The advantage is that you do not need to add any secrets to the repo, the `GITHUB_TOKEN` is provided by default.

```yaml
runs-on: windows-latest
name: Check for success
permissions:
  id-token: write
  contents: read

steps:
  - name: Checkout
    uses: actions/checkout@v3

  - name: Get AAD Secret
    id: aad-secret
    uses: LanceMcCarthy/akeyless-aad-secret@v1
    with:
      akeyless-secret-path: '/path-to/my-dynamic-secret'
      akeyless-access-id: 'p-123456'
      repo-token: ${{ secrets.GITHUB_TOKEN }}

  - name: Verify Output
    shell: pwsh
    run: |
      echo "${{ steps.aad-secret.outputs.app-id }}"
      echo "${{ steps.aad-secret.outputs.tenant-id }}"
      echo "${{ steps.aad-secret.outputs.secret-text }}"
      echo "${{ steps.aad-secret.outputs.key-id }}"
      echo "${{ steps.aad-secret.outputs.display-name }}"
```

>Important: Take note of `permissions:` section, this is required to access the GITHUB_TOKEN.

### Access Key (aka API key) Option

IF you cannot use JWT option, you can still generate an access_token in the Akeyless portal and use it here.

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
      akeyless-secret-path: '/path-to/my-dynamic-secret'
      akeyless-access-id: 'p-123456'
      akeyless-access-key: '${{ secrets.YOUR_AKEYLESS_ACCESS_KEY }}'

  - name: Verify Output
    shell: pwsh
    run: |
      echo "${{ steps.aad-secret.outputs.app-id }}"
      echo "${{ steps.aad-secret.outputs.tenant-id }}"
      echo "${{ steps.aad-secret.outputs.secret-text }}"
      echo "${{ steps.aad-secret.outputs.key-id }}"
      echo "${{ steps.aad-secret.outputs.display-name }}"
```