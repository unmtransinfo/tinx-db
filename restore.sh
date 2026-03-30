#!/usr/bin/env bash
set -e

DB_NAME="${MYSQL_DATABASE:-tcrd}"
DUMP_URL="${DUMP_URL:-https://unmtid-dbs.net/download/TIN-X/tinx-mysql-shell.tar.gz}"

TARBALL=/tmp/tinx-mysql-shell.tar.gz
DUMP_DIR=/tmp/tcrd-shell-dump

echo "Downloading MySQL Shell dump from '$DUMP_URL'..."
curl -fsSL -o "$TARBALL" "$DUMP_URL"

echo "Extracting dump archive..."
tar -xzf "$TARBALL" -C /tmp

echo "Loading dump into '$DB_NAME' using mysqlsh..."
mysqlsh root@localhost \
  --password="${MYSQL_ROOT_PASSWORD}" \
  -- util load-dump "$DUMP_DIR" \
  --threads=8 \
  --skipBinlog=true

# Clean up temporary files to reclaim disk space
rm -rf "$TARBALL" "$DUMP_DIR"

echo "Restore complete."

# Create read-only user if DB_USER and DB_PASSWORD are set
if [ -n "$DB_USER" ] && [ -n "$DB_PASSWORD" ]; then
  echo "Creating read-only user '$DB_USER'..."
  mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "
    CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
  "
  mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -D "${DB_NAME}" -e "
    GRANT SELECT ON ${DB_NAME}.* TO '${DB_USER}'@'%';
  "
  echo "Read-only user '$DB_USER' created successfully."
fi

# Create completion marker
echo "Database initialization complete at $(date)" > /var/lib/mysql/restore_complete
echo "Database restore and setup complete."

