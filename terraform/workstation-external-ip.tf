# workstation-external-ip.tf
# local PC 공인ip 주소를 확인하고 입력한다고 보면 된다.
data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}

locals {
  workstation-external-cidr = "${chomp(data.http.workstation-external-ip.body)}/32"
}