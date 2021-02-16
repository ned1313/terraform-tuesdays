# Let's create some local values of different object types
locals {
  mystring = "taco"
  mylist = ["chicken","beef","fish"]
  myset = toset(local.mylist)
  mymap = {
      meat = "chicken"
      cheese = "jack"
      shell = "soft"
  }
}