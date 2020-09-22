data aws_caller_identity receiver {
    provider = aws.receiver
}

resource aws_ram_principal_association sender_invite {
  provider = aws.network

  principal          = data.aws_caller_identity.receiver.account_id
  resource_share_arn = var.resource_share_arn
}

# Not needed in the current Org
# resource aws_ram_resource_share_accepter receiver_accept  {
#     provider = aws.receiver

#   share_arn = aws_ram_principal_association.sender_invite.resource_share_arn
# }