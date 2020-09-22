output vpc_id {
  value = aws_vpc.main.id
}

output private_route_table_ids {
  value = aws_route_table.private.*.id
}

output private_subnet_ids {
  value = aws_subnet.public.*.id
}

output private_subnet_arns {
  value = aws_subnet.private.*.arn
}

output public_subnet_arns {
  value = aws_subnet.public.*.arn
}



output public_subnet_ids {
  value = aws_subnet.public.*.id
}