terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 5.7.0"
    }
  }

  required_version = ">= 1.9"
}
