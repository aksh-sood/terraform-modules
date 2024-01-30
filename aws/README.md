# Description
The following folder is a sub part of the entire Terraform IAAC project and deals with only the creation of AWS resources listed below. Of all the resources listed below the EKS and RDS resources can be optionally executed depending upon the users needs .

- VPC
- Private Public Subnets
- NAT Gateway
- Route Tables
- Internet Gateway
- Client VPN Endpoint
- Security Hub Controls and remediations
- KMS Key
- ACM domain certificate
- EKS Cluster
- EKS Managed Node Groups
- IAM roles and policies for EKS Cluster and Nodes
- EFS Drive for persistent volume and security Group For EFS
- RDS Cluster

# Modules

##### [VPC](./aws/modules/vpc)

The VPC module deals with the creation of VPC in the given region with internet and NAT gateway and also the different different public and private subnets with different ACL's as well. The VPC has flow logging enabled and has dedicated public and private network ACL and rules set . It also provisions one NAT gateway by default in the first az.

**Note:** Make sure that S3 bucket policies are configured properly to allow logs from different sources like VPC and ELB depending upon the resources being provisioned.
**Note:** If the `create_eks` variable is set to `true` then minimum AZs requried in that region should be 3 .


##### [Security Hub Module](./aws/modules/domain-certificate/)
The security hub module deals with the enabling of secuirty hub in a region and enabling the standards that are supplied to it. It also disables the rules that are provided to it for each of the standards implmented .  

The following security standards are implemented by default and can be overridden using `security_hub_standards` variable.
- aws-foundational-security-best-practices/v/1.0.0
- cis-aws-foundations-benchmark/v/1.4.0
- pci-dss/v/3.2.1
- nist-800-53/v/5.0.0

**NOTE:**
- **If the security hub is already subscribe for a region then set the `subscribe_security_hub` as `false` or import the resource using following command to prevent any errors `terraform import module.security-hub.aws_securityhub_account.default <account_id>` as terraform does not support any data sources for security hub**
- **The rules that are disabled once , removing them from the list does not enable that rule back**
- **This module does not deal with the remediation of the security hub controls. the remediations are caaried in each module depending upon the resource it is provision**

##### [Domain Certificate Module](./aws/modules/domain-certificate/)

The certificate module creates a domain certificate in the AWS Certificate Manager by importing the certificate data from S3 bucket (**Note:** For the certificate data to be read the file transfer type for objects required is in any text format which is set by the script). There are no inputs for this module.

##### [KMS](./aws/modules/kms/)

The KMS module creates a KMS key are that is used for default EBS encryption and node EBS volume encryption with alias as ```generic-cmk``` .

##### [EKS](./aws/modules/eks/)

The EKS module provisions the EKS cluster and installs the required addons in it. The cluster is provisioned in the VPC created by the VPC module and in all its subnets by default . The EKS module has two sub modules :

1. [cluster](./aws/modules/eks/modules/cluster/)
Responsible for creating the EKS cluster with specified requirements.
The cluster config file is also pulled after creation of the eks cluster to `~/.kube/{environment}`

2. [nodes](./aws/modules/eks/modules/nodes/)
Creates the EKS managed node groups provided by the user

3. [addons](./aws/modules/eks/modules/addons)
Responsible for installation of addons in cluster which are listed below.
    - aws-ebs-csi-driver
    - vpc-cni
    - coredns
    - aws-efs-csi-driver
    - kube-proxy
    - lbc-controller

4. [IAM](./aws/modules/eks/modules/iam)
The IAM module is used to create the user managed policies and map them to cluster role and node role after creating it. The IAM folder also has one more sub directory called [policies](./aws/modules/eks/modules/iam/policies/) which has all the policies in json format for their creation. The smae module also creates a role and attach policy to it for grafana assumed role within the eks cluster.

5. [EFS](./aws/modules/eks/modules/efs)
The EFS module creates a EFS drive for persistent volume to be used in the EKS cluster with the required security group . The security group whitelists the incoming traffic from EKS primary security group in which the EKS nodes also resides for nodes to access the drive.

##### [RDS](./aws/modules/rds/)
RDS Module creates a Aurora Mysql RDS Cluster within the VPC private subnets.

# Folder Structure
Below is the structure of AWS Folder.

```
.
├── backend.tf
├── locals.tf
├── main.tf
├── modules
│   ├── security-hub
│   ├── domain-certificate
│   ├── eks
│   │   ├── modules
│   │   │   ├── addons
│   │   │   ├── cluster
│   │   │   ├── efs
│   │   │   ├── iam
│   │   │   │   ├── policies
│   │   │   └── nodes
│   ├── kms
│   └── vpc
├── outputs.tf
├── providers.tf
├── terraform.tfvars
└── vars.tf
```

The providers.tf file contains all the necessary packages that are required to run the script i.e aws provider 

The main.tf file is the file that triggers the modules for creation of resources.

The vars.tf file has the input variables for for customizing the resources.

The outputs.tf file has the variables that are shown at the end of the script in the console from the module as result.

The backend.tf file has configuration for infrastructure state storage to S3 bucket.The key for state storage are named after teh folders in resource folders in in the bucket that is AWS and kubernetes.

The terraform.tf file can be used to access the variables to edit the configuration and make changes to the infrastructure

The main configuration lies inside the modules folder which has a multiple sub directories that are called by the main.tf file. The module has a main.tf ,vars.tf and outputs.tf file. 

## How to Run

* Configure AWS credentials 

* Install the necessary modules for each of the folders by going into the relevant directories and applying the below command.
```
terraform init
```

* Set the values for input variables from .tfvars . One can edit the existing terraform.tfvars file or create there own .tfvars and reference it through command line during apply and plan.

* Test run the script (Optional)
```
terraform plan
```
* Run the aws folder script 
```
terraform apply
```


### Inputs

| Name  | Description |Type | Default | 
|:-----------|:---------|:-----------|:---------|
|region      |AWS region to configure provider and provision the resources|string|`"us-east-1"`| 
|environment|Environment for which the resources are being provisioned|string|`"test"`|
|vpc_cidr|CIDR value for VPC|string|`"10.0.0.0/16"`|
|cost_tags      |Tags associated with specifc cusotmer and environment|map(string)|`{ env-type = "test" customer = "internal" cost-center = "overhead"}`| 
|vpc_tags      |Tags for new VPC and some related resources|map(string)|`{}`| 
|az_count      |Number of availability zones where the subnets are to be created **(cannot be greater than 5 or less than 1)**|number |`3`| 
|enable_nat_gateway      |Enables NAT gateway in the first az for the VPC |boolean         |`true`| 
|public_subnet_cidrs      |List of CIDR blocks to create public subnets|list(string)   |`["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]`| 
|private_subnet_cidrs     |List of CIDR blocks to create private subnets|list(string)  |`["10.0.96.0/22", "10.0.100.0/22", "10.0.104.0/22"]`| 
|subscribe_security_hub|Optional subscription to secuirty hub | bool | `false` |
|siem_storage_s3_bucket      |S3 bucket name for alerts and logging |string     |`"aes-siem-800161367015-log"`|
|additional_cluster_policies |additional cluster policies for EKS cluster |map(string)|`{}`|
|cluster_version |EKS cluster version |string| `"1.28"`|
|additional_eks_addons |Additional addons for EKS cluster |list(string)| `[]`|
|eks_node_groups |EKS node configuration to provision in cluster|map(eks-node-group-config)|[EKS Node Group Config](#markdown-header-eks-node-group-config)|
|acm_certificate_bucket |S3 bucket name where domain certificate data is stored|string|`"baton-domain-certificates"`|
|acm_private_key| S3 object key for domain certificate private key |string |`"batonsystem.com/cloudflare/batonsystem.com.key"`|
|acm_certificate | S3 object key for domain certificate body|string |`"batonsystem.com/cloudflare/batonsystem.com.crt"`|
|acm_certificate_chain |S3 object for domain certificate key chain|string|`"batonsystem.com/cloudflare/origin_ca_rsa_root.pem"`|
|security_hub_standards | Security hub standards to to enabled |list(string)| ```["aws-foundational-security-best-practices/v/1.0.0","cis-aws-foundations-benchmark/v/1.4.0","pci-dss/v/3.2.1","nist-800-53/v/5.0.0"]```|
|disabled_security_hub_controls| Security hub controls to be disabled for each of the implemented standards | map(maps(string))|[Disabled Security Hub Controls](#markdown-header-disabled-security-hub-controls)|
|create_rds|Determines whether to create an RDS instance|bool|`true`|
|rds_mysql_version|MySQL version for RDS Aurora|string|`-`|
|rds_instance_type|RDS Instance Type|string|`-`|
|rds_master_password|Master Password for RDS|string|`-`|
|rds_master_username|Master Username for RDS|string|`master`|
|rds_reader_needed|Enable reader for RDS|bool|`false`|
|rds_parameter_group_family|Parameter group Family name|string|`-`|
|rds_enable_performance_insights|Enable performance insights for RDS|bool|`-`|
|rds_performance_insights_retention_period|Performance Insights retention period|number|`7`|
|rds_enable_event_notifications|Enable event notifications for RDS|bool|`true`|
|rds_reader_instance_type|Reader instance type for RDS|`-`|`-`|
|rds_ingress_whitelist|Ingress whitelist for RDS|list|`-`|
|rds_enable_deletion_protection|Enable deletion protection for RDS|bool|`true`|
|rds_enable_auto_minor_version_upgrade|Enable auto minor version upgrade for RDS|bool|`false`|
|rds_db_cluster_parameter_group_parameters|DB cluster parameter group parameters|list|`[]`|
|rds_preferred_backup_window|Preferred backup window for RDS|string|`"07:00-09:00"`|
|rds_publicly_accessible|Make RDS publicly accessible|bool|`false`|
|rds_db_parameter_group_parameters|DB parameter group parameters|list(map)|`[{"name": "long_query_time", "value": "10", "apply_method": "immediate"}]`|
|rds_enabled_cloudwatch_logs_exports|Enabled CloudWatch Logs Exports for RDS|list(string)|`["slowquery", "audit", "error"]`|
|rds_ca_cert_identifier|CA certificate identifier for RDS|string|`-`|
|rds_backup_retention_period|Backup retention period for RDS in days|number|`7`|

#### EKS Node Group Config

The following object defines the entire required configuraiton for the eks managed node_groups as well as the global settings. With the following parameters .

| Name  | Description |Type | Default | 
|:-----------|:---------|:-----------|:---------|
|additional_node_inline_policies| inline policy to attach to nodes| string | `null`|
|additional_node_policies|additional aws managed node policies for EKS nodes |map(string)|`null`|
|volume_type(required)| type of EBS volume for each node | string |`"gp3"`|
|volume_size(required)| size of EBS volmue for each node | number |`20`|
|node_groups **(required)**| configuration for multiple node groups| list(node_groups) | [Node Groups](#markdown-header-node-groups)|

#### Node Groups

The following object defines the differnet node group settings with parameters mentioned below.

| Name  | Description |Type | Default | 
|:-----------|:---------|:-----------|:---------|
| name(required) | name of the node group | string | `"node1"`|
| min_size(required) | minimum and desired number of nodes in node group | number | `1`|
| max_size(required) | maximum number of nodes in node group | number | `1`|
| additional_security_groups | additional custom security groups for EKS nodes |list(string) |`[]`|
| instance_types(required) | List of types of EC2 instances to create nodes| list(string) | `["m5.large"]`|
| tags| Tags to associate with nodes| map(string)| `{}`|

**Example of Node Config and Node Groups**

This is also the default value for the `eks_node_groups` variable.
```

eks_node_groups = {

  additional_node_inline_policies = null
  additional_node_policies        = null
  volume_type                     = "gp3"
  volume_size                     = 20

  node_groups = [{
    name = "node1"

    instance_types = ["m5.large"]

    min_size = 1
    max_size = 1

    additional_security_groups = []

    tags = {}
    }
  ]
}
```

#### Disabled Security Hub Controls

The following map lists the security controls that are disabled for each of the standards implemented in this reposistory with there reason.

```{
    "aws-foundational-security-best-practices/v/1.0.0" = {
      "AutoScaling.6"    = "Not applicable to us because of our deployment model"
      "CloudFormation.1" = "Not applicable to our use case"
      "CloudTrail.5"     = "Using SIEM instead"
      "EC2.9"            = "Only the bare necessary machines are exposed"
      "EC2.10"           = "Using SIEM instead"
      "EC2.17"           = "EKS nodes and VPN instances need multiple ENIs"
      "EC2.18"           = "Need 443 and 80 for exposing the application"
      "ECR.3"            = "Need to retain the images"
      "IAM.2"            = "Only one Deployment user"
      "IAM.6"            = "Do not use sub account root account. Main root account has MFA enabled"
      "RDS.6"            = "Not Required"
      "RDS.13"           = "We need to keep updates manual, automatic updates may break something"
      "S3.11"            = "Already covered in the cloudtrail logs"
      "SNS.2"            = "Not required"
      "SSM.1"            = "We do not plan on using System Manager"
      "SSM.3"            = "We do not plan on using System Manager"
      "SecretsManager.1" = "In Baton, we use SecretsManager to store application secrets which includes credentials of external portals, items deployed in K8s clusters etc along with the credentials of the AWS resource. Hence, it's not possible to automatically to rotate the secrets stored in SecretsManager within the scope of AWS"
      "SecretsManager.4" = "In Baton, we use SecretsManager to store application secrets which includes credentials of external portals, items deployed in K8s clusters etc along with the credentials of the AWS resource. Hence, it's not possible to automatically to rotate the secrets stored in SecretsManager within the scope of AWS"
    }
    "cis-aws-foundations-benchmark/v/1.4.0" = {
      "3.3" = "We are already doing that." 
      "1.5" = "Baton does not use root on linked accounts"
      "1.6" = "Baton does not use root on linked accounts"
      "3.4" = "Using SIEM instead"
      "3.6" = "Not Required"
      "3.7" = "Not Required"
      "5.3" = "Need 443 and 80 for exposing the application"
    }
    "pci-dss/v/3.2.1" = {
      "PCI.IAM.2"        = "Only one Deployment user"
      "PCI.IAM.4"        = "Baton does use root on linked accounts"
      "PCI.IAM.5"        = "Baton does not use root on linked accounts"
      "PCI.IAM.6"        = "The deployment user doesn't have console login enabled"
      "PCI.SSM.1"        = "We don't plan on using System Manager"
      "PCI.SSM.3"        = "We don't plan on using System Manager"
      "PCI.CloudTrail.1" = "Not Required"
      "PCI.CloudTrail.4" = "Using SIEM instead"
    }
    "nist-800-53/v/5.0.0" = {
      "IAM.9"            = "Using SIEM Instead"
      "AutoScaling.6"    = "Not applicable to us because of our deployment model"
      "CloudFormation.1" = "Not applicable to our use case"
      "CloudTrail.5"     = "Using SIEM Instead"
      "EC2.9"            = "Only the bare necessary machines are exposed"
      "EC2.10"           = "Using SIEM instead"
      "EC2.17"           = "EKS nodes and VPN instances need multiple ENIs"
      "EC2.18"           = "Need 443 and 80 for exposing the application"
      "ECR.3"            = "Need to retain the images"
      "IAM.2"            = "Only one Deployment user"
      "IAM.5"            = "The deployment user doesn't have console login enabled"
      "IAM.6"            = "Do not use sub account root account. Main root account has MFA enabled"
      "IAM.9"            = "Baton does not use root on linked accounts"
      "IAM.19"           = "The deployment user doesn't have console login enabled"
      "RDS.6"            = "Not Required"
      "RDS.13"           = "We need to keep updates manual, automatic updates may break something"
      "S3.11"            = "Already covered in the cloudtrail logs"
      "SNS.2"            = "Not required"
      "SSM.1"            = "We do not plan on using System Manager"
      "SSM.3"            = "We do not plan on using System Manager"
      "SecretsManager.1" = "In Baton, we use SecretsManager to store application secrets which includes credentials of external portals, items deployed in K8s clusters etc along with the credentials of the AWS resource. Hence, it's not possible to automatically to rotate the secrets stored in SecretsManager within the scope of AWS"
      "SecretsManager.4" = "In Baton, we use SecretsManager to store application secrets which includes credentials of external portals, items deployed in K8s clusters etc along with the credentials of the AWS resource. Hence, it's not possible to automatically to rotate the secrets stored in SecretsManager within the scope of AWS"
    }
  }
```

### Output

The script takes 40-50 mins to complete a run after which the VPC, EKS ,RDS, ACM and KMS key are configured with other necessary components with below elements as outputs.

| Name  | Type | Description |
|:-----------|:---------|:-----------|
|vpc_id                   |string        | VPC id for the new VPC created                       |
|public_subnets           |list(string)  | List of IDs of public subnets                        |
|private_subnets          |list(string)  | List of IDs of private subnets                       |
|efs_id                   |string        | EFS Volume ID for persistent storage                 |
|acm_certificate_arn      |string        | ARN of domain certificate for istio ingress          |
|grafana_role_arn         |string        | ARN of the Grafana role                              |
|rds_writer_endpoint      |string        |Writer endpoint of the RDS cluster                    |
|rds_reader_endpoint      |string        |Reader endpoint of the RDS cluster                    |
|rds_cloudwatch_log_groups|string        |CloudWatch log groups associated with the RDS cluster |
|rds_master_username      |string        |MYSQL Username for the master user                    |
|rds_master_password      |string        |MYSQL Password for the master user                    |