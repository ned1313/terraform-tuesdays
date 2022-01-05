terraform {
    cloud {
        organization = "taconet"
        workspaces {
            name = "shared-services-prod"
        }
    }
}