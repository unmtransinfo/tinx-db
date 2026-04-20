#!/usr/bin/env bash
set -e

# ---------------------------------------------------------------------------
# Connection parameters — all can be overridden via environment variables.
#
#   HOST            Host (or Docker container name/IP) of the MySQL server.
#                   Default: localhost
#   PORT            Port the MySQL server is listening on.
#                   Default: 3306
#   MYSQL_PASSWORD  Password for the root user. Leave empty to be prompted.
#
# Example — MySQL running inside a Docker container:
#   HOST=my-tcrd-container PORT=3306 ./tcrd_migrate.sh
# ---------------------------------------------------------------------------

HOST="${HOST:-localhost}"
PORT="${PORT:-3306}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-}"

# Build mysql client argument string.
# A password is passed via -p<password> only when the variable is non-empty;
# otherwise the client will prompt interactively.
mysql_args=(-h "$HOST" -P "$PORT" -u root)
[[ -n "$MYSQL_PASSWORD" ]] && mysql_args+=("-p${MYSQL_PASSWORD}")

# ---------------------------------------------------------------------------
# 1. Copy the required tables from tcrd -> tinx
# ---------------------------------------------------------------------------
REQUIRED_TABLES="
tinx_articlerank
tinx_disease
tinx_importance
tinx_novelty
tinx_target
pubmed
protein
target
t2tc
do
do_parent
dto
"

SQL="CREATE DATABASE IF NOT EXISTS tinx;
SET foreign_key_checks = 0;
"

for TABLE in $REQUIRED_TABLES; do
    SQL+="CREATE TABLE tinx.${TABLE} LIKE tcrd.${TABLE};
INSERT INTO tinx.${TABLE} SELECT * FROM tcrd.${TABLE};
"
done

SQL+="SET foreign_key_checks = 1;"

mysql "${mysql_args[@]}" -e "$SQL"

# ---------------------------------------------------------------------------
# 2. Run migration scripts in order against tinx
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for script in "$SCRIPT_DIR/sql/"*.sql; do
    mysql "${mysql_args[@]}" tinx < "$script"
done