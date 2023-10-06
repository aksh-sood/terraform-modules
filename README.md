# Description
This Repository contains the code to automate the creation of different AWS resources listed below :-

  - VPC
  - Subnets
  - NAT Gateway
  - KMS Key
  - ACM domain certificate
  - EKS Cluster
  - EKS Managed Node Groups
  - IAM roles and policies for EKS
  - Istio installation in EKS cluster

All the resources related to EKS are optionally executable as per the user requirement.

# Prerequisites

The following technologies are used in local system while creating this script

| Resource  | Version |
|:----------|:--------|
| Terraform | 1.4.6   |
| AWS CLI	  | 2.11.15 |
| Helm	    | 3.12.1  |

Provider verisons used while creation of script

| Resource   | Version |
|:-----------|:--------|
| AWS        | 19.15.3 |
| Helm       | 2.10.1  | 
| Kubernetes | 2.10.0  |

Before running the script ensure that you have the AWS credentials configured in your system.


# Modules

#### [VPC](./modules/vpc)

The VPC module deals with the creation of VPC in the given region with internet and NAT gateway and also the different different public and private subnets with different ACL's as well. The VPC has flow logging enabled and has dedicated public and private network ACL and rules set . It also provisions one NAT gateway by default in the first az.


#### [Certificate Module](./modules/certificate/)

The certificate module creates a domain certificate in the AWS Certificate Manager by importing the certificate data from S3 bucket (Note : For the certificate data to be read the file transfer type for objects required is in any text format which is set by the script). There are no inputs for this module.

#### [KMS](./modules/kms/)

The KMS module creates a KMS key are that is used for default EBS encryption and node EBS volume encryption with alias as ```generic-cmk``` .

#### [EKS](./modules/eks/)

The EKS module provisions the EKS cluster and installs the required addons in it. The cluster is provisioned in the VPC created by the VPC module and in all its subnets by default . The EKS module has two sub modules :

1. [cluster](./modules/eks/modules/cluster/)
Responsible for creating the EKS cluster with specified requirements.
The cluster config file is also pulled after creation of the eks cluster to `~/.kube/{environment}`

2. [nodes](./modules/eks/modules/nodes/)
Creates the EKS managed node groups provided by the user

3. [addons](./modules/eks/modules/addons)
Responsible for installation of addons in cluster which are listed below.
    - aws-ebs-csi-driver
    - vpc-cni
    - coredns
    - aws-efs-csi-driver
    - kube-proxy
    - lbc-controller

4. [IAM](./modules/eks/modules/iam)
The iam module is used to create the user managed policies and map them to cluster role after creating it. The iam folder also has one more sub directory called [policies](./modules/eks/modules/iam/policies/) which has all the policies in json format for their creation.

5. [istio](./modules/eks/modules/istio)
The isito module installs the isito service mesh onto the EKS cluster in `istio-system` namespace and create an ingress of type application load balancer exposing the cluster to the outside world.

# Folder Structure

```
.
├── backend.tf
├── main.tf
├── modules
│   ├── certificate
│   ├── eks
│   │   ├── modules
│   │   │   ├── addons
│   │   │   ├── cluster
│   │   │   ├── iam
│   │   │   │   ├── policies
│   │   │   ├── istio
│   │   │   └── nodes
│   ├── kms
│   └── vpc
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

The main configuration lies inside the modules folder which has a multiple sub directories that are called by the root main.tf file. The module has a main.tf ,vars.tf and outputs.tf file. 

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
|region      |AWS region to configure provider and provision the resources|string|`"us-east-1"`| 
|environment|Environment for which the resources are being provisioned|string|`"test"`|
|vpc_cidr|CIDR value for VPC|string|`"10.0.0.0/16"`|
|cost_tags      |Tags associated with specifc cusotmer and environment|map(string)|`{ env-type = "test" customer = "internal" cost-center = "overhead"}`| 
|vpc_tags      |Tags for new VPC and some related resources|map(string)|`{}`| 
|az_count      |Number of availability zones where the subnets are to be created **(cannot be greater than 5 or less than 1)**|number |`3`| 
|enable_nat_gateway      |Enables NAT gateway in the first az for the VPC |boolean         |`true`| 
|public_subnet_cidrs      |List of CIDR blocks to create public subnets|list(string)   |`["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]`| 
|private_subnet_cidrs     |List of CIDR blocks to create private subnets|list(string)  |`["10.0.96.0/22", "10.0.100.0/22", "10.0.104.0/22"]`| 
|siem_storage_s3_bucket      |S3 bucket name for alerts and logging |string     |`"aes-siem-800161367015-log"`|
|additional_cluster_policies |additional cluster policies for EKS cluster |map(string)|`{}`|
|cluster_version |EKS cluster version |string| `"1.27"`|
|eks_node_groups |EKS node configuration to provision in cluster|map(any)|[EKS Node Group Config](#markdown-header-eks-node-group-config)|
|acm_certificate_bucket |S3 bucket name where domain certificate data is stored|string|`"baton-domain-certificates"`|
|public_key| S3 object key for domain certificate public key |string |`"batonsystems.com/cloudflare/batonsystems.com.key"`|
|cert_key | S3 object key for domain certificate certificate|string |`"batonsystems.com/cloudflare/batonsystems.com.crt"`|
|pem_key  |S3 object for domain certificate private key|string|`"batonsystems.com/cloudflare/origin_ca_rsa_root.pem"`|
|istio_version| isito version to be installed| string| `"1.18.0"`|

#### EKS Node Group Config

The following object defines the entire required configuraiton for the eks managed node_groups as well as the global settings. With the following parameters .

| Name  | Description |Type | Default | 
|:-----------|:---------|:-----------|:---------|
|additional_node_inline_policies| inline policy to attach to nodes| string | `null`|
|additional_node_policies|additional aws managed node policies for EKS nodes |map(string)|`null`|
|volume_type(required)| type of EBS volume for each node | string |`"gp3"`|
|volume_size(required)| size of EBS volmue for each node | number |`20`|
|node_groups(required)| configuration for multiple node groups| list(node_groups) | [Node Groups](#markdown-header-node-groups)|

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

#### Example of Node Config and Node Groups

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
### Output

The script takes 40-50 mins to complete a run after which the VPC, EKS and KMS key are configured with other necessary components with below elements as outputs.

| Name  | Type | Description |
|:-----------|:---------|:-----------|
|vpc_id          |string        | VPC id for the new VPC created |
|public_subnets  |list(string)  | List of IDs of public subnets  |
|private_subnets |list(string)  | List of IDs of private subnets |