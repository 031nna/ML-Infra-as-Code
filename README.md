# ML-Infra-as-Code
Sample end to end IAC of ML deployment and management.


Training guide: https://d1.awsstatic.com/training-and-certification/docs-machine-learning-engineer-associate/AWS-Certified-Machine-Learning-Engineer-Associate_Exam-Guide.pdf


Research: https://chatgpt.com/c/6921f965-f438-8327-b23f-df2efdf89573


Video tutorial on sagemaker: https://www.youtube.com/watch?v=Ld2oTLY47sA


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

