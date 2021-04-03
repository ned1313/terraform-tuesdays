# We're going to need the root compartment ID
# I assume that the OCI CLI is already installed and you've managed to log in

# PowerShell
oci iam compartment list --query "data[0].\`"compartment-id\`""

# Bash
oci iam compartment list --query "data[0].\"compartment-id\""

# Use the returned value for the variable parent_compartment_id

# We also need the region list
oci iam region list
