# terraform-project
# 🚀 Secure Web App on AWS using Terraform

This project builds a **secure multi-tier web application** infrastructure on AWS using Terraform. It uses **public NGINX reverse proxy EC2s** and **private Apache backend EC2s**, load balancers, VPC modules, and remote state storage.

---

## 🧱 Architecture Overview


<img width="1066" height="610" alt="image" src="https://github.com/user-attachments/assets/fc597109-ec78-473a-ac20-977ddc5526a5" />

## ☁️ Infrastructure Components

- **VPC** with 4 subnets:
  - 2 public subnets → NGINX proxies
  - 2 private subnets → Apache backends
- **Public ALB** → routes to NGINX
- **Internal ALB** → routes to Apache backends
- **EC2 Provisioning**:
  - NGINX on proxy servers (via `remote-exec`)
  - Apache (`httpd`) on backend servers
  - local provisioning to print the ips in a file.txt
- **State Management**:
  - Remote state stored in **S3**
  - Locking with **DynamoDB**
- **Workspaces**:
  - `dev` used to isolate environment

## ☁️ take care of when applying 
- whenever you edit the ec2 you must destroy it and apply it again
- take care of the structure of the modules (mina,outputs,variables)
- security groups are sensitive as you may accidentally forget to open needed ports
- make sure you associated the route table to the ec2


## ☁️ some screenshots from my project
- **final results**
  
<img width="892" height="195" alt="image" src="https://github.com/user-attachments/assets/8bfc14fa-a9a9-469e-9c8d-d88bc21f9fc5" />
<img width="926" height="154" alt="image" src="https://github.com/user-attachments/assets/ba53ee9b-4d78-464d-b06b-9c754ca03f15" />

- **current working space**
  
<img width="528" height="153" alt="image" src="https://github.com/user-attachments/assets/18796247-49bc-41a0-8c0f-a47e08c38db3" />


  - **proxy configuration**

<img width="528" height="153" alt="image" src="https://github.com/user-attachments/assets/333fc2ee-f20c-4978-b873-7b962b16b1df" />
<img width="975" height="345" alt="image" src="https://github.com/user-attachments/assets/6cbdc911-f47c-4e42-bcfc-d1fda7564fae" />
<img width="776" height="248" alt="image" src="https://github.com/user-attachments/assets/82606305-9f6e-49a4-9a12-9c3dcf794118" />

- **The s3 that contain the state file**
  
<img width="975" height="403" alt="image" src="https://github.com/user-attachments/assets/46f5774e-1618-4ab9-b2fc-390d7ed97991" />



  





