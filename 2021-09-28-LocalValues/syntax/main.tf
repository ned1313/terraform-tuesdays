locals {
  shell = ["crunchy", "soft"]
  tags = {
    number = 42
    item   = "towel"
    planet = "Earth"
    poetry = "Vogon"
  }
  meaning_of_life = "What is 6 x 7? ${local.tags["number"]}"
}