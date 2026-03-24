#!/usr/bin/env bash
set -e

# Docker resource constraints
CPUS=8
MEMORY=32G

# MySQL user params
MYSQL_ROOT_PASSWORD="root_pass" # modify if using in prod
MYSQL_DATABASE="tinx" # database name
DB_USER="tinx_user" # read-only user
DB_PASSWORD="user_pass" # modify if using in prod

# MySQL params - you will need to tune these based on your available resources (defaults are for 32GB RAM, 8 cpus)
INNODB_BUFFER_POOL_SIZE=20G # InnoDB buffer pool — most important knob, use ~60-70% of RAM
INNODB_BUFFER_POOL_INSTANCES=8 # 1 per cpu 
INNODB_READ_IO_THREADS=8 # 1 per cpu
INNODB_WRITE_IO_THREADS=8 # 1 per cpu
INNODB_PURGE_THREADS=4 # 1/2 per cpu
INNODB_REDO_LOG_CAPACITY=4G
INNODB_LOG_BUFFER_SIZE=256M
INNODB_FLUSH_METHOD="O_DIRECT"
INNODB_FLUSH_LOG_AT_TRX_COMMIT=2 # see: https://docs.netapp.com/us-en/ontap-apps-dbs/mysql/mysql-innodb_flush_log_at_trx_commit.html
BULK_INSERT_BUFFER_SIZE=256M
SORT_BUFFER_SIZE=64M
READ_RND_BUFFER_SIZE=32M
JOIN_BUFFER_SIZE=32M

# TODO: replace this with dockerhub repo once pushed
docker build -t tinx-db .
docker run -d \
  --cpus ${CPUS} \
  --memory ${MEMORY} \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
  -e MYSQL_DATABASE=${MYSQL_DATABASE} \
  -e DB_USER=${DB_USER} \
  -e DB_PASSWORD=${DB_PASSWORD} \
  tinx-db \
  --innodb-buffer-pool-size=${INNODB_BUFFER_POOL_SIZE} \
  --innodb-buffer-pool-instances=${INNODB_BUFFER_POOL_INSTANCES} \
  --innodb-read-io-threads=${INNODB_READ_IO_THREADS} \
  --innodb-write-io-threads=${INNODB_WRITE_IO_THREADS} \
  --innodb-purge-threads=${INNODB_PURGE_THREADS} \
  --innodb-redo-log-capacity=${INNODB_REDO_LOG_CAPACITY} \
  --innodb-log-buffer-size=${INNODB_LOG_BUFFER_SIZE} \
  --innodb-flush-method=${INNODB_FLUSH_METHOD} \
  --innodb-flush-log-at-trx-commit=${INNODB_FLUSH_LOG_AT_TRX_COMMIT} \
  --bulk-insert-buffer-size=${BULK_INSERT_BUFFER_SIZE} \
  --sort-buffer-size=${SORT_BUFFER_SIZE} \
  --read-rnd-buffer-size=${READ_RND_BUFFER_SIZE} \
  --join-buffer-size=${JOIN_BUFFER_SIZE}