#!/bin/bash

set -e

function wait_service {
    while ! nc -z $1 $2; do
        sleep 1
    done
}

case $1 in
    run-migrations)
        echo "--> Applying migrations"
        wait_service $REDIS_HOST $REDIS_PORT
        wait_service $DB_HOST $DB_PORT
        exec php artisan migrate --no-interaction
        ;;
    run-artisanserver)
        echo "--> Starting Laravel's server"
        wait_service $REDIS_HOST $REDIS_PORT
        wait_service $DB_HOST $DB_PORT
        exec php artisan serve --host=0.0.0.0 --port=8000
        ;;
    run-npmwatch)
        echo "--> Starting NPM run watch"
        exec npm run watch
        ;;
    run-tests)
        echo "--> Starting Laravel's test framework"
        wait_service $REDIS_HOST $REDIS_PORT
        wait_service $DB_HOST $DB_PORT
        exec php artisan test --no-interaction
        ;;
    *)
        exec "$@"
        ;;
esac
