data "http" "my_ip" {
  url = "http://ifconfig.me"
}

output "my_ip" {
    value = data.http.my_ip.body
}

output "response_header" {
    value = data.http.my_ip.response_headers
}

output "response_date" {
    value = data.http.my_ip.response_headers["Date"]
}
