terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"  # or "us-west-2"
}

# Create VPC with public and private subnets
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name = "pluralsight-sandbox-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    "Environment" = "sandbox"
    "Terraform"   = "true"
  }
}

# Create EKS cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.36.0"

  cluster_name    = "pluralsight-sandbox-eks"
  cluster_version = "1.27"

  subnets = module.vpc.private_subnets
  vpc_id  = module.vpc.vpc_id

  # Enable public access to the cluster endpoint for sandbox usability
  cluster_endpoint_public_access = true

  # Managed node group configuration (non-auto scaling)
  eks_managed_node_groups = {
    sandbox_nodes = {
      desired_capacity = 2
      max_capacity     = 2
      min_capacity     = 2

      instance_types = ["t3.medium"]  # Allowed sandbox VM size

      disk_size = 50  # EBS volume size ≤ 100 GB as per sandbox limits

      tags = {
        "Environment" = "sandbox"
        "Terraform"   = "true"
      }
    }
  }

  tags = {
    "Environment" = "sandbox"
    "Terraform"   = "true"
  }
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "kubeconfig_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}
