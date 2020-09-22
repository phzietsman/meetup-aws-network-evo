locals {
  share_name = "network-share-${var.account_name}"
}

resource aws_ram_resource_share main {
  name                      = local.share_name
  allow_external_principals = false

  tags = {
    Name = local.share_name
  }
}

resource aws_ram_resource_association subnets {

  count = length(var.subnet_arns)

  resource_arn       = var.subnet_arns[count.index]
  resource_share_arn = aws_ram_resource_share.main.arn
}