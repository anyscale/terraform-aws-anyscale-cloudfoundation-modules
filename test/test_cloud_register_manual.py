# This script will be used by SA team to:
# Test the following functionalities work well together:
# 1. terraform
# 2. cloud register
# 3. cloud functional verification

# Prerequisites:
# 1. (for AWS) Use the AWS credentials that you want to create resources in.
#    (for GCP) It will need your GCP credentials as you run.
# 2. Use the anyscale credentials that you want to register the cloud to.
# 3. Have terraform installed and python package python_terraform installed.
# 4. Run this script in product repo.

from datetime import datetime
import re
import subprocess
import argparse
import boto3
from google.cloud import storage
import time
from rich.progress import track

from python_terraform import IsFlagged, IsNotFlagged, Terraform

from anyscale.controllers.cloud_controller import CloudController


# Feel free to edit the following variables for AWS
def _get_terraform_anyscale_v2_e2e_public_vars_aws():
    """Get the variables for the aws terraform apply.
    The variables are required by the terraform as input variables.
    """
    return {
        "aws_region": "us-east-2",
        "customer_ingress_cidr_ranges": "0.0.0.0/0",
        "anyscale_access_role_trusted_role_arns": [
            "arn:aws:iam::623395924981:root",  # staging
            "arn:aws:iam::521861002309:root",  # predeploy
            "arn:aws:iam::525325868955:root",  # production
        ],
    }


# Feel free to edit the following variables for GCP
def _get_terraform_anyscale_v2_e2e_public_vars_gcp(
    billing_account_id: str, anyscale_org_id: str, root_folder_number: str
):
    """Get the variables for the gcp anyscale-v2-commonname terraform apply.
    The variables are required by the terraform as input variables.
    """
    return {
        "anyscale_google_region": "us-central1",
        "anyscale_google_zone": "us-central1-a",
        "anyscale_org_id": anyscale_org_id,  # Anyscale org id.
        "customer_ingress_cidr_ranges": "0.0.0.0/0",  # Suggested by the terraform.  # noqa: E501
        "root_folder_number": root_folder_number,  # This is the folder id of the folder "cloud-setup-terraform-test" in gcp.  # noqa: E501
        "billing_account_id": billing_account_id,
    }


def _parse_registration_command(input_string):
    """Parse the registration command from the terraform output."""
    pattern = r"EOT\n(.*?)EOT"
    match = re.search(pattern, input_string, re.DOTALL)
    if not match:
        return None

    registration_command = match.group(1)
    print(registration_command)
    return _parse_options(registration_command)


def _parse_options(input_string):
    """Parse the options from the registration command."""
    matches = re.findall(r"--(\S+?)\s(\S+)", input_string)
    return {key: value.strip() for key, value in matches}


def start_aws_test(branch_name: str, local_path: str):
    # If you have some error like "destination path 'terraform-aws-anyscale-cloudfoundation-modules' already exists and is not an empty directory",  # noqa: E501
    # remove the terraform-aws-anyscale-cloudfoundation-modules folder and run this script again.  # noqa: E501
    # "sudo rm -r terraform-aws-anyscale-cloudfoundation-modules"
    print("Starting aws test...")

    if local_path:
        print("Using local path...")
        working_dir = local_path
    else:
        print("Cloning the repo...")
        repo_url = "https://github.com/anyscale/terraform-aws-anyscale-cloudfoundation-modules/"
        subprocess.check_call(["git", "clone", repo_url])
        # Checkout to a specific branch
        subprocess.check_call(
            ["git", "checkout", branch_name],
            cwd="terraform-aws-anyscale-cloudfoundation-modules",
        )
        working_dir = "terraform-aws-anyscale-cloudfoundation-modules/test/anyscale-v2-e2e-public-test"  # noqa: E501

    tf = Terraform(
        working_dir=working_dir,
        variables=_get_terraform_anyscale_v2_e2e_public_vars_aws(),
    )
    tf.init()
    print(
        "Applying anyscale_v2_e2e_public aws terraform... (It will take about 2~5 minutes)"  # noqa: E501
    )
    # To debug, we can add capture_output=False to see the stdout, in which case the stdout will be None.  # noqa: E501
    return_code, stdout, stderr = tf.apply(skip_plan=True)
    if return_code != 0:
        raise RuntimeError(
            f"Error applying anyscale_v2_e2e_public aws terraform: {stderr}"
        )
    print(f"Applied anyscale_v2_e2e_public aws result: {stdout}")

    ## Register the cloud.
    cloud_name = (
        f"test_terraform_anyscale_v2_e2e_public_aws_{datetime.now().isoformat()}"
    )
    stdout_dict = _parse_registration_command(stdout)
    print(f"Parsed stdout_dict: {stdout_dict}")
    s3_bucket_id = stdout_dict.get("s3-bucket-id")
    memorydb_cluster_id = stdout_dict.get("memorydb-cluster-id", None)
    print("Registering cloud...")
    try:
        cloud_controller = CloudController()
        cloud_controller.register_aws_cloud(
            region=stdout_dict.get("region"),
            name=cloud_name,
            vpc_id=stdout_dict.get("vpc-id"),
            subnet_ids=stdout_dict.get("subnet-ids").split(","),
            efs_id=stdout_dict.get("efs-id"),
            anyscale_iam_role_id=stdout_dict.get("anyscale-iam-role-id"),
            instance_iam_role_id=stdout_dict.get("instance-iam-role-id"),
            security_group_ids=stdout_dict.get("security-group-ids").split(","),
            s3_bucket_id=s3_bucket_id,
            # change to functional_verify="workspace,service" once service is ready.
            # For functional verify, the console will ask for your confirm to proceed.
            functional_verify=None,
            private_network=False,
            cluster_management_stack_version="v2",
            memorydb_cluster_id=memorydb_cluster_id,
            yes=True,
        )
        print("Cloud registered successfully")
    except Exception as e:
        print(f"Error registering cloud: {e}")

    # pause for 3 min to wait for Anyscale to be ready
    for i in track(range(60 * 3), description="Waiting for Anyscale to ready..."):
        time.sleep(1)

    cloud_controller.verify_cloud(
        cloud_name=cloud_name,
        cloud_id=None,
        strict=True,
        functional_verify="workspace,service",
        yes=True,
    )

    ## Delete the cloud.
    try:
        print("Deleting cloud...")
        cloud_controller.delete_cloud(
            cloud_name=cloud_name,
            cloud_id="",
            skip_confirmation=True,
        )
        print("Cloud deleted successfully")
    except Exception as e:
        print(f"Error deleting cloud: {e}")

    ## Emptying the s3 bucket.
    print(f"Emptying s3 bucket {s3_bucket_id}...")
    s3_client = boto3.client("s3")
    object_response_paginator = s3_client.get_paginator("list_object_versions")
    delete_marker_list = []
    version_list = []
    for object_response_itr in object_response_paginator.paginate(Bucket=s3_bucket_id):
        if "DeleteMarkers" in object_response_itr:
            for delete_marker in object_response_itr["DeleteMarkers"]:
                delete_marker_list.append(
                    {
                        "Key": delete_marker["Key"],
                        "VersionId": delete_marker["VersionId"],
                    }
                )

        if "Versions" in object_response_itr:
            for version in object_response_itr["Versions"]:
                version_list.append(
                    {"Key": version["Key"], "VersionId": version["VersionId"]}
                )

    for i in range(0, len(delete_marker_list), 1000):
        response = s3_client.delete_objects(
            Bucket=s3_bucket_id,
            Delete={"Objects": delete_marker_list[i : i + 1000], "Quiet": True},
        )
        print(response)

    for i in range(0, len(version_list), 1000):
        response = s3_client.delete_objects(
            Bucket=s3_bucket_id,
            Delete={"Objects": version_list[i : i + 1000], "Quiet": True},
        )
        print(response)

    print(f"S3 bucket {s3_bucket_id} emptied successfully")
    ## Destroy the terraform.
    print("Destroying anyscale_v2_e2e_public aws terraform...")
    return_code, stdout, stderr = tf.destroy(force=IsNotFlagged, auto_approve=IsFlagged)
    if return_code != 0:
        raise RuntimeError(
            f"Error destroying anyscale_v2_e2e_public aws terraform: {stderr}"
        )
    print(f"Destroyed anyscale_v2_e2e_public aws terraform successfully {stdout}")


def start_gcp_test(
    branch_name: str,
    local_path: str,
    gcp_billing_id: str,
    anyscale_org_id: str,
    root_folder_number: str,
):
    if local_path:
        print("Using local path...")
        working_dir = local_path
    else:
        print("Cloning the repo...")
        repo_url = "https://github.com/anyscale/terraform-google-anyscale-cloudfoundation-modules/"
        subprocess.check_call(["git", "clone", repo_url])
        # Checkout to a specific branch
        subprocess.check_call(
            ["git", "checkout", branch_name],
            cwd="terraform-aws-anyscale-cloudfoundation-modules",
        )
        working_dir = "terraform-google-anyscale-cloudfoundation-modules/test/anyscale-v2-e2e-public-test"  # noqa: E501  # noqa: E501

    tf = Terraform(
        working_dir=working_dir,
        variables=_get_terraform_anyscale_v2_e2e_public_vars_gcp(
            gcp_billing_id, anyscale_org_id, root_folder_number
        ),
    )
    tf.init()
    print(
        "Applying anyscale_v2_e2e_public gcp terraform... (It will take about 10 minutes)"  # noqa: E501
    )
    # To debug, we can add capture_output=False to see the stdout, in which case the stdout will be None.  # noqa: E501
    return_code, stdout, stderr = tf.apply(skip_plan=True)
    if return_code != 0:
        raise RuntimeError(
            f"Error applying anyscale_v2_e2e_public gcp terraform: {stderr}"
        )
    print(f"Applied anyscale_v2_e2e_public gcp result: {stdout}")

    # pause for 2 min to wait for GCP to be ready
    for i in track(range(60 * 1), description="Waiting for GCP to ready..."):
        time.sleep(1)

    ## Register the cloud.
    cloud_name = (
        f"test_terraform_anyscale_v2_e2e_public_gcp_{datetime.now().isoformat()}"
    )
    stdout_dict = _parse_registration_command(stdout)
    print(f"Parsed stdout_dict: {stdout_dict}")
    print("Registering gcp cloud...")

    bucket_name = stdout_dict.get("cloud-storage-bucket-name")
    try:
        cloud_controller = CloudController()
        cloud_controller.register_gcp_cloud(
            region=stdout_dict.get("region"),
            name=cloud_name,
            project_id=stdout_dict.get("project-id"),
            vpc_name=stdout_dict.get("vpc-name"),
            subnet_names=stdout_dict.get("subnet-names").split(","),
            filestore_instance_id=stdout_dict.get("filestore-instance-id"),
            filestore_location=stdout_dict.get("filestore-location"),
            anyscale_service_account_email=stdout_dict.get(
                "anyscale-service-account-email"
            ),
            instance_service_account_email=stdout_dict.get(
                "instance-service-account-email"
            ),
            provider_id=stdout_dict.get("provider-name"),
            firewall_policy_names=stdout_dict.get("firewall-policy-names").split(","),
            cloud_storage_bucket_name=bucket_name,
            # change to functional_verify="workspace,service" once service is ready.
            # For functional verify, the console will ask for your confirm to proceed.
            functional_verify=None,
            private_network=False,
            cluster_management_stack_version="v2",
            memorystore_instance_name=None,
            yes=True,
        )
        print("Cloud registered successfully")
    except Exception as e:
        print(f"Error registering gcp cloud: {e}")

    # pause for 3 min to wait for Anyscale to be ready
    for i in track(range(60 * 3), description="Waiting for Anyscale to ready..."):
        time.sleep(1)

    cloud_controller.verify_cloud(
        cloud_name=cloud_name,
        cloud_id=None,
        strict=True,
        functional_verify="workspace",
        yes=True,
    )

    ## Delete the cloud.
    try:
        cloud_controller.delete_cloud(
            cloud_name=cloud_name,
            cloud_id="",
            skip_confirmation=True,
        )
        print("GCP Cloud deleted successfully")
    except Exception as e:
        print(f"Error deleting gcp cloud: {e}")

    ## Emptying bucket
    print(f"Emptying bucket {bucket_name}...")
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    # get all objects and delete them
    blobs = bucket.list_blobs()
    for blob in track(blobs, description=f"Emptying bucket {bucket_name}"):
        blob.delete()

    ## Destroy the terraform.
    print("Destroying anyscale_v2_e2e_public gcp terraform...")
    return_code, stdout, stderr = tf.destroy(force=IsNotFlagged, auto_approve=IsFlagged)
    if return_code != 0:
        raise RuntimeError(
            f"Error destroying anyscale_v2_e2e_public gcp terraform: {stderr}"
        )
    print(f"Destroyed anyscale_v2_e2e_public gcp terraform successfully {stdout}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--cloud-provider",
        "-c",
        required=True,
        type=str.lower,
        dest="cloudProvider",
        help="The cloud provider to use",
    )
    parser.add_argument(
        "--gcp-billing-id",
        "-g",
        type=str,
        dest="gcpBillingId",
        help="The GCP billing id to use",
    )
    parser.add_argument(
        "--anyscale-org-id",
        "-o",
        type=str,
        dest="anyscaleOrgId",
        help="The Anyscale org id to use",
    )
    parser.add_argument(
        "--root-folder-number",
        "-r",
        type=str,
        dest="rootFolderNumber",
        help="The root folder number to use",
    )
    argGroup = parser.add_mutually_exclusive_group(required=True)
    argGroup.add_argument(
        "--branch-name",
        "-b",
        type=str,
        dest="branchName",
        help="The branch name to use",
    )
    argGroup.add_argument(
        "--local_path",
        "-l",
        type=str,
        dest="localPath",
        help="The local path to use",
    )
    # branch_name = input("What is your branch name? ")
    args, _ = parser.parse_known_args()
    cloud_provider = args.cloudProvider
    branch_name = args.branchName
    local_path = args.localPath

    if cloud_provider == "aws":
        start_aws_test(branch_name, local_path)
    elif cloud_provider == "gcp":
        gcp_billing_id = args.gcpBillingId
        if not gcp_billing_id:
            raise RuntimeError(
                "Please provide the GCP billing id with --gcp-billing-id"
            )
        anyscale_org_id = args.anyscaleOrgId
        if not anyscale_org_id:
            raise RuntimeError(
                "Please provide the Anyscale org id with --anyscale-org-id"
            )
        root_folder_number = args.rootFolderNumber
        if not root_folder_number:
            raise RuntimeError(
                "Please provide the root folder number with --root-folder-number"
            )
        start_gcp_test(
            branch_name, local_path, gcp_billing_id, anyscale_org_id, root_folder_number
        )
    else:
        raise RuntimeError(f"Unsupported cloud provider: {cloud_provider}")
