# Description
This Repository contains the code to automate the creation of different AWS and Kubernetes resources using terraform as its base . The repository is divided into two different folders AWS and Kubernetes , each containing the relevant resources from its kind.

This is done for easier management of code and resources and also encounter issues with kubernetes provider configuration and prevent the time loss during terraform state refresh. 

Below is a list of resources created :-

  - AWS
    - VPC
    - Private and Public Subnets
    - NAT Gateway
    - Route Tables
    - Internet Gateway
    - Security Hub Controls and remediations
    - Client VPN Endpoint
    - KMS Key
    - ACM domain certificate
    - EKS Cluster
    - EKS Managed Node Groups
    - IAM roles and policies for EKS Cluster and Nodes
    - EFS Drive for persistent volume and security Group For EFS
  
  - Kubernetes
    - EFS and EBS Addons 
    - Istio installation in EKS cluster
    - Istio ingress of type ALB
    - Kube Prometheus Stack installation 
    - Prometheus Alerts
    - Grafana Dashboards and Users

Documentation to the relevant resources can be found in [AWS](./aws/README.md) and [Kubernetes](./kubernetes/README.md)

# WHY TWO FOLDERS

Following single folder structure ,the Kubernetes provider configuration is not compatible as is giving many issues in execution of the script as it is not supporting runtime configuration changes resulting in failure of connection to the EKS cluster or failure in creation of Kubernetes resources .

Also the corresponding structure and resources would be to big , even if the change happens in a single resource ,terraform refreshes the entire state file to detect the changes which  would cause significant delay in the apply and plan operations .

Terraform community also suggests to keep these folders separate for better management and because of their limitations.

# Prerequisites

The following technologies are used in local system while creating this script

| Resource  | Version |
|:----------|:--------|
| Terraform | 1.4.6   |
| AWS CLI	  | 2.11.15 |
| Helm	    | 3.12.1  |

Provider versions used while creation of script

| Resource   | Version |
|:-----------|:--------|
| AWS        | 5.20.1  |
| Helm       | 2.10.1  | 
| Kubernetes | 2.10.0  |
| Grafana    | 2.3.3   |

Module versions

| Resource   | Version |
|:-----------|:--------|
| EKS        | 19.20.0 |
| EFS        | 1.3.1   | 
| KMS        | 2.1.0   |
| VPC        | 5.2.0   |

Before running the script ensure that you have the AWS credentials configured in your system.