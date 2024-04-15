package tests

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

var tests = []struct {
    vmSize string
    valid bool
}{
    {"Standard_E4s_v5", true},
    {"Standard_G4s_v5", false},
}

func TestVmSizeValidation(t *testing.T) {
    for _, tt := range tests {
        t.Run(tt.vmSize, func(t *testing.T) {
            terraformOptions := &terraform.Options{
                TerraformDir: "../",
                Vars: map[string]interface{}{
                    "vm_size": tt.vmSize,
                },
            }
            _, err := terraform.InitAndPlanE(t, terraformOptions)
            if tt.valid {
                assert.NoError(t, err)
            } else {
                assert.Error(t, err)
            }
        })
    }
}