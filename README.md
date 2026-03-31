# TIN-X DB

This repository contains code for constructing the docker image of the TIN-X database.

At the time of writing the DB platform used is `mysql`.

## Prerequisites

- [Docker](https://docs.docker.com/engine/install/)
- At least 90GB of free storage space
- (Recommended) at least 32GB of RAM

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

2. Run [tune.sh](tune.sh) to generate a MySQL configuration file based on your resources params (`CPUS` and `MEMORY`)

3. Run docker compose:

   ```bash
   docker compose up -d
   ```

   One can track the progress of the restore with:

   ```bash
   docker compose logs -f
   ```

   The DB will take some time to restore, it takes about 2 hours using `CPUS=8` and `MEMORY=128G`.

   The container will be ready to use once you see a message like the following:

   ```bash
   [Server] /usr/sbin/mysqld: ready for connections.
   ```

4. After the DB restore/initialization is complete one can connect to the database like so from the host:

   ```bash
   # use DB_PASSWORD when prompted for password
   mysql -D tcrd -u <DB_USER> -P <HOST_PORT> -h 127.0.0.1 -p
   ```

## How dump file was created

On the TIN-X production server (chiltepin.health.unm.edu) the following command was executed against a live version of the TIN-X database:

```bash
# Step 1: Install mysqlsh into the already-running container
# (MySQL repo is already configured in the image, so this just works)
docker-compose exec mysql microdnf install -y mysql-shell

# Step 2: Run the schema dump (inside the container, output to /tmp)
docker-compose exec mysql mysqlsh root@localhost \
  -- util dump-schemas tcrd \
  --outputUrl=/tmp/tcrd-shell-dump \
  --threads=8 \
  --compression=zstd

# Step 3: Tar it up inside the container
docker-compose exec mysql tar -czf /tmp/tinx-mysql-shell.tar.gz \
  -C /tmp tcrd-shell-dump/

# Step 4: Copy the tarball out to the host
docker cp $(docker-compose ps -q mysql):/tmp/tinx-mysql-shell.tar.gz ./
```

This dump file was generated on 03/26/2026.
