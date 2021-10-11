# Deploying a Flask App to GCP

These files are going to deploy a Flask app to GCP using instance groups and Cloud SQL (MySQL). We are going to put the details for the database connection into a secret and grant the service account associated with the instance group access to read the DB connection info. The instance group will install Python, pip, and all the other requirements to run the application and store the connection information in environment variables.

Here's how to get the GCP values:

```bash
export TF_VAR_org_id=$(gcloud organizations list --format=json | jq .[0].name -r | cut -d'/' -f2)
export TF_VAR_billing_account=$(gcloud beta billing accounts list --format=json | jq .[0].name -r | cut -d'/' -f2)
```

Once you have all your variable values set, standard Terraform workflow applies. You will need to authenticate to Google Cloud using the `gcloud` CLI or with service account credentials. If you want to use your `gcloud` CLI creds, select the configuration you would like to use and then run the following:

```bash
gcloud auth application-default login
```

## Thoughts on automation

One of the problems here is the time it takes for a Google Cloud API to be enabled after the project is created. That's okay at the command line b/c we can just re-run the `terraform apply`. But that doesn't work so great for automation. There's also some trouble on the destroy where the instance group might report as being deleted, but the instances themselves are not fully gone. In those cases, the destroy of the subnet will fail since the instances still have nics on the subnet. That means we have to accomodate both issues in our automation.

### Project provisioning

Since enabling the APIs can take a while, I think it makes sense to move project provisioning to its own directory, and have our automation run the project deployment first and wait two minutes if changes are made. That should be enough for when a new project is created or a new API is enabled. When there are no changes needed for the project, the pipeline can jump ahead to deploying or updating the infrastructure.

### Deployment destruction

The destruction of resources is probably going to fail the first time. The automation should attempt three destructions, separated by 30 seconds, before it finally gives up and reports an error out to the automation workflow.

### GCP load balancing

Load balancing in GCP is hella weird. There is no load balancer, just a collection of other objects that sort of piece together into a load balancer. Fortunately, there is a module to handle this and we're making use of it. If I were trying to piece this together from the Terraform docs, I would probably give up and have a short conversation with a tall bottle.