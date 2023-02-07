terraform {
  /*backend "remote" {
    organization = "nitc-project-demo"

    workspaces {
      name = "project_example_remote_backend"
    }
  }*/
  
  cloud {
    organization = "nitc-project-demo"

    workspaces {
      name = "project_example_remote_backend"
    }
  }
}