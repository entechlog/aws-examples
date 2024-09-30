# Define the DMS replication subnet group
resource "aws_dms_replication_subnet_group" "dms_private_subnet_group" {
  replication_subnet_group_description = "Private subnet group for DMS replication"
  replication_subnet_group_id          = "${local.resource_name_prefix}-dms-replication-subnet-group"
  subnet_ids                           = module.data_vpc.private_subnet_id
}
