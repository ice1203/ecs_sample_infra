# terraform.tfの中で指定したrequired_providersの名前と一致させる必要がある
# aws環境にリソースをデプロイするための各種情報を定義
# 例えばリージョンや認証情報（AWS CLIプロファイル指定も可、IAMロールも使用可）、デフォルトで各リソースに付与するタグの指定など
# また複数のプロバイダを定義することで異なるアカウントやリージョンに一括でリソースをデプロイすることも可能
provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      iac = "terraform"
    }
  }
}
