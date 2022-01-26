locals {
  users = [
      {
          name = "Arthur Dent"
          display_name = "Arthur"
          employee_id = "52"
      },
      {
          name = "Ford Prefect"
          display_name = "Ford"
          employee_id = "101010"
      },
      {
          name = "Tricia McMillan"
          display_name = "Trillian"
          employee_id = "42"
      }
  ]

  groups = {
      admins = ["Arthur"]
      developers = ["Tricia","Ford"]
      managers = ["Ford"]
  }
}