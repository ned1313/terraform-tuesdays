terraform {
    backend "remote" {
        hostname = "app.terraform.io"
        organization = "taconet"
        workspaces {
            name = "networking-useast1-dev"
        }
    }
}