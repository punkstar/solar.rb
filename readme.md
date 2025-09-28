# ☀️ Solar

This repository provides tools for working with home solar power plants, specifically targeting Octopus as a provider.

## Setup

```
docker pull timescale/timescaledb-ha:pg17
docker run -d --name timescaledb -p 15432:5432  -v ./pgdata:/pgdata -e PGDATA=/pgdata -e POSTGRES_PASSWORD=password timescale/timescaledb-ha:pg17
bundle exec sequel -m migrations "postgres://postgres:password@127.0.0.1:15432/solar"
```