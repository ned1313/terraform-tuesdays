# Ephemeral Values and Write Only Arguments

Ephemeral resources were introduced in Terraform 1.10, but they were missing a key component. Write-only arguments are a new feature in Terraform 1.11, and they help to complete the goals of ephemeral resources.

## Ephemeral Values

I've already done a whole video on what ephemeral values are and how they work, check it out in the doobly doo, but allow me to summarize it here as well. Ephemeral values were created to help address the issue of sensitive values being stored in state and plan files. State data holds the attribute values of all data sources and resources, and some of those attributes might be sensitive data you'd rather not appear in state.

An additional concern is sensitive information found in saved Terraform plan files. Plan files not only contain the entirety of the configuration, but also the planned changes and variable values used to create the plan.

Values that are marked as ephemeral will never be persisted in state or in a plan file. The value is accessed and stored in memory for the period during which it is needed, and then it is flushed. You can get ephemeral values from input variables, output values, or ephemeral resources. Input variables and output values can be marked as ephemeral by setting the ephemeral argument to true. Ephemeral resources are a distinct block type and must be implemented by a provider.

## Use Cases

So how can you use ephemeral values? When the feature was released in 1.10, the primary use cases were for provider settings and provisioner credentials. That's because the values used for providers and provisioners are not persisted in the plan file or in state. What about resources arguments though? By default, all resource arguments are recorded in the plan and state, so you could not use ephemeral values, that is until the introduction of write-only arguments.

## Write-Only Arguments

Write-only arguments are a special type of resources argument that is not persisted in state and not written to the plan file. You can write a new value to the resource, but you cannot retrieve the current value through state data. Now you can't simply mark any argument in a resource as write-only, instead a new argument needs to be added to the resource type in the provider to support the write-only functionality.

For example, version 4.34.0 of the AzureRM provider includes a write only arguments for the value of a Key Vault Secret, and a write-only password argument for several database related resources like azurerm_mssql_server. As new releases of the provider roll out, additional resources will have write-only arguments added to them.

You might be wondering, if Terraform doesn't know the value of the write-only argument, how does it know when that value changes? The answer is that along with the new write only argument is a version argument to signal to Terraform that the current value should be overwritten. For instance, in the `azurerm_mssql_server` resource, the write-only password argument is called `administrator_login_password_wo` and the version argument is called `administrator_login_password_wo_version`. That seems to be the pattern for all write-only arguments I've seen. The write-only argument ends in _wo and the corresponding version argument adds _version to the end.

## Examples

Why don't we walk through a few examples so you can see these write-only arguments in action. I'll start with Azure Key Vault.

In this example I'm deploying an Azure key vault, and then I've got two different instances of a key vault secret. The first sets the value of the secret using the input variable db password regular. The second one is a little different, instead of setting the value argument, instead I'm using the value_wo argument. When you use that argument, you also have to include the vault_wo_version argument. Both of those are set using the single input variable db_password_ephemeral, which if I jump over to the variables.tf is an object with two keys, the value and the version.

In the terraform.tfvars, I am setting both password values the same, and using 1 for the version of the password. Now let's deploy this and check out the contents of state.

I'll pull up the terminal and run a terraform apply with auto-approve. While that is provisioning, I want to point out that normally you wouldn't pass a secret with a terraform.tfvars file. That kind of defeats the purpose. So this is for demonstration purposes only.

Okay, the deployment completed, so let's take a look at the state data. If I simply run terraform show, the output will include both key vault secrets, but the stored value is redacted since it's sensitive. However, I'm going to open the state file directly and look for the normal password. Under its entry, sure enough the value field has our password. But if I scroll down to the write-only secret, the value field is null and the version field is set to 1.

Using the write only argument means the secret value isn't in my state. Neat! Now what if I wanted to update the secret. I'll change the value for the write-only secret, and then I'll run a terraform plan. Because I didn't change the value of the version, terraform has no way of knowing that the value of the secret should be updated. And sure enough, we get back a plan with no changes. Now I will update the version to 2, and run a new plan. Since the version has changed, now terraform knows it needs to update the value as well, and the plan we get back has one to change.

So that's how we might get a secret value into key vault without storing it in state data. What about using the secret? That's where ephemeral resources come into play.

In the directory mssql_server, I have an ephemeral block here for a key vault secret. The syntax of the block is exactly the same as the key vault secret data source, but there's a key distinction. A key vault data source would store the value in state data, but the ephemeral resource won't.

To use this ephemeral resource, I have an azure mssql server using the argument administrator_login_password_wo and wo_version. Just like when we created the key vault secret, we need to include a version here so terraform knows if it needs to update the login password, since that value isn't stored in state.

Let's see what happens when I run a plan. Let me kick off the plan, and then we can look at what terraform is doing during the plan. For the inputs to the configuration, I created an input variable that includes the vault id, secret name, and version number, which just happens to be the outputs from the previous configuration. Tres convenient no?

Okay, in the plan Terraform opens the contents of the ephemeral resource in memory. Then it uses that information with the mssql server object, and once the plan is complete, the ephemeral resource is closed. Terraform will do the same thing during apply, accessing the ephemeral resource, using the value for creation, and closing the resource.

Feel free to deploy this configuration yourself if you want to see the resulting state data.

## Unsupported Resources

The addition of write-only arguments is absolutely fantastic and I'm excited to see more resource types implement them. But what if the resource type you want to manage isn't supported? There is a solution! The AzAPI provider.

First I want to thank fellow HashiCorp Ambassador Stu Mace for bringing this to my attention. He wrote a blog post about it, that I highly recommend. Essentially, the AzApi provider has added a sensitive_body section to the azapi_resource and azapi_update_resources. If you want to have a property of a resource be treated as write-only, you simply have to move it to the sensitive_body section instead of the regular body section.

Let's take a look at Stu's example. In this configurition we're wiring up a container group to a log analytics workbook and we need the shared key of the workbook to do so.

The azapi provider now has the ephemeral resource azapi_resource_action, which you can use to retrieve sensitive values, which is what we're doing here with the primary and secondary shared keys.

Down in the azapi_resource for the container group, there is a sensitive body section that includes the nested property log analytics workspace key and it is set to the value of the primary key from the ephemeral resource action.

Let's kick off the deployment to show that the contents of the sensitive body aren't written to state. There's a couple nice things about this approach. First off, any property could become write-only without needing an update to the provider to support it. Second, there's no write-only version number you have to keep track of. Which is nice. The downside is now you have to use the azapi provider for that resource.

Okay now that the deployment is complete, we can search for the sensitive body in state and its set to null. Now let's change the configuration to use the secondary key instead. After I make that change, I'll run a terraform plan, and after a few moments it tell me that it needs to update the container group in place, but it doesn't actually tell me the exact property that caused the modification. How does it even know there was a change?

Going back to the state data, there's a private value here, which is pretty clearly a hash. That hash is calculated based on the last contents of the sensitive_body. So if the contents change, terraform knows that it needs to modify the resource. However, it doesn't know which property changed, so it can't tell you that.

So again, the nice thing is that you don't have to track the version of each sensitive value. But the downside is that you can't tell from the plan which value actually changed. Probably not a big deal, but I did want to point it out.

## Conclusion

The introduction of write-only arguments closes the loop on the ideas first introduced with ephemeral values in Terraform 1.10. Between write-only arguments in azurerm resources and the sensitive_body in azapi resources, you can now keep your secrets out of Terraform state entirely. And I think that's a good thing!

But I'm curious what you think. Are you going to start using ephemeral resources and write-only arguments, or is the juice not worth the squeeze. Let me know in the comments or hit me up on LinkedIn. Until next time, keep calm and Terraform on!