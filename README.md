# Axiler - DevSecOps Showcase: A Secure CI/CD Pipeline on GKE

This repository contains the complete infrastructure and CI/CD pipeline for a take-home assessment.  
It demonstrates a robust **DevSecOps** approach to deploying, securing, and managing a containerized application on **Google Kubernetes Engine (GKE)**.  

The project goes beyond a simple deployment; it's a narrative of building resilient, secure, and automated infrastructure from the ground up, including navigating and solving complex, real-world platform challenges.  

---

## Live Demo
The Juice Shop application is deployed and accessible with HTTPS at:  
[https://juiceshop.34.107.194.151.nip.io](https://juiceshop.34.107.194.151.nip.io)  
*(Note: This infrastructure may be torn down after the assessment period.)*

---

## Architecture Diagram
The architecture is designed for **security, automation, and scalability**, with a clear flow from a code commit to a live, secured endpoint.  

![Architecture Diagram](image/architecture-diagram.png)

---

## Flow Description
1. A developer pushes code to the **main branch** on the GitHub repository.  
2. **GitHub Actions** is triggered, starting the CI/CD pipeline.  
3. The pipeline authenticates to Google Cloud securely using **Workload Identity Federation (WIF)**.  
4. A **Docker image** is built and scanned for vulnerabilities using **Trivy**.  
5. If the scan passes, the image is pushed to a private **Google Artifact Registry**.  
6. The pipeline deploys the image to **GKE** using **Helm**.  
7. **GKE Ingress** provisions a Google-managed SSL certificate, routing traffic from a static IP.  
8. End-users access the application securely over **HTTPS**.  

---

## Project Motivation & Goals
The inspiration for this project comes directly from **Axiler's mission**:  
> To build *"silent guardians for the digital frontier."*

I deployed **OWASP Juice Shop**, a deliberately vulnerable app, to demonstrate **proactive DevSecOps security**.  
This project showcases:  

- **Infrastructure as Code (IaC):** Auditable, repeatable environments.  
- **CI/CD Automation:** GitOps-style workflow from commit to production.  
- **Container Security:** "Shift-left" scanning for vulnerabilities before deployment.  
- **Cloud-Native Security:** Keyless authentication + managed TLS.  
- **Scalability:** Auto-scaling managed Kubernetes clusters.  

---

## Technology Stack & Design Choices

| **Category**           | **Tool** | **Why I Chose It** |
|-------------------------|----------|---------------------|
| **Cloud Provider**      | Google Cloud Platform (GCP) | Free trial credits, mature GKE & WIF. |
| **Orchestration**       | GKE | Managed, self-healing, auto-scaling, GCP-native integration. |
| **Infrastructure as Code** | Terraform | Industry-standard IaC, repeatable & auditable. |
| **CI/CD**               | GitHub Actions | Native to repo, OIDC support, rich marketplace. |
| **Packaging**           | Helm | Version-controlled deployments, upgrades, rollbacks. |
| **Containerization**    | Docker | Lightweight, portable, consistent environments. |
| **Security Scanning**   | Trivy | Open-source, fast, CI/CD integrated scanning. |
| **Authentication**      | Workload Identity Federation (WIF) | Keyless, secure, eliminates long-lived secrets. |
| **Networking & HTTPS**  | GKE Ingress + Managed Certificates | Automated TLS, zero maintenance. |

---

## The Project Journey: A Chronicle of Real-World Debugging

Building this pipeline was a multi-stage process that involved overcoming a series of realistic infrastructure and platform challenges. This journey highlights a core DevOps principle: **build, test, and automate incrementally**.

### Phase 1: Infrastructure Provisioning & Foundational Hurdles
- **GCP Quota Limits:** The initial `terraform apply` failed due to a default SSD quota limit in the new GCP project. The fix was to explicitly define a smaller, cost-effective `pd-standard` disk for the GKE nodes, demonstrating resource management.
- **Regional vs. Zonal Clusters:** An early configuration created a regional GKE cluster, resulting in 6 nodes instead of the intended 2. I corrected the Terraform code to create a more efficient zonal cluster, showcasing an understanding of cloud architecture and cost control.

### Phase 2: Manual Deployment as a Baseline
- **Validation:** Performed a full manual deployment using Helm (`helm install ...`) to confirm the GKE cluster was healthy and the Juice Shop application's Helm chart was correctly configured.
- **Baseline:** Established a "known good" state, making it easier to debug subsequent automation issues.

### Phase 3: The CI/CD Authentication Gauntlet
- **The Initial `unauthorized_client` Error:** The pipeline immediately failed with a WIF error, indicating the OIDC token from GitHub was rejected by GCP's attribute condition. This triggered a deep investigation into every component of the authentication chain.
- **The "Zombie" Resource Contradiction:** Debugging revealed a bizarre platform-level issue:
  - `gcloud ... pools delete` → *Not Found*  
  - `gcloud ... pools create` → *Already Exists*  
- **The Solution – A Clean Slate:** This behavior proved the issue was a resource state propagation problem within the GCP project. The only viable solution was to start fresh in a brand new GCP project and use completely unique names for the WIF components. This methodical approach to isolating and bypassing a platform-level bug was the key to moving forward.

### Phase 4: Fine-Tuning the Automated Deployment
- **ImagePullBackOff:** The first Helm deployment from the pipeline timed out. `kubectl describe pod` revealed the issue: GKE nodes lacked permission to pull images from the private Google Artifact Registry. Solved by granting the Artifact Registry Reader role to the GKE nodes' default service account.
- **Pending Pods:** Next run timed out with pods stuck in a Pending state. The root cause was insufficient CPU/memory resources. Enabled GKE cluster autoscaling, allowing the cluster to automatically add new nodes on demand—the cloud-native solution to resource contention.

### The Lesson
This multi-phase journey, from manual deployment to a fully automated and hardened pipeline, reflects a real-world DevOps workflow of **iterative improvement** and **persistent problem-solving**.   

---

## Future Improvements
- **Monitoring & Alerting:** Deploy `kube-prometheus-stack`, configure Grafana + Alertmanager.  
- **Centralized Logging:** Add EFK (Elasticsearch, Fluentd, Kibana) stack.  
- **Zero-Trust Networking:** Strict Kubernetes `NetworkPolicy` for pod communication.  
- **GitOps Deployment:** Use ArgoCD for a pull-based deployment model.  

---
