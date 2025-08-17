# End-to-End-Oracle-to-Snowflake-Pipeline
Demonstrates cloud ETL skills by building a secure data pipeline from Oracle (AWS RDS) to Snowflake using Fivetran over SSH (via an EC2 server). The project includes automated report generation with Python (python-docx) and staging in Snowflake for simple user access.

## Table of Contents
1) [Project Overview & Architecture](#1-project-overview--architecture)  
2) [Provisioning Oracle Database in AWS RDS](#2-provisioning-oracle-database-in-aws-rds)  
3) [Configuring Secure Connectivity and Database Access](#3-configuring-secure-connectivity-and-database-access)  
4) [Automated Report Generation in Snowflake](#4-automated-report-generation-in-snowflake)  

## 1) Project Overview & Architecture
![alt text](https://github.com/jerryzhangdata/End-to-End-Oracle-to-Snowflake-Pipeline/blob/main/Images/Project%20Architecture.png)

## 2) Provisioning Oracle Database in AWS RDS
We begin by provisioning a database in AWS to use as our data source. In RDS (Relationship Database Service), we create an Oracle database using the minimum allowed storage and compute specifications. We configure the network settings to allow public access and ensure that TCP port 1521 is unblocked. Finally, we make record the Admin username/password and the Database name which is needed to connect to the database using Oracle SQL Developer.
![alt text](https://github.com/jerryzhangdata/End-to-End-Oracle-to-Snowflake-Pipeline/blob/main/Images/Screenshot%201%20(AWS%20RDS).png)

## 3) Configuring Secure Connectivity and Database Access

## 4) Automated Report Generation in Snowflake
