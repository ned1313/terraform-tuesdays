# Create a random integer for website naming

run "random_int_apply" {
    module {
        source = "./tests/setup"
    }
}

# Verify website works
run "execute" {
  variables {
    website_name = "Test${run.random_int_apply.integer}"
  }
}

run "check_site" {
  command = apply

  variables {
    website_url = run.execute.homepage_url
  }

  module {
    source = "./tests/loader"
  }

  assert {
    condition     = data.http.main.status_code == 200
    error_message = "Website ${run.execute.homepage_url} returned the status code ${data.http.main.status_code}. Expected 200."
  }
}