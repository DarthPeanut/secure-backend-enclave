# Secure Cloud-Native Web Application & GitOps Pipeline

An enterprise-grade, highly secure, automated FastAPI microservice deployed onto the **Azure Cloud Platform** using **Terraform** for Infrastructure as Code (IaC) and **GitHub Actions** for CI/CD. 

This repository demonstrates modern DevSecOps practices, featuring OIDC credential-less authentication, strict non-root container hardening, unprivileged network binding, and automated perimeter defenses.

---

## 🏗️ Architectural Topology

```text
+---------------------------------------------------------------------------------+
|                                 AZURE CLOUD                                     |
|                                                                                 |
|  +------------------------+      +-------------------------------------------+  |
|  | Azure Container        |      | Azure Container Apps (ACA)                |  |
|  | Registry (ACR)         |      | Managed Environment                       |  |
|  |                        |      |                                           |  |
|  | [Secure API Image] ----+----->|  +-------------------------------------+  |  |
|  +------------------------+      |  | Isolated Container Replica          |  |  |
|                                  |  |                                     |  |  |
|                                  |  |  - Non-privileged User: appuser     |  |  |
|  +------------------------+      |  |  - Inbound Target Port: 8080        |  |  |
|  | Log Analytics          |      |  |  - Framework: FastAPI / Uvicorn     |  |  |
|  | Workspace              |      |  +-------------------------------------+  |  |
|  |                        |      |                       |                   |  |
|  |  - System Logs (KQL)  |<-----+-----------------------+                   |  |
|  +------------------------+      +-----------------------+-------------------+  |
|                                                          ^                      |
+----------------------------------------------------------|----------------------+
| Inbound HTTPS
| (TLS Terminated)
|
[ Public Internet ]
```

---

## 🔒 Security & Engineering Standards

* **Infrastructure as Code (IaC):** 100% of the cloud fabric—including resource groups, container registries, and log workspaces—is provisioned using **Terraform** to prevent configuration drift.
* **OIDC Federated Authentication:** The CI/CD pipeline establishes a short-lived cryptographic trust handshake between GitHub and Azure Active Directory via **OpenID Connect (OIDC)**, completely removing hardcoded passwords or service principal secrets from the repository.
* **Container Hardening:** Built on an optimized `python:3.11-slim` base image. The runtime container drops root privileges entirely, executing under a dedicated `USER appuser` and routing traffic through non-privileged port `8080`.
* **Observability & Log Analysis:** System logs and container metrics route to an Azure Log Analytics Workspace, parsed natively using **Kusto Query Language (KQL)** for real-time telemetry.
* **Perimeter Defense:** A comprehensive `.gitignore` configuration isolates local plain-text Terraform state metadata (`.tfstate`) and environment secrets, ensuring zero credential leaks to public registries.

---

## 🚀 Repository Structure

```text
├── .github/workflows/
│   └── deploy.yml          # GitHub Actions CI/CD Pipeline utilizing OIDC
├── app/
│   ├── Dockerfile          # Hardened, non-root multi-stage container build
│   ├── main.py             # FastAPI asynchronous application
│   └── requirements.txt    # Application dependencies (FastAPI, Uvicorn)
├── terraform/
│   ├── main.tf             # Core IaC configuration (ACA, ACR, Log Analytics)
│   ├── variables.tf        # Input variables
│   └── outputs.tf          # Core resource output exports
└── .gitignore              # Repository perimeter shield blocking .tfstate & secrets
```
---

🛠️ Local Setup & Deployment
Prerequisites
Windows Command Prompt (cmd.exe) or Linux/macOS terminal

Azure CLI installed

Terraform CLI installed

1. Initialize the Infrastructure
Navigate to the terraform directory and provision the secure azure infrastructure:

Bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
2. Verify Repository Security Perimeter
Run the built-in Git diagnostic engine to confirm that your sensitive tracking files are successfully blocked from leaking to public remote servers:

Bash
git check-ignore -v terraform/terraform.tfstate
3. CI/CD GitOps Trigger
To trigger a fresh image compilation and a rolling revision update inside Azure Container Apps, stage and push the source code up to your repository:

Bash
git add .
git commit -m "feat: deploy containerized web application to cloud fabric"
git push origin main

---

📡 Live Production Verification
Once the automated pipeline runs green, verify the endpoints:

API Documentation Panel: https://<your-container-app-url>/docs

Health Assessment Check: https://<your-container-app-url>/api/v1/health


---

### Step 3: Push it to GitHub
Once saved, use your Command Prompt to push the documentation live to your profile:

```cmd
git add README.md
git commit -m "docs: implement professional production-grade repository readme"
git push origin main
```