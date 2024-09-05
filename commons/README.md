# Description

This folder works like a universal module for multiple directories in this script. It houses many modules for both AWS and Kubernetes resources , below is the list of resources it houses inside the AWS and Kubernetes subdirectories.

- AWS
  - Kinesis Streams
  - S3 Bucket
  - IAM role for Lambda functions
  - Lambda Functions
  - RDS Cluster
  - ActiveMQ
  - RabbitMQ
  - SQS
- Kubernetes
  - Baton Namepspace
  - Baton Application 
  - RabbitMQ
- Utilities
  - CloudFlare 

# Modules

### [Cloudflare](./utilities/cloudflare)

Responsible for create CNAME records on cloudlfare.

| Name                                      | Description                               | Type         | Default                                                                     |
|:------------------------------------------|:------------------------------------------|:-------------|:----------------------------------------------------------------------------|
|cnames | Set of suffix for subdomain in CNAME records | set(string) |  | 
|name | Name of environment | string |  | 
|domain_name | domain name registered in cloudflare | string |  | 
|loadbalancer_url |target domain for CNAME records | string | 

### [RDS](./aws/rds/)

This module creates an Aurora RDS Cluster with MYSQL engine with multiple configuration options ranging from SQL version to having a reader instance or not . Follow the below inputs for more .

##### Inputs

| Name                                      | Description                               | Type         | Default                                                                     |
|:------------------------------------------|:------------------------------------------|:-------------|:----------------------------------------------------------------------------|
| create_rds_reader                         | Enable reader for RDS                     | bool         | `false`                                                                     |
| rds_mysql_version                         | MySQL version for RDS Aurora              | string       | `-`                                                                         |
| rds_instance_type                         | RDS Instance Type                         | string       | `-`                                                                         |
| rds_master_password                       | Master Password for RDS                   | string       | `-`                                                                         |
| rds_master_username                       | Master Username for RDS                   | string       | `master`                                                                    |
| rds_parameter_group_family                | Parameter group Family name               | string       | `-`                                                                         |
| rds_enable_performance_insights           | Enable performance insights for RDS       | bool         | `-`                                                                         |
| rds_performance_insights_retention_period | Performance Insights retention period     | number       | `7`                                                                         |
| rds_enable_event_notifications            | Enable event notifications for RDS        | bool         | `true`                                                                      |
| rds_reader_instance_type                  | Reader instance type for RDS              | `-`          | `-`                                                                         |
| rds_ingress_whitelist                     | Ingress whitelist for RDS                 | list         | `-`                                                                         |
| rds_enable_deletion_protection            | Enable deletion protection for RDS        | bool         | `true`                                                                      |
| rds_enable_auto_minor_version_upgrade     | Enable auto minor version upgrade for RDS | bool         | `false`                                                                     |
| rds_db_cluster_parameter_group_parameters | DB cluster parameter group parameters     | list         | `[]`                                                                        |
| rds_preferred_backup_window               | Preferred backup window for RDS           | string       | `"07:00-09:00"`                                                             |
| rds_publicly_accessible                   | Make RDS publicly accessible              | bool         | `false`                                                                     |
| rds_db_parameter_group_parameters         | DB parameter group parameters             | list(map)    | `[{"name": "long_query_time", "value": "10", "apply_method": "immediate"}]` |
| rds_enabled_cloudwatch_logs_exports       | Enabled CloudWatch Logs Exports for RDS   | list(string) | `["slowquery", "audit", "error"]`                                           |
| rds_ca_cert_identifier                    | CA certificate identifier for RDS         | string       | `-`                                                                         |
| rds_backup_retention_period               | Backup retention period for RDS in days   | number       | `7`                                                                         |

##### Outputs

| Name                      | Type   | Description                                           |
| :------------------------ | :----- | :---------------------------------------------------- |
| rds_writer_endpoint       | string | Writer endpoint of the RDS cluster                    |
| rds_reader_endpoint       | string | Reader endpoint of the RDS cluster                    |
| rds_cloudwatch_log_groups | string | CloudWatch log groups associated with the RDS cluster |
| rds_master_username       | string | MYSQL Username for the master user                    |
| rds_master_password       | string | MYSQL Password for the master user                    |

### [ACTIVE MQ](./aws/activemq/)

This module provisions a single ACTIVEMQ Broker and security group for it .

##### Inputs

| Name                       | Description                                                                                               | Type   | Default         |
|:---------------------------|:----------------------------------------------------------------------------------------------------------|:-------|:----------------|
| engine_version             | Version of ActiveMQ engine                                                                                | String | `"5.17.6"`     |
| storage_type               | Preferred storage type for ActiveMQ                                                                       | String | `"efs"`         |
| instance_type              | ActiveMQ host's instance type                                                                             | String | `"mq.t2.micro"` |
| apply_immediately          | Specifies whether any broker modifications are applied immediately, or during the next maintenance window | bool   | `true`          |
| auto_minor_version_upgrade | Whether to automatically upgrade to new minor versions of brokers as Amazon MQ makes releases available.  | bool   | `false`         |
| publicly_accessible        | Specify whether the ActiveMQ instance should be publicly accessible                                       | bool   | `true`          |
| username                   | Username to authenticate into the ActiveMQ server                                                         | String | `"admin"`       |

##### Outputs

| Name     | Type   | Description                |
|:---------|:-------|:---------------------------|
| url      | string | URL of the ActiveMQ broker |
| username | string | Username for ActiveMQ      |
| password | string | Password for ActiveMQ      |

### [RABBITMQ (AWS)](./aws/activemq/)

This module provisions a single RABBITMQ Broker and security group for it .

##### Inputs

| Name                        | Description                                                       | Type         | Default       |
|-----------------------------|-------------------------------------------------------------------|--------------|---------------|
| vpc_id\*                    | VPC ID where resources will be deployed                           | String       | `-`           |
| subnet_ids\*                | List of Subnet IDs within the specified VPC                       | List(String) | `-`           |
| engine_version              | Version of RabbitMQ to deploy                                     | String       | `3.11.20`     |
| host_instance_type          | EC2 instance type used as host for RabbitMQ cluster nodes         | String       | `mq.m5.large` |
| apply_immediately           | Whether to apply changes immediately or during maintenance window | Boolean      | `false`       |
| auto_minor_version_upgrade  | Automatically upgrade minor versions of RabbitMQ                  | Boolean      | `false`       |
| publicly_accessible         | Allow public access to RabbitMQ cluster                           | Boolean      | `false`       |
| tags\*                      | Tags assigned to AWS resources                                    | Map(String)  | `-`           |
| username                    | Username for RabbitMQ admin account                               | String       | `master`      |
| name\*                      | Custom name for RabbitMQ cluster                                  | String       | `-`           |
| whitelist_security_groups\* | Security groups allowed to connect to RabbitMQ cluster            | List(String) | `-`           |
| enable_cluster_mode         | Enable RabbitMQ clustering feature                                | Boolean      | `false`       |

##### Outputs

| Name        | Type      | Description                                        |
|-------------|-----------|----------------------------------------------------|
| password    | Sensitive | Generated password for RabbitMQ admin account      |
| username    | String    | Specified username for RabbitMQ admin account      |
| console_url | String    | URL to access RabbitMQ management console          |
| endpoint    | String    | Endpoint address for connecting to RabbitMQ broker |

### [LAMBDA](./aws/lambda)

This module creates a Lambda function with security group for the lambda as well as event source mapping for the lambda .Environment name is being appened to all the names provied to in this resource to keep the distinction for each resource clear. The module supports configuration for both sqs as well as kinesis sources . `stream_arn` or `sqs_arn` input values determine hwo the event source mapping is configured . Only one is supported and required for a single lambda. 

##### Inputs

| Name                      | Description                                             | Type         | Default |
| :------------------------ | :------------------------------------------------------ | :----------- | :------ |
| stream_arn                | ARN of Kinesis Stream for event source mappping         | string       | `null`  |
| sqs_arn                   | ARN of SQS for event source mappping                    | string       | `null`  |
| name\*                    | Name for the Lambda function                            | string       |         |
| package_key\*             | S3 path for script or code to run                       | string       |         |
| handler\*                 | The method in your function code that processes events  | string       |         |
| lambda_packages_s3_bucket | Name of S3 Bucket with Lambda functions                 | string       |         |
| tags\*                    | Tags for the Lambda Function                            | map(string)  |         |
| environment_variables\*   | Configuraiton for the Lambda Environment variables      | map(dynamic) |         |
| subnet_ids\*              | Subnet IDS to associate with the Lambda                 | list(string) |         |
| lambda_role_arn\*         | ARN of the IAM role to associate to the Lambda          | string       |         |
| vpc_id\*                  | VPC ID to associate the Lambda function to              | string       |         |
| region\*                  | AWS Region in which the function is created             | string       |         |
| environment\*             | Name of the environment to append to the resources name | string       |         |

##### Outputs

| Name              | Type   | Description                      |
|:------------------|:-------|:---------------------------------|
| security_group_id | string | Security Group ID for the Lambda |

### [LAMBDA IAM](./aws/lambda-iam)

This module generates the IAM role to associate to the lambda functions for giving them the required access

##### Inputs

| Name        | Description                                             | Type   | Default |
| :---------- | :------------------------------------------------------ | :----- | :------ |
| region      | AWS Region in which the function is created             | string |         |
| environment | Name of the environment to append to the resources name | string |         |

##### Outputs

| Name | Type | Description |
| :--- | :--- | :---------- |
|lambda_role_arn|string|ARN of the IAM role created for the Lambda|

### [S3](./aws/s3)

This module creates a S3 Bucket with the respective region with S3 server_side_encryption_configuration also.

##### Inputs

| Name          | Description                                             | Type        | Default |
| :------------ | :------------------------------------------------------ | :---------- | :------ |
| environment\* | Name of the environment to append to the resources name | string      |         |
| name\*        | Name of the bucket                                      | string      |         |
| tags\*        | Tags for the bucket                                     | map(string) |         |

##### Outputs

| Name | Type | Description |
| :--- | :--- | :---------- |
|bucket_arn|string|ARN of the S3 Bucket|

### [SQS](./aws/sqs)

This module creates a SQS with visibility set to `305` seconds by default.Environment name is being appened to all the names provided to in this resource to keep the distinction for each resource clear.

##### Inputs

| Name   | Description         | Type        | Default |
| :----- | :------------------ | :---------- | :------ |
| name\* | Name of the bucket  | string      |         |
| tags\* | Tags for the bucket | map(string) |         |

##### Outputs

| Name | Type   | Description    |
| :--- | :----- | :------------- |
| arn  | string | ARN of the SQS |

### [STREAM](./aws/stream)

This module creates a AWS Kinesis Stream with default `retention_period` as `12`.

##### Inputs

| Name   | Description         | Type        | Default |
| :----- | :------------------ | :---------- | :------ |
| name\* | Name of the bucket  | string      |         |
| tags\* | Tags for the bucket | map(string) |         |

##### Outputs

| Name       | Type   | Description               |
| :--------- | :----- | :------------------------ |
| stream_arn | string | ARN of the Kinesis Stream |

### [Rabbit MQ (kubernetes)](./kubernetes/rabbitmq)

This module helps to expose the rabbitmq console url and make it accesciable over internet. It contains a set of kubenetes objects to that route any incoming traffic to the rabbitMQ console URL. 

##### Inputs

| Name   | Description         | Type        | Default |
|:-------|:--------------------|:------------|:--------|
| name\* | Name of the environment  | string      |         |
| domain_name\* | Domain Name to add to gateways and services | string |         |
| rabbitmq_endpoint\* | Console URL of rabbitmq | string | | 

### [Baton Application Namespace](./kubernetes/baton-application)

Responsible for creation of namespaces and virtualservies, gateways, deployments, service accounts and takes care of these requirements for running the applications. Helm chart has been created for deploying these objects except the gateways and namespaces.

The services are exposed for the following URL `{environment}-{subdomain_suffix}-{service}-{domain}` or if `subdomain_suffix` is not give then `{environment}-{domain}`

| Name          | Description                                             | Type   | Default |
|:--------------|:--------------------------------------------------------|:-------|:--------|
| environment\* | Name of the environment to append to the resources name | string |         |
| domain_name\*                  | Domain name registerd in the DNS service                | string                             |
| common_connections             | Global connections to attach to each service            | map(string)                        |                                                                              |
| baton_application_namespace\* | List of namespaces and services with requirments        | list(baton_application_namespaces) | [Baton Application Namespace](#markdown-header-baton-application-namespaces) |

### Baton Namespace

The following object deals with the namespaces and other kubernetes resources for a service to run . Below are the parameters for the object.

| Name              | Description                                                                | Type           | Default                                            |
|:------------------|:---------------------------------------------------------------------------|:---------------|:---------------------------------------------------|
| namespace\* | Namespace value | string |  |
| istio_injection | Whether to enable istio injection or not | bool | `true` |
| enable_activemq | Whether to enable ActiveMQ deployment or not | bool | `false` |
| common_env        | Environment properties common between multiple services across a namespace | map(string)    | `{}` |
| customer\*        | Name of the customer| string      |          |
| domain_name\* | Name of domain to link with gateways and services| string | |
| docker_registry | Registry to pull the docker images from | string | |
| services\*        | List of services to create in the mentioned namespace                      | list(services) | [Baton Services](#markdown-headers-baton-services) |

### Baton Services

This object taked the paramters needed by a single service to run and are passed to the deployment and service files inside the helm chart. Following are the objects for a single service.

##### Inputs

| Name              | Description                                                                                                                            | Type        | Default  |
|:------------------|:---------------------------------------------------------------------------------------------------------------------------------------|:------------|:---------|
| name\*            | Name of the service                                                                                                                    | string      |          |
| port     | Port for the service     | number      |   `8080`     |
| target_port\*     | Target port for the service   | number      |          |
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
      enable_activemq = true
      services = [
        {
          name            = "app1"
          health_endpoint = "/health"
          port            = 8080
          target_port     = 8080
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
          port            = 8080
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
          port            = 8080
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

##### Outputs

| Name       | Type   | Description               |
|:-----------|:-------|:--------------------------|
|activemq_credentials| map | credentials for different ActiveMQ deployments within a namespace|