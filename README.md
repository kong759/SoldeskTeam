# SoldeskTeam
프로젝트 협업 레포지터리

조장: 강성원
조원: 손형진, 김경묵, 김민준


목표: Terraform 을 활용한 MSA 웹서비스 인프라 구현 및 CICD 체계 구현
	
개요: Terraform 으로 VPC 구성 및 Route53, ALB, Fargate on EKS , RDS 등을 구성하고, CodeSeries 로 도커 이미지를 EKS 에 자동 배포
	
	
예상 필요 사항	
	* ALB 로 웹서비스 로드 밸런스 구현
	* 도커로 이미지를 각각 제작 
	   - 프론트엔드 : Apache 서버 이미지로 구현
	   - 백엔드 : Tomcat 서버 이미지로 구현, RDS 서버 구현 
	* 인프라는 Kubernetes로 Fagate on EKS 를 활용한 오케스트레이션 구현
	* AutoScailing 을 활용한 고가용성 체계 구현
	* AWS 플랫 폼에서 진행 
	* 도커 이미지는 ECR에 보관하며, CodeCommit,Codebuild, CodePipeline 을 사용하여 CI/CD 체계 구현

	   
