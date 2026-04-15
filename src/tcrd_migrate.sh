#!/usr/bin/env bash
set -e

# 1. Copy the required tables from tcrd -> tinx
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

mysql -u root -p -e "$SQL"

# 2. Run migration scripts in order against tinx
for script in src/sql/*.sql; do
    mysql -u root -p"${PASSWORD}" tinx < "$script"
done