# Output the Transit Gateway IDs for each region
output "transit_gateway_ids" {
  value = {
    "us-east-1"      = aws_ec2_transit_gateway.tgw_us_east_1.id
    "us-west-2"      = aws_ec2_transit_gateway.tgw_us_west_2.id
    "ap-southeast-1" = aws_ec2_transit_gateway.tgw_ap_southeast_1.id
    "eu-west-1"      = aws_ec2_transit_gateway.tgw_eu_west_1.id
  }
  description = "Map of region to Transit Gateway ID"
}

# Output the Transit Gateway Peering Attachment IDs
output "transit_gateway_peering_attachment_ids" {
  value = [
    aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_us_west_2.id,
    aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_ap_southeast_1.id,
    aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_west_2_ap_southeast_1.id,
    aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_eu_west_1,
    aws_ec2_transit_gateway_peering_attachment.tgw_peering_eu_west_1_ap_southeast_1,
    aws_ec2_transit_gateway_peering_attachment.tgw_peering_eu_west_1_us_west_2
  ]
  description = "List of Transit Gateway Peering Attachment IDs"
}
