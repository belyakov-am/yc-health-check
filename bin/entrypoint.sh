#!/usr/bin/env bash

waiting_services() {
  if [ -n "${POSTGRES_HOST}" ]
  then
      echo "Waiting for PostgreSQL..."

      while ! nc -z $POSTGRES_HOST $POSTGRES_PORT; do
        sleep 0.5
        echo "Still waiting..."
      done

      echo "PostgreSQL started"
  fi

}

waiting_services
exec ./main