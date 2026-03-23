#!/usr/bin/env bash
set -e

DB_NAME="${MYSQL_DATABASE:-tcrd}"
DUMP_URL="${DUMP_URL:-https://unmtid-dbs.net/download/TIN-X/tinx-mysql.dump}"

echo "Downloading and restoring database into '$DB_NAME' from '$DUMP_URL'..."

# Stream the dump directly into mysql - avoids storing 35 GB on disk twice
curl -fsSL "$DUMP_URL" \
  | mysql \
      -u root \
      -p"${MYSQL_ROOT_PASSWORD}" \
      "$DB_NAME"

echo "Restore complete."

# Create read-only user if DB_USER and DB_PASSWORD are set
if [ -n "$DB_USER" ] && [ -n "$DB_PASSWORD" ]; then
  echo "Creating read-only user '$DB_USER'..."

  mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<-EOSQL
    -- Create the read-only user (accessible from any host)
    CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';

    -- Grant SELECT on all tables in the target database
    GRANT SELECT ON \`$DB_NAME\`.* TO '$DB_USER'@'%';

    -- Apply privilege changes immediately
    FLUSH PRIVILEGES;
EOSQL

  echo "Read-only user '$DB_USER' created successfully."
fi

# Create completion marker
echo "Database initialization complete at $(date)" > /var/lib/mysql/restore_complete
echo "Database restore and setup complete."

