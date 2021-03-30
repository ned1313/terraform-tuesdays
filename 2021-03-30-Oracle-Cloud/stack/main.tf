provider "oci" {}

resource "oci_core_instance" "generated_oci_core_instance" {
	agent_config {
		is_management_disabled = "false"
		is_monitoring_disabled = "false"
		plugins_config {
			desired_state = "ENABLED"
			name = "Compute Instance Monitoring"
		}
	}
	availability_config {
		recovery_action = "RESTORE_INSTANCE"
	}
	availability_domain = "xiWQ:US-ASHBURN-AD-2"
	compartment_id = "ocid1.compartment.oc1..aaaaaaaabpeyahikaarslfoirmzgu2gi45nsuzia4n5ldofdfijsdzymycmq"
	create_vnic_details {
		assign_public_ip = "true"
		subnet_id = "ocid1.subnet.oc1.iad.aaaaaaaac5wnvn6xvtwm4r64i75eztc5it3wekv3itidlz5g4qy5bpeunzaa"
	}
	display_name = "instance-20210326-1308"
	instance_options {
		are_legacy_imds_endpoints_disabled = "false"
	}
	metadata = {
		"ssh_authorized_keys" = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDaHgJGzjSXNoxWqPEwarVN/gcpPHyu3LciPZ/IYvJcoSBSlV7tDs32j85WFnElIc20c9OYZs24mmWmfm/B/CwQUOFcx1mokFVmDNLxruYuC4/rmn6UwbAIAZU2eTQeNKrZY4JbD2r2X5RjLh14gVOYnra4siRATbM45yL2dqJCyS9VRDD1IDti5WZzesJNbnsQH6Pn1K6sKK7X/rbcMizxO3+JjcVMgA4v5MH1CCLgFIUH/qajxWD6EyS7OKOAj4jA9C1U+LRngg+8IOq+5uccgB6glzSSz1GuBb/ON23NJTXXRcoUEk3tJ1yv98TTEbU7NySu32a1/+TJ4lcIzFG1 ssh-key-2021-03-26"
	}
	shape = "VM.Standard.E2.1.Micro"
	source_details {
		source_id = "ocid1.image.oc1.iad.aaaaaaaa3lgud4qd5op4euavw7ilyeaie7fiakvs64khlswok4llmcsasmiq"
		source_type = "image"
	}
}
