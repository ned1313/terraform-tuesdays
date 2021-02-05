data "external" "example" {
  program = ["powershell.exe", "./program.ps1"]

  query = {
    # arbitrary map from strings to strings, passed
    # to the external program as the data query.
    name = "Ned"
  }
}

output "result" {
    value = data.external.example.result["Message"]
}