# Description

The following folder is a sub part of the entire Terraform IAAC project and deals with the creation of Kubernetes resources listed below.

- LBC Addon
- Istio installation in EKS cluster
- Istio ingress of type ALB
- Kube Prometheus Stack installation
- Prometheus Alerts
- Grafana Dashboards and Users
- Cloudflare CNAME records
- Jaeger

# Modules

##### [Istio](./kubernetes/module/istio)

The isito module installs the isito service mesh onto the EKS cluster in `istio-system` namespace and creates an ingress object of type Application Load Balancer exposing the cluster to the outside world. It also implements basic authentication over WASM plugin for domains like jaeger, alertmanager, prometheus.

**Note:** The ALB created from this module can only enable flow logging if the logging S3 bucket supplied is in the same AWS region as the ALB. Also make sure that S3 bucket policies are configured properly to allow logs from different sources like VPC and ELB.
**WARNING:** If the S3 logging bucket is not in the same region then `loadbalancer_url` is not generated leading to failiure of script.

##### [Addons](./kubernetes/module/addons)

Responsible for installation of helm based eks addons in cluster which are listed below. - lbc-controller

The versions for the following can be supplied from the input variables.

##### [Cloudflare](./kubernetes/module/cloudflare)

Responsible for create CNAME records on cloudlfare for grafana, kibana, jaeger,prometheus, alertmanager.

##### [Jaeger](./kubernetes/module/jaeger)

This module is responsible for installation and configuration of jaeger tracing components on top of istio . The jaeger components are not installed via helm and neither are they configured in this module. The maintainers of istio also maintain a configuration for [jaeger installation](https://istio.io/latest/docs/ops/integrations/jaeger/#installation) which we apply in this module using kubectl provider .

##### [Monitoring](./kubernetes/module/monitoring)

Installs the Kube Stack Prometheus on the EKS cluster and also creates prometheus alerts and grafana dashboards for the same. The configuration for the alertmanager and alerts is supplied from the helm values by templating the values file and suppling it the values for alerts and Alert Manager form two different files [alerts](./kubernetes/module/monitoring/configs/alerts.yaml) and [alertmanager](./kubernetes/module/monitoring/configs/alertmanager.yaml) file respectively.

The grafana configuration is carried out in a seperate submodule . The alerts notification is sent to slack if severity is of type warning and if critical then to pagerduty. The storage volume for the PVC'S for Prometheus,Alertmanager and Grafana is also set at this level with variables configured for each of them as `200Gi`,`5Gi` and `10Gi` respectively by default, the Prometheus and Alertmanager volume size can be changed from top level vars or tfvars file but for grafana volume needs to be configured from [monitoring vars file](./modules/monitoring/vars.tf).

CNAME records are also created via this module for prometheus, grafana and alertmanager exposing the services at `{environment}-{service}-{domain}` EXAMPLE `test-grafana-123.com`.

This module also uses `kubectl` and `cloudflare` providers which are configured in root providers file and passed down in the main file as `Gateway`,`CNAME` records and `VirtualService` objects are created here.

###### [Grafana Config](./kubernetes/module/monitoring/modules/grafana-config)

This module is a legacy module as it uses grafana provider to create the dashboards, Hence this module cannot be dependent on any other module and cannot be set to optional if required. The reason for configuring the grafana provider inside monitoring module is that grafana is not a hashicorp module and is a seperate project .

The Grafana provider uses the URL to access grafana and admin credentials are configured in it for authentication. The [dashboards](./kubernetes/module/monitoring/modules/grafana-config/dashboards) folder contains the json files for creating different grafana dashboards. Also a no admin user (developer) is also created.

**Note:** The grafana service needs to be exposed via main monitoring module which is used by the grafana provider to create the objects.

# Folder Structure

```
.
├── backend.tf
├── main.tf
├── modules
│   ├── addons
│   ├── cloudflare
│   ├── istio
│   ├── jaeger
│   └── monitoring(legacy module)
|       ├── modules
|       |   └── grafana-config(legacy module)
|       |       └── dashboards
|       └── configs
│           ├── alertmanager.yaml
│           ├── alerts.yaml
│           ├── config.yaml
│           ├── virtualServices.yaml
│           └── dashboards
├── providers.tf
├── terraform.tfvars
└── vars.tf
```

The providers.tf file contains the necessary packages that are required to run the script i.e helm and kubernetes provider .(**Note:** Grafana Provider is configured inside the [grafana-config](./kubernetes/module/monitoring/modules/grafana-config) submodule as it is not a hashicorp module and runs into issues wiht the randomly generated password if used in root providers file)

The main.tf file is the file that triggers the modules for creation of resources.

The vars.tf file has the input variables for for customizing the resources.

The outputs.tf file has the variables that are shown at the end of the script in the console from the module as result.

The backend.tf file has configuration for infrastructure state storage to S3 bucket.The key for state storage are named after the folders in resource folders in in the bucket that is AWS and kubernetes.

The terraform.tf file can be used to access the variables to edit the configuration and make changes to the infrastructure

The main configuration lies inside the modules folder which has a multiple sub directories that are called by the main.tf file. The module has a main.tf ,vars.tf and outputs.tf file.

## How to Run

- Configure AWS credentials

- Install the necessary modules for each of the folders by going into the relevant directories and applying the below command.

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

| Name                           | Description                                                         | Type                                                        | Default                                                                      |
| :----------------------------- | :------------------------------------------------------------------ | :---------------------------------------------------------- | :--------------------------------------------------------------------------- |
| kube_prometheus_stack_version  | Prometheus version to be installed                                  | string                                                      | `"49.2.0"`                                                                   |
| istio_version                  | isito version to be installed                                       | string                                                      | `"1.20.0"`                                                                   |
| slack_channel_name\*           | slack channnel name to recieve prometheus alerts                    | string                                                      |                                                                              |
| slack_web_hook\*               | slack applicaiton webhook for prometheus alerts                     | string                                                      |                                                                              |
| pagerduty_key\*                | PagerDuty key for prometheus alerts                                 | string                                                      |                                                                              |
| efs_id\*                       | EFS ID from aws script for persistent storage                       | string                                                      |                                                                              |
| efs_addon_version              | Version of the efs driver                                           | string                                                      | `"2.2.0"`                                                                    |
| lbc_addon_version              | Version of lbc driver                                               | string                                                      | `"1.6.0"`                                                                    |
| environment\*                  | Environment for which the resources are being provisioned           | string                                                      |                                                                              |
| domain_name\*                  | Domain name registerd in the DNS service                            | string                                                      |                                                                              |
| acm_certificate_arn\*          | ARN of the domain certificate from the AWS script for istio ingress | string                                                      |                                                                              |
| siem_storage_s3_bucket         | S3 bucket name for alerts and logging                               | string                                                      |                                                                              |
| custom_alerts                  | List of custom alerts for prometheus                                | [map(custom_alerts)](#markdown-header-custom-alerts-config) | `[]`                                                                         |
| grafana_role_arn\*             | ARN for the grafana role                                            | string                                                      |                                                                              |
| prometheus_volume_size         | PVC size for prometheus                                             | string                                                      | `"200Gi"`                                                                    |
| alert_manager_volume_size      | PVC size for alertmanager                                           | string                                                      | `"5Gi"`                                                                      |
| cloudflare_api_token\*         | cloudflare API access token                                         | string                                                      |                                                                              |
| enable_siem                    | Optional enabling of logging in ALB                                 | bool                                                        | `true`                                                                       |
| baton_application_namespaces\* | List of namespaces and services with requirments                    | list(baton_application_namespaces)                          | [Baton Application Namespace](#markdown-header-baton-application-namespaces) |

**NOTE: `enable_siem` parameter is used to enable/disable the logging of istio ingress . If set to `true` ,`siem_storage_s3_bucket` is required attribute with S3 bucekt in the same region as the EKS cluster**

### Custom Alerts Config

The following object is used to create additional custom alerts for the Alert Manager in prometheus.
It follows the same structure as setting up an alert in yaml configuration in PrometheusRule object.

| Name          | Description                                 | Type             | Default                                                                             |
| :------------ | :------------------------------------------ | :--------------- | :---------------------------------------------------------------------------------- |
| alert\*       | Name of the alert                           | string           |                                                                                     |
| expr\*        | PromQL query for the alert                  | string           |                                                                                     |
| for\*         | Time for which the alert must be triggering | string           |                                                                                     |
| labels\*      | labels for the alert                        | map(labels)      | [Custom Objects In Custom Alerts](#markdown-header-custom-objects-in-custom-alerts) |
| annotations\* | Annotations for the alert                   | map(annotations) | [Custom Objects In Custom Alerts](#markdown-header-custom-objects-in-custom-alerts) |

### Custom Objects In Custom Alerts

There are two custom object in `custom_alerts` object `labels` and `annotations`

**Labels**

| Name       | Description                | Type   | Default |
| :--------- | :------------------------- | :----- | :------ |
| severity\* | level of severity of alert | string |         |

**Annotations**

| Name          | Description              | Type   | Default |
| :------------ | :----------------------- | :----- | :------ |
| summary\*     | Summary for the alert    | string |         |
| description\* | Description of the alert | string |         |

**Example for Custom Alerts**

```
custom_alerts=[{
  alert  = "KubernetesVolumeOutOfDiskSpace"
  expr   = "kubelet_volume_stats_available_bytes / kubelet_volume_stats_capacity_bytes * 100 < 20"
  for    = "2m"
  labels = { "severity" = "warning" }
  annotations = {
    summary     = "Kubernetes Volume out of disk space"
    description = "Volume is almost full"
  }
}]
```

### Baton Application Namespaces

The following object deals with the namespaces and other kubernetes resources for a service to run . Below are the paramters for the object.

**All values are required**

| Name              | Description                                                                | Type           | Default                                            |
| :---------------- | :------------------------------------------------------------------------- | :------------- | :------------------------------------------------- |
| namespace\*       | Namespace value                                                            | string         |                                                    |
| istio_injection\* | Whether to enable istio injection or not                                   | bool           |                                                    |
| common_env        | Environment properties common between multiple services across a namespace | map(string)    | `{}`                                               |
| services\*        | List of services to create in the mentioned namespace                      | list(services) | [Baton Services](#markdown-headers-baton-services) |

### Baton Services

This object taked the paramters needed by a single service to run adn are passed to the deployment and service files inside the helm chart. Following are the objects for a single service.

| Name              | Description                                                                                                                            | Type        | Default  |
| :---------------- | :------------------------------------------------------------------------------------------------------------------------------------- | :---------- | :------- |
| name\*            | Name of the service                                                                                                                    | string      |          |
| customer\*        | Name of the customer                                                                                                                   | string      |          |
| target_port\*     | Port exposed by the service                                                                                                            | number      |          |
| health_endpoint\* | Health check endpoint of the service                                                                                                   | string      |          |
| subdomain_suffix  | Suffix to append to the environment name in sub domain for a service                                                                   | string      | `""`     |
| url_prefix\*      | Prefix for the service URL                                                                                                             | string      |          |
| image_tag         | Version of the image to be used                                                                                                        | string      | `latest` |
| env\*             | Env mapping for deployment object . The key provided is supplied to the `name` parameter and value provided goes to `value` parameter. | map(string) |          |

**Note: By default `{ "APP_ENVIRONMENT" = customer, "SPRING_PROFILES_ACTIVE" = namespace }` are always appended to `env` attribute.**

**Example service object**

```
[
      {
      namespace       = "ns1"
      istio_injection = true
      customer        = "cust1"
      common_env      = { "key7" = "v7", "key8" = "v8" }
      services = [
        {
          name            = "app1"
          health_endpoint = "/health"
          target_port     = 8080
          subdomain_suffix= "api"
          url_prefix      = "/app1"
          env             = { "key1" = "v1", "key2" = "v2" }
          image_tag       = "latest"
        },
        {
          name            = "app3"
          health_endpoint = "/health"
          target_port     = 8080
          url_prefix      = "/app3"
          env             = { "key5" = "v5", "key6" = "v6" }
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
| grafana_password     | string | Admin passwrod for grafana dashboard     |
| grafana_dev_password | string | Developer password for grafana dashboard |
| loadbalancer_url     | string | URL of ALB LoadBalancer                  |
