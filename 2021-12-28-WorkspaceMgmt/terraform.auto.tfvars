organization = "globomantics-test"

workspaces = {
  workspace1 = ["dev", "applications"]
  workspace2 = ["dev", "infrastructure"]
  workspace3 = ["prod", "applications"]
}

teams = {
  developers = []
  opsadmins  = []
}

tags = {
  dev = {
    developers = "read"
    opsadmins  = "read"
  }
  applications = {
    developers = "read"
  }
  prod = {
    developers = "read"
    opsadmins  = "admin"
  }
  infrastructure = {
    opsadmins = "read"
  }
}