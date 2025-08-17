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
