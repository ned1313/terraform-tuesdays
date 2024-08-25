module "session" {
  source  = "HashiConf2024/sessions/template"
  version = "0.1.0"

  session_name = "modules-best-practices"
  speaker_name = "Ned"
  shirt        = "burritos"
  mug          = true
  dog          = false
}