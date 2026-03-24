# TIN-X DB

This repository contains code for constructing the docker image of the TIN-X database.

At the time of writing the DB platform used is `mysql`.

## Usage

1. Copy `.env.example` to `.env` and edit values to match your environment:

```bash
cp .env.example .env
```

| Variable              | Description                                                             |
| --------------------- | ----------------------------------------------------------------------- |
| `CPUS`                | CPU cores allocated to the container (decimals accepted, e.g. `4.5`)    |
| `MEMORY`              | RAM allocated to the container — suffix must be `G` or `M` (e.g. `32G`) |
| `MYSQL_ROOT_PASSWORD` | Root password for the MySQL instance                                    |
| `MYSQL_DATABASE`      | Name of the database to create and restore into                         |
| `DB_USER`             | Read-only user created after restore                                    |
| `DB_PASSWORD`         | Password for the read-only user                                         |
| `HOST_PORT`           | Host port mapped to MySQL's container port 3306                         |

All InnoDB tuning parameters (`innodb_buffer_pool_size`, IO threads, redo log capacity, etc.) are derived automatically from `CPUS` and `MEMORY`.

2. Run `pull_db.sh` to build the image, derive tuning params, and start the container:

```bash
bash pull_db.sh
```

## How dump file was created

On the TIN-X production server (chiltepin.health.unm.edu) the following command was executed against a live version of the TIN-X database:

```bash
docker-compose exec mysql mysqldump -u tcrd_read_only -p \
  --no-tablespaces \
  --skip-triggers \
  --compact \
  tcrd > tinx-mysql.dump
```

This dump file was generated on 03/23/2026.
