# ML-Infra-as-Code

**Predictive Maintenance ML Pipeline for Aircraft Engines**
*End-to-end cloud-native ML platform on AWS — from raw sensor data to real-time failure predictions.*

---

## Overview

Aircraft engine failures are costly, dangerous, and — with sufficient data — predictable. This project implements a full **Predictive Maintenance ML Pipeline** that ingests raw engine sensor data, processes it through a cloud-native ETL pipeline, trains a machine learning model, and exposes predictions via a real-time inference API.

Built on NASA's CMAPSS jet engine dataset, the pipeline is fully defined as **Infrastructure as Code** using Terraform, making it reproducible, auditable, and deployable from scratch.

### Why Predictive Maintenance?

| Approach | Characteristic |
|---|---|
| **Scheduled maintenance** | Time-based, fixed intervals — risks unexpected failure or over-maintenance |
| **Reactive maintenance** | Act after failure — maximizes downtime and cost |
| **Predictive maintenance** | Condition-based, data-driven — replace parts only when failure is imminent |

Predictive maintenance reduces unplanned downtime, extends component life, and lowers operational cost — particularly critical in aviation where equipment failure has direct safety implications.

---

## Architecture

The pipeline maps seven sequential stages to managed AWS services:

```
┌──────────────────┐
│   Raw Dataset    │   ← NASA CMAPSS sensor data uploaded to S3
│   (S3 Raw)       │
└────────┬─────────┘
         │  (Event-driven or Scheduled)
         ▼
┌──────────────────┐
│    AWS Glue      │   ← ETL: cleaning, normalization, feature engineering
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│   AWS Athena     │   ← SQL-based feature validation and exploration
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ SageMaker Train  │   ← Managed training job on processed feature set
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Model Registry   │   ← Versioned model artifacts with approval workflow
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Deploy Endpoint  │   ← Real-time SageMaker inference endpoint
└────────┬─────────┘
         │
         ▼
   API Gateway + Lambda
         │
         ▼
   Downstream Service / Application
```

---

## Key Features

- **Predictive Modeling** — Remaining Useful Life (RUL) regression trained on jet engine multi-variate sensor streams
- **End-to-End ML Pipeline** — Automated flow from raw data ingestion through to a deployed, queryable endpoint
- **Infrastructure as Code** — All AWS resources provisioned via Terraform: VPC, IAM, SageMaker Domain, and Notebook Instance
- **Real-Time Inference** — Low-latency predictions served through API Gateway and Lambda

---

## Tech Stack

| Layer | Service |
|---|---|
| **Data Storage** | AWS S3 — raw and processed data lake |
| **ETL / Preprocessing** | AWS Glue — managed PySpark data transformation |
| **Data Validation** | AWS Athena — SQL queries over S3 |
| **ML Training** | AWS SageMaker — managed training jobs |
| **Model Management** | SageMaker Model Registry — versioning and approval |
| **Inference** | SageMaker Real-Time Endpoint |
| **API Layer** | AWS API Gateway + AWS Lambda |
| **Infrastructure** | Terraform (HashiCorp) |

---

## Dataset

This project uses the **NASA CMAPSS (Commercial Modular Aero-Propulsion System Simulation)** dataset — a standard benchmark for predictive maintenance research.

- **Source:** [NASA CMAPSS Jet Engine Simulated Data](https://catalog.data.gov/dataset/cmapss-jet-engine-simulated-data)
- **Content:** Multi-variate time-series of 21 sensor readings from simulated jet engines across multiple operational conditions and fault modes
- **Target:** Remaining Useful Life (RUL) — number of operational cycles remaining before engine failure
- **Scale:** Thousands of engine run-to-failure cycles across four sub-datasets (FD001–FD004), varying in complexity and operating conditions

---

## Pipeline Flow

### 1. Data Ingestion
Raw CMAPSS files are uploaded to an **S3 raw data bucket**. An event notification or scheduled trigger initiates the downstream pipeline.

### 2. ETL — AWS Glue
A Glue job reads the raw sensor data, applies normalization and feature engineering (e.g., rolling-window statistics over sensor readings), and writes the processed dataset back to S3 in a query-optimized format.

### 3. Feature Validation — AWS Athena
Athena runs SQL queries over the processed S3 data to validate feature distributions, detect nulls, and confirm schema correctness before training begins.

### 4. Model Training — AWS SageMaker
A SageMaker training job consumes the validated feature set and trains a regression model to predict Remaining Useful Life (RUL). The trained model artifact is stored in S3.

### 5. Model Registry
The trained model is registered in the **SageMaker Model Registry** with versioning and an approval gate, enabling controlled promotion to production.

### 6. Endpoint Deployment
An approved model version is deployed to a **SageMaker real-time inference endpoint**, making predictions available at low latency.

### 7. Inference API
**API Gateway + Lambda** expose the SageMaker endpoint as a REST API, providing a clean interface for downstream applications or services.

---

## Setup and Deployment

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- AWS CLI configured with a valid profile (default: `aws_david_dev`)
- An S3 bucket and DynamoDB table provisioned for remote Terraform state (see [Security](#security))

### Configuration

Variables are defined in `terraform/variables.tf`. Override as needed:

| Variable | Default | Description |
|---|---|---|
| `aws_region` | `us-east-1` | Target AWS region |
| `aws_profile` | `aws_david_dev` | AWS CLI named profile |
| `instance_type` | `ml.t3.medium` | SageMaker Notebook instance type |

### Deploy Infrastructure

```bash
cd terraform

# Initialize providers and configure remote backend
terraform init

# Preview what will be created
terraform plan

# Provision all resources
terraform apply
```

This provisions:

- A VPC with two public subnets (`us-east-1a`, `us-east-1b`)
- A security group permitting HTTPS (443) inbound
- An IAM execution role for SageMaker with S3 and SageMaker permissions
- A SageMaker Studio Domain and user profile
- A SageMaker Notebook Instance (`ml.t3.medium` by default)

### Tear Down

```bash
terraform destroy
```

> **Note:** Destroying a SageMaker Domain requires all active apps and user profiles to be stopped first from the AWS Console or CLI.

---

## Security

### Terraform Remote State

Terraform state files contain sensitive resource metadata and must **never be committed to version control**. Store state remotely with encryption and distributed locking:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "ml-infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

**Recommended setup:**

- Create a dedicated S3 bucket with versioning and server-side encryption (SSE-S3 or SSE-KMS) enabled
- Create a DynamoDB table with `LockID` (String) as the partition key to prevent concurrent state writes
- Restrict bucket access via IAM — only authorized CI/CD roles or principals should have read/write access
- Enable S3 access logging for audit trails

The `.gitignore` in this repository excludes `*.tfstate`, `*.tfstate.backup`, and the `.terraform/` directory.

---

## Resources

| Resource | Link |
|---|---|
| AWS ML Engineer Associate Exam Guide | [AWS Training Docs](https://d1.awsstatic.com/training-and-certification/docs-machine-learning-engineer-associate/AWS-Certified-Machine-Learning-Engineer-Associate_Exam-Guide.pdf) |
| NASA CMAPSS Dataset | [data.gov](https://catalog.data.gov/dataset/cmapss-jet-engine-simulated-data) |
| SageMaker Studio Dashboard | [AWS Console — us-east-1](https://us-east-1.console.aws.amazon.com/sagemaker/home?region=us-east-1#/notebooks-and-git-repos) |
| SageMaker Video Tutorial | [YouTube](https://youtu.be/Ld2oTLY47sA?t=3743) |

---

## Future Improvements

- **CI/CD for ML** — Automated retraining triggered by new data arrivals via SageMaker Pipelines or AWS Step Functions
- **Model Monitoring** — SageMaker Model Monitor for ongoing data quality and model quality checks in production
- **Drift Detection** — Automated alerts when input feature distributions shift relative to the training baseline
- **Least-Privilege IAM** — Replace broad managed policies with scoped, resource-level custom policies
- **Multi-Environment Support** — Separate Terraform workspaces or state paths for dev, staging, and production

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

## Contributing

Contributions, issues, and feature requests are welcome. Please open an issue before submitting a pull request.
