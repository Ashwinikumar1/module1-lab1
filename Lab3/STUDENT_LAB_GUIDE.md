# Lab 3: Building, Evaluating, Deploying & Publishing the Cymbal Navigation Agent with ADK

Welcome to **Lab 3** of Project Elevate. In this hands-on lab, you will act as a Lead AI & Solutions Engineer at **Cymbal Group**. You will take pre-developed agent code for the **Cymbal Navigation & Planner Agent**, validate its local execution, expand its evaluation dataset, run ADK evaluations, deploy it to Vertex AI Agent Runtime with BigQuery Observability, register it into Gemini Enterprise, and verify full 4-tier enterprise observability.

---

## 🎯 Learning Objectives

By completing this lab, you will learn how to:
1. **Verify GCP Environment & Enable Required APIs**: Validate `gcloud` credentials and enable Vertex AI, IAM, Telemetry, BigQuery, and Gemini Enterprise APIs.
2. **Local Agent Testing**: Execute interactive web-based playground sessions and CLI smoke tests using `agents-cli`.
3. **Execute ADK Agent Evaluation (Quality Flywheel)**: Expand the golden dataset (`evalset.json`) and run ADK quality flywheel evaluations using the `evaluation` skill.
4. **Deploy to Vertex AI Agent Runtime**: Deploy the agent to Vertex AI Agent Runtime (Reasoning Engine) with OpenTelemetry Cloud Tracing and BigQuery Agent Analytics enabled using the `deployment` skill.
5. **Publish & Register to Gemini Enterprise**: Programmatically register the deployed agent into Gemini Enterprise using the `publish` skill.
6. **Enable & Verify 4-Tier Enterprise Observability**: Execute test queries and audit telemetry across Cloud Trace spans, Prompt-Response logs, and BigQuery `agent_events` dataset queries using the `observability` skill.
7. **Leverage Agentic Skills**: Prompt your AI Coding Assistant (Antigravity) using high-level skill-based workflows.

---

## 📋 Prerequisites & Environment Setup

Before starting the lab tasks, satisfy the following setup requirements:

### 1. Account & GCP Project Authentication
* Ensure active GCloud authentication and Application Default Credentials (ADC):
  ```bash
  gcloud auth login
  gcloud auth application-default login
  ```
* Set active GCP Project ID and Vertex AI environment variables:
  ```bash
  export GCP_PROJECT_ID="YOUR_PROJECT_ID"
  export GOOGLE_CLOUD_PROJECT="YOUR_PROJECT_ID"
  export GOOGLE_CLOUD_LOCATION="global"
  export GOOGLE_GENAI_USE_VERTEXAI="true"
  gcloud config set project $GCP_PROJECT_ID
  ```

### 2. Standard Installed Tools
* **Google Agents CLI (`agents-cli`)**: Pre-installed via `uv tool install google-agents-cli`.
* **Python Runtime & UV**: Python 3.10+ and `uv` package manager.

---

## 🏢 Business Scenario: The Cymbal Navigation & Planner Agent

**Cymbal Group** requires an enterprise location-aware travel and event planning assistant. The customer engineering team has provided pre-developed agent source code in `cymbal_navigation_agent/`. 

The agent integrates two primary tool capabilities:
1. **Google Search Tool (`GoogleSearchTool`)**: Native search grounding tool for real-time web intelligence, local event details, and venue reviews.
2. **Google Maps API Tools (`search_google_maps` & `get_route_directions`)**: Custom API tools for physical address lookups, ratings, coordinates, and multi-modal transit/driving directions.

---

## ⚙️ Step 0: Mandatory GCP Preflight Check

Before starting local testing or deployment, run the preflight verification script:

```bash
bash scripts/preflight_check.sh
```

---

## 💻 Step 1: Local Agent Testing

Verify local agent execution using the web playground:

```bash
agents-cli playground
```
Access the local UI playground at `http://127.0.0.1:8080/dev-ui/?app=cymbal_navigation_agent`.

---

## 🚀 Student Lab Tasks (4 Core Skill-Driven Tasks)

In this lab, you will use **Agentic Skills** located in `skills/` (and `.agents/skills/`). Rather than typing raw low-level terminal commands, you will instruct your AI assistant (Antigravity) using **high-level agentic prompts** that leverage these pre-built skills.

---

### Task 1: Expand Golden Evaluation Dataset & Execute ADK Evaluation

**Goal**: Expand the evaluation dataset (`tests/eval/datasets/evalset.json`) with additional complex multi-turn travel and navigation scenarios, then execute the ADK evaluation flywheel to evaluate task success, tool quality, trajectory quality, and navigation accuracy.

#### 💡 High-Level Prompt for your AI Assistant:
> *"Please open the `evaluation` skill ([skills/evaluation/SKILL.md](file:///Users/ashwinikm/Desktop/Project_Elevate/projectelevate-module1/Lab3/skills/evaluation/SKILL.md)). First, add 2 new multi-turn travel evaluation test cases to `tests/eval/datasets/evalset.json` testing combined event search and driving directions. Then, execute the ADK evaluation flywheel using `tests/eval/eval_config.yaml` and generate the evaluation report artifact at `artifacts/docs/step9_eval_report.md`."*

#### Evaluated Metrics:
* **`multi_turn_task_success`**: Goal completion across multi-turn queries.
* **`multi_turn_tool_use_quality`**: Function call accuracy for Google Search and Google Maps tools.
* **`multi_turn_trajectory_quality`**: Planning step efficiency.
* **`navigation_accuracy_judge`**: Custom LLM judge checking address accuracy and route clarity.

#### Expected Output Artifact:
* `artifacts/docs/step9_eval_report.md`

---

### Task 2: Deploy Agent to Vertex AI Agent Runtime with BigQuery Observability

**Goal**: Deploy the `cymbal_navigation_agent` to managed Vertex AI Agent Runtime (Reasoning Engine) with OpenTelemetry Cloud Tracing (`gcp_trace`) and BigQuery Agent Analytics enabled (`--bq`).

#### 💡 High-Level Prompt for your AI Assistant:
> *"Please follow the `deployment` skill ([skills/deployment/SKILL.md](file:///Users/ashwinikm/Desktop/Project_Elevate/projectelevate-module1/Lab3/skills/deployment/SKILL.md)). Deploy the `cymbal_navigation_agent` to Vertex AI Agent Runtime with global model resolution enabled (`GOOGLE_CLOUD_LOCATION=global`), OpenTelemetry trace exporter set to `gcp_trace`, and BigQuery telemetry analytics enabled (`--bq`). Document the deployment output in `artifacts/docs/step10_deploy_report.md` and save raw logs to `artifacts/docs/step10_deploy_log.txt`."*

#### Deployment Rules:
* Sets `GOOGLE_CLOUD_LOCATION=global` for global model resolution (`gemini-2.5-flash`).
* Enables `--bq` for automated BigQuery streaming telemetry export.

#### Expected Output Artifacts:
* `artifacts/docs/step10_deploy_log.txt`
* `artifacts/docs/step10_deploy_report.md`

---

### Task 3: Publish & Register Deployed Agent to Gemini Enterprise

**Goal**: Register the deployed Reasoning Engine instance into Gemini Enterprise Engine & Collection so enterprise users can discover and interact with the agent.

#### 💡 High-Level Prompt for your AI Assistant:
> *"Please follow the `publish` skill ([skills/publish/SKILL.md](file:///Users/ashwinikm/Desktop/Project_Elevate/projectelevate-module1/Lab3/skills/publish/SKILL.md)). Read the deployed Reasoning Engine metadata from `deployment_metadata.json` and publish the agent to Gemini Enterprise under the collection engine `projects/$GCP_PROJECT_ID/locations/global/collections/default_collection/engines/cymbal-app` with the display name 'Cymbal Navigation Agent'. Generate `artifacts/docs/step16_publish_report.md` upon completion."*

#### Expected Output Artifacts:
* `artifacts/docs/step16_publish_log.txt`
* `artifacts/docs/step16_publish_report.md`

---

### Task 4: Execute Live Test Queries & Verify 4-Tier Observability

**Goal**: Run live test queries against the deployed agent instance to generate telemetry traffic, then audit all 4 enterprise observability tiers (Cloud Trace spans, Prompt-Response logs, BigQuery `agent_events` dataset queries, and third-party metrics).

#### 💡 High-Level Prompt for your AI Assistant:
> *"Please use the `observability` skill ([skills/observability/SKILL.md](file:///Users/ashwinikm/Desktop/Project_Elevate/projectelevate-module1/Lab3/skills/observability/SKILL.md)). Execute sample test queries against the deployed Reasoning Engine resource ID. Then verify telemetry across 4 tiers: audit Cloud Trace spans for `invoke_agent` and `execute_tool`, verify prompt-response privacy logs, run a BigQuery SQL query against `$GCP_PROJECT_ID.telemetry.agent_events`, and record the output in `artifacts/docs/step17_observability_report.md`."*

#### 4 Observability Tiers Verified:
1. **Cloud Trace**: OpenTelemetry span hierarchy (`invoke_agent` → `execute_tool`).
2. **Prompt-Response Logging**: Privacy payload logging policies.
3. **BigQuery Agent Analytics**: Streaming SQL queries on `agent_events` table.
4. **Third-Party Metrics**: Telemetry export hooks.

#### Expected Output Artifacts:
* `artifacts/docs/step17_observability_log.txt`
* `artifacts/docs/step17_observability_report.md`

---

## 🔍 Verification: How to Verify Gemini Enterprise (GE) Deployment

After completing Task 3 & Task 4, verify that your agent is correctly registered and live on Gemini Enterprise using either of the following methods:

### Method 1: CLI Verification
Check registered agents using `agents-cli`:

```bash
agents-cli publish status \
  --gemini-enterprise-app-id "projects/$GCP_PROJECT_ID/locations/global/collections/default_collection/engines/cymbal-app"
```

Expected response should confirm:
* **Registration Mode**: `ADK` (Reasoning Engine wrapper)
* **Resource ID**: `projects/<PROJECT_NUMBER>/locations/us-central1/reasoningEngines/<REASONING_ENGINE_ID>`
* **Status**: `ACTIVE`

### Method 2: GCP Console / Gemini Enterprise Web Interface Verification
1. Open the GCP Console and navigate to **Vertex AI Agent Builder / Discovery Engine**:
   `https://console.cloud.google.com/gen-app-builder/engines?project=YOUR_PROJECT_ID`
2. Select your Engine ID: **`cymbal-app`**.
3. Under **Agents / Assistants**, verify that **`Cymbal Navigation Agent`** appears in the active agent list.
4. Click **Preview / Test Agent** in the UI and enter a test prompt:
   > *"How do I get from SFO Airport to Moscone Center?"*
5. Confirm that the agent returns structured travel recommendations with tool execution traces visible.

---

## 🛠️ Summary of Available Agent Skills

| Skill | Location | Purpose |
|---|---|---|
| **Preflight Check** | `scripts/preflight_check.sh` | Validates GCP credentials & enables required APIs |
| **`evaluation`** | [skills/evaluation/SKILL.md](file:///Users/ashwinikm/Desktop/Project_Elevate/projectelevate-module1/Lab3/skills/evaluation/SKILL.md) | ADK quality flywheel dataset execution & scoring |
| **`deployment`** | [skills/deployment/SKILL.md](file:///Users/ashwinikm/Desktop/Project_Elevate/projectelevate-module1/Lab3/skills/deployment/SKILL.md) | Deploys agent to Vertex AI Reasoning Engine with BQ telemetry |
| **`publish`** | [skills/publish/SKILL.md](file:///Users/ashwinikm/Desktop/Project_Elevate/projectelevate-module1/Lab3/skills/publish/SKILL.md) | Registers Reasoning Engine into Gemini Enterprise App |
| **`observability`** | [skills/observability/SKILL.md](file:///Users/ashwinikm/Desktop/Project_Elevate/projectelevate-module1/Lab3/skills/observability/SKILL.md) | Verifies 4-tier telemetry (Cloud Trace, BQ SQL, Privacy) |

---

## ✅ Submission Checklist

- [ ] Completed GCP Preflight Check (`scripts/preflight_check.sh`).
- [ ] Validated local execution via `agents-cli playground`.
- [ ] Completed Task 1 (Evaluation & Dataset Expansion) → `artifacts/docs/step9_eval_report.md`.
- [ ] Completed Task 2 (Vertex AI Agent Runtime Deployment) → `artifacts/docs/step10_deploy_report.md`.
- [ ] Completed Task 3 (Gemini Enterprise Registration) → `artifacts/docs/step16_publish_report.md`.
- [ ] Completed Task 4 (4-Tier Observability Verification) → `artifacts/docs/step17_observability_report.md`.
- [ ] Verified Gemini Enterprise deployment via CLI status or Web UI.

---
*End of Student Lab Guide.*
