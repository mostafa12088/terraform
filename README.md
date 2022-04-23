# Creating Bold using Triple Start (***)
**terraform**

# Creating Italic using 'Underscore' Sign
_This is a terraform readme file for **VPC**_. 

# Variables
>All the variables are defined here.
___
# Creating Bullet Points
- This is a bullet point
* this is also a bullet point
___

# Putting the codes in md file using tilda sign
Below is a sample terraform code snippet:
~~~ terraform

resource "google_compute_network" "network" {
  for_each                        = local.vpc
  project                         = var.project_id
  name                            = each.value.name
  routing_mode                    = each.value.routing_mode
  auto_create_subnetworks         = each.value.create_subnetworks
  delete_default_routes_on_create = each.value.delete_default_route
  mtu                             = each.value.mtu
}
~~~
---

# Creating links for text using text in Third Brucket [] and desired Link in First Brucket ()
[Shard-VPC](https://cloud.google.com/vpc/docs/shared-vpc)

# Linking Image using Exclamatory(!) Sign
![Test_image](https://github.com/mostafa12088/terraform/blob/main/Screenshot%202022-04-11%20at%2015.04.18.png)

### Some text
---