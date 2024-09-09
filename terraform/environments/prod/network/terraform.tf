terraform {
  # 本コードでのterraformの必須バージョン指定
  required_version = ">= 1.9.1"
  # awsプロバイダバージョン指定
  # プロバイダとはaws等のcloudとやり取りするためのプラグイン
  required_providers {
    # 下の"aws"はプロバイダを一意に識別するローカル名のため
    # 後述のproviderで指定する名前と一致させる必要あり
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.57.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }
}
