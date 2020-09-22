module account_a_vpc {
  source = "./modules/vpc"

  providers = {
    aws = aws.account_a
  }

  cidr         = "10.1.0.0/16"
  account_name = "a"
}

module account_b_vpc {
  source = "./modules/vpc"

  providers = {
    aws = aws.account_b
  }

  cidr         = "10.2.0.0/16"
  account_name = "b"
}


module peer {
  source = "./modules/peering"

  providers = {
    aws.requester = aws.account_a
    aws.accepter  = aws.account_b
  }

  requester_vpc_id          = module.account_a_vpc.vpc_id
  requester_route_table_ids = module.account_a_vpc.private_route_table_ids

  accepter_vpc_id          = module.account_b_vpc.vpc_id
  accepter_route_table_ids = module.account_b_vpc.private_route_table_ids
}
