#!/bin/sh
set -e

# Run static collection on container start
python3 manage.py collectstatic --noinput

# Start Apache
exec "$@"