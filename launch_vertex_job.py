import argparse
import datetime as dt
import shutil
import subprocess
from pathlib import Path


def get_latest_image_uri(
    docker_registry="europe-west2-docker.pkg.dev/prj-biomodal-forte/europe-ml-docker",
    image_name="test_boltz",
) -> str:
    """
    Get the latest image URI from the Google Cloud Artifact Registry.

    Args:
        region: Google Cloud Artifact Registry region
        project_id: Google Cloud project ID
        container_repository: container repository name
        image_name: image name

    Returns:
        the latest image URI
    """
    command_stdout = subprocess.run(
        [
            "gcloud",
            "artifacts",
            "docker",
            "tags",
            "list",
            f"{docker_registry}/{image_name}",
            "--sort-by=~TAG",
            "--limit=1",
            "--format=value(TAG)",
        ],
        capture_output=True,
        check=True,
        text=True,
    ).stdout

    latest_image_tag = command_stdout.strip()

    image_uri = f"{docker_registry}/{image_name}:{latest_image_tag}"

    return image_uri


def launch_folding_job(folder_id: str, parent_folder: str, operation: str, job_region: str, use_spot: bool = False):
    if job_region == "europe-west2":
        image_uri = get_latest_image_uri(docker_registry = "europe-west2-docker.pkg.dev/prj-biomodal-forte/europe-ml-docker")
    elif "us" in job_region:
        image_uri = get_latest_image_uri(docker_registry = "us-docker.pkg.dev/prj-biomodal-forte/us-ml-docker")
    else:
        image_uri = get_latest_image_uri(docker_registry = "europe-west2-docker.pkg.dev/prj-biomodal-forte/europe-ml-docker")

    datetime_now = dt.datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
    job_name = f"biomodal_boltz.{folder_id}.{datetime_now}"

    vm_configurations = {
        "L4": {
            # 4 NVIDIA L4 24GB GPU, 48 vCPUs, 192GB RAM
            "machine_type": "g2-standard-48",
            "accelerator_type": "NVIDIA_L4",
            "accelerator-count": 4,
            "replica_count": 1,
        },
    }

    vm_configuration = vm_configurations["L4"]
    command = [
            "gcloud",
            "ai",
            "custom-jobs",
            "create",
            f"--project=prj-biomodal-forte",
            f"--display-name={job_name}",
            f"--region={job_region}",
            f"--worker-pool-spec=machine-type={vm_configuration['machine_type']},"
            f"accelerator-type={vm_configuration['accelerator_type']},"
            f"replica-count={vm_configuration['replica_count']},"
            f"accelerator-count={vm_configuration['accelerator-count']},"
            f"container-image-uri={image_uri}",
            f"--args={folder_id},{parent_folder},{operation}",
        ]
    if use_spot:
        command.append("--config=config_for_spot.yaml")

    # launch folding job
    subprocess.run(
        command,
        check=True,
    )


def main():
    argument_parser = argparse.ArgumentParser()
    argument_parser.add_argument(
        "--folder_id", help="the folder id containing the yaml for this batch"
    )
    argument_parser.add_argument(
        "--parent_folder", help="the folder id containing the parent folder for this run"
    )
    argument_parser.add_argument(
        "--operation", help="the operation id to run for this batch"
    )
    argument_parser.add_argument(
        "--region", default="europe-west2", help="the region to use for this batch"
    )
    argument_parser.add_argument(
        "--use-spot", action="store_true", help="whether to use spot instances or not"
    )

    args = argument_parser.parse_args()

    folder_id = args.folder_id
    parent_folder = args.parent_folder
    operation = args.operation
    region = args.region
    use_spot = args.use_spot
    launch_folding_job(folder_id, parent_folder, operation, region, use_spot)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n" "interrupted with CTRL-C, exiting...")
