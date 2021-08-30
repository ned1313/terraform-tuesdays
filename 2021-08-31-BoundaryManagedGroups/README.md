# Configuring Managed Groups with Azure AD and Boundary

Back in June we took a look at how you can set up OIDC for Boundary using Azure AD as the authentication provider. Since that time Boundary has added the ability to create managed groups based on claims from the OIDC provider. This means that you can use the group membership (or other claims) of a user in Azure AD to control their permissions in Boundary. Pretty neat huh?

In this demo we are going to get a dev instance of Boundary running, and then use Terraform to provision the necessary resources in Azure AD and Boundary to set up managed groups and OIDC authentication. **Bonus**: we'll use the newly released 2.0 version of the Azure AD provider, in which I have already found a bug!

## Azure AD stuff

To set up OIDC authentication in Azure, we need to create a service principal and application in Azure AD. When creating the application, we will give it permissions to read information about users and groups in our Azure AD tenant. We'll also create an Azure AD group called Boundary Admins and add ourselves to the group.

The permissions we give to the Azure AD application are actually just requests for permissions, so we will have to run an Azure CLI command after Terraform is done to grant the requests.

## Boundary stuff

On the Boundary side, we will create an organzation and and OIDC authentication method to associate with the organization. Then we will create a managed group refering to the Boundary Admins group in Azure AD and grant the managed group admin permissions on the new organization through a role.

## Following along

You'll need Docker, Boundary, and Terraform installed. You'll also need an Azure AD tenant with permissions to create applications, service principals, and groups. Assuming you've got all those bases covered, then all you need to do is run the commands in `commands.sh`.