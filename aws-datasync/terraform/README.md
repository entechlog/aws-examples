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
        SourceAccount[Source Account] -->|Defines IAM Role| SourceRole[Cross-Account IAM Role]
        SourceRole -->|Trust Relationship| DestinationAccountRoot[Destination Account Root User]
        
        DestinationAccount[Destination Account] -->|Defines IAM User| DestinationUser[Cross-Account IAM User]
        DestinationUser -->|Assigned Assume Role Policy| DestinationPolicy[Assume Role Policy]
        DestinationPolicy -->|Allows Role Assumption| SourceRole

        SourceAccount -->|Creates S3 Bucket| SourceS3Bucket[Source S3 Bucket]
        SourceS3Bucket -->|Bucket Policy for Role Access| SourceRole

        SourceAccount -->|Uploads sample files| SourceS3Object[Source S3 Object]
        SourceS3Object -->|Stored in| SourceS3Bucket

        DestinationAccount -->|Creates S3 Bucket| DestinationS3BucketCopy[Destination S3 Bucket for Copy]
        SourceRole -->|Access Policy allows operations| DestinationS3BucketCopy

        SourceS3Bucket -->|Copy Operation| DestinationS3BucketCopy
        DestinationS3BucketCopy -->|Bucket Policy allows source role access| SourceRole
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
        subgraph SourceAccount[Source Account]
            SourceRole[DataSync IAM Role] -->|Read Access Policy| SourceS3Bucket[Source S3 Bucket]
            SourceRole -->|Logs Policy| CloudWatchLogs[CloudWatch Log Group]
            SourceRole -->|Attached Read Policy| SourcePolicy[DataSync Read Access Policy]
            SourceDataSyncLocation[DataSync S3 Location] --> SourceS3Bucket
            DataSyncTask[DataSync Task] -->|Source to Destination| DestinationDataSyncLocation[DataSync Destination S3 Location]
        end

        subgraph DestinationAccount[Destination Account]
            DestinationS3Bucket[Destination S3 Bucket] -->|Bucket Policy| DestinationBucketPolicy[DataSync Bucket Policy]
            DestinationDataSyncLocation --> DestinationS3Bucket
        end

        SourceS3Bucket -->|DataSync Task| DestinationS3Bucket
        SourceRole -.->|Assume Role| DestinationAccount
        SourcePolicy -->|Access to Source Bucket| SourceS3Bucket
        DestinationBucketPolicy -->|Access Permissions| DestinationS3Bucket
```

## Copy using replication
```mermaid
    graph TD;
        subgraph SourceAccount[Source Account]
            SourceRole[Replication IAM Role] -->|AssumeRole Policy| S3Service[S3 Service]
            SourceRole -->|Attached Replication Policy| SourcePolicy[Replication Access Policy]
            SourceS3Bucket[Source S3 Bucket] -->|Replication Configuration| ReplicationTask[Replication Task]
            ReplicationTask -->|Replicates to Destination Bucket| DestinationS3Bucket[Destination S3 Bucket]
            SourcePolicy -->|Permissions on Source Bucket| SourceS3Bucket
        end

        subgraph DestinationAccount[Destination Account]
            DestinationS3Bucket -->|Bucket Policy| DestinationBucketPolicy[Replication Bucket Policy]
            DestinationBucketPolicy -->|Permissions for Source Role| SourceRole
        end

        SourceRole -.->|Assume Role| DestinationAccount
        DestinationBucketPolicy -->|Access Permissions| DestinationS3Bucket
```

# Reference
- https://repost.aws/knowledge-center/s3-cross-account-replication-object-lock