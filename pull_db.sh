#!/usr/bin/env bash
set -e

# ── Docker resource constraints ───────────────────────────────────────────────
CPUS=8      # passed to --cpus; decimals accepted (e.g. 4.5)
MEMORY=32G  # passed to --memory; suffix must be G or M (e.g. 32G, 16384M)

# ── MySQL credentials ─────────────────────────────────────────────────────────
MYSQL_ROOT_PASSWORD="root_pass"  # modify if using in prod
MYSQL_DATABASE="tinx"
DB_USER="tinx_user"
DB_PASSWORD="user_pass"          # modify if using in prod

# MySQL host port
HOST_PORT=3306

# ── Auto-derive MySQL tuning from CPUS / MEMORY ───────────────────────────────

# Parse MEMORY into total megabytes (awk handles the arithmetic; bash is int-only)
mem_unit="${MEMORY: -1}"
mem_num="${MEMORY%[GMgm]}"
case "${mem_unit^^}" in
    G) MEM_MB=$(awk "BEGIN{printf \"%d\", ${mem_num} * 1024}") ;;
    M) MEM_MB=${mem_num} ;;
    *) echo "ERROR: MEMORY must end in G or M (e.g. 32G, 16384M)" >&2; exit 1 ;;
esac

# Round CPUS to nearest integer (supports decimal input e.g. 4.5)
CPU_INT=$(awk "BEGIN{printf \"%d\", ${CPUS} + 0.5}")

# buffer pool ≈ 65% of RAM, in whole GB — the single most important InnoDB knob
BP_GB=$(awk "BEGIN{printf \"%d\", ${MEM_MB} * 0.65 / 1024}")
INNODB_BUFFER_POOL_SIZE="${BP_GB}G"

# 1 instance per CPU, clamped to [1, 64] (MySQL hard limit)
INNODB_BUFFER_POOL_INSTANCES=$(( CPU_INT < 1 ? 1 : (CPU_INT > 64 ? 64 : CPU_INT) ))

# IO threads aligned to CPU count (same clamp as instances)
INNODB_READ_IO_THREADS=${INNODB_BUFFER_POOL_INSTANCES}
INNODB_WRITE_IO_THREADS=${INNODB_BUFFER_POOL_INSTANCES}

# Purge threads ≈ half of CPUs, minimum 1
INNODB_PURGE_THREADS=$(( CPU_INT / 2 < 1 ? 1 : CPU_INT / 2 ))

# Redo log capacity ≈ 20% of buffer pool, minimum 1G, in whole GB
# (replaces innodb_log_file_size in MySQL 8.0.30+)
REDO_GB=$(awk "BEGIN{v=int(${BP_GB} * 0.20); print (v < 1 ? 1 : v)}")
INNODB_REDO_LOG_CAPACITY="${REDO_GB}G"

# Log buffer ≈ 0.8% of RAM, clamped to [16M, 256M]
LOG_BUF_MB=$(awk "BEGIN{v=int(${MEM_MB} * 0.008); if(v<16)v=16; if(v>256)v=256; print v}")
INNODB_LOG_BUFFER_SIZE="${LOG_BUF_MB}M"
INNODB_FLUSH_METHOD="O_DIRECT"
# see: https://docs.netapp.com/us-en/ontap-apps-dbs/mysql/mysql-innodb_flush_log_at_trx_commit.html
INNODB_FLUSH_LOG_AT_TRX_COMMIT=2

# Fixed: per-connection buffers — kept modest because they multiply per thread
BULK_INSERT_BUFFER_SIZE=256M
SORT_BUFFER_SIZE=64M
READ_RND_BUFFER_SIZE=32M
JOIN_BUFFER_SIZE=32M

echo "Derived MySQL tuning for ${CPUS} CPUs / ${MEMORY} RAM:"
echo "  innodb_buffer_pool_size      = ${INNODB_BUFFER_POOL_SIZE}"
echo "  innodb_buffer_pool_instances = ${INNODB_BUFFER_POOL_INSTANCES}"
echo "  innodb_read_io_threads       = ${INNODB_READ_IO_THREADS}"
echo "  innodb_write_io_threads      = ${INNODB_WRITE_IO_THREADS}"
echo "  innodb_purge_threads         = ${INNODB_PURGE_THREADS}"
echo "  innodb_redo_log_capacity     = ${INNODB_REDO_LOG_CAPACITY}"
echo "  innodb_log_buffer_size       = ${INNODB_LOG_BUFFER_SIZE}"

# ── Build and run ─────────────────────────────────────────────────────────────
# TODO: replace this with dockerhub repo once pushed
docker build -t tinx-db .
docker run -d \
  --cpus ${CPUS} \
  --memory ${MEMORY} \
  -p ${HOST_PORT}:3306 \
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