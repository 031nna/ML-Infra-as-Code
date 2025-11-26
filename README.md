# ML-Infra-as-Code
🚀 Project: Predictive Aircraft Part Replacement System (Predictive Maintenance ML Pipeline)


Training guide: https://d1.awsstatic.com/training-and-certification/docs-machine-learning-engineer-associate/AWS-Certified-Machine-Learning-Engineer-Associate_Exam-Guide.pdf


Research: https://chatgpt.com/c/6921f965-f438-8327-b23f-df2efdf89573

Dataset: NASA CMAPSS Jet Engine Simulated Data https://catalog.data.gov/dataset/cmapss-jet-engine-simulated-data

AWS console: https://us-east-2.console.aws.amazon.com/console/home?nc2=h_si&refid=da5a4023-2af6-4275-9a1e-478c6572e2c6&region=us-east-2&src=header-signin#

Video tutorial on sagemaker: https://www.youtube.com/watch?v=Ld2oTLY47sA
Video on AI Engineering: https://www.youtube.com/watch?v=j_StCjwpfmk
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
