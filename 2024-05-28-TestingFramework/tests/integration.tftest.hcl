# Create a random integer for website naming

# Verify website works
run "execute" {
  command = apply

  variables {
    website_name = "Test${substr(uuid(),0,5)}"
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