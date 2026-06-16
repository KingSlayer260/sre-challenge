# Warpnet SRE Challenge

This is my attempt at the Warpnet SRE challenge. I run a Proxmox server at home, so I used that as the environment instead of a local virtual environment.


### Prerequisites

- Proxmox node with API token
- Self-hosted GitHub Actions runner on the orchestration machine, configured for this repo or fork
- `ansible`, `terraform`, `jq`, `unzip` on the orchestration machine
- Ansible Vault password (set as `VAULT_PASSWORD` GitHub secret)
- Terraform state passphrase (set as `TF_STATE_PASSPHRASE` GitHub secret)


### Setup (run once)

First copy the `setup.vars.example` to `setup.vars` and fill in the right info. 

After that, run the setup script — it generates secrets and creates encrypted vault files for dev and prod:
```bash
./setup.sh
```


### Deploy

To deploy the app just push to the `dev` or `main` branch and de github workflow will automaticly deploy to the right environment.



## Objectives

I 

- **Functionality**
  - Flask app running via Gunicorn
  - Login/logout with PostgreSQL backend
  - Dev: Docker Compose via Ansible on a dedicated VM
  - Prod: Kubernetes (Minikube) on a dedicated VM, exposed via nginx reverse proxy


- **Simplicity**
  - `fetchone()` instead of fetching all users
  - Push to `dev` or `main` — GitHub Actions handles the rest

- **Readability**
  - Ansible split into roles per responsibility
  - Cleaned up `.gitignore` (removed irrelevant generated python template stuff)

- **Extensibility**
  - SQLite replaced by PostgreSQL
  - Kubernetes manifests with HPA for auto-scaling
  - Ingress + nginx reverse proxy for clean external access


- **Maintainability**
  - Pinned versions in `requirements.txt`
  - Variables centralized in Ansible vars
  - Secrets injected via Kubernetes Secrets, not hardcoded

- **Observability**
  - Successful and failed logins logged

- **Security**
  - CodeQL static analysis on every push
  - Database credentials & secretkey encrypted with Ansible Vault
  - Gunicorn instead of Flask dev-server
  - Removed password from failed and succesfull login

  - metrics-server runs with `--kubelet-insecure-tls` — Minikube's kubelet uses a self-signed cert, proper CA setup would require mounting Minikube's CA into the pod. Non-issue on a real cluster.
  
  - The original code logged the user's passsword in the logs when a failed or succesfull login occurred

  - Now only fetches the user logging in instead of all users.
  Its not necessary to fetch all users, just the one who's logging in.

  - Passwords are now checked in hash instead of plaintext. 

  - Original code had the secret_key hardcoded into the code.
  Everybody who has access to the repo can generate their own cookies. Now it is loaded from env.







