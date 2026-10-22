### Infrastructure Provisioning & Environment Note
The Terraform codebase is structured following production best practices with dedicated modules for VPC, Compute (ASG), Security Groups, IAM, Database (RDS), and Storage (S3 & Secrets Manager).

- **Syntactic & Structural Validation:** All resources and dependencies are fully mapped and verified via `terraform plan`.
- **Target Environment Constraint:** During the deployment phase, resource provisioning was halted by organization-level Service Control Policies (`arn:aws:organizations::541165757114:policy/o-rxma1nyyrz/service_control_policy/p-exox1olu`) applied to the sandbox IAM entity, which explicitly denies VPC, S3 bucket, and Secrets Manager creation.
