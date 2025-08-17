# End-to-End-Oracle-to-Snowflake-Pipeline
Demonstrates cloud ELT skills by building a secure data pipeline from Oracle (AWS RDS) to Snowflake using Fivetran over SSH (via an EC2 server). The project includes automated report generation with Python (python-docx) and staging in Snowflake for simple user access.

## Table of Contents
1) [Project Overview & Architecture](#1-project-overview--architecture)  
2) [Provisioning Oracle Database in AWS RDS](#2-provisioning-oracle-database-in-aws-rds)  
3) [Secure Connectivity and Database Access via Fivetran](#3-secure-connectivity-and-database-access-via-fivetran)  
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
To move data from Oracle into Snowflake, we the managed ELT service **Fivetran**. Fivetran enables **Change Data Capture (CDC)**, automatically detecting new or updated records in Oracle and pushing them to Snowflake.

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

For networking configuration, we once again create a new security group to allow inbound traffic from **TCP port 22** (SSH) from the internet. To ensure SSH Server retains the same IP/hostname after stopping/restarting, we assign the server an Elastic IP address (public static IP).

![alt text](https://github.com/jerryzhangdata/End-to-End-Oracle-to-Snowflake-Pipeline/blob/main/Images/Screenshot%206%20(Elastic%20IP).png)

We then connect to the EC instance in the Terminal using SSH. Per [Fivetran's SSH guide](https://fivetran.com/docs/connectors/databases/connection-options#sshtunnel), we configure a fivetran user and enter the **Public SSH key** into the .ssh directory.

![alt text](https://github.com/jerryzhangdata/End-to-End-Oracle-to-Snowflake-Pipeline/blob/main/Images/Screenshot%205%20(EC2%20SSH%20Configuration).png)

### 3b) Configuring Snowflake as Fivetran Destination


## 4) Automated Report Generation in Snowflake
