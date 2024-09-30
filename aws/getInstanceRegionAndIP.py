import argparse
import sys
import boto3
from botocore.exceptions import ClientError


def search_instances(region, instance_ids, profile, quiet):
    session = boto3.Session(profile_name=profile)
    ec2_client = session.client('ec2', region_name=region)

    for instance_id in instance_ids:
        try:
            response = ec2_client.describe_instances(InstanceIds=[instance_id])

            for reservation in response['Reservations']:
                for instance in reservation['Instances']:
                    instance_id = instance['InstanceId']
                    private_ip = instance['PrivateIpAddress']
                    print("\n-----------------------------")
                    print(f"Instance ID: {instance_id}")
                    print(f"Region: {region}")
                    print(f"Private IP: {private_ip}")
                    print("-----------------------------")

                    # Instance found, move on to the next instance ID
                    break

                # Instance found, move on to the next instance ID
                if instance_id == instance['InstanceId']:
                    break

        except ClientError as e:
            if e.response['Error']['Code'] == 'InvalidInstanceID.NotFound':
                if not quiet:
                    print(f"'{instance_id}' not found in region {region}", file=sys.stderr)
            else:
                print(f"Error in region {region}: {str(e)}", file=sys.stderr)


def search_instances_across_regions(instance_ids, regions, profile, quiet, progress):
    for instance_id in instance_ids:
        for region in regions:
            try:
                search_instances(region, [instance_id], profile, quiet)
                if progress:
                    print(".", end='', flush=True)
            except ClientError as e:
                print(f"Error occurred while searching instances in region {region}: {str(e)}", file=sys.stderr)

        if progress:
            print()  # Print a newline after checking all regions for an instance ID


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Search AWS instances across regions.')
    parser.add_argument('--instances', nargs='+', help='Instance IDs to search')
    parser.add_argument('--regions', nargs='+', help='Regions to search')
    parser.add_argument('--profile', help='AWS profile name')
    parser.add_argument('--quiet', action='store_true', help='Suppress standard error output')
    parser.add_argument('--progress', action='store_true', help='Print a single period for each region checked')
    args = parser.parse_args()

    if not args.instances or not args.profile:
        parser.print_help()
        sys.exit(1)

    instance_ids = args.instances
    regions = args.regions or boto3.Session(profile_name=args.profile).get_available_regions('ec2')

    search_instances_across_regions(instance_ids, regions, args.profile, args.quiet, args.progress)

