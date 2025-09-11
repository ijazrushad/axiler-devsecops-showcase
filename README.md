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

## The Project Journey: A Debugging Story

### The Challenge: `unauthorized_client` error
- The OIDC token from GitHub was rejected by GCP’s attribute condition.  
- I investigated **typos, IAM bindings, WIF provider strings, GitHub secrets**.  

### The Contradiction: "Zombie" resources
- `gcloud ... pools delete` → *Not Found*  
- `gcloud ... pools create` → *Already Exists*  
- Issue confirmed as a **GCP platform-level bug**.  

### The Solution
- Created a **new GCP project** with fresh unique resource names (e.g., `axiler-pool-777`).  
- Issue immediately resolved.  

### The Lesson
- Know when the problem is **your config vs. the platform**.  
- Debugging in cloud systems requires **systematic isolation** and sometimes a **clean-slate approach**.  

---

## Future Improvements
- **Monitoring & Alerting:** Deploy `kube-prometheus-stack`, configure Grafana + Alertmanager.  
- **Centralized Logging:** Add EFK (Elasticsearch, Fluentd, Kibana) stack.  
- **Zero-Trust Networking:** Strict Kubernetes `NetworkPolicy` for pod communication.  
- **GitOps Deployment:** Use ArgoCD for a pull-based deployment model.  

---
