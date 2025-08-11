## How to Update or Create New SSM Parameters or Secrets

To **update or create** new SSM Parameters, create a `.tfvars` file in the same directory with the following structure:

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
