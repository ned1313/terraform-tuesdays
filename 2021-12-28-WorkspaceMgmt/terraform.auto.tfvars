organization = "globomantics-test"

workspaces = {
  workspace1 = ["dev", "applications"]
  workspace2 = ["dev", "infrastructure"]
  workspace3 = ["prod", "applications"]
  workspace4 = ["prod","infrastructure"]
}

teams = {
  developers = []
  opsadmins  = []
  auditors = []
}

tags = {
  dev = {
    developers = "read"
    opsadmins  = "read"
    auditors = "read"
  }
  applications = {
    developers = "read"
  }
  prod = {
    developers = "read"
    opsadmins  = "admin"
    auditors = "read"
  }
  infrastructure = {
    opsadmins = "read"
  }
}