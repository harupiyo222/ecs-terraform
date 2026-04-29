# ECS 冗長化構成 - Terraform IaC

このプロジェクトは、AWS 上で ECS（Elastic Container Service）を冗長化する構成を Terraform でコード化したものです。

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

**特徴：**
- ✅ マルチ AZ 冗長構成（2つ以上のAZに分散）
- ✅ ALB でトラフィック分散
- ✅ Auto Scaling で自動スケーリング対応
- ✅ CloudWatch Logs で集約ログ
- ✅ Fargate で インフラ管理不要

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

## 🚀 クイックスタート

### 1️⃣ ECR イメージを準備

```bash
# ECR リポジトリを作成（初回のみ）
aws ecr create-repository --repository-name myapp --region ap-northeast-1

# Dockerfile からイメージをビルド＆プッシュ
docker build -t myapp:latest .
docker tag myapp:latest 123456789.dkr.ecr.ap-northeast-1.amazonaws.com/myapp:latest
docker push 123456789.dkr.ecr.ap-northeast-1.amazonaws.com/myapp:latest
```

### 2️⃣ terraform.tfvars を編集

```hcl
# コンテナイメージ URI を設定
container_image = "123456789.dkr.ecr.ap-northeast-1.amazonaws.com/myapp:latest"
```

### 3️⃣ Terraform で デプロイ

```bash
# 初期化
terraform init

# 計画を確認
terraform plan

# 適用
terraform apply

# 出力を確認
terraform output
```

## 📊 主要な設定値

| 項目 | デフォルト値 | 説明 |
|---|---|---|
| `container_image` | `""` | **必須**：ECR イメージ URI |
| `container_port` | `8080` | コンテナのリッスンポート |
| `container_cpu` | `256` | Fargate のCPUユニット |
| `container_memory` | `512` | Fargate のメモリ（MB） |
| `asg_desired_count` | `2` | 常に実行するタスク数 |
| `asg_min_count` | `2` | 最小タスク数 |
| `asg_max_count` | `4` | 最大タスク数 |

## 🔧 カスタマイズ

### コンテナのスペック変更

```hcl
# terraform.tfvars
container_cpu    = 512   # 256 → 512 CPU ユニット
container_memory = 1024  # 512 → 1024 MB
```

**Fargate 対応の CPU/メモリ組み合わせ：**
```
CPU: 256
  - メモリ: 512, 1024, 2048

CPU: 512
  - メモリ: 1024, 2048, 3072, 4096

CPU: 1024
  - メモリ: 2048～8192 (1024 単位)

CPU: 2048
  - メモリ: 4096～16384 (1024 単位)

CPU: 4096
  - メモリ: 8192～30720 (1024 単位)
```

### Auto Scaling の設定変更

```hcl
# terraform.tfvars
asg_desired_count = 3   # 常に 3 タスク実行
asg_max_count     = 10  # 最大 10 タスクまでスケールアップ
```

Auto Scaling ポリシー：
- **CPU > 70%** → スケールアップ
- **メモリ > 80%** → スケールアップ
- **ALB リクエスト > 1000/分** → スケールアップ

### HTTPS を有効化

`alb.tf` のコメントアウト部分を有効化し、ACM 証明書 ARN を指定：

```hcl
# alb.tf
certificate_arn = "arn:aws:acm:ap-northeast-1:ACCOUNT_ID:certificate/CERTIFICATE_ID"
```

## 📋 必要な AWS リソース（事前準備）

1. **ECR リポジトリ**
   ```bash
   aws ecr create-repository --repository-name myapp
   ```

2. **AWS 認証情報**
   ```bash
   aws configure
   ```

3. **AWS CLI のインストール**
   ```bash
   pip install awscli
   ```

## 🔍 デプロイ後の確認

### 1️⃣ ALB DNS 名を確認

```bash
terraform output alb_dns_name
# 出力：myapp-production-alb-123456789.ap-northeast-1.elb.amazonaws.com
```

### 2️⃣ アプリケーションにアクセス

```bash
curl http://myapp-production-alb-123456789.ap-northeast-1.elb.amazonaws.com
```

### 3️⃣ ECS タスク状態を確認

```bash
aws ecs list-tasks --cluster api-cluster --region ap-northeast-1
aws ecs describe-tasks --cluster api-cluster --tasks <TASK_ARN> --region ap-northeast-1
```

### 4️⃣ ログを確認

```bash
# CloudWatch Logs で確認
aws logs tail /ecs/myapp-production --follow --region ap-northeast-1

# または AWS コンソール
# CloudWatch → ロググループ → /ecs/myapp-production
```

## 🔄 アップデート手順

### コンテナイメージを更新

```bash
# 新バージョンをビルド＆プッシュ
docker build -t myapp:v2.0 .
docker tag myapp:v2.0 123456789.dkr.ecr.ap-northeast-1.amazonaws.com/myapp:v2.0
docker push 123456789.dkr.ecr.ap-northeast-1.amazonaws.com/myapp:v2.0

# Terraform で イメージ URI を更新
# terraform.tfvars
container_image = "123456789.dkr.ecr.ap-northeast-1.amazonaws.com/myapp:v2.0"

# 適用
terraform apply
```

ECS は新しいタスク定義を自動的に検出し、ローリングデプロイを実行します。

## 🧹 削除

```bash
terraform destroy
```

⚠️ **警告**：このコマンドですべてのリソースが削除されます。

## 📈 本番環境の推奨事項

### 1️⃣ State 管理

```hcl
# main.tf の backend を有効化
backend "s3" {
  bucket         = "your-terraform-state"
  key            = "ecs-redundancy/terraform.tfstate"
  region         = "ap-northeast-1"
  encrypt        = true
  dynamodb_table = "terraform-locks"
}
```

### 2️⃣ HTTPS を有効化

ACM 証明書を取得して、`alb.tf` のリスナーを有効化。

### 3️⃣ ロギング・モニタリング

- CloudWatch Alarms でメトリクスを監視
- AWS X-Ray でトレース
- VPC Flow Logs でネットワーク監視

### 4️⃣ セキュリティグループのカスタマイズ

現在、`ecs_security_group` は ALB からのみ受け入れています。必要に応じてカスタマイズしてください。

### 5️⃣ 環境分離

本番環境以外（dev、staging）用に別の `terraform.tfvars` を作成：

```bash
terraform apply -var-file="dev.tfvars"
terraform apply -var-file="staging.tfvars"
terraform apply -var-file="production.tfvars"
```

## 🐛 トラブルシューティング

### タスクが起動しない

```bash
# タスク定義を確認
aws ecs describe-task-definition --task-definition api-server --region ap-northeast-1

# ECS ログを確認
aws logs tail /ecs/myapp-production --follow
```

### ALB のヘルスチェック失敗

```hcl
# terraform.tfvars でヘルスチェックパスを確認
health_check_path = "/"  # アプリが対応しているパスを指定
```

### Auto Scaling が動かない

```bash
# Auto Scaling ターゲットを確認
aws application-autoscaling describe-scalable-targets \
  --service-namespace ecs \
  --region ap-northeast-1
```

## 📚 参考リンク

- [AWS ECS ドキュメント](https://docs.aws.amazon.com/ja_jp/ecs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Fargate の料金](https://aws.amazon.com/ja/fargate/pricing/)

## 📝 ライセンス

MIT License

---

**質問・問題がある場合：**
- Terraform ログを確認：`TF_LOG=DEBUG terraform apply`
- AWS CloudTrail でイベント確認
- AWS サポートに問い合わせ
