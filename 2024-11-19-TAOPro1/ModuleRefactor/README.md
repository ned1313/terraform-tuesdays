# Refactoring for a Module

In this example scenario, your challenge is to take the existing configuration that was deployed and refactor it to use modules.

## Scenario

You've recently inherited this configuration from your team. The configuration is already managing real resources in AWS. Your team would like you to refactor the code in to use modules for the EC2 instance and S3 bucket. The change should not disrupt the infrastructure currently being managed by Terraform.

## Setup

Before you begin with this scenario, you'll need to deploy the resources configuration to verify you are not disrupting them. Take the following steps:

1. Authenticate to AWS using your preferred method
1. Change the region set in the provider if desired
1. Initialize and apply the configuration
1. Verify the web page presented by the `public_dns` output works

## EC2 Module

You will create a local module for creating the EC2 instance. Add the folder path `modules/instance` to the root module. The module should contain the following:

* `aws_instance`
* `aws_security_group`

You will need to create input variables to pass information from the root module to the new child module. The following information should be configurable:

* AWS AMI used by the instance
* Subnet ID for instance
* Name of the instance
* Port to allow for security group
* Instance type
* User data contents

Your module also needs to pass back the public DNS of the instance as an output.

Remember that the modifications should not destroy or modify the existing EC2 instance or security group.

## S3 Module

You will use a module from the public registry to replace the S3 bucket resources defined in the configuration.

The module to use can be found here: [https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/4.2.2](https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/4.2.2)

For consistent results, use this exact version of the module in your configuration.

The current configuration should leverage the module to replace the following resources:

* `aws_s3_bucket`
* `aws_s3_bucket_ownership_controls`
* `aws_s3_bucket_acl`

Use the outputs of the module to update the `bucket_name` output of the root module.

It is OK to replace or update the `aws_s3_bucket_ownership_controls` and `aws_s3_bucket_acl` resources, as long as the S3 bucket itself is not destroyed and the output for the bucket name does not change.

## Solution

Before checking the solution in the solution folder, try to make the modifications yourself. If you are stumped, you can check the solution files first.

Here are some helpful hints:

* Use the `moved` block or `terraform state mv` commands to avoid replacing resources
* Consider what input variables your module should have, are there any safe defaults?
* Try to keep your module generalized, don't make too many assumptions!
* The instance module will need at least one output defined
* The S3 bucket module uses a count meta-argument, what does that do to the address?

Please note that the actual solution is not the only possible solution. As long as you have met the requirements, you have a valid solution.

## Cleanup

Be sure to use `terraform destroy` after you're done to avoid incurring charges in AWS.