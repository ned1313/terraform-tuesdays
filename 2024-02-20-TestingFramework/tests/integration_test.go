package tests

import (
	"fmt"
	"testing"
	"math/rand"
	"crypto/tls"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformHttpExample(t *testing.T) {
	t.Parallel()

	// A unique ID to use for the website name
	uniqueID := rand.Intn(100) + 100

	// Create website name value
	websiteName := fmt.Sprintf("testingsite%d", uniqueID)

	// Construct the terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"website_name":    websiteName,
		},
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	instanceURL := terraform.Output(t, terraformOptions, "homepage_url")

	// Setup a TLS configuration to submit with the helper, a blank struct is acceptable
	tlsConfig := tls.Config{}

	// Verify that we get back a 200 OK with the expected instanceText
	http_helper.HttpGet(t, instanceURL, &tlsConfig)
}