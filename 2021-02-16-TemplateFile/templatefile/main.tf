output "template" {
  value = templatefile("${path.module}/test.tmpl",
  {
    "mystring" = local.mystring
    "mylist"  = local.mylist
    "mymap" = local.mymap
    "myset" = local.myset
  })
}