organization = "taco-workspaces"

workspaces = {
  workspace1 = {
      read_access = ["auditors"]
      write_access = []
      admin_access = ["developers"]
      tags = ["dev", "applications"]
  }
  workspace2 = {
      read_access = ["auditors"]
      write_access = []
      admin_access = ["opsadmins"]
      tags = ["dev", "infrastructure"]
  }
  workspace3 = {
      read_access = ["auditors"]
      write_access = ["developers"]
      admin_access = []
      tags = ["prod", "applications"]
  }
}

teams = {
  developers = []
  opsadmins  = []
  auditors = []
}