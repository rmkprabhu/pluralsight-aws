module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.36.0"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    sandbox_nodes = {
      desired_capacity = var.node_desired_capacity
      max_capacity     = var.node_desired_capacity
      min_capacity     = var.node_desired_capacity

      instance_types = [var.node_instance_type]

      disk_size = var.node_disk_size

      tags = {
        Environment = "sandbox"
        Terraform   = "true"
      }
    }
  }

  tags = {
    Environment = "sandbox"
    Terraform   = "true"
  }
}
