# Axiler - DevSecOps Showcase: A Secure CI/CD Pipeline on GKE

This repository contains the complete infrastructure and CI/CD pipeline for a take-home assessment.  
It demonstrates a robust **DevSecOps** approach to deploying, securing, and managing a containerized application on **Google Kubernetes Engine (GKE)**.  

The project goes beyond a simple deployment; it's a narrative of building resilient, secure, and automated infrastructure from the ground up, including navigating and solving complex, real-world platform challenges.  

---

## Live Demo
The Juice Shop application is deployed and accessible with HTTPS at:  
[https://juiceshop.34.107.194.151.nip.io](https://juiceshop.34.107.194.151.nip.io)  
Monitoring Portal:
[https://grafana.34.107.194.151.nip.io/](https://grafana.34.107.194.151.nip.io/)
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
9. NetwkPolicy Enable by Default Deny
10. Grafan Dashboard Live

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
- **Monitoring** Grafana + Prometheus Live Dashboard.

---

## Technology Stack & Design Choices

| **Category**           | **Tool** | **Why I Chose It** |
|-------------------------|----------|---------------------|
| **Application**      | OWASP Juice Shop | Chosen specifically because it is a deliberately insecure application |
| **Cloud Provider**      | Google Cloud Platform (GCP) | Free trial credits, mature GKE & WIF. |
| **Orchestration**       | GKE | Managed, self-healing, auto-scaling, GCP-native integration. |
| **Infrastructure as Code** | Terraform | Industry-standard IaC, repeatable & auditable. |
| **CI/CD**               | GitHub Actions | Native to repo, OIDC support, rich marketplace. |
| **DNS Service**         | nip.io | A free and clever wildcard DNS service. It was used to provide a valid, resolvable domain name for the application's public IP address |
| **Packaging**           | Helm | Version-controlled deployments, upgrades, rollbacks. |
| **Containerization**    | Docker | Lightweight, portable, consistent environments. |
| **Security Scanning**   | Trivy | Open-source, fast, CI/CD integrated scanning. |
| **Authentication**      | Workload Identity Federation (WIF) | Keyless, secure, eliminates long-lived secrets. |
| **Networking & HTTPS**  | GKE Ingress + Managed Certificates | Automated TLS, zero maintenance. |
| **Monitoring Tools**  |Prometheus + Grafana | Open Source |

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

### Phase 5: The GKE Ingress Gauntlet & The Reverse Proxy Solution
- **The Initial FailedNotVisible Error:** The ManagedCertificate resource for Grafana was persistently failing its validation check. This indicated that the Google Cloud Load Balancer, created by the GKE Ingress, was unreachable from the public internet.
- **A Multi-Layered Investigation:** The troubleshooting journey involved methodically isolating and eliminating potential causes:
- `Zero-Trust Policies:` I first suspected the new NetworkPolicy rules were blocking the CA's validation servers or GKE's health checkers. O created more permissive rules, but the error remained.
- `Ingress Conflicts:` I discovered multiple issues with the Ingress setup: a "catch-all" rule on the Juice Shop Ingress was hijacking traffic, and a missing default-http-backend service was preventing the GKE controller from syncing any changes. I fixed both.
- `The "Two Load Balancers" Problem:` After fixing the above, GKE created two separate, conflicting Application Load Balancers instead of merging the Ingress rules. The new one for Grafana was created without a public IP (frontend), confirming a deep-seated configuration conflict.
- **The Final Solution – The Reverse Proxy Pattern:** After exhausting all standard Ingress configurations, the definitive solution was to simplify the task for the GKE controller. I implemented a classic reverse proxy pattern:
- A lightweight NGINX proxy Deployment was created in the default namespace.
- The single, unified Ingress now only routes to services within its own namespace (juice-shop-service and grafana-proxy-service).
- The NGINX proxy then handles the simple and reliable cross-namespace forwarding to the real Grafana service in the monitoring namespace.

This elegant solution bypassed the GKE controller's complex and problematic cross-namespace logic, providing a stable, secure, and scalable frontend for both applications. It's a testament to solving problems by moving up the stack and abstracting away platform-level complexities.


### The Lesson
This multi-phase journey, from manual deployment to a fully automated and hardened pipeline, reflects a real-world DevOps workflow of **iterative improvement** and **persistent problem-solving**.   

---

## Future Improvements
- **Centralized Logging:** Add EFK (Elasticsearch, Fluentd, Kibana) stack.   
- **GitOps Deployment:** Use ArgoCD for a pull-based deployment model. 

## Conclusion

This project successfully demonstrates a complete, secure, and automated DevSecOps workflow on GKE. From writing infrastructure as code with Terraform to navigating complex authentication and networking bugs in a cloud-native environment, it showcases the persistence and deep technical knowledge required to build and maintain resilient systems. The result is a "silent guardian"—an automated pipeline that securely delivers applications to the digital frontier.


---
