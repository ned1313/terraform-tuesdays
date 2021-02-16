output "template" {
  value = templatefile("test.tmpl",
  {
    "mystring" = local.mystring
    "mylist"  = local.mylist
    "mymap" = local.mymap
    "myset" = local.myset
  })
}