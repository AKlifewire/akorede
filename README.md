# AK Smart Home Platform – Fullstack Serverless IoT Automation

## Vision
AK Smart Home is a *scalable, multi-tenant smart home automation platform* that lets users control and monitor devices in real time using *AI-powered automation, MQTT messaging, and dynamic UI rendering*.

Built entirely with *AWS CDK, it supports a **modular multi-stack architecture*, enabling seamless scaling and secure infrastructure-as-code practices. The UI is dynamically rendered in Flutter from backend-driven JSON stored in S3.

---

## Core Goals

- *Serverless, scalable backend* (CDK-based)
- *AI-driven energy & device automation*
- *Dynamic UI fetched via GraphQL and S3*
- *Multi-user + multi-device real-time control*
- *Modern developer experience with CI/CD, IaC, and Amplify*

---

## AWS Architecture (Modular CDK Stacks)

| Stack               | Purpose                                                                 |
|--------------------|-------------------------------------------------------------------------|
| AuthStack         | Cognito UserPool/IdentityPool for auth                                 |
| LambdaStack       | Business logic (get-ui-page, control-device, etc.)                 |
| IoTStack          | IoT Core: MQTT, Fleet Provisioning, OTA, Defender                      |
| AppSyncStack      | GraphQL API for UI fetch, mutations, subscriptions                     |
| UIStack           | S3 bucket to store UI JSON schemas per device/user                     |
| SSMParameterStack | Stores exported outputs for centralized access across stacks           |

---

## Frontend (Flutter + Amplify Hosting)

- *Auth*: Uses Amplify.Auth to manage login/signup/session
- *UI Rendering*: Fetches JSON-based layouts via AppSync + S3
- *Real-time updates*: Subscribes to AppSync GraphQL onDeviceStateChanged
- *Device control*: Sends mutations that trigger MQTT via Lambda

---

## Data Flow Summary

1. *User logs in* via Cognito using Flutter + Amplify.Auth
2. *App fetches UI layout* via AppSync → Lambda → S3 (JSON)
3. *User taps control* → AppSync mutation → Lambda → MQTT publish → ESP32 device
4. *Device sends update* → MQTT → IoT Rule → AppSync subscription → Flutter UI auto-updates

---

## Deployment & CI/CD

- *Backend*: GitHub → CodePipeline → CDK deploy
- *Frontend*: Flutter Web → Amplify Hosting → auto-deploy on push
- *Secrets*: Shared via SSM Parameter Store (encrypted)
- *Domain*: ak.lifewire.com served via Amplify

---

## In Progress / Roadmap

- [ ] Device provisioning (Fleet Provisioning + just-in-time registration)
- [ ] Voice assistant integration via AWS Bedrock chatbot
- [ ] Offline edge AI via Greengrass + SageMaker Edge
- [ ] Advanced energy analytics via IoT Analytics + Timestream
- [ ] Monetization: Stripe subscriptions + enterprise plans
- [ ] Emergency location tracking via AWS Location + SNS

---

## Strategic Advantages

- *Fully serverless* (no EC2, Kubernetes, or manual scaling)
- *AI-powered automation pipeline* (SageMaker, Bedrock, IoT Events)
- *Multi-tenant architecture*: Users only see/control their own devices
- *Developer-first architecture*: CI/CD, IaC, modern tooling
- *Modular CDK stacks*: Easy to extend, test, and scale independently

---

## AI Integration

- *Amazon Q*: Used for CDK optimization, guidance, and architecture validation
- *AWS Bedrock*: Plans for chatbot UI + voice assistant integration
- *SageMaker*: For anomaly detection, smart scheduling, energy insights
- *IoT Events*: For condition-based automation and fault detection

---

## Author & Project Lead

- *Name*: AK Lifewire
- *GitHub*: [github.com/AKlifewire](https://github.com/AKlifewire)
- *Domain*: [ak.lifewire.com](https://ak.lifewire.com)
- *Role*: Fullstack Cloud/IoT Architect, Founder

---

## Summary

This project isn’t just an app — it’s a *platform, a **career-launching product, and a **foundation for a smart home AI company. With modular infrastructure, real-time control, and AI-powered automation, you're paving the way for a **next-gen smart home platform* built the right way from Day 1.