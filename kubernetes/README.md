# Description

The following folder is a sub part of the entire Terraform IAAC project and deals with only the creation of Kubernetes resources listed below.

- EFS and EBS Addons 
- Istio installation in EKS cluster
- Istio ingress of type ALB
- Kube Prometheus Stack installation 
- Prometheus Alerts
- Grafana Dashboards and Users

# Modules

##### [Istio](./kubernetes/module/istio)
The isito module installs the isito service mesh onto the EKS cluster in `istio-system` namespace and creates an ingress object of type Application Load Balancer exposing the cluster to the outside world.

**Note:** The ALB created from this module can only enable flow logging if the logging S3 bucket supplied is in the same AWS region as the ALB. Also make sure that S3 bucket policies are configured properly to allow logs from different sources like VPC and ELB

##### [Addons](./kubernetes/module/addons)
Responsible for installation of helm based eks addons in cluster which are listed below.
    - aws-efs-csi-driver
    - lbc-controller

The versions for the following can be supplied from the input variables. 
The `aws-efs-csi-driver` is also responsible for creating a `StorageClass` object for persistent volumes.

##### [Monitoring](./kubernetes/module/monitoring)

Installs the Kube Stack Prometheus on the EKS cluster and also creates prometheus alerts and grafana dashboards for the same. The configuration for the alertmanager and alerts is supplied from the helm values by templating the values file and suppling it the values for alerts and Alert Manager form two different files [alerts](./kubernetes/module/monitoring/alerts.yaml) and [alertmanager](./kubernetes/module/monitoring/alertmanager.yaml) file respectively. The grafana configuration is carried out in a seperate submodule . The alerts notification is sent to slack if severity is of type warining and if critical then to pagerduty. The storage volume for the PVC'S for Prometheus,Alertmanager and Grafana is also set at this level with variables configured for each of them as 200Gi,5Gi and 10Gi respectively by default, the Prometheus and Alertmanager volume size can be changed from top level vars or tfvars file but for grafana volume needs to be configured from [monitoring vars file](./modules/monitoring/vars.tf)

###### [Grafana Config](./kubernetes/module/monitoring/modules/grafana-config)

This module is a legacy module as it uses grafana provider to create the dashboards, Hence this module cannot be dependent on any other module and cannot be set to optional if required. The reason for configuring the grafana provider inside monitoring module is that grafana is not a hashicorp module and is a seperate project . 

The Grafana provider uses the URL to access grafana and admin credentials are configured in it for authentication. The [dashboards](./kubernetes/module/monitoring/modules/grafana-config/dashboards) folder contains the json files for creating different grafana dashboards. Also a no admin user (developer) is also created. 

**Note:** The grafana service needs to be exposed to the outside world and the URL must be configured for access and creation of grafana resources.

# Folder Structure

```
.
├── backend.tf
├── main.tf
├── modules
│   ├── addons
│   ├── istio
│   └── monitoring(legacy module)
|       ├── modules
|       |   └── grafana-config(legacy module)
|       |       └── dashboards
│       ├── alertmanager.yaml
│       ├── alerts.yaml
│       ├── config.yaml
│       └── dashboards
├── providers.tf
├── terraform.tfvars
└── vars.tf
```

The providers.tf file contains the necessary packages that are required to run the script i.e helm and kubernetes provider .(**Note:** Grafana Provider is configured inside the [grafana-config](./kubernetes/module/monitoring/modules/grafana-config) submodule as it is not a hashicorp module)

The main.tf file is the file that triggers the modules for creation of resources.

The vars.tf file has the input variables for for customizing the resources.

The outputs.tf file has the variables that are shown at the end of the script in the console from the module as result.

The backend.tf file has configuration for infrastructure state storage to S3 bucket.The key for state storage are named after the folders in resource folders in in the bucket that is AWS and kubernetes.

The terraform.tf file can be used to access the variables to edit the configuration and make changes to the infrastructure

The main configuration lies inside the modules folder which has a multiple sub directories that are called by the main.tf file. The module has a main.tf ,vars.tf and outputs.tf file. 

## How to Run

* Configure AWS credentials 

* Install the necessary modules for each of the folders by going into the relevant directories and applying the below command.
```
terraform init
```

* Set the values for input variables from .tfvars . One can edit the existing terraform.tfvars file or create there own .tfvars and reference it through command line during apply and plan. Few input variables need to be provided from AWS module's output if using in conjunction with it.

* Test run the script (Optional)
```
terraform plan
```
* Run the kubernetes folder script 
```
terraform apply
```


### Inputs

| Name  | Description |Type | Default | 
|:-----------|:---------|:-----------|:---------|
|kube_prometheus_stack_version| Prometheus version to be installed| string| `"49.2.0"`|
|istio_version| isito version to be installed| string| `"1.20.0"`|
|slack_channel_name| slack channnel name to recieve prometheus alerts| string|`""`|
|slack_web_hook| slack applicaiton webhook for prometheus alerts| string|  `""`|
|pagerduty_key      | PagerDuty key for prometheus alerts|string|`""`|
|efs_id| EFS ID from aws script for persistent storage| string | `""`|
|efs_addon_version| Version of the efs driver | string  | `"2.2.0"`|
|lbc_addon_version| Version of lbc driver|string|`"1.6.0"`|
|environment|Environment for which the resources are being provisioned|string|`""`|
|acm_certificate_arn|ARN of the domain certificate from the AWS script for istio ingress| string | `""`|
|siem_storage_s3_bucket      |S3 bucket name for alerts and logging |string     |`""`|
|custom_alerts|List of custom alerts for prometheus|[map(custom_alerts)](#markdown-header-custom-alerts-config)| `[]` |
|pagerduty_key|Key for Pager Duty alerts|string|`""`|
|grafana_role_arn|ARN for the grafana role|string|`""`|
|prometheus_volume_size|PVC size for prometheus|`"200Gi"`|
|alert_manager_volume_size|PVC size for aleretmanager|`"5Gi"`|

### Custom Alerts Config

The following object is used to create additional custom alerts for the Alert Manager in prometheus.
It follows the same structure as setting up an alert in yaml configuration in PrometheusRule object.

| Name  | Description |Type | Default | 
|:-----------|:---------|:-----------|:---------|
|alert| Name of the alert | string | |
|expr| PromQL query for the alert | string | |
|for| Time for which the alert must be triggering | string | |
|labels | labels for the alert | map(labels) |[Custom Objects In Custom Alerts](#markdown-header-custom-objects-in-custom-alerts)|
|annotations| Annotations for the alert | map(annotations)|[Custom Objects In Custom Alerts](#markdown-header-custom-objects-in-custom-alerts)|

### Custom Objects In Custom Alerts

There are two custom object in `custom_alerts` object `labels` and `annotations` 

**Labels**

| Name  | Description |Type | Default | 
|:-----------|:---------|:-----------|:-----------|
|severity | level of severity of alert | string | |

**Annotations**

| Name  | Description |Type | Default | 
|:-----------|:---------|:-----------|:-----------|
|summary| Summary for the alert | string | |
|description|Description of the alert| string| |

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

### Output

| Name  | Type | Description |
|:-----------|:---------|:-----------|
|grafana_password     |string      |Admin passwrod for grafana dashboard|
|grafana_dev_password |string      |Developer password for grafana dashboard|