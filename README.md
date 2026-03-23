# TIN-X DB

This repository contains code for constructing the docker image of the TIN-X database.

At the time of writing the DB platform used is `mysql`.

## How dump file was created

On the TIN-X production server (chiltepin.health.unm.edu) the following command was executed against a live version of the TIN-X database:

```bash
docker-compose exec mysql mysqldump -u tcrd_read_only -p \
  --no-tablespaces \
  --skip-triggers \
  --compact \
  tcrd > tcrd_mysql.sql
```

This dump file was generated on 03/23/2026.
