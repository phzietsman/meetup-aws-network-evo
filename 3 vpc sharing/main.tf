module account_network_vpc {
  source = "./modules/vpc"

  providers = {
    aws = aws.network
  }

  cidr         = "10.1.0.0/16"
  account_name = "network"
}

module account_network_ram {
  source = "./modules/ram"

  providers = {
    aws = aws.network
  }
  account_name = "network"
  subnet_arns  = module.account_network_vpc.private_subnet_arns
}

module account_a_share {
  source = "./modules/share"

  providers = {
    aws.network = aws.network
    aws.receiver = aws.account_a
  }

  resource_share_arn  = module.account_network_ram.resource_share_arn
}

# module account_b_share {
#   source = "./modules/share"

#   providers = {
#     aws.network = aws.network
#     aws.receiver = aws.account_b
#   }

#   subnet_arns  = module.account_network_ram.resource_share_arn
# }