Remove-Item -LiteralPath ".terraform" -Force -Recurse -ErrorAction SilentlyContinue

Remove-Item -LiteralPath ".terraform.lock.hcl" -Force -ErrorAction SilentlyContinue

Remove-Item -LiteralPath "plan.tfplan" -Force -ErrorAction SilentlyContinue

terraform init

terraform validate

terraform fmt

terraform plan -out="./plan.tfplan"