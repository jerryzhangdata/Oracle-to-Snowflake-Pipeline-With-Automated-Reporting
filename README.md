# End-to-End-Oracle-to-Snowflake-Pipeline
Demonstrates cloud ELT skills by building a secure data pipeline from Oracle (AWS RDS) to Snowflake using Fivetran over SSH (via an EC2 server). The project includes automated report generation with Python (python-docx) and staging in Snowflake for simple user access.


## Table of Contents
1) [Project Overview & Architecture](#1-project-overview--architecture)  
2) [Provisioning Oracle Database in AWS RDS](#2-provisioning-oracle-database-in-aws-rds)  
3) [Secure Connectivity and Database Access via Fivetran](#3-secure-connectivity-and-database-access-via-fivetran)  
   - [3a) Configuring Oracle RDS as Fivetran Connection](#3a-configuring-oracle-rds-as-fivetran-connection)  
   - [3b) Configuring Snowflake as Fivetran Destination](#3b-configuring-snowflake-as-fivetran-destination)  
   - [3c) Testing the Pipeline](#3c-testing-the-pipeline)  
4) [Automated Report Generation in Snowflake](#4-automated-report-generation-in-snowflake)  


## 1) Project Overview & Architecture
![alt text](https://github.com/jerryzhangdata/End-to-End-Oracle-to-Snowflake-Pipeline/blob/main/Images/Project%20Architecture.png)

## 2) Provisioning Oracle Database in AWS RDS
We begin by provisioning an Oracle database instance in **Amazon RDS** to serve as the source system.  For this demo, we selected the **minimum supported compute and storage configuration** (db.m5.large, 20 GiB) to minimize cost. We record the credentials DB name (ORCL) and the master (admin) username/password (required for connecting via Oracle SQL Developer).

![alt text](https://github.com/jerryzhangdata/End-to-End-Oracle-to-Snowflake-Pipeline/blob/main/Images/Screenshot%201%20(AWS%20RDS).png)


For networking configuration, we select **"Public Access:Yes"** to allow access over the internet, and record the Endpoint (hostname). We also create a security group allowing inbound connections from **TCP port 1521** (Oracle Listener Port) and assign it the VPC (Virtual Private Cloud) network. 

![alt text](https://github.com/jerryzhangdata/End-to-End-Oracle-to-Snowflake-Pipeline/blob/main/Images/Screenshot%202%20(AWS%20Security%20Group).png)


With the database provisioned, we verified connectivity by logging in via Oracle SQL Developer using the admin credentials. Next, we loaded a sample drug discovery dataset from [Kaggle](https://www.kaggle.com/datasets/shahriarkabir/drug-discovery-virtual-screening-dataset) into the Oracle database for use in this pipeline.

![alt text](https://github.com/jerryzhangdata/End-to-End-Oracle-to-Snowflake-Pipeline/blob/main/Images/Screenshot%203%20(Oracle%20Data%20Load).png)


## 3) Secure Connectivity and Database Access via Fivetran
To move data from Oracle into Snowflake, we the managed ELT service **Fivetran**. Fivetran enables **CDC (Change Data Capture)**, automatically detecting new or updated records in Oracle and pushing them to Snowflake.


### 3a) Configuring Oracle RDS as Fivetran Connection
Per the Fivetran [Amazon RDS for Oracle Setup Guide](https://fivetran.com/docs/connectors/databases/oracle/oracle-connector/rds-setup-guide), we select **SSH** as the connection method. In SQL Developer, using the admin account, we run the query below to create a dedicated service account for Fivetran and grant it the necessary access privileges.

```sql
-- Configured per fivetran setup guide: https://fivetran.com/docs/connectors/databases/oracle/oracle-connector/setup-guide
-- The Admin user has insufficient privileges to grant access to DBA_SEGMENTS
CREATE USER fivetran_user IDENTIFIED BY "!9uGLU#aCwgTRJy";
GRANT SELECT ON DRUG_DISCOVERY TO fivetran_user;
GRANT SELECT ON DBA_EXTENTS TO fivetran_user;
GRANT SELECT ON DBA_TABLESPACES TO fivetran_user;
CREATE PROFILE fivetran_profile LIMIT SESSIONS_PER_USER 10;
ALTER USER fivetran_user PROFILE fivetran_profile;

-- Validate user creation
SELECT USERNAME, PROFILE FROM DBA_USERS where USERNAME='FIVETRAN_USER';
```


Next, we create an **EC2 instance** to serve as the **SSH Server**, tunneling Oracle traffic securely to Fivetran. For this demo, we once again selected a **minimal compute and storage configuration** (t3.micro, 8 GiB) to minimize cost.

![alt text](https://github.com/jerryzhangdata/End-to-End-Oracle-to-Snowflake-Pipeline/blob/main/Images/Screenshot%204%20(EC2%20SSH%20Server).png)


For networking configuration, we create a new security group to allow inbound traffic on **TCP port 22 (SSH)** from the internet (in production, we would limit this to trusted IPs only). To ensure the SSH server retains the same IP/hostname after stopping/restarting, we assign the server an **Elastic IP** (static public IP).

![alt text](https://github.com/jerryzhangdata/End-to-End-Oracle-to-Snowflake-Pipeline/blob/main/Images/Screenshot%206%20(Elastic%20IP).png)


We then connect to the EC instance in the Terminal using SSH. Per [Fivetran's SSH guide](https://fivetran.com/docs/connectors/databases/connection-options#sshtunnel), we configure a fivetran user and enter the **Public SSH key** into the .ssh directory.

![alt text](https://github.com/jerryzhangdata/End-to-End-Oracle-to-Snowflake-Pipeline/blob/main/Images/Screenshot%205%20(EC2%20SSH%20Configuration).png)


Finally, we configure the Fivetran connection, providing details for both the SSH server (host, SSH user) and the Oracle RDS database (host, database user/password, service name). We select **Fivetran Teleport Sync** as the connection method to enable CDC.

![](https://github.com/jerryzhangdata/End-to-End-Oracle-to-Snowflake-Pipeline/blob/main/Images/Screenshot%207%20(Fivetran%20to%20Oracle%20RDS).png)


### 3b) Configuring Snowflake as Fivetran Destination
Using the **Partner Connect** feature in Snowflake, we automatically provision a staging database, warehouse, and dedicated service account for Fivetran with the necessary access privileges.

![alt text](https://github.com/jerryzhangdata/End-to-End-Oracle-to-Snowflake-Pipeline/blob/main/Images/Screenshot%208%20(Snowflake%20Partner%20Connect).png)


We generate an SSH public/private key pair locally using the terminal. The public key is then assigned to the Fivetran service account in a Snowflake SQL worksheet.

```sql
-- Assign the public SSH key to the Fivetran user. The private key was entered into Fivetran when configuring the destination
ALTER USER PC_FIVETRAN_USER
SET RSA_PUBLIC_KEY = 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn4ObTHy7EYPAyQv6anCcaloNBJfmxUWlE5jIeiMv7dq0FQcocEe24CWLIiP88gFdqWNwa/stmiu1DtTCeT8mQFa4x7hFwgJmvlN5OUK8tI+ucqyZRBhcI+vGDCud4e7p9Gq4EMP3k65PnAm/L8AhtZp2QUiW8qrJX31rrJTjmnPxNxwgfgWyI0Hq3j4gR252Hqhb6K76tQ4UqRC3smDzohZDjsXdtGUfEt2cEd6V47+P04Jo6vPkEunyGiArpwNCoT9UGng6SmMJ6DxmABYMCz3i+8eGUarxlZ6RNhvdY2emPrn0Ve74hkKRKudRNb9lsdUsK8GgppiksUrz601YoQIDAQAB';

-- Validate user creation
DESC USER PC_FIVETRAN_USER;

```

Finally, we configure Snowflake as the Fivetran destination, with most settings automatically pre-filled through Partner Connect.

![alt text](https://github.com/jerryzhangdata/End-to-End-Oracle-to-Snowflake-Pipeline/blob/main/Images/Screnshot%209%20(Fivetran%20to%20Snowflake).png)

### 3c) Testing the Pipeline
To test the pipeline, we insert dummy data into the Oracle database and verify that Fivetran syncs the updates into Snowflake. Each dummy row is labeled with the `CURRENT_TIMESTAMP` at the time of insertion, making it easy to verify that the new rows were replicated into Snowflake.

![](https://github.com/jerryzhangdata/End-to-End-Oracle-to-Snowflake-Pipeline/blob/main/Images/Screenshot%2010%20(Dummy%20Data%20Insertion).png)


In Fivetran, we trigger a manual sync, and the interface confirms that one new row was successfully loaded.

![](https://github.com/jerryzhangdata/End-to-End-Oracle-to-Snowflake-Pipeline/blob/main/Images/Screenshot%2011%20(Fivetran%20Sync).png)


We query the Snowflake staging database and confirm that the new row has been loaded successfully!

![](https://github.com/jerryzhangdata/End-to-End-Oracle-to-Snowflake-Pipeline/blob/main/Images/Screenshot%2012%20(Confirm%20Data%20Load%20in%20Snowflake).png)


## 4) Automated Report Generation in Snowflake
Using the sample dataset from Oracle, we generate a Word (.docx) report in a **Snowflake Notebook**. The report is created automatically with Python (`python-docx`) and saved to an **internal stage** for simple user access. This workflow allows users to generate reports entirely within Snowflake, with no local setup required.

'''sql
-- Create an internal stage to store the file results
CREATE DATABASE IF NOT EXISTS ORACLE_REPORT_DEMO;
CREATE SCHEMA IF NOT EXISTS ORACLE_REPORT_DEMO.INTERNAL_STAGES;
CREATE STAGE IF NOT EXISTS ORACLE_REPORT_DEMO.INTERNAL_STAGES.DRUG_DISCOVERY_REPORT;

-- Validate stage creation
LIST @ORACLE_REPORT_DEMO.INTERNAL_STAGES.DRUG_DISCOVERY_REPORT;
'''
