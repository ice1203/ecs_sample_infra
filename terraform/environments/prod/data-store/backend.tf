terraform {
  # tfstateファイル格納場所としてS3を指定
  backend "s3" {
    # S3のバケット名 GithubActionsワークフロー内でterraform init時にバケット名指定するためコメントアウト
    # tfstateファイルのパス
    key = "ecs-sample-infra/terraform/prod/data-store/terraform.tfstate"
    # S3バケットのリージョン
    region = "ap-northeast-1"
    # tfstateファイルのロック機能（排他制御）をDynamoDBで有効化
    dynamodb_table = "terraform_state_lock"
  }
}
