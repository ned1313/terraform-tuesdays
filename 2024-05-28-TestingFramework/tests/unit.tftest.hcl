# Test different inputs for the storage account
run "sa_test_1" {
  command = plan

  variables {
    website_name = "TestWebsiteName"
  }

  assert {
    condition     = can(regex("testwebsitenamedata\\d{3}$", local.storage_account_name))
    error_message = "${var.website_name} did not render properly. Received ${local.storage_account_name}."
  }
}



run "sa_test_2" {
  command = plan

  variables {
    website_name = "ALLCAPS"
  }

  assert {
    condition     = can(regex("allcapsaregreatdata\\d{3}$", local.storage_account_name))
    error_message = "${var.website_name} did not render properly. Received ${local.storage_account_name}."
  }
}

run "sa_test_3" {
  command = plan

  variables {
    website_name = "S_p-e(c)i.a_l"
  }

  assert {
    condition     = can(regex("specialdata\\d{3}$", local.storage_account_name))
    error_message = "${var.website_name} did not render properly. Received ${local.storage_account_name}."
  }
}


run "sa_test_4" {
  command = plan

  variables {
    website_name = "ThisIsAReallyLong"
  }

  expect_failures = [
    var.website_name,
  ]
}

