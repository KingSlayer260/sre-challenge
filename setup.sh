#!/bin/bash
set -e

if [ ! -f setup.vars ]; then
    echo "setup.vars not found, copy setup.vars.example and fill in your values"
    exit 1
fi

source setup.vars

# install ansible & requirements
sudo apt update && sudo apt install -y python3 python3-pip
pip install ansible docker
ansible-galaxy collection install community.docker
ansible-galaxy install gantsign.minikube
sudo apt-get install -y jq


# random keys for dev and prod
DEV_SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")
PROD_SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")

# generate separate ssh keypairs for dev and prod vm
DEV_VM_SSH_KEY_PATH="$HOME/.ssh/sre-challenge-dev"
PROD_VM_SSH_KEY_PATH="$HOME/.ssh/sre-challenge-prod"

for KEY_PATH in "$DEV_VM_SSH_KEY_PATH" "$PROD_VM_SSH_KEY_PATH"; do
    if [ ! -f "$KEY_PATH" ]; then
        ssh-keygen -t ed25519 -f "$KEY_PATH" -N "" -C "sre-challenge"
        chmod 600 "$KEY_PATH"
        chmod 644 "${KEY_PATH}.pub"
    fi
done

DEV_VM_SSH_PUBLIC_KEY=$(cat "${DEV_VM_SSH_KEY_PATH}.pub")
PROD_VM_SSH_PUBLIC_KEY=$(cat "${PROD_VM_SSH_KEY_PATH}.pub")

# write vars
cat > .ansible/inventory/dev/group_vars/all/vars.yml <<EOF
db_host: db
db_name: sre
db_user: sre
proxmox_endpoint: "${PROXMOX_ENDPOINT}"
proxmox_node: "${PROXMOX_NODE}"
proxmox_ssh_key_path: "${PROXMOX_SSH_KEY_PATH}"
terraform_workspace: "dev"
target_group: "dev_vm"
vm_name: "sre-dev"
vm_ip: "${DEV_VM_IP}"
vm_gateway: "${VM_GATEWAY}"
ssh_public_key: "${DEV_VM_SSH_PUBLIC_KEY}"
ssh_key_path: "${DEV_VM_SSH_KEY_PATH}"
vm_user: "dev"
EOF

cat > .ansible/inventory/prod/group_vars/all/vars.yml <<EOF
db_host: db
db_name: sre
db_user: sre
minikube_version: "1.32.0"
kubectl_version: "1.28.3"
proxmox_endpoint: "${PROXMOX_ENDPOINT}"
proxmox_node: "${PROXMOX_NODE}"
proxmox_ssh_key_path: "${PROXMOX_SSH_KEY_PATH}"
terraform_workspace: "prod"
target_group: "prod_vm"
vm_name: "sre-prod"
vm_ip: "${PROD_VM_IP}"
vm_gateway: "${VM_GATEWAY}"
ssh_public_key: "${PROD_VM_SSH_PUBLIC_KEY}"
ssh_key_path: "${PROD_VM_SSH_KEY_PATH}"
vm_user: "prod"
EOF

# create vault files
cat > .ansible/inventory/dev/group_vars/all/vault.yml <<EOF
app_secret_key: "${DEV_SECRET_KEY}"
db_password: "${DEV_DB_PASSWORD}"
proxmox_api_token: "${PROXMOX_API_TOKEN}"
EOF

cat > .ansible/inventory/prod/group_vars/all/vault.yml <<EOF
app_secret_key: "${PROD_SECRET_KEY}"
db_password: "${PROD_DB_PASSWORD}"
proxmox_api_token: "${PROXMOX_API_TOKEN}"
EOF

echo "$VAULT_PASSWORD" | ansible-vault encrypt --vault-password-file /dev/stdin \
    .ansible/inventory/dev/group_vars/all/vault.yml

echo "$VAULT_PASSWORD" | ansible-vault encrypt --vault-password-file /dev/stdin \
    .ansible/inventory/prod/group_vars/all/vault.yml

ansible-playbook .ansible/master.yml --tags setup --ask-vault-pass

echo ""
echo "done"
echo "dev vm ssh key:  ${DEV_VM_SSH_KEY_PATH}"
echo "prod vm ssh key: ${PROD_VM_SSH_KEY_PATH}"
echo ""
echo "run the setup first:  ansible-playbook .ansible/master.yml --tags setup --ask-vault-pass"
echo "to deploy dev:        ansible-playbook .ansible/master.yml -i .ansible/inventory/dev --tags dev_deploy --ask-vault-pass"
echo "to deploy prod:       ansible-playbook .ansible/master.yml -i .ansible/inventory/prod --tags prod_deploy --ask-vault-pass"
