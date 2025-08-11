### How to Encrypt Or Decrypt files with sops
```bash
1. Install sops from [offical Github.](https://github.com/getsops/sops/releases)
#Use KMS Key 'ssm-parameters-encryption-key-<ENV>' to encrypt tfavars file
2. sops -e --kms KMS_ARN FILE #For Encrypting tfvars file
3. sops -d -i FILE #For Decrypting tfvars file
```

## How to Update or Create New SSM Parameters or Secrets

To **update or create** new SSM Parameters, create a `.tfvars` file in the tfvars directory with the following structure:

```hcl
ssm_parameters = {
  "API_XD-XX-dev" = {
    value = "XXX"
    type  = "SecureString"
  },
  "API_XD-dev" = {
    value = "XXX"
    type  = "SecureString"
  }
}
