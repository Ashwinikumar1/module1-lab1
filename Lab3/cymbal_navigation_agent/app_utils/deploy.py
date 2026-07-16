import os
import argparse
from google.adk.cli.cli_deploy import to_agent_engine as deploy_agent

from cymbal_navigation_agent.agent import app

def main():
    parser = argparse.ArgumentParser(description="Deploy Cymbal Navigation Agent to Agent Runtime")
    parser.add_argument("--project", default=os.getenv("GOOGLE_CLOUD_PROJECT"), help="Google Cloud Project ID")
    parser.add_argument("--region", default="us-central1", help="GCP Region")
    parser.add_argument("--service-account", help="Service Account Email")
    args = parser.parse_args()

    print(f"Deploying Cymbal Navigation Agent to Agent Runtime in project: {args.project}, region: {args.region}...")
    
    # Deploy using ADK Agent Runtime deploy wrapper
    res = deploy_agent(
        app=app,
        project=args.project,
        location=args.region,
        service_account=args.service_account
    )
    print("Deployment triggered successfully!")
    print(res)

if __name__ == "__main__":
    main()
