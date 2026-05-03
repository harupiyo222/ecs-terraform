# ECS 冗長化構成 - Terraform

AWS 上で ECSを冗長化する構成を Terraform でコード化したものです。
実際の現場ではmodule化して環境ごとに使い分けているようですが、個人開発レベルなので単一のディレクトリにしています。

## 📐 アーキテクチャ概要

```
インターネット
    ↓
ALB（Application Load Balancer）
    ├─ api-subnet-01（AZ1）
    │   └─ ECS Task: api-server-01
    └─ api-subnet-02（AZ2）
        └─ ECS Task: api-server-02
            ↓
        ECR（コンテナレジストリ）
```

## 📁 ファイル構成

```
ecs-terraform/
├── main.tf                 # Terraform プロバイダ設定
├── variables.tf            # 変数定義
├── terraform.tfvars        # 変数値（環境別設定）
├── outputs.tf              # 出力値
├── vpc.tf                  # VPC・ネットワーク構成
├── security_groups.tf      # セキュリティグループ
├── alb.tf                  # Application Load Balancer
├── iam.tf                  # IAM ロール・ポリシー
├── ecs.tf                  # ECS クラスタ・サービス・タスク定義
├── auto_scaling.tf         # Auto Scaling ポリシー
└── README.md               # このファイル
```

**特徴：**

- ✅ マルチ AZ 冗長構成（2つ以上のAZに分散）
- ✅ ALB でトラフィック分散
- ✅ Auto Scaling で自動スケーリング対応
- ✅ Fargate で インフラ管理不要

**追加したい要件：**

- CloudWatch監視・アラート
- Secrets Managerでの秘密情報管理
  （RDS接続文字列・Cognito設定等）
- WAF CloudFront
- cognitoでの認証
- Next.js → Prisma → RDS（PostgreSQL）
- ECRへの通信用のVPCエンドポイント
- ヘルスチェック設定
- RDS自動バックアップ
- ECRライフサイクルポリシー
