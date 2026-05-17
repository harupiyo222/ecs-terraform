# ECS - Terraform

## 概要

TerraformでAWS上にコンテナアプリケーションの本番想定インフラをコード化。
CloudFront + ALB + ECS Fargate + RDSの構成をマルチAZ・3層サブネットで実装。

【AWS】
IAM | Route 53 | Certificate Manager | RDS(MySQL) |
Systems Manager（Parameter Store） | CloudFront |
S3 | ALB | ECR | ECS | Fargate | CloudWatch

【IaC】
Terraform

【OS】
Linux(Amazon Linux)

【DB】
MySQL

## 特徴

- マルチAZ冗長構成（ap-northeast-1a / 1c）
- サブネットを3層（Public / Protected / Private）に分離
- ALBでトラフィック分散
- Fargate Spotでコスト削減
- Auto Scaling（CPU使用率70%でスケールアウト）
- CloudFront + S3でパスごとにALBとS3に振り分ける
- RDSパスワードをSSM Parameter Storeで管理
- Terraformリモートステート — S3バックエンドでtfstateを管理（チーム開発・CI/CD対応）

# 構成図

![システム構成図](./構成図.png)

## アーキテクチャ概要

```
Internet
    ↓
Route53 (ドメイン)
    ↓
CloudFront (HTTPS / CDN)
    ├── /* ───────────────────────────────────────── S3 (frontend SPA)
    └── /api/* ──→ ALB (backend API)
                │
                │  VPC (10.0.0.0/21)
                ├─────────────────────────────────────────────┐
                │  Public Subnet (10.0.1.0/24 / 10.0.2.0/24) │
                │  ALB・NAT Gateway                           │
                ├─────────────────────────────────────────────┤
                │  Protected Subnet (10.0.3.0/24 / 10.0.4.0) │
                │  ECS Task 1a (Fargate Spot)  │  ECS Task 1c │
                ├─────────────────────────────────────────────┤
                │  Private Subnet (10.0.5.0/24 / 10.0.6.0)   │
                │  RDS Mysql (db.t3.micro / Single-AZ) ※本番想定の場合はMulti-AZ推奨  │
                └─────────────────────────────────────────────┘

SSM Parameter Store → RDS Credentials
```

## ファイル構成

```
ecs-terraform/
├── main.tf             # Terraform provider・locals
├── variables.tf        # 変数定義
├── terraform.tfvars    # 変数値
├── network.tf          # VPC・Subnet・Route Table
├── security_groups.tf  # Security Group (ALB / ECS / RDS)
├── alb.tf              # Application Load Balancer
├── ecs.tf              # ECS Cluster・Service・Task Definition
├── iam.tf              # IAM Role・Policy
├── auto_scaling.tf     # Auto Scaling
├── rds.tf              # RDS・DB Subnet Group・SSM Parameter Store
├── acm.tf              # ACM Certificate (us-east-1)
├── route53.tf          # Route53 DNS Records
├── cloudfront.tf       # CloudFront Distribution
├── s3.tf               # S3 Bucket (Static Assets)
├── backend.tf          # Terraform リモートステート (S3)
└── README.md
```

## AWS コスト見積もり（月額目安）

| サービス            |   月額（目安） | 備考                                    |
| ------------------- | -------------: | --------------------------------------- |
| ECS Fargate         |        ~$11.09 | Fargate Spot使用で約70%削減可能         |
| ECR                 |         ~$0.50 | ストレージ $0.10/GB・転送 $0.09/GB      |
| RDS                 |        ~$18.72 | db.t3.micro・MySQL 8.0                  |
| NAT Gateway         |        ~$44.64 | データ転送量による変動あり              |
| ALB                 |        ~$28.30 | LCU使用量による変動あり                 |
| CloudFront          |             $0 | 月1TB・1,000万リクエストまで無料枠      |
| S3                  |     ~$0.03以下 | tfstate保存・静的アセット配信           |
| SSM Parameter Store |             $0 | 標準パラメータは無料                    |
| Route 53            |          $0.50 | ホストゾーン1つ                         |
| ACM                 |             $0 | AWS管理サービスと組み合わせる場合は無料 |
| **合計**            | **~$107 / 月** |                                         |
