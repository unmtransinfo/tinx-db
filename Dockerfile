# see https://kedar.nitty-witty.com/blog/a-unique-foreign-key-issue-in-mysql-8-4 for why 8.4 cannot be used
FROM mysql:8.0

# Default database name — must match the schema name embedded in the dump
ENV MYSQL_DATABASE=tcrd

# URL of the MySQL Shell dump tarball to restore at first-boot initialization
ENV DUMP_URL=https://unmtid-dbs.net/download/TIN-X/tinx-mysql-shell.tar.gz

# Install curl and mysql-shell (mysql:8 is Oracle Linux 9 based)
RUN microdnf install -y curl mysql-shell && microdnf clean all

# Copy the restore + user-provisioning script into the init directory
COPY restore.sh /docker-entrypoint-initdb.d/restore.sh

# Ensure the restore script is executable
RUN chmod +x /docker-entrypoint-initdb.d/restore.sh

# Document default MySQL port
EXPOSE 3306

