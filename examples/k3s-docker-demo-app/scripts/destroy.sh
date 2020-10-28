#!/bin/sh -xe

mkdir -p ".terraform.d/plugin-cache"
echo plugin_cache_dir = \""$PWD/.terraform.d/plugin-cache"\" > "$HOME/.terraformrc"

# Terraform helm provider requires this file to be present
mkdir "$HOME/.kube"
touch "$HOME/.kube/config"

mkdir -p bin
export PATH="$PWD/bin:$PATH"

if ! test -x bin/kubectl; then
	wget https://storage.googleapis.com/kubernetes-release/release/v1.19.0/bin/linux/amd64/kubectl -O bin/kubectl
	chmod +x bin/kubectl
fi

cd terraform || exit
terraform init -upgrade
terraform workspace select "$CLUSTER_NAME" || terraform workspace new "$CLUSTER_NAME"
terraform init -upgrade
terraform destroy --auto-approve
if [ "$CLUSTER_NAME" != "default" ]; then
	terraform workspace select default
	terraform workspace delete "$CLUSTER_NAME"
fi
cd - || exit