terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2"
    }
  }
}

locals {
  yaml_data = yamldecode(file("${path.module}/data.yaml"))
}
output "yaml_users" {
  value = local.yaml_data.users
}
output "admin_users" {
  value = [for user in local.yaml_data.users : user.name if user.role == "admin"]
}

locals {
  json_data = jsondecode(file("${path.module}/data.json"))
}

output "server_names" {
  value = [for server in local.json_data.servers : server.name]
}

locals {
  csv_data = csvdecode(file("${path.module}/data.csv"))
}

output "csv_parsed" {
  value = local.csv_data
}

output "server_types" {
  value = { for entry in local.csv_data : entry.name => entry.type }
}

locals {
  server_info = [
    { name = "web1", type = "t2.micro", region = "us-west-1" },
    { name = "db1", type = "t3.medium", region = "us-east-1" },
    { name = "app1", type = "t2.micro", region = "us-west-1" },
    { name = "app2", type = "t2.micro", region = "us-west-1" },
    { name = "db2", type = "t3.medium", region = "us-east-1" },
  ]

  server_regions = distinct([for server in local.server_info : server.region])

  server_name_by_region = { for region in local.server_regions : region => [
    for server in local.server_info : server.name if server.region == region]
  }
}

output "server_regions" {
  value = distinct([for server in local.server_info : server.region])
}

output "us_west_servers" {
  value = [for server in local.server_info : server.name if server.region == "us-west-1"]
}

locals {
  org = yamldecode(file("${path.module}/employees.yaml"))

  over_50k = [for employee in local.org.employees : employee.name if employee.salary > 50000]

  departments = distinct([for employee in local.org.employees : employee.department])

  employees_by_department = { for department in local.departments : department => [
    for employee in local.org.employees : employee.name if employee.department == department]
  }

  department_count = { for department in local.departments : department => length(local.employees_by_department[department]) }
}

locals {
  server_list = [
    {
      name   = "web1"
      type   = "t2.micro"
      region = "us-west-1"
      disks = {
        disk1 = {
          size = 100
          type = "ssd"
        }
        disk2 = {
          size = 50
          type = "hdd"
        }
      }

    },
    {
      name   = "db1"
      type   = "t3.medium"
      region = "us-east-1"
      disks = {
        disk1 = {
          size = 200
          type = "ssd"
        }
        disk2 = {
          size = 100
          type = "ssd"
        }
      }
    },
    {
      name   = "app1"
      type   = "t2.micro"
      region = "us-west-1"
      disks = {
        disk1 = {
          size = 100
          type = "ssd"
        }
      }
    },
    {
      name   = "app2"
      type   = "t2.micro"
      region = "us-west-1"
      disks = {
        disk1 = {
          size = 100
          type = "ssd"
        }
      }
    },
    {
      name   = "db2"
      type   = "t3.medium"
      region = "us-east-1"
      disks = {
        disk1 = {
          size = 200
          type = "ssd"
        }
        disk2 = {
          size = 100
          type = "ssd"
        }
      }
    }
  ]
}