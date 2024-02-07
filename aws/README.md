# Description
The following folder is a sub part of the IAAC project and deals with only the creation of AWS resources listed below. Of all the resources listed below the EKS resources can be optionally executed depending upon the users needs .

- VPC
- Private Public Subnets
- NAT Gateway
- Route Tables
- Internet Gateway
- Client VPN Endpoint
- KMS Key
- EKS Cluster (optional)
- EKS Managed Node Groups (optional)
- IAM roles and policies for EKS Cluster and Nodes (optional)
- EFS Drive for persistent volume and security Group For EFS (optional)

# Modules

##### [VPC](./aws/modules/vpc)

The VPC module deals with the creation of VPC in the given region with internet and NAT gateway and also the different different public and private subnets with different ACL's as well. The VPC has flow logging enabled and has dedicated public and private network ACL and rules set . It also provisions one NAT gateway by default in the first AZ.

##### [KMS](./aws/modules/kms/)

The KMS module creates a KMS key are that is used for default EBS encryption and node EBS volume encryption with alias as ```generic-cmk-(environment)``` .

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
    - kube-proxy

4. [IAM](./aws/modules/eks/modules/iam)
The IAM module is used to create the user managed policies and map them to cluster role and node role after creating it. The IAM folder also has one more sub directory called [policies](./aws/modules/eks/modules/iam/policies/) which has all the policies in json format for their creation. The smae module also creates a role and attach policy to it for grafana assumed role within the eks cluster.

5. [EFS](./aws/modules/eks/modules/efs)
The EFS module creates a EFS drive for persistent volume to be used in the EKS cluster with the required security group . The security group whitelists the incoming traffic from EKS primary security group in which the EKS nodes also resides for nodes to access the drive.

# Folder Structure
Below is the structure of AWS Folder.

```
.
├── backend.tf
├── locals.tf
├── main.tf
├── modules
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
|additional_cluster_policies |additional cluster policies for EKS cluster |map(string)|`{}`|
|cluster_version |EKS cluster version |string| `"1.28"`|
|eks_node_groups |EKS node configuration to provision in cluster|map(eks-node-group-config)|[EKS Node Group Config](#markdown-header-eks-node-group-config)|

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

The following object defines the different node group settings with parameters mentioned below.

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

### Output

The script takes 40-50 mins to complete a run after which the VPC, EKS and KMS key are configured with other necessary components with below elements as outputs.

| Name  | Type | Description |
|:-----------|:---------|:-----------|
|vpc_id              |string        | VPC id for the new VPC created              |
|public_subnets      |list(string)  | List of IDs of public subnets               |
|private_subnets     |list(string)  | List of IDs of private subnets              |
|efs_id              |string        | EFS Volume ID for persistent storage        |
|grafana_role_arn    |string        | ARN of the Grafana role                     |