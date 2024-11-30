# Description

The following folder is meant to be executed as part of DR rollback for RDS cluster Secondary region to Primary region. This script allows the users to provide custom parameters to prevent any human errors while rolling back and make it easier to sync with the terraform state. 

Unlike other folders in this repository, this is a single module fodler and creates only two resources:-
1. RDS Cluster
2. RDS Instance

### Inputs

>**Warning !!!** : The resources being mentioned here must match the same as originally provisioned resources that were in use for Primary RDS before DR switchover unless specifically requested for DR values to maintain the terraform state. All the resources can be found from AWS console.


| Name                           | Description                                                         | Type                                                        | Default                                                                      |
| :----------------------------- | :------------------------------------------------------------------ | :---------------------------------------------------------- | :--------------------------------------------------------------------------- |
| region                                    | AWS region to configure provider and provision the resources                                               | string                             | `"us-east-1"`                                                                |
| environment                               | Environment for which the resources are being provisioned                                                  | string                             | `-`                                                                     |
| cost_tags                                 | Tags associated with specifc customer and environment                                                      | map(string)                        | `{ env-type = "test" customer = "internal" cost-center = "overhead"}`        |
|primary_crr_rds_config\*            | Configuration parameters for RDS cluster CRR (**DR resources must be provisioned in prior**)| object | [Primary CRR RDS Config](#markdown-header-primary-crr-rds-config) |
|primary_central_vpc_id| VPC ID in which the RDS cluster needs to be provisioned| string| `-`|
|primary_rds_cluster_parameter_group_name| Parameter group name of RDS cluster to be used| string|`-`|
|primary_db_subnet_group_id| Database subnet group to be used for RDS| string| `-` |
|primary_rds_security_group_id| Security group ID of RDS to be used| 
|dr_rds_cluster_arn| Cluster ARN of Secondary cluster| string| `-`|
|db_parameter_group_name| Parameter group name of the RDS Cluster| string| `-`|

### Primary CRR RDS Config
The following object is used to setup Cross Region Replication(CRR) for the RDS cluster created in the primary region. For CRR to be setup the DR region must be already setup without an active EKS cluster. All the below requested parameters are to be provided from DR region. 

| Name              | Description                                                                | Type           | Default                                            |
|:------------------|:---------------------------------------------------------------------------|:---------------|:---------------------------------------------------|
| backup_retention_period\* | Time period to retain RDS CRR backup| number | `-` |
| vpc_id\* | VPC ID of DR region | string  | `-`|
| eks_security_group\*| Security group ID of EKS in DR region|  string | `-` |
|kms_key_id\*| KMS key ARN used for encrypting generic resources. Has the following alias format `{alias}-{environment}-{region}"` | string | `-`|
|subnet_ids\*|Subnet IDS in which the CRR cluster needs to bre created | list(string)| `-` |
|deletion_protection| Whether to enable delete protection or not |  bool | `true` |
|parameter_group_family| family of the parameter group of RDS cluster | string |`"aurora-mysql5.7"`|
|engine_version|RDS engine version of the CRR|string|`"5.7.mysql_aurora.2.11.5"`|
|instance_type|Size of the CRR instance | string|`"db.t4g.large"` |
|db_parameter_group_parameters| Parameters for the parameter group of DB | list(map(string))| `[{name="log_bin_trust_function_creators", value = 1, apply_method = "pending-reboot", }, {,name = "binlog_format", value = "MIXED", apply_method = "pending-reboot", }, {name         = "long_query_time", value = "10", apply_method = "immediate"}]`|
