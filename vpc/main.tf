
module "vpc" {

  source = "./modules"

  project_id = "testproject-317120"

  /******************
  VPC Configuration
  ******************/
  network_name = [
    {
      name                 = "vpc-01"
      routing_mode         = "GLOBAL"
      create_subnetworks   = false
      delete_default_route = true
      mtu                  = 0
    },
    {
      name                 = "vpc-03"
      routing_mode         = "GLOBAL"
      create_subnetworks   = false
      delete_default_route = true
      mtu                  = 0
    }
  ]
  /*********************
  Subnet Configuration
  *********************/
  subnets = [
    {
      network_name          = "vpc-01"
      subnet_name           = "vpc-01-subnet-01"
      subnet_ip             = "10.10.10.0/24"
      subnet_region         = "europe-west3"
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
    },
    {
      network_name          = "vpc-01"
      subnet_name           = "vpc-01-subnet-02"
      subnet_ip             = "10.10.20.0/24"
      subnet_region         = "europe-west3"
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
    }
  ]

  secondary_ranges = {
    vpc-01-subnet-01 = [
      {
        range_name    = "vpc-01-subnet-01-secondary-01"
        ip_cidr_range = "192.168.10.0/24"
      },
      {
        range_name    = "vpc-01-subnet-01-secondary-02"
        ip_cidr_range = "192.168.20.0/24"
      }
    ]

    vpc-01-subnet-02 = [
      {
        range_name    = "vpc-01-subnet-01-secondary-01"
        ip_cidr_range = "192.168.30.0/24"
      },
      {
        range_name    = "vpc-01-subnet-01-secondary-02"
        ip_cidr_range = "192.168.40.0/24"
      }
    ]
  }

  /**********************
  Firewall Configuration
  **********************/
  rules = [{
    name                    = "allow-ssh-icmp-ingress-from-iap"
    network_name            = "vpc-01"
    description             = null
    direction               = "INGRESS"
    priority                = null
    ranges                  = ["35.235.240.0/20"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null

    allow = [{
      protocol = "tcp"
      ports    = ["22", 443]
      },
      {
        protocol = "icmp"
        ports    = []
      }
    ]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
    },
    {
      name                    = "deny-all-egress"
      network_name            = "vpc-01"
      description             = null
      direction               = "EGRESS"
      priority                = 65535
      ranges                  = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null

      allow = []

      deny = [{
        protocol = "icmp"
        ports    = []
        }
      ]
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    }
  ]

}