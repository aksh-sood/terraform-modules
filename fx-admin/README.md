# Description

This module contains the setup for FX Admin node resources required for onboarding a new customer. This module is dependent on the [commons](../commons/) folder which has multiple modules that are being called within this script. Below is a list of resources being generated here.

- Kinesis Streams
- Kinesis Firehose
- Kinesis Analytics Application
- Lambda Functions
- ActiveMQ
- RabbitMQ
- RDS Database
- S3 Buckets for baton and swift messages
- Baton Applications and namespaces configuraitons
- Cloudflare CNAME records for RabbitMQ
- AWS Secrets to store different credentails
- Kubernetes objects to expose RabbitMQ to internet
- Kubernetes Job to automate RabbitMQ Configuration 
- Kubernetes Job to import directory service database

# Modules

This folder only contains three modules in itself . Please refer the below list to [know more](../commons/README.md) about modules bring reffered here.

- [Lambda](../commons/aws/lambda/)
- [Lambda IAM](../commons/aws/lambda-iam/)
- [Stream](../commons/aws/stream/)
- [RDS](../commons/aws/rds/)
- [S3](../commons/aws/s3/)
- [SQS](../commons/aws/sqs/)
- [Secrets](../commons/aws/secrets/)
- [RabbitMQ (AWS)](../commons/aws/rabbitmq/)
- [ActiveMQ (AWS)](../commons/aws/activemq/)
- [Cloudflare](../commons/utilities/cloudflare/)
- [RabbitMQ (Kubernetes)](../commons/kubernetes/rabbitmq/)
- [ActiveMQ (Kubernets)](../commons/kubernetes/activemq/)
- [Baton Application Namespace](../commons/kubernetes/baton-application-namespace/)

##### [Kinesis App](./modules/kinesis-app/)

The following module deals with creation of Kinesis Analytical Application with is linked with two kinesis streams of matching trades and normalized trades and takes there ARN as input .

#### [Kinesis Firehose](./modules/kinesis-firehose/)

The following mode creates a kinesis firehose stream to write into S3 bucket that is internally creates in this script.

#### [Data Import Job](./modules/data-import-job/)

This module creates job that imports data into RDS which is required for initializing **directory-service** for FX Admin account. The SQL dump file  is mounted to EKS cluster for importing the data. Note : `directory_service_data_s3_bucket_name`,`directory_service_data_s3_bucket_path` are required attributes if data is being imported.

#### [RabbitMQ Config](./modules/rabbitmq-config/)
This module creates a Kubernetes job which configures RabbitMQ. A **vhost** and **exchange** is creates by this module which are required for data pipeline to work properly.

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
- _rabbitmq_ : Creates RabbitMQ broker in private subnets
- _secrets_ : Creates AWS secrets to store important credentials
- _baton_namespace_ : Creates different deployments and other necessary kuberntes objects 

# Folder Structure

```
.
├── backend.tf
├── main.tf
├── modules
│   ├── utilities
│   ├── kinesis-firehose
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
|dr_region | AWS region for DR setup | string| `us-west-2` |
|setup_dr| Whether to setup DR replcation for not(works only if run on the primary infra side) | bool| `false`|  
|is_dr| Whether the currently being infrastrcture is for DR purpose or not | bool | `false` |
| dr_kms_key_arn | KMS key ARN for the FX ADMIN resources in the DR region(required if `setup_dr` is true)(Has the following alias `resource-{environment}-{region}`)| string | `null` |
| create_rds | Wheather to create RDS cluster or not (conflicts with `is_dr`)| bool | `true`|
| k8s_cluster_name | EKS cluster name in which the applicaitons should run | string|`"test"`|
| environment                               | Environment for which the resources are being provisioned                                                  | string                             | `"test"`                                                                     |
| cost_tags                                 | Tags associated with specifc customer and environment                                                      | map(string)                        | `{ env-type = "test" customer = "internal" cost-center = "overhead"}`        |
| dr_tags                                 | Tags associated for RDS CRR resources   | map(string)                        | `{}`        |
| vendor\*                                  | Name of the vendor hosting applications                                                                    | string                             |                                                                              |
| directory_service_data_s3_bucket_name| Name of the S3 bucket to mount to EKS| string | `null`|
| directory_service_data_s3_bucket_path| File path for the sql dump file to import |string|`null`|
| directory_service_data_s3_bucket_region|region of the S3 bucket|string|`"us-east-1"`|
| activemq_ingress_whitelist_ips | CIDR to whitelist to activeMQ security group on ingress | list(string) | `[]` |
| activemq_egress_whitelist_ips | CIDR to whitelist to activeMQ security group on egress | list(string) | `[]` |
| activemq_engine_version                   | Version of ActiveMQ engine                                                                                 | String                             | `"5.17.6"`                                                                  |
| activemq_storage_type                     | Preferred storage type for ActiveMQ                                                                        | String                             | `"efs"`                                                                      |
| activemq_instance_type                    | ActiveMQ host's instance type                                                                              | String                             | `"mq.t2.micro"`                                                              |
| activemq_apply_immediately                | Specifies whether any broker modifications are applied immediately, or during the next maintenance window  | bool                               | `true`                                                                       |
| activemq_auto_minor_version_upgrade       | Whether to automatically upgrade to new minor versions of brokers as Amazon MQ makes releases available.   | bool                               | `false`                                                                      |
| activemq_publicly_accessible              | Specify whether the ActiveMQ instance should be publicly accessible                                        | bool                               | `true`                                                                       |
| activemq_username                         | Username to authenticate into the ActiveMQ server                                                          | String                             | `"admin"`                                                                    |
| tgw_ram_principals                         | List of accounts to which tgw needs to be shared                                                      | list(string)                             | `[]`                                                                    |
| rabbitmq_engine_version                   | Version of the RabbitMQ broker engine                                                                      | String                             | `3.11.20`                                                                    |
| rabbitmq_enable_cluster_mode              | Enable RabbitMQ Cluster Mode.                                                                              | Bool                               | `false`                                                                      |
| rabbitmq_instance_type                    | Broker's instance type                                                                                     | String                             | `"mq.t3.micro"`                                                                |
| rabbitmq_auto_minor_version_upgrade       | Whether to automatically upgrade to new minor versions of brokers as Amazon MQ makes releases available.   | Bool                               | `false`                                                                      |
| rabbitmq_username                         | Username of the user.                                                                                      | String                             | `master`                                                                     |
| rabbitmq_apply_immediately                | Specifies whether any broker modifications are applied immediately, or during the next maintenance window. | bool | `false` |
|rabbitmq_virtual_host|Virtual host to create in rabbitmq|string|`/nex_osttra`|
|rabbitmq_exchange|Exchange to create in rabbitmq |string|`trml_osttra`|
| env_secrets                      | AWS secret name containing the secrets to be appended                                                                        | string                             |`""`|   
| lambda_packages_s3_bucket                 | S3 bucket name for bucket storing binary files for lambdas                                                 | string                             | `"fx-dev-lambda-packages"`                                                   |
| public_subnets\*                          | List of IDs of public subnets                                                                              | list(string)                       |                                                                              |
| private_subnets\*                         | List of IDs of private subnets                                                                             | list(string)                       |                                                                              |
| domain_name                               | Domain name to use for exposing endpoints                                                                  | string                             | `batonsystems.com`                                                           |
| vpc_id\*                                  | VPC ID to to link to lambdas , activeMQ , RDS                                                              | string                             |                                                                              |
| eks_security_group\*                      | Security group linked to EKS                                                                               | string                             |                                                                              |
| loadbalancer_url\* | Target for configuring DNS records |  string |`""` |
| cnames | Set of CNAME suffixed for subdomain |set(string)  |`[]` | 
| cloudflare_api_token\* | API token for configuring cloudflare provider |  string | `-`|
| kms_key_arn\*    | KMS key ARN to use for encrypting resources | string  |   `-`  |
| additional_secrets | Map of secrets to save to AWS secrets manager | map(any) | `{}` |
| sftp_host\* | Hostname for baton SFTP server | string | `-` |
| sftp_user\* | Username for baton SFTP server| string | `-` |
| sftp_password\* |  Password for baton SFTP server | string | `-` |  
|baton_application_namespaces\*            | List of namespaces and services with requirments                                                           | list(baton_application_namespaces) | [Baton Application Namespace](#markdown-header-baton-application-namespaces) |
|import_directory_service_db| Whether to import seed data for directory service bootup | bool |  `true`|
|rds_config\*            | Configuration parameters for RDS cluster | object | [RDS Config](#markdown-header-rds-config) |
|crr_rds_config\*            | Configuration parameters for RDS cluster CRR (**DR resources must be provisioned in prior**)| object | [CRR RDS Config](#markdown-header-crr-rds-config) |

### RDS Config
This object is used to configure the RDS cluster to be created in primary region.

| Name              | Description                                                                | Type           | Default                                            |
|:------------------|:---------------------------------------------------------------------------|:---------------|:---------------------------------------------------|
|rds_performance_insights_retention_period\*| time period to retain the performance insights|  number | `-`|
| rds_backup_retention_period\* | Time period to retain RDS CRR backup| number | `-` |
|rds_enable_deletion_protection|To enable delete protection on RDS cluster or not| bool | `true`|
|rds_snapshot_identifier|Snapshot ID to restore incase of snapshot restoration| string | `null`| 
|rds_mysql_version|MYSQL version of the RDS Cluster | string|  `"5.7"`|
|rds_instance_type|Instance Size of the RDS Cluster|string|`"db.t4g.large"`|
|rds_master_username| Master username for RDS cluster| string| `master`|
|create_rds_reader|whether to create RDS reader or not | bool | `false`|
|rds_parameter_group_family|parameter group family name|string|`"aurora-mysql5.7"`|
|rds_enable_performance_insights|Whether to enable performace insights | bool|`true` |
|rds_enable_event_notifications|Enabling event notification for RDS cluster |bool| `false`|
|rds_reader_instance_type|Instance size for RDS reader| string | `"db.t4g.large"`|
|rds_ingress_whitelist|CIDR blocks to whitelist to RDS cluster security group| list(string)|`[]`|
|rds_enable_auto_minor_version_upgrade|Whether to enable auto minor version upgrades on RDS | bool | `false`|
|rds_publicly_accessible| Whether to enable public access to RDS cluster | bool | `false`|
|rds_enabled_cloudwatch_logs_exports|Cloudwatch logs to enable for RDS cluster | list(string)|`["slowquery", "audit", "error"]`|
|rds_ca_cert_identifier| RDS certificate identifier | string| `"rds-ca-rsa2048-g1"`|
|rds_db_cluster_parameter_group_parameters|Cluster paramter group values|list(map(string))|`[{name="log_bin_trust_function_creators", value = 1, apply_method = "pending-reboot", }, {,name = "binlog_format", value = "MIXED", apply_method = "pending-reboot", }, {name         = "long_query_time", value = "10", apply_method = "immediate"}]` |
|rds_db_parameter_group_parameters| Parameters for the parameter group of DB | list(map(string))| `[{name="log_bin_trust_function_creators", value = 1, apply_method = "pending-reboot", }, {name         = "long_query_time", value = "10", apply_method = "immediate"}]`|

### CRR RDS Config
The following object is used to setup Cross Region Replication(CRR) for the RDS cluster created in the primary region. For CRR to be setup the DR region must be already setup without an active EKS cluster. All the below requested parameters are to be provided from DR region. 

| Name              | Description                                                                | Type           | Default                                            |
|:------------------|:---------------------------------------------------------------------------|:---------------|:---------------------------------------------------|
| backup_retention_period\* | Time period to retain RDS CRR backup| number | `-` |
| vpc_id\* | VPC ID of DR region | string  | `-`|
| eks_security_group\*| Security group ID of EKS in DR region|  string | `-` |
|kms_key_id\*| KMS key ARN used for encrypting generic resources. Has the follwoing alias format `{alias}-{environment}-{region}"` | string | `-`|
|subnet_ids\*|Subnet IDS in which the CRR cluster needs to bre created | list(string)| `-` |
|deletion_protection| Whether to enable delete protection or not |  bool | `true` |
|parameter_group_family| family of the parameter group of RDS cluster | string |`"aurora-mysql5.7"`|
|engine_version|RDS engine version of the CRR|string|`"5.7.mysql_aurora.2.11.5"`|
|instance_type|Size of the CRR instance | string|`"db.t4g.large"` |
|db_parameter_group_parameters| Parameters for the parameter group of DB | list(map(string))| `[{name="log_bin_trust_function_creators", value = 1, apply_method = "pending-reboot", }, {,name = "binlog_format", value = "MIXED", apply_method = "pending-reboot", }, {name         = "long_query_time", value = "10", apply_method = "immediate"}]`|


### Baton Application Namespaces

The following object deals with the namespaces and other kubernetes resources for a service to run . Below are the parameters for the object.


| Name              | Description                                                                | Type           | Default                                            |
|:------------------|:---------------------------------------------------------------------------|:---------------|:---------------------------------------------------|
| namespace\*       | Namespace value                                                            | string         |                                                    |
| istio_injection | Whether to enable istio injection or not                                   | bool           | `true`         |
|enable_activemq|To deploy activemq in this namespace|bool|`false`|
| common_env        | Environment properties common between multiple services across a namespace | map(string)    | `{}`                                               |
| customer\*        | Name of the customer | string      |          |
| docker_registry\* | Registry to pull the docker images from | string ||
| services\*        | List of services to create in the mentioned namespace                      | list(services) | [Baton Services](#markdown-headers-baton-services) |

### Baton Services

This object taked the paramters needed by a single service to run and are passed to the deployment and service files inside the helm chart. Following are the objects for a single service.

##### Inputs

| Name              | Description                                                                                                                            | Type        | Default  |
|:------------------|:---------------------------------------------------------------------------------------------------------------------------------------|:------------|:---------|
| name\*            | Name of the service                                                                                                                    | string      |          |
| target_port     | Port exposed on the container |number      |     `8080`     |
| port\*     | Port exposed by the pod | number      |          |
| health_endpoint | Health check endpoint of the service | string      |`"/health"`|
| subdomain_suffix  | Suffix to append to the environment name in sub domain for a service| string  |`""` |
|replicas| Number of replicas to provision for a deployment | number | `1` |
| url_prefix\*      | Prefix for the service URL  | string      |          |
| image_tag         | Version of the image to be used| string      | `latest` |
| env\*             | Env mapping for deployment object . The key provided is supplied to the `name` parameter and value provided goes to `value` parameter. | map(string) |          |
|volumeMounts | Different volume and mounts configuration to add to the deployment | object(volumeMounts) | [Volume Mounts](#markdown-headers-volume-mounts) | 

**Note: By default `{ "APP_ENVIRONMENT" = customer, "SPRING_PROFILES_ACTIVE" = namespace }` are always appended to `env` attribute.**
**Note: subdomain_suffix must begin in `-` eg: `-api`**
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
      enable_activemq = true
      services = [
        {
          name            = "app1"
          health_endpoint = "/health"
          target_port     = 8080
          port            = 8088
          subdomain_suffix= "-api"
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
          port            = 7088
          url_prefix      = "/app3"
          env             = {}
          image_tag       = "latest"
        }
      ]
    },
    {
      namespace       = "ns2"
      istio_injection = false
      enable_activemq = true
      customer        = "cust2"
      services = [
        {
          name            = "app2"
          health_endpoint = "/health"
          target_port     = 8080
          subdomain_suffix= "-api"
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
|activemq_url         | string |endpoint of activemq|
|activemq_username    | string |ActiveMQ Username credential|
|activemq_password    | string |ActiveMQ password credential|
|rabbitmq_endpoint    | string |endpoint of rabbitMQ |
|rabbitmq_username    | string |rabbitMQ Username credential|
|rabbitmq_password    | string |rabbitMQ password credential|
|rabbitmq_nlb_url     | string |rabbitMQ Network Loadbalancer URL|
|rds_writer_endpoint  | string |Writer endpoint of the RDS cluster|
|rds_reader_endpoint  | string |Reader endpoint of the RDS cluster|
|rds_master_username  | string |RDS master username credential|
|rds_master_password  | string |RDS master password credential|
|activemq_credentials | list(map) | Credentials for different ActiveMQ deployments within a namespace|
