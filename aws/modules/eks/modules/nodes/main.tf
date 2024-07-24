resource "aws_eks_node_group" "managed_nodes" {

  cluster_name  = var.cluster_name
  node_role_arn = var.node_role_arn
  subnet_ids    = var.subnet_ids

  scaling_config {
    min_size     = var.min_size
    max_size     = var.max_size
    desired_size = var.desired_size
  }

  node_group_name = var.name

  capacity_type        = "ON_DEMAND"
  disk_size            = null
  force_update_version = true
  instance_types       = var.instance_types
  labels               = merge(var.labels, { "name" = "${var.name}" })

  dynamic "launch_template" {
    # dynamic block helps appends to launch templates list if any change is made to the
    # node group configuration and help in rollback the older versions if required and set the 
    # new template as default
    for_each = true ? [1] : []

    content {
      id      = aws_launch_template.this.id
      version = aws_launch_template.this.default_version
    }
  }


  update_config {
    max_unavailable_percentage = 34
  }

  lifecycle {
    create_before_destroy = false
  }

  tags = merge(
    var.tags,
    { Name = var.name }
  )
}

resource "aws_launch_template" "this" {

  name_prefix = "${var.name}-eks-node-group-"

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings

    content {
      device_name = try(block_device_mappings.value.device_name, null)

      dynamic "ebs" {
        for_each = try([block_device_mappings.value.ebs], [])

        content {
          delete_on_termination = try(ebs.value.delete_on_termination, null)
          encrypted             = try(ebs.value.encrypted, null)
          iops                  = try(ebs.value.iops, null)
          kms_key_id            = try(ebs.value.kms_key_id, null)
          snapshot_id           = try(ebs.value.snapshot_id, null)
          throughput            = try(ebs.value.throughput, null)
          volume_size           = try(ebs.value.volume_size, null)
          volume_type           = try(ebs.value.volume_type, null)
        }
      }

    }
  }

  metadata_options {
    http_tokens = "required"
  }

  key_name      = var.ssh_key
  ebs_optimized = true

  monitoring {
    enabled = true
  }

  dynamic "tag_specifications" {
    for_each = toset(var.tag_specifications)

    content {
      resource_type = tag_specifications.key
      tags          = merge({ Name = var.name })
    }
  }

  update_default_version = true
  vpc_security_group_ids = compact(concat([var.primary_security_group_id], var.node_security_group_id))

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }

}