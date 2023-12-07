# Akeyless Azure AD Dynamic Secret Action

This GitHub Action uses Akeyless REST API to generate and fetch an Azure Active Directory dynamic secret.

## Inputs

- `akeyless-secret-path` (**required**): The location of the secret in your AAD secret in the Akeyless vault (ex. /path-to/my-secret)
- `akeyless-access-id` (**required**): The Akeyless access ID (ex. p-123456, found in Users & Auth Methods portal)
- `akeyless-access-key` (**required**): The API access key, visit https://docs.akeyless.io/docs/api-key for more info.
- `vault-url`: This value overrides the default vault root URL. The default value is https://api.akeyless.io'

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
    uses: ./
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