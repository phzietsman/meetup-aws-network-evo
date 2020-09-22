terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.7.0"
    }
  }
}

provider aws {
  alias = "network"

  region  = var.region
  profile = var.account_profile_network
}

provider aws {
  alias = "account_a"

  region  = var.region
  profile = var.account_profile_account_a
}

provider aws {
  alias = "account_b"

  region  = var.region
  profile = var.account_profile_account_b
}