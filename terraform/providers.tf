# providers.tf
#프로바이더는 서비스 제공자라고 할수 있다. 
#테라폼은 멀티 플랫폼 서비스를 지원하므로 프로바이더를 선택하여 인프라를 구축 할 수 있으며 현 프로젝트는 AWS로 진행.
provider "aws" {
  region = "us-east-2"
  access_key = "AKIAQIRZSFDXULE7JU5H"
  secret_key = "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"
}

provider "http" {}