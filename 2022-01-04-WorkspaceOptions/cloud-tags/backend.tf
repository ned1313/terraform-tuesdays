terraform {
    cloud {
        organization = "taconet"
        workspaces {
            tags = ["security","cloud:aws"]
        }
    }
}