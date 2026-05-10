# ECS - Terraform

AWS上でのコンテナアプリケーション構成をTerraform でコード化したものです。

- Terraform tfstate — S3でtfstateを管理
- フラットな単一ディレクトリ構成で全リソースを管理（学習・把握しやすさを優先）

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
                │  RDS Mysql (db.t3.micro)               │
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
└── vpc_endpoints.tf    # VPC エンドポイント (ECR / S3 / CloudWatch Logs)
└── README.md
```

## コスト計算

- Route 53: 0.50ドル
- ALB: 28.30ドル
- Fargate: 11.09ドル ※Spotで7割引可
- NAT Gateway: 48.24ドル
- RDS: 18.72ドル
- VPC Endpoints: ~43.80ドル ※Interface型3つ × 2AZ × $0.01/時間
- CloudWatch Logs: ~1〜2ドル ※ログ取り込み量による（7日保持）
- S3: ~0.03ドル以下 ※静的アセット保存
- CloudFront: 無料枠内なら0ドル ※月1TB・1000万リクエストまで無料
- SSM Parameter Store: 0ドル ※標準パラメータは無料

## 特徴

- マルチAZ冗長構成（ap-northeast-1a / 1c）
- サブネットを3層（Public / Protected / Private）に分離
- ALBでトラフィック分散
- Fargate Spotでコスト削減
- Auto Scaling（CPU使用率70%でスケールアウト）
- CloudFront + S3でパスごとにALBとS3に振り分ける
- RDSパスワードをSSM Parameter Storeで管理
- VPCエンドポイント — ECSからECR・S3・CloudWatch LogsへNAT非経由でアクセス（コスト削減・セキュリティ向上）
- Terraformリモートステート — S3バックエンドでtfstateを管理（チーム開発・CI/CD対応）
