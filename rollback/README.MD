# Description

The following folder is meant to be executed as part of DR rollback for RDS cluster Secondary region to Primary region. This script allows the users to provide custom parameters to prevent any human errors while rolling back and make it easier to sync with the terraform state.

Unlike other folders in this repository, this is a single module fodler and creates only two resources:-
1. RDS Cluster
2. RDS Instance

### Inputs

>**NOTE !!!** : All the parameters for provisioning this eks cluster are taken from variable `rds-config`. Except the one mentoined below. Please refer the [FX-Admin README](../fx-admin/README.md) for more details.

| Name                           | Description                                                         | Type                                                        | Default                                                                      |
| :----------------------------- | :------------------------------------------------------------------ | :---------------------------------------------------------- | :--------------------------------------------------------------------------- |
|dr_rds_cluster_arn\*| Cluster ARN of Secondary cluster| string| `-`|

### Outputs

This module has no output.