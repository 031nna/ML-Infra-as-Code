# ML-Infra-as-Code
🚀 Project: Predictive Aircraft Part Replacement System (Predictive Maintenance ML Pipeline)



Training guide: https://d1.awsstatic.com/training-and-certification/docs-machine-learning-engineer-associate/AWS-Certified-Machine-Learning-Engineer-Associate_Exam-Guide.pdf

Dataset: NASA CMAPSS Jet Engine Simulated Data https://catalog.data.gov/dataset/cmapss-jet-engine-simulated-data

Sagemaker dashboard:https://us-east-1.console.aws.amazon.com/sagemaker/home?region=us-east-1#/notebooks-and-git-repos

```
    ┌────────────┐
    │   Dataset  │  
    │ (S3 Raw)   │
    └─────┬──────┘
          │
   (Event or Scheduled)
          ▼
    ┌────────────┐
    │   Glue     │  ← ETL / preprocessing
    └─────┬──────┘
          │
          ▼
    ┌────────────┐
    │  Athena    │  ← exploration, feature validation
    └─────┬──────┘
          │
          ▼
   ┌──────────────────┐
   │ SageMaker Train  │  ← training job
   └──────┬───────────┘
          │
          ▼
   ┌──────────────────┐
   │ Model Registry    │
   └──────┬───────────┘
          │
          ▼
   ┌──────────────────┐
   │ Deploy Endpoint  │  ← real-time inference
   └──────┬───────────┘
          │
          ▼
     API Gateway + Lambda
          │
          ▼
     Frontend / Service

```
