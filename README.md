# 🚀 CloudFlix – Scalable Netflix-Style Video Streaming Platform on AWS

CloudFlix is a cloud-native video streaming platform built using **microservices architecture** and deployed on **AWS Cloud Infrastructure**.

It simulates a real-world OTT platform (like Netflix) with scalable video processing, secure streaming, and distributed system design.

---

## 🎬 Features

- 🔐 JWT-based Authentication
- 📤 Video Upload to AWS S3
- ⚙️ Event-Driven Processing Pipeline
- 🎥 HLS Adaptive Streaming (.m3u8)
- 🌍 Global CDN Delivery via CloudFront
- 🔐 Secure Streaming with Signed URLs
- 📊 Watch History Tracking (DynamoDB)
- ⚡ Redis Caching for performance
- 📈 Auto Scaling & Load Balancing

---

## 🏗️ Architecture Overview

### 📌 High-Level Flow

User → API Gateway → Microservices → AWS Services

### 🎥 Video Processing Pipeline

Upload → S3 → Lambda → SNS → SQS → Worker → MediaConvert → HLS → CloudFront

### ▶️ Streaming Flow

User → CloudFront → S3 (HLS Files)

---

## ☁️ AWS Services Used

### Compute
- EC2 (Microservices)
- Auto Scaling Group
- Application Load Balancer
- AWS Lambda

### Storage
- Amazon S3 (Video storage & HLS output)

### Video Processing
- AWS MediaConvert

### CDN
- Amazon CloudFront (Signed URLs)

### Databases
- Amazon RDS (Aurora - MySQL)
- Amazon DynamoDB
- Amazon ElastiCache (Redis)

### Messaging
- Amazon SNS
- Amazon SQS

### Networking
- Amazon VPC (Multi-VPC)
- NAT Gateway
- Transit Gateway
- Public & Private Subnets

### Monitoring
- Amazon CloudWatch

---

## 🧠 Microservices

- **Auth Service** → Authentication & JWT
- **Video Service** → Upload & Metadata
- **Streaming Service** → Secure playback
- **Worker Service** → Video processing jobs

---

## 🔄 Event-Driven Architecture

This project uses an asynchronous pipeline:

S3 Upload → Lambda Trigger → SNS → SQS → Worker → MediaConvert

### Benefits:
- Scalable
- Fault-tolerant
- Decoupled services

---

## 🗄️ Database Design

### RDS (Aurora)
- Users
- Videos
- Metadata

### DynamoDB
- Watch history
- User activity

### Redis (ElastiCache)
- Caching trending videos
- Fast API responses

---

## 🔐 Security

- JWT Authentication
- IAM Roles & Policies
- Signed URLs for secure streaming
- Private subnet architecture
- Restricted S3 access

---

## 🌐 Networking Architecture

- Multi-VPC Architecture
- Transit Gateway connectivity
- Public VPC → Load Balancer
- Application VPC → Microservices
- Data VPC → Databases

---

## 📁 Project Structure
