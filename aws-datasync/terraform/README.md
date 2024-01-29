- [Overview](#overview)
  - [Copy using aws CLI](#copy-using-aws-cli)
  - [Copy using DataSync](#copy-using-datasync)
  - [Copy using replication](#copy-using-replication)
- [Reference](#reference)

# Overview
This repository contains a comprehensive guide and the necessary Terraform configurations to set up and demonstrate cross-account S3 data replication within AWS. It showcases how to securely and efficiently replicate data from an S3 bucket in one AWS account (Source Account) to another S3 bucket in a different AWS account (Destination Account). This setup is invaluable for scenarios such as data backup, disaster recovery, or data synchronization across different AWS environments.

## Copy using aws CLI
```mermaid
graph TD;
    SourceAccount[Source Account] -->|Creates IAM Role & S3 Bucket| SourceS3Bucket[Source S3 Bucket]
    DestinationAccount[Destination Account] -->|Bucket Receives Data| DestinationS3Bucket

    SourceS3Bucket -->|Stores Uploaded Files| SourceS3Object[Sample Files]
    SourceAccount -->|IAM Role Trusts| DestinationAccount
```

1. Configure the AWS CLI Profile
You need to configure the AWS CLI with a profile that can assume the cross-account role. This is typically done in your AWS configuration file, which is located at ~/.aws/config on Linux and macOS, or at C:\Users\USERNAME\.aws\config on Windows.

    Example Configuration:

    ```bash
    [profile cross]
    role_arn = arn:aws:iam::<DEV_ACCOUNT_ID>:role/<ROLE_NAME>
    source_profile = <BASE_PROFILE>
    region = <REGION>
    ```

    Replace <DEV_ACCOUNT_ID> with the AWS account ID where the cross-account role exists, <ROLE_NAME> with the name of the IAM role you wish to assume (e.g., dev-entechlog-data-cross-account-role), <BASE_PROFILE> with a profile that has permissions to assume this role, and <REGION> with the appropriate AWS region.

    Steps to Configure:
    - Open the AWS configuration file in a text editor.
    - Add the above configuration to the file, replacing placeholders with actual values.
    - Save and close the file.

1. Setting Up the Base Profile
The source_profile in the cross profile configuration refers to another profile that has credentials to assume the cross-account role. Ensure that this base profile is correctly set up with access keys.

    Example Base Profile Setup:
    ```bash
    [profile <BASE_PROFILE>]
    aws_access_key_id = <YOUR_ACCESS_KEY_ID>
    aws_secret_access_key = <YOUR_SECRET_ACCESS_KEY>
    region = <REGION>
    ```

1. Testing the Profile
To validate that the cross profile is correctly set up and can assume the cross-account role, use the AWS CLI to make a call that requires valid credentials.

    Test Command:
    ```bash
    aws sts get-caller-identity --profile cross
    ```

    This command should return details of the assumed role, including the account ID and the role ARN.

1. Accessing the S3 Bucket
Once you've confirmed the profile is working, you can use it to access resources in the other account. For example, to list the contents of the S3 bucket:

    ```bash
    aws s3 ls s3://<SOURCE_BUCKET_NAME> --profile cross
    aws s3 ls s3://<SOURCE_BUCKET_NAME> --profile cross
    aws s3 ls s3://<SOURCE_BUCKET_NAME> --recursive --human-readable --summarize --profile cross
    aws s3 sync s3://<SOURCE_BUCKET_NAME> s3://<DESTINATION_BUCKET_NAME> --profile cross
    ```

## Copy using DataSync
```mermaid
    graph TD;
        SourceAccount[Source Account] -->|DataSync Role & Policy| SourceS3Bucket[Source S3 Bucket]
        SourceS3Bucket -->|Syncs Data| DataSyncTask[DataSync Task]
        DataSyncTask -->|Transfers Data| DestinationS3Bucket[Destination S3 Bucket]
        DestinationAccount[Destination Account] -->|Receives Data| DestinationS3Bucket
```

## Copy using replication
```mermaid
    graph TD;
        SourceAccount[Source Account] -->|Replication IAM Role| SourceS3Bucket[Source S3 Bucket]
        SourceS3Bucket -->|Replication Task| DestinationS3Bucket[Destination S3 Bucket]
        DestinationAccount[Destination Account] -->|Bucket Policy| DestinationS3Bucket

        SourceS3Bucket -->|Permissions to Replicate| SourceRole[Replication IAM Role]
        SourceRole -->|Assumes Role| DestinationS3Bucket
```

# Reference
- https://repost.aws/knowledge-center/s3-cross-account-replication-object-lock