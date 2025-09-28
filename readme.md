docker pull timescale/timescaledb-ha:pg17

# Runs the database on port 15432
docker run -d --name timescaledb -p 15432:5432  -v ./pgdata:/pgdata -e PGDATA=/pgdata -e POSTGRES_PASSWORD=password timescale/timescaledb-ha:pg17

# Runs migrations.
bundle exec sequel -m migrations "postgres://postgres:password@127.0.0.1:15432/solar"