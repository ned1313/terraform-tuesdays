# The pipeline needs a service principal to use for an AzureRM service connection

# You also need a service principal to use for creating resources in an AzureRM sub

# I don't think those should be the same SP. The KV might be in a different sub than the place
# you want to create resources. So we'll create two SPs.

# Create SP for service connection in pipeline. Will be used to access KV.

# Create SP for creation of Azure resources in selected subscription.
# These credentials will be written to the Key Vault and retrieved during pipeline run

