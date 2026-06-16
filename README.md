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

In this part I will explain how I have improved on the stated objectives from the sre-challenge.

- **Functionality**
  - (app) Flask app running via Gunicorn
  - (app) Login/logout with PostgreSQL backend
  - (app) Dev: Docker Compose via Ansible on a dedicated VM
  - (app) Prod: Kubernetes (Minikube) on a dedicated VM, exposed via nginx reverse proxy


- **Simplicity**
  - (app) `fetchone()` instead of fetching all users in the app
  - (github workflow) Push to `dev` or `main` — GitHub Actions handles the rest

- **Readability**
  - (orchestration) Ansible split into roles per responsibility `dev` and `prod`
  - (github repo) Cleaned up `.gitignore` (removed irrelevant generated python template stuff)

- **Extensibility**
  - (app) SQLite replaced by PostgreSQL
  - (kubernetes) Kubernetes manifests with HPA for auto-scaling
  - (kubernetes) Ingress + nginx reverse proxy for clean external access


- **Maintainability**
  - (app) Pinned versions in `requirements.txt`
  - (orchestration) Variables centralized in Ansible vars
  - (kubernetes) Secrets injected via Kubernetes Secrets, not hardcoded

- **Observability**
  - (app) Successful and failed logins logged

- **Security**
  - (github workflows) CodeQL static analysis on every push, fails on error severity
  - (orchestration) Database credentials & secretkey encrypted with Ansible Vault
  - (app) Gunicorn instead of Flask dev-server
  - (app) Removed password from failed and succesfull login

  - (kubernetes) !!! metrics-server runs with `--kubelet-insecure-tls` — Minikube's kubelet uses a self-signed cert, proper CA setup would require mounting Minikube's CA into the pod. Non-issue on a real cluster. !!!
  
  - (app) The original code logged the user's passsword in the logs when a failed or succesfull login occurred

  - (app) Now only fetches the user logging in instead of all users.
  Its not necessary to fetch all users, just the one who's logging in.

  - (app) Passwords are now checked in hash instead of plaintext. 

  - (app) Original code had the secret_key hardcoded into the code.
  Everybody who has access to the repo can generate their own cookies. Now it is loaded from env.







