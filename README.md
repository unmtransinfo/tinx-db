# TIN-X DB

This repository contains code for constructing the docker image of the TIN-X database.

At the time of writing the DB platform used is `mysql`.

## Usage

1. Build:

```bash
docker build -t tinx-db .
```

2. Run:

```bash
docker run -d \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=your_root_password \
  -e MYSQL_DATABASE=tcrd \
  -e DB_USER=tcrd_read_only \
  -e DB_PASSWORD=your_password \
  tinx-db
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
