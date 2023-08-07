# Description

This Repository contains the code to automate the creation of different AWS resources related to networking like VPC , its subnets , internet gateway, nat gateway with keeping the security hub requirements in mind and flow logging enabled for VPC.

# Prerequisites

The following technologies are used in local system while creating this script

| Resource  | Version |
|:----------|:--------|
| Terraform | 1.4.6   |
| AWS CLI   | 2.11.15 |

Provider versions used while creation of script

| Resource   | Version |
|:-----------|:--------|
| AWS        | 19.15.3 |

Before running the script ensure that you have the AWS credentials configured in your system.

# Modules

#### [VPC](./modules/vpc)

The VPC module deals with the creation of VPC in the given region with internet and NAT gateway and also the different different public and private subnets with different ACL's as well. The VPC has flow logging enabled and has dedicated public and private network ACL and rules set . It also provisions one NAT gateway by default in the first az.

# Folder Structure

```
.
├── backend.tf
├── main.tf
├── modules
│   └── vpc
│       ├── main.tf
│       ├── outputs.tf
│       └── vars.tf
├── outputs.tf
├── providers.tf
├── README.md
├── terraform.tfvars
└── vars.tf
```

The [providers.tf](./providers.tf) file contains all the necessary plugins that are required to run the script i.e AWS provider.

The [root main.tf](./main.tf) file is the file that triggers the VPC module for creation of resources.

The root [vars.tf](./vars.tf) file has the input variables for for customizing the resources.

The root [outputs.tf](./outputs.tf) file has the variables that are shown at the end of the script in the console from the module as result.

The [backend.tf](./backend.tf) file has configuration for infrastructure state storage to S3 bucket.

The [terraform.tf](./terraform.tfvars) file can be used to access the variables to edit the configuration and make changes to the infrastructure

The main configuration lies inside the modules folder which has a sub directory VPC that is called by the root main.tf file. The module has a main.tf ,vars.tf and outputs.tf file. 

## How to Run

* Install the necessary modules
```
terraform init
```

* Configure AWS credentials 

* Test run the script (Optional)
```
terraform plan
```
* Run the script 
```
terraform apply
```

### Inputs


| Name  | Description |Type | Default | 
|:-----------|:---------|:-----------|:---------|
|region      |AWS region to configure provider and provision the resources|string                      |```"us-east-1"```| 
|environment|Environment for which the resources are being provisioned|string|```"test"```|
|vpc_cidr|CIDR value for VPC|string|```"10.0.0.0/16"```|
|cost_tags      |Tags for tracking cost |map(string)              |```{ env-type    = "test" customer    = "internal" cost-center = "overhead"}```| 
|vpc_tags      |Tags for new VPC and some related resources|map(string)               |```{ Purpose = "Automation using terraform"}```| 
|az_count      |Number of availability zones where the subnets are to be created **(cannot be greater than 5 or less than 1)**|number                    |```3```| 
|enable_nat_gateway      |Enables NAT gateway in the first az for the VPC |boolean         |```true```| 
|public_subnets_cidr      |List of CIDR blocks to create public subnets|list(string)   |```["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]```| 
|private_subnets_cidr      |List of CIDR blocks to create private subnets|list(string)  |```["10.0.96.0/22", "10.0.100.0/22", "10.0.104.0/22"]```| 
|siem_storage_s3_bucket      |S3 bucket name for storing SIEM events|string      |```"aes-siem-800161367015-log"```|

### Output


The script takes 5 mins to complete a run after which the VPC is configured with other necessary components with below elements as outputs.


| Name  | Type | Description |
|:-----------|:---------|:-----------|
|vpc_id                              |string        | VPC ID for the new vpc created       |
|public_subnets                      |list(string)  | IDs of public subnets        |
|private_subnets                     |list(string)  | IDs of private subnets       |

