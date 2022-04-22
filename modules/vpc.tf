
/******************
 VPC Configuration
 *****************/
locals {
  vpc = {
    for x in var.network_name :
    "${x.name}" => x
  }
}

resource "google_compute_network" "network" {
  for_each                        = local.vpc
  project                         = var.project_id
  name                            = each.value.name
  routing_mode                    = each.value.routing_mode
  auto_create_subnetworks         = each.value.create_subnetworks
  delete_default_routes_on_create = each.value.delete_default_route
  mtu                             = each.value.mtu
}

/*********************
 Subnet Configuration
 *********************/
locals {
  subnets = {
    for x in var.subnets :
    "${x.subnet_name}" => x
  }
}

resource "google_compute_subnetwork" "subnetwork" {
  for_each                 = local.subnets
  name                     = each.value.subnet_name
  ip_cidr_range            = each.value.subnet_ip
  region                   = each.value.subnet_region
  private_ip_google_access = lookup(each.value, "subnet_private_access", "true")
  dynamic "log_config" {
    for_each = lookup(each.value, "subnet_flow_logs", false) ? [{
      aggregation_interval = lookup(each.value, "subnet_flow_logs_interval", "INTERVAL_5_SEC")
      flow_sampling        = lookup(each.value, "subnet_flow_logs_sampling", "0.5")
      metadata             = lookup(each.value, "subnet_flow_logs_metadata", "INCLUDE_ALL_METADATA")
    }] : []
    content {
      aggregation_interval = log_config.value.aggregation_interval
      flow_sampling        = log_config.value.flow_sampling
      metadata             = log_config.value.metadata
    }
  }
  network     = google_compute_network.network[each.value.network_name].name
  project     = var.project_id
  description = lookup(each.value, "description", null)
  secondary_ip_range = [
    for i in range(
      length(
        contains(
        keys(var.secondary_ranges), each.value.subnet_name) == true
        ? var.secondary_ranges[each.value.subnet_name]
        : []
    )) :
    var.secondary_ranges[each.value.subnet_name][i]
  ]
}

/**********************
 Firewall Configuration
 **********************/
resource "google_compute_firewall" "rules" {
  for_each    = { for x in var.rules : x.name => x }
  depends_on  = [google_compute_network.network]
  name        = each.value.name
  description = each.value.description
  direction   = each.value.direction
  network                 = google_compute_network.network[each.value.network_name].name
  project                 = var.project_id
  source_ranges           = each.value.direction == "INGRESS" ? each.value.ranges : null
  destination_ranges      = each.value.direction == "EGRESS" ? each.value.ranges : null
  source_tags             = each.value.source_tags
  source_service_accounts = each.value.source_service_accounts
  target_tags             = each.value.target_tags
  target_service_accounts = each.value.target_service_accounts
  priority                = each.value.priority

  dynamic "log_config" {
    for_each = lookup(each.value, "log_config") == null ? [] : [each.value.log_config]
    content {
      metadata = log_config.value.metadata
    }
  }

  dynamic "allow" {
    for_each = lookup(each.value, "allow", [])
    content {
      protocol = allow.value.protocol
      ports    = lookup(allow.value, "ports", null)
    }
  }

  dynamic "deny" {
    for_each = lookup(each.value, "deny", [])
    content {
      protocol = deny.value.protocol
      ports    = lookup(deny.value, "ports", null)
    }
  }
}