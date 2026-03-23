FROM mysql:8

# Default database name (can be overridden at runtime via MYSQL_DATABASE)
ENV MYSQL_DATABASE=tcrd

# URL of the SQL dump to stream at first-boot initialisation
ENV DUMP_URL=https://unmtid-dbs.net/download/TIN-X/tinx-mysql.dump

# Install curl (mysql:8 is Oracle Linux 9 based)
RUN microdnf install -y curl && microdnf clean all

# Copy the restore + user-provisioning script into the init directory
COPY restore.sh /docker-entrypoint-initdb.d/restore.sh

# Ensure the restore script is executable
RUN chmod +x /docker-entrypoint-initdb.d/restore.sh

# Document default MySQL port
EXPOSE 3306

