# End-to-End-Oracle-to-Snowflake-Pipeline
Demonstrates cloud ETL skills by building a secure data pipeline from Oracle (AWS RDS) to Snowflake using Fivetran over SSH (via an EC2 server). The project includes automated report generation with Python (python-docx) and staging in Snowflake for simple user access.

## Table of Contents
1) [Project Overview & Architecture](#1-project-overview--architecture)  
2) [Provisioning Oracle Database in AWS RDS](#2-provisioning-oracle-database-in-aws-rds)  
3) [Configuring Secure Connectivity and Database Access](#3-configuring-secure-connectivity-and-database-access)  
4) [Automated Report Generation in Snowflake](#4-automated-report-generation-in-snowflake)  

## 1) Project Overview & Architecture
![alt text](https://github.com/jerryzhangdata/End-to-End-Oracle-to-Snowflake-Pipeline/blob/main/images/Project%20Architecture.png)

## 2) Provisioning Oracle Database in AWS RDS
We begin by provisioning an Oracle database instance in **Amazon RDS** to serve as the source system.  For this demo, we selected the **minimum supported compute and storage configuration** (db.m5.large, 20 GiB GP3) to minimize cost. We record the credentials DB name (ORCL) and the master (admin) username/password (required for connecting via Oracle SQL Developer). 
![alt text](https://github.com/jerryzhangdata/End-to-End-Oracle-to-Snowflake-Pipeline/blob/main/Images/Screenshot%201%20(AWS%20RDS).png)

For networking configuration, we select "Public Access:Yes" to allow access over the internet. We also create a security group allowing inbound connections from TCP port 1521 (Oracle Listener Port) and assign it the VPC (Virtual Private Cloud) network.
![alt text](https://github.com/jerryzhangdata/End-to-End-Oracle-to-Snowflake-Pipeline/blob/main/Images/Screenshot%202%20(AWS%20Security%20Group).png)

## 3) Configuring Secure Connectivity and Database Access

## 4) Automated Report Generation in Snowflake
