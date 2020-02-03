## aws_s3 ##

This project contains python scripts and files associated with M2GEN/bioinformatcs for uploading and downloading data to and from S3.  The project includes the following files:
1. `upload_tree_s3.py` - python script to upload a directory tree on the local computer to s3
2. `download_tree_s3.py` - python script to download a tree from s3 to local root folder
3. `awscontext.py` - a python module defining a python class for managing the various context options when uploading data
4. `awscontext.json` - a configuration file specifying contexts for various AWS environments and accounts

### upload_tree_s3.py ###
This python script utilizes boto3 (an python API to AWS services) to upload files and their associated directory tree(s) to an S3 bucket.  

In using the AWS services, AWS command line must be installed and configured in ~/.aws.  The configuration must include a security key that has permissions to access the S3 bucket.  Since the AWS envrionment can have multiple configurations, the use can specify an AWS profile.  By default, the "default" profile is used.  

The script uses a "context" configuration file as well a command line options.  The provided context configuration file is `awscontext.json`.  The context includes defaults for:
1. Bucket name
2. AWS credential profile name

There are configuration command line options to `upload_tree_s3.py` for specifying:
1. The file name of the context configuration file
2. Profile name (over-riding the configuration file)
3. Bucket name (over-riding the configuration file)

There are additional options to `upload_tree_s3.py` for copying or uploading to S3 including:
1. Include only specified files (e.g., '*.py')
2. Exclude specified files (e.g., '*.vcf')
3. Include only specified folders (e.g., '*.config')
4. Exclude specified folders (e.g., '*.log, *.results, *.data')
5. Recursively copy subfolders
6. Copy all files (not just changed files)

A brief summary of all the options are available by specifying `--help` option.  Another useful option is `--test` (or `-T`) to output what will be uploaded without actually executing the upload. See the examples below for additional help.

### Examples ###
1. <i>Example 1</i> - Upload all the files in the cwd to the default S3 bucket (m2gen-bioinformatics-data).  Subdirectories are not uploaded.
```{r}
cd /work/kuraisar
upload_tree_s3.py -A
```
2. <i>Example 2</i> - Without actually executing the upload print a summary for recursively uploading all new or changed files in the specified folder and its subfolders.
```{r}
upload_tree_s3.py -r -s /work/kuraisar -T
```
3. <i>Example 3</i> - Upload example 2.
```{r}
upload_tree_s3.py -r -s /projects/topmed/analysts/kuraisa/analysis_pipeline
```
