data "aws_caller_identity" "current" {}

# Cluster associated Policies and Role Creation
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
    policy_arn => "arn:aws:iam::aws:policy/${policy_arn}"
  }
  cluster_policies_map = merge(local.managed_cluster_policies_map,
    {
      ELBPermission     = aws_iam_policy.elb_policy.arn
      CloudWatchMetrics = aws_iam_policy.cloudwatch_policy.arn
  })
}

resource "aws_iam_role" "cluster_role" {
  name               = "eks_cluster_${var.cluster_name}_${var.region}"
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

#Policy for nodes to manage secrets and efs access
resource "aws_iam_policy" "custom_node" {
  name        = "custom_node_${var.cluster_name}_${var.region}"
  description = "Custom policy for EKS nodes"
  policy      = file("${path.module}/policies/node-custom.json")

  tags = var.tags
}

#The following policy does not allow delete permission over s3 objects
resource "aws_iam_policy" "s3_access" {
  count = var.mount_point_s3_bucket_name != "" && var.mount_point_s3_bucket_name != null ? 1 : 0

  name        = "custom_s3_access_policy_${var.cluster_name}_${var.region}"
  description = "S3 access policy for mounting s3 bucket to eks"
  policy = templatefile("${path.module}/policies/s3-mount-policy.json", {
    s3_bucket_name = var.mount_point_s3_bucket_name
  })
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
    policy_arn => "arn:aws:iam::aws:policy/${policy_arn}"
  }

  additional_managed_node_policies_map = {
    for policy_arn in var.additional_node_policies :
    split("/", policy_arn)[length(split("/", policy_arn)) - 1] => policy_arn
  }

  s3_access = var.mount_point_s3_bucket_name != "" && var.mount_point_s3_bucket_name != null ? {
    S3access = aws_iam_policy.s3_access[0].arn
  } : {}

  custom_inline = var.additional_node_inline_policy != null ? {
    CustomInline = aws_iam_policy.additional_inline_node_policy[0].arn
  } : {}

  node_policies_map = merge(local.managed_node_policies_map, {
    ELBPermission    = aws_iam_policy.elb_policy.arn
    CustomNodePolicy = aws_iam_policy.custom_node.arn
  }, local.additional_managed_node_policies_map, local.s3_access, local.custom_inline)
}

resource "aws_iam_role" "node_role" {
  name               = "eks_node_${var.cluster_name}_${var.region}"
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


#Grafana role 

resource "aws_iam_role" "grafana" {
  name               = "grafana_${var.cluster_name}_${var.region}"
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