# Description
This repository contains the code to automate the creation of different AWS and Kubernetes resources using Terraform as its base. The repository is divided into different folders, each containing the relevant resources from its kind.

This is done for easier management of code and resources and also encounter issues with kubernetes provider configuration and prevent the time loss during Terraform state refresh. 

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
    - Opensearch Domain
  
  - Kubernetes
    - LBC Addons 
    - Istio installation in EKS cluster
    - Istio ingress of type ALB
    - Kube Prometheus Stack installation 
    - Prometheus Alerts
    - Grafana Dashboards and Users
    - Filebeat
    - Config server
    - SFTP server
  
  - FX Admin
    - Kinesis Streams
    - Kinesis Firehose
    - Kinesis analytics application
    - Lambda Functions
    - ActiveMQ
    - RDS Database
    - S3 Buckets for baton and swift messages

  - Commons
    - AWS
      - Kinesis Streams
      - S3 Bucket
      - IAM role for Lambda functions
      - Lambda Functions
      - RDS Cluster
      - ActiveMQ
      - SQS
    - Kubernetes
      - Baton Application Namepspaces
    - Utilities
      - Cloudflare

Documentation to the relevant resources can be found in [AWS](./aws/README.md), [Kubernetes](./kubernetes/README.md), [Commons](./commons/README.md) and [FX ADMIN](./fx-admin/README.md)

# WHY MULTIPLE FOLDERS

Following the single folder structure, the Kubernetes provider configuration is not compatible. It is causing many issues in the execution of the script as it does not support runtime configuration changes, resulting in a failure to connect to the EKS cluster or in the creation of Kubernetes resources.

Additionally, the corresponding structure and resources would be too large. Even if a change occurs in a single resource, Terraform refreshes the entire state file to detect the changes, causing a significant delay in the apply and plan operations.

The Terraform community also suggests keeping these folders separate for better management and due to their limitations.

The [commons](./commons/) folder is used a utility across multiple folders with common resources being created across multiple folders adn acts as a universal module for other folders.

The [FX Admin](./fx-admin/) folder deals with the creation of resources strictly for the admin account which distributes the messages to other customer accounts .

# Prerequisites

The following technologies are used in local system while creating this script

| Resource  | Version |
|:----------|:--------|
| Terraform | 1.4.6   |
| AWS CLI	  | 2.11.15 |
| Helm	    | 3.12.1  |

Before running the script ensure that you have the AWS credentials configured in your system.