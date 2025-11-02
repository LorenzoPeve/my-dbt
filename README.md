# dbt Tutorial Repository

Welcome to the dbt tutorial repository! This repo is designed to help you learn and practice dbt concepts.

## Structure

- **Each branch** in this repository covers a specific dbt topic or feature.
- Switch between branches to explore different tutorials and examples.

## Getting Started

1. Clone the repository.
2. Checkout the branch for the topic you want to learn.
3. Follow the instructions in the branch's README or documentation.

### Setting up the Python Environment

```bash
python3 -m venv env
source env/bin/activate
pip install -r requirements.txt
```

### Setting up PostgreSQL in Docker

To set up PostgreSQL in Docker, you can use the following command:

```bash
docker run --name my_postgres -d -p 5432:5432 -e POSTGRES_PASSWORD=mypass123  -v my_postgres_data:/var/lib/postgresql/data postgres
```

### Resolving dbt Profile Directory Error

If you encounter the following error:

```
Error: Invalid value for '--profiles-dir': Path '/Users/lorenzopeve/.dbt' does not exist.
```

Create the following environment variables in your shell:

```bash
export DBT_PROFILES_DIR=$PWD/.dbt/ 
```

This error occurs because dbt searches for the `profiles.yml` file in `~/Users/name/.dbt/` by default. By setting the `DBT_PROFILES_DIR` environment variable, you can specify a different directory for dbt to look for the profiles.yml file.
