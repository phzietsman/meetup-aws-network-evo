data aws_caller_identity peer {
  provider = aws.accepter
}

data aws_vpc accepter {
  provider = aws.accepter
  id       = var.accepter_vpc_id
}

data aws_vpc requester {
  provider = aws.requester
  id       = var.requester_vpc_id
}

resource aws_vpc_peering_connection peer {
  provider = aws.requester

  vpc_id        = var.requester_vpc_id
  peer_vpc_id   = var.accepter_vpc_id
  peer_owner_id = data.aws_caller_identity.peer.account_id
  auto_accept   = false

  tags = {
    Side = "Requester"
  }
}

resource aws_vpc_peering_connection_accepter peer {
  provider = aws.accepter

  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}

resource aws_vpc_peering_connection_options requester {
  provider = aws.requester

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource aws_vpc_peering_connection_options accepter {
  provider = aws.accepter

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}

// Routing 
// requester_route_table_ids
// accepter_route_table_ids

resource aws_route requester {
  count = length(var.requester_route_table_ids)

  provider = aws.requester

  route_table_id            = var.requester_route_table_ids[count.index]
  destination_cidr_block    = data.aws_vpc.accepter.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
}


resource aws_route acccepter {
  count = length(var.accepter_route_table_ids)

  provider = aws.accepter

  route_table_id            = var.accepter_route_table_ids[count.index]
  destination_cidr_block    = data.aws_vpc.requester.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
}


