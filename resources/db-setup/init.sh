# Run the createAppUser command
createAppUser oracle dummypassword XEPDB1

# sqlplus sys/dummypassword@XEPDB1 as sysdba @/docker-entrypoint-initdb.d/init.sql
