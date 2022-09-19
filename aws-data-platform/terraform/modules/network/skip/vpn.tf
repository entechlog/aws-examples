resource "aws_customer_gateway" "home" {
  bgp_asn    = 65000
  ip_address = var.remote_public_ip_address
  type       = "ipsec.1"

  tags = merge(local.tags, {
    Name        = "${lower(var.env_code)}-${lower(var.project_code)}-home-cgw"
    Environment = "${upper(var.env_code)}"
  })
}

resource "aws_vpn_gateway" "home" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.tags, {
    Name        = "${lower(var.env_code)}-${lower(var.project_code)}-home-vgw"
    Environment = "${upper(var.env_code)}"
  })
}

resource "aws_vpn_gateway_attachment" "home" {
  vpc_id         = aws_vpc.vpc.id
  vpn_gateway_id = aws_vpn_gateway.home.id
}

resource "aws_vpn_connection" "home" {
  vpn_gateway_id      = aws_vpn_gateway.home.id
  customer_gateway_id = aws_customer_gateway.home.id
  type                = "ipsec.1"
  static_routes_only  = true


  tags = merge(local.tags, {
    Name        = "${lower(var.env_code)}-${lower(var.project_code)}-home-vpn"
    Environment = "${upper(var.env_code)}"
  })

}


resource "aws_vpn_gateway_route_propagation" "public" {
  vpn_gateway_id = aws_vpn_gateway.home.id
  route_table_id = aws_route_table.public.id
  timeouts {
    create = "5m"
  }
}

resource "aws_vpn_gateway_route_propagation" "private" {
  vpn_gateway_id = aws_vpn_gateway.home.id
  route_table_id = aws_route_table.private.id
  timeouts {
    create = "5m"
  }
}

resource "aws_vpn_connection_route" "home" {
  destination_cidr_block = var.remote_private_cidr_block
  vpn_connection_id      = aws_vpn_connection.home.id
}