data "aws_caller_identity" "current" {}

# Cluster associated Policies and role Creation
resource "aws_iam_policy" "elb_policy" {
  name_prefix = "k8s_elb_policy_${var.cluster_name}_${var.region}"
  description = "elb policy for k8s cluster"
  policy      = file("${path.module}/policies/eksctl-cluster-PolicyELBPermissions.json")

  tags = var.tags
}

#policy for Cloud Watch metrics
resource "aws_iam_policy" "cloudwatch_policy" {
  name_prefix = "k8s_cloudwatch_policy_${var.cluster_name}_${var.region}"
  description = "cloudwacth logs policy for k8s cluster"
  policy      = file("${path.module}/policies/eksctl-cluster-PolicyCloudWatchMetric.json")

  tags = var.tags
}


#saving all the polices for cluster role creation into a variable
locals {
  managed_cluster_policies_map = {
    for policy_arn in var.cluster_policies :
    split("/", policy_arn)[length(split("/", policy_arn)) - 1] => policy_arn
  }
  cluster_policies_map = merge(local.managed_cluster_policies_map,
    {
      ELBPermission     = aws_iam_policy.elb_policy.arn
      CloudWatchMetrics = aws_iam_policy.cloudwatch_policy.arn
  })
}

resource "aws_iam_role" "cluster_role" {
  name_prefix        = "eks_${var.cluster_name}_${var.region}"
  assume_role_policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [

      {
          "Effect": "Allow",
          "Principal": {
              "Service": "eks.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
      }
  ]
}
EOF

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster_role" {
  for_each = { for k, v in local.cluster_policies_map : k => v }

  role       = aws_iam_role.cluster_role.name
  policy_arn = each.value
}

# Node Policy and Role Creation

#Policy for nodes to manage secrets
resource "aws_iam_policy" "secrets_policy" {
  name_prefix = "SecretsManager_Read_Only_Access_${var.cluster_name}_${var.region}"
  description = "provides read only access to secrets"
  policy      = file("${path.module}/policies/secretsManager.json")

  tags = var.tags
}

#Policy for efs driver integeration
resource "aws_iam_policy" "efs_policy" {
  name_prefix = "efs_csi_driver_policy_${var.cluster_name}_${var.region}"
  description = "efs policy for k8s cluster"
  policy      = file("${path.module}/policies/efs-driver.json")

  tags = var.tags
}

resource "aws_iam_policy" "additional_inline_node_policy" {
  count       = var.additional_node_inline_policy != null ? 1 : 0
  name_prefix = "custom_inline__node_policy_${var.cluster_name}_${var.region}"
  description = "Additional policy for eks nodes"
  policy      = var.additional_node_inline_policy

  tags = var.tags
}

#saving all the polices for node role creation into a variable
locals {
  managed_node_policies_map = {
    for policy_arn in var.node_policies :
    split("/", policy_arn)[length(split("/", policy_arn)) - 1] => policy_arn
  }

  additional_managed_node_policies_map = {
    for policy_arn in var.additional_node_policies :
    split("/", policy_arn)[length(split("/", policy_arn)) - 1] => policy_arn
  }

  custom_inline = var.additional_node_inline_policy != null ? { CustomInline = aws_iam_policy.additional_inline_node_policy[0].arn } : {}

  node_policies_map = merge(local.managed_node_policies_map, {
    SecretsReadOnlyAccess           = aws_iam_policy.secrets_policy.arn
    AmazonEKS_EFS_CSI_Driver_Policy = aws_iam_policy.efs_policy.arn
  }, local.additional_managed_node_policies_map, local.custom_inline)
}

resource "aws_iam_role" "node_role" {
  name_prefix        = "eks_${var.cluster_name}_${var.region}"
  assume_role_policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Principal": {
            "Service": "ec2.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
      }
    ]
}
EOF

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "node_role" {
  for_each = { for k, v in local.node_policies_map : k => v }

  role       = aws_iam_role.node_role.name
  policy_arn = each.value

}

resource "aws_iam_role" "grafana" {
  name_prefix        = "grafana_${var.cluster_name}_${var.region}"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action": "sts:AssumeRole"
      }
      
    ]
  }
  EOF

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "grafana" {
  for_each = { for k, v in var.grafana_policies : k => v }

  role       = aws_iam_role.grafana.name
  policy_arn = each.value
}