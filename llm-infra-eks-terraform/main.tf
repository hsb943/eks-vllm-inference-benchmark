module "networking" {
  source             = "./modules/networking"
  vpc_cidr           = var.vpc_cidr
  name_prefix        = var.name_prefix
  tags               = local.tags
  availability_zones = var.availability_zones
}

module "eks" {
  source             = "./modules/eks"
  cluster_name       = var.cluster_name
  name_prefix        = var.name_prefix
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids_by_az[var.node_availability_zone]
  public_subnet_ids  = module.networking.public_subnet_ids
}

module "security" {
  source            = "./modules/security"
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  name_prefix       = var.name_prefix
}

