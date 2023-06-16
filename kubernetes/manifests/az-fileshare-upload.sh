#!/bin/bash

az storage file upload -s FILESHARE_NAME --account-name  STORAGE_ACCOUNT_NAME --source SOURCE --path DESTINATION --account-key SAKEY





az storage file upload -s --account-name  devstorageaccount --source grafana.db


az storage file upload -s --account-name  devstorageaccount --source /tmp/vault-0.db --path vault.db
az storage file upload -s --account-name  devstorageaccount --source /tmp/vault-0-raft.db --path raft/raft.db
az storage file upload -s --account-name  devstorageaccount --source /tmp/vault-1.db --path vault.db
az storage file upload -s --account-name  devstorageaccount --source /tmp/vault-1-raft.db --path raft/raft.db
az storage file upload -s --account-name  devstorageaccount --source /tmp/vault-2.db --path vault.db
az storage file upload -s --account-name  devstorageaccount --source /tmp/vault-2-raft.db --path raft/raft.db






az storage file upload -s --account-name  devstorageaccount --source /tmp/secret.key



#to be run from az-cli container deployed in the cluster - find deployment file in same folder or check multitool namespace if it's already deployed there


