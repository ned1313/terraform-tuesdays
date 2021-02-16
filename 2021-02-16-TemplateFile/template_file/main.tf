# Let's try and render the test template using the template_file data source
data "template_file" "test" {
  template = file("test.tmpl")
  vars = {
    "mystring" = local.mystring
    #"mylist"  = local.mylist # This won't work b/c it's not a string
    "mylist" = join(",", local.mylist)
    # We also cannot pass a map for the same reason
    # First we can get the keys
    "mapkeys" = join(",", keys(local.mymap))
    "mapvalues" = join(",", values(local.mymap))

    # Let's try my set
    "myset" = join(",",local.myset)
  }
}

output "template" {
  value = data.template_file.test.rendered
}