# Multi-Tier AWS Infrastructure

This repository defines a practical, enterprise-style AWS environment using Terraform. It creates a secure network with public and private subnets, a bastion host, AWS Client VPN, an EC2 web-app tier, RDS PostgreSQL database, automated backups, monitoring alarms, and a disaster-recovery plan.

## Features

- **Networking**

  - VPC with public and private subnets across two AZs
  - Internet Gateway and public route table

- **Security & Access**

  - Bastion host (SSH access) in public subnet
  - AWS Client VPN with certificate authentication
  - IAM and CloudTrail logging

- **Compute & Database**

  - EC2 instances for application tier
  - RDS PostgreSQL in private subnet

- **Backup & DR**

  - Daily snapshots via AWS Backup
  - Cross-region snapshot replication and failover guidance

- **Monitoring & Alerts**
  - CloudWatch CPU alarms
  - SNS topic for notifications

## Prerequisites

- Terraform ≥ 1.4
- AWS CLI configured with appropriate permissions
- ACM certificates for Client VPN (root CA & server cert)
- SSH key pair in target region

## Getting Started

1. **Clone the repo**

   ```bash
   git clone https://github.com/your-username/aws-multi-tier-infrastructure.git
   cd aws-multi-tier-infrastructure
   ```

2. **Review and customize**  
   Edit `terraform.tfvars` with your region, AZs, CIDRs, AMI IDs, key names, and ACM certificate ARNs.

3. **Initialize Terraform**

   ```bash
   terraform init
   ```

4. **Plan and apply**
   ```bash
   terraform plan
   terraform apply
   ```

## File Structure

```
.
├── main.tf          # Core provider and resource definitions
├── variables.tf     # Input variable declarations
├── outputs.tf       # Key outputs (VPC ID, subnet IDs, endpoints)
├── terraform.tfvars # Example values for all variables
└── README.md        # Project overview and instructions
```

## Variables

| Name                         | Description                                        | Type               |
| ---------------------------- | -------------------------------------------------- | ------------------ |
| `aws_region`                 | AWS region                                         | string             |
| `availability_zones`         | List of AZs                                        | list(string)       |
| `vpc_cidr`                   | VPC CIDR block                                     | string             |
| `public_subnets_cidrs`       | Public subnet CIDRs                                | list(string)       |
| `private_subnets_cidrs`      | Private subnet CIDRs                               | list(string)       |
| `bastion_allowed_cidr`       | CIDR block allowed SSH access to bastion           | string             |
| `bastion_ami`                | AMI ID for bastion host                            | string             |
| `bastion_instance_type`      | EC2 instance type for bastion                      | string             |
| `key_name`                   | SSH key pair name                                  | string             |
| `client_vpn_root_cert_arn`   | ACM root CA certificate ARN for VPN authentication | string             |
| `client_vpn_server_cert_arn` | ACM server certificate ARN for VPN endpoint        | string             |
| `client_vpn_cidr`            | Client VPN CIDR for client IP allocation           | string             |
| `rds_allocated_storage`      | RDS storage in GB                                  | number             |
| `rds_engine_version`         | PostgreSQL engine version                          | string             |
| `rds_instance_class`         | RDS instance size                                  | string             |
| `rds_db_name`                | Initial database name                              | string             |
| `rds_username`               | RDS master username                                | string             |
| `rds_password`               | RDS master password                                | string (sensitive) |

## Outputs

- **vpc_id**: ID of the created VPC
- **public_subnet_ids**: List of public subnet IDs
- **private_subnet_ids**: List of private subnet IDs
- **bastion_public_ip**: Public IP address of the bastion host
- **rds_endpoint**: Endpoint address for the RDS instance
- **client_vpn_endpoint_id**: Client VPN endpoint ID

## Next Steps

- Refactor into modules for reusable components
- Add Route 53 failover record sets for DR
- Integrate Lambda for automated health checks
- Implement IAM policies for least-privilege access

## Contributing

1. Fork the repo
2. Create a feature branch
3. Submit a pull request with tests and documentation updates

## License

Licensed under the MIT License. See [LICENSE](LICENSE) for details.
