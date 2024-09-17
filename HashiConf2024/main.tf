module "session" {
  source = "./HashiConf2024/sessions"

  session_name = "modules-best-practices"
  speaker_name = "Ned Bellavance"
  shirt        = "tacos"
  mug          = true
  dog          = false
}