# Description

This module contains the setup for FX Admin node resources required for onboarding a new customer. This module is dependent on the [commons](../commons/) folder which has multiple modules that are being called within this script. Below is a list of resources being generated here.

- Kinesis Streams
- Kinesis Firehose
- Kinesis analytics application
- Lambda Functions
- ActiveMQ
- RabbitMQ
- RDS Database
- S3 Buckets for baton and swift messages
- Baton Applications and namespaces configuraitons
- Cloudflare CNAME records for RabbitMQ

# Modules

This folder only contains two modules in itself . Please refer the below list to [know more](../commons/README.md) about modules bring reffered here.

- [Lambda](../commons/aws/lambda/)
- [Lambda IAM](../commons/aws/lambda-iam/)
- [Stream](../commons/aws/stream/)
- [RDS](../commons/aws/rds/)
- [RabbitMQ](../commons/aws/rabbitmq/)
- [S3](../commons/aws/s3/)
- [SQS](../commons/aws/sqs/)
- [ActiveMQ](../commons/aws/activemq/)
- [Baton Application Namespaces](../commons/kubernetes/baton-application-namespace/)

##### [Kinesis App](./modules/kinesis-app/)

The following module deals with creation of Kinesis Analytical Application with is linked with two kinesis streams of matching trades and normalized trades and takes there ARN as input .

#### [Kinesis Firehose](./modules/kinesis-firehose/)

The following mode creates a kinesis firehose stream to write into S3 bucket that is internally creates in this script.

## Common Modules Usage

Below mentioned modules are sourced via [commons](../commons/) folder , below is the description for each module created in this directory.

- _normalized_trml_kinesis_stream_ : For creating kinesis stream for normalized data.
- _matched_trades_kinesis_stream_ : For creating kinesis stream for matched trades data.
- _lambda_iam_ : For IAM roles required for lambda funtions execution .
- _normalized_trml_lambda_ : For creating lambda function for normalizing trade data.
- _matched_trades_lambda_ : For creating lambda function for mathced trades.
- _activemq_ : ActiveMQ Broker for sending messages to customer accounts.
- _rds_cluster_ : RDS Cluster with Aurora MySQL instances
- _s3_ : Creates a S3 bucket for Baton
- _s3_swift_ : Creates a S3 bucket gor SWIFT messages
- _cloudflare_ : Create CNAME records in cloudflare

# Folder Structure

```
.
├── backend.tf
├── main.tf
├── modules
│   └── kinesis-app
├── outputs.tf
├── providers.tf
├── README.md
└── vars.tf
```

The providers.tf file contains the necessary packages that are required to run the script i.e helm and kubernetes provider .

The main.tf file is the file that triggers the modules for creation of resources.

The vars.tf file has the input variables for for customizing the resources.

The outputs.tf file has the variables that are shown at the end of the script in the console from the module as result.

The backend.tf file has configuration for infrastructure state storage to S3 bucket.The key for state storage are named after the folders in resource folders in in the bucket that is AWS and kubernetes.

## How to Run

- Configure AWS credentials

- Install the necessary modules for each of the folders by going into the relevant directories and executing the below command.

```
terraform init
```

- Set the values for input variables from .tfvars . One can edit the existing terraform.tfvars file or create there own .tfvars and reference it through command line during apply and plan. Few input variables need to be provided from AWS module's output if using in conjunction with it.

- Test run the script (Optional)

```
terraform plan
```

- Run the kubernetes folder script

```
terraform apply
```

### Inputs

| Name                                      | Description                                                                                                | Type                               | Default                                                                      |
|:------------------------------------------|:-----------------------------------------------------------------------------------------------------------|:-----------------------------------|:-----------------------------------------------------------------------------|
| region                                    | AWS region to configure provider and provision the resources                                               | string                             | `"us-east-1"`                                                                |
| k8s_cluster_name | EKS cluster name in which the applicaitons should run | string|`"test"`|
| environment                               | Environment for which the resources are being provisioned                                                  | string                             | `"test"`                                                                     |
| cost_tags                                 | Tags associated with specifc customer and environment                                                      | map(string)                        | `{ env-type = "test" customer = "internal" cost-center = "overhead"}`        |
| vendor\*                                  | Name of the vendor hosting applications                                                                    | string                             |                                                                              |
| rds_mysql_version                         | MySQL version for RDS Aurora                                                                               | string                             | `-`                                                                          |
| rds_instance_type                         | RDS Instance Type                                                                                          | string                             | `-`                                                                          |
| rds_master_password                       | Master Password for RDS                                                                                    | string                             | `-`                                                                          |
| rds_master_username                       | Master Username for RDS                                                                                    | string                             | `master`                                                                     |
| rds_reader_needed                         | Enable reader for RDS                                                                                      | bool                               | `false`                                                                      |
| rds_parameter_group_family                | Parameter group Family name                                                                                | string                             | `-`                                                                          |
| rds_enable_performance_insights           | Enable performance insights for RDS                                                                        | bool                               | `-`                                                                          |
| rds_performance_insights_retention_period | Performance Insights retention period                                                                      | number                             | `7`                                                                          |
| rds_enable_event_notifications            | Enable event notifications for RDS                                                                         | bool                               | `true`                                                                       |
| rds_reader_instance_type                  | Reader instance type for RDS                                                                               | string                             | `-`                                                                          |
| rds_ingress_whitelist                     | Ingress whitelist for RDS                                                                                  | list                               | `-`                                                                          |
| rds_enable_deletion_protection            | Enable deletion protection for RDS                                                                         | bool                               | `true`                                                                       |
| rds_enable_auto_minor_version_upgrade     | Enable auto minor version upgrade for RDS                                                                  | bool                               | `false`                                                                      |
| rds_db_cluster_parameter_group_parameters | DB cluster parameter group parameters                                                                      | list                               | `[]`                                                                         |
| rds_preferred_backup_window               | Preferred backup window for RDS                                                                            | string                             | `"07:00-09:00"`                                                              |
| rds_publicly_accessible                   | Make RDS publicly accessible                                                                               | bool                               | `false`                                                                      |
| rds_db_parameter_group_parameters         | DB parameter group parameters                                                                              | list(map)                          | `[{"name": "long_query_time", "value": "10", "apply_method": "immediate"}]`  |
| rds_enabled_cloudwatch_logs_exports       | Enabled CloudWatch Logs Exports for RDS                                                                    | list(string)                       | `["slowquery", "audit", "error"]`                                            |
| rds_ca_cert_identifier                    | CA certificate identifier for RDS                                                                          | string                             | `-`                                                                          |
| rds_backup_retention_period               | Backup retention period for RDS in days                                                                    | number                             | `7`                                                                          |
| activemq_engine_version                   | Version of ActiveMQ engine                                                                                 | String                             | `"5.15.16"`                                                                  |
| activemq_storage_type                     | Preferred storage type for ActiveMQ                                                                        | String                             | `"efs"`                                                                      |
| activemq_instance_type                    | ActiveMQ host's instance type                                                                              | String                             | `"mq.t2.micro"`                                                              |
| activemq_apply_immediately                | Specifies whether any broker modifications are applied immediately, or during the next maintenance window  | bool                               | `true`                                                                       |
| activemq_auto_minor_version_upgrade       | Whether to automatically upgrade to new minor versions of brokers as Amazon MQ makes releases available.   | bool                               | `false`                                                                      |
| activemq_publicly_accessible              | Specify whether the ActiveMQ instance should be publicly accessible                                        | bool                               | `true`                                                                       |
| activemq_username                         | Username to authenticate into the ActiveMQ server                                                          | String                             | `"admin"`                                                                    |
| rabbitmq_engine_version                   | Version of the RabbitMQ broker engine                                                                      | String                             | `3.11.20`                                                                    |
| rabbitmq_enable_cluster_mode              | Enable RabbitMQ Cluster Mode.                                                                              | Bool                               | `false`                                                                      |
| rabbitmq_instance_type                    | Broker's instance type                                                                                     | String                             | `"mq.t3.micro"`                                                                |
| rabbitmq_auto_minor_version_upgrade       | Whether to automatically upgrade to new minor versions of brokers as Amazon MQ makes releases available.   | Bool                               | `false`                                                                      |
| rabbitmq_publicly_accessible              | Whether to enable connections from applications outside of the VPC that hosts the broker's subnets.        | Bool                               | `false`                                                                      |
| rabbitmq_username                         | Username of the user.                                                                                      | String                             | `master`                                                                     |
| rabbitmq_apply_immediately                | Specifies whether any broker modifications are applied immediately, or during the next maintenance window. | Bool                               | `false`                                                                      |
| lambda_packages_s3_bucket                 | S3 bucket name for bucket storing binary files for lambdas                                                 | string                             | `"fx-dev-lambda-packages"`                                                   |
| public_subnets\*                          | List of IDs of public subnets                                                                              | list(string)                       |                                                                              |
| private_subnets\*                         | List of IDs of private subnets                                                                             | list(string)                       |                                                                              |
| domain_name                               | Domain name to use for exposing endpoints                                                                  | string                             | `batonsystems.com`                                                           |
| vpc_id\*                                  | VPC ID to to link to lambdas , activeMQ , RDS                                                              | string                             |                                                                              |
| eks_security_group\*                      | Security group linked to EKS                                                                               | string                             |                                                                              |
|loadbalancer_url\* | Target for configuring DNS records |  string |`""` |
| cnames | Set of CNAME suffixed for subdomain |set(string)  |`[]` | 
| cloudflare_api_token\* | API token for configuring cloudflare provider |  string | |
| kms_key_arn\*                             | KMS key ARN to use for encrypting resources                                                                | string                             |                                                                              |
| additional_secrets | Map of secrets to save to AWS secrets manager | map(any) | `{}` |
| sftp_host\* | Hostname for baton SFTP server | string | |
| sftp_user\* | Username for baton SFTP server| string | 
| sftp_password\* |  Password for baton SFTP server | string |  baton_application_namespaces\*            | List of namespaces and services with requirments                                                           | list(baton_application_namespaces) | [Baton Application Namespace](#markdown-header-baton-application-namespaces) |

### Baton Application Namespaces

The following object deals with the namespaces and other kubernetes resources for a service to run . Below are the parameters for the object.


| Name              | Description                                                                | Type           | Default                                            |
|:------------------|:---------------------------------------------------------------------------|:---------------|:---------------------------------------------------|
| namespace\*       | Namespace value                                                            | string         |                                                    |
| istio_injection | Whether to enable istio injection or not                                   | bool           | `true`         |
| common_env        | Environment properties common between multiple services across a namespace | map(string)    | `{}`                                               |
| customer\*        | Name of the customer                                                                                                                   | string      |          |
| docker_registry\* | Registry to pull the docker images from | string ||
| services\*        | List of services to create in the mentioned namespace                      | list(services) | [Baton Services](#markdown-headers-baton-services) |

### Baton Services

This object taked the paramters needed by a single service to run and are passed to the deployment and service files inside the helm chart. Following are the objects for a single service.

##### Inputs

| Name              | Description                                                                                                                            | Type        | Default  |
|:------------------|:---------------------------------------------------------------------------------------------------------------------------------------|:------------|:---------|
| name\*            | Name of the service                                                                                                                    | string      |          |
| target_port\*     | Port exposed by the service                                                                                                            | number      |          |
| health_endpoint\* | Health check endpoint of the service                                                                                                   | string      |          |
| subdomain_suffix  | Suffix to append to the environment name in sub domain for a service                                                                   | string      | `""`     |
| url_prefix\*      | Prefix for the service URL                                                                                                             | string      |          |
| image_tag         | Version of the image to be used                                                                                                        | string      | `latest` |
| env\*             | Env mapping for deployment object . The key provided is supplied to the `name` parameter and value provided goes to `value` parameter. | map(string) |          |
|volumeMounts | Different volume and mounts configuration to add to the deployment | object(volumeMounts) | [Volume Mounts](#markdown-headers-volume-mounts) | 

**Note: By default `{ "APP_ENVIRONMENT" = customer, "SPRING_PROFILES_ACTIVE" = namespace }` are always appended to `env` attribute.**

### Volume Mounts

Object parameters for adding mounts to  [Baton Services](#markdown-headers-baton-services). The objects `volume` and `mounts` configurations are typical to the kubernetes YAML configurations.
| Name              | Description                                                                                                                            | Type        | Default  |
|:------------------|:---------------------------------------------------------------------------------------------------------------------------------------|:------------|:---------|
| volumes | Volume configuration for deployment files. Can accept any kind of valid volume configuration for different types of volumes but should be with k8's YAML standards | list(any) | `[]` |
|mounts | Mount configuration to the containers for volumes provided| list(mounts) |[Mounts](#markdown-headers-mounts)|

### Mounts

Object parameters for adding mounts to  [Volume Mounts](#markdown-headers-volume-mounts) . This object configuration is typical to the kubernetes YAML configurations.
| Name              | Description                                                                                                                            | Type        | Default  |
|:------------------|:---------------------------------------------------------------------------------------------------------------------------------------|:------------|:---------|
|mountPath\*| Directory on container where to mount the file |string||
|name\*| Name of volume |string||
|subPath\*|  |string||


**Example input for baton application namespace**

```
[
      {
      namespace       = "ns1"
      istio_injection = true
      docker_registry = "123456789.dkr.ecr.us-west-2.amazonaws.com"
      common_env      = { "key7" = "v7", "key8" = "v8" }
      customer        = "cust1"
      services = [
        {
          name            = "app1"
          health_endpoint = "/health"
          target_port     = 8080
          subdomain_suffix= "api"
          url_prefix      = "/app1"
          env             = { "key1" = "v1", "key2" = "v2" }
          image_tag       = "latest"
          volumeMounts    = {
          volumes = [
          {
            name = "secretVol"
            secret = {
              secretName = "secretName"
              readOnly   = true
            }
          }
        ]
            mounts=[
        {
          mountPath = "/home/ubuntu/Desktop"
          name      = "secretVol"
          subPath   = "my-secret"
        }
        ]
          }
        },
        {
          name            = "app3"
          health_endpoint = "/health"
          target_port     = 8080
          url_prefix      = "/app3"
          env             = {}
          image_tag       = "latest"
        }
      ]
    },
    {
      namespace       = "ns2"
      istio_injection = false
      customer        = "cust2"
      services = [
        {
          name            = "app2"
          health_endpoint = "/health"
          target_port     = 8080
          endpoint        = "api"
          url_prefix      = "/app2"
          env             = { "key3" = "v3", "key4" = "v4" }
          image_tag       = "latest"
        }
      ]
    }
]
```
### Output

| Name                 | Type   | Description                              |
| :------------------- | :----- | :--------------------------------------- |
|activemq_url       | string |endpoint of activemq|
|activemq_username  | string |ActiveMQ Username credential|
|activemq_password  | string |ActiveMQ password credential|
|rabbitmq_endpoint  | string |endpoint of rabbitMQ |
|rabbitmq_username  | string |rabbitMQ Username credential|
|rabbitmq_password  | string |rabbitMQ password credential|
|rds_writer_endpoint| string |Writer endpoint of the RDS cluster|
|rds_reader_endpoint| string |Reader endpoint of the RDS cluster|
|rds_master_username| string |RDS master username credential|
|rds_master_password| string |RDS master password credential|