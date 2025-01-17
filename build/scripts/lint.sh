#!/usr/bin/env bash

EXIT_CODE=0
DIRNAME=$(dirname "$0")
HOST_APP_VOLUME="${HOST_APP_VOLUME-${PWD}/${DIRNAME}/../..}"
DOCKERFILE=Dockerfile
DOCKERFILE_PATH=.

set -v

docker run --rm -v "${PWD}/${DOCKERFILE_PATH}/${DOCKERFILE}":/Dockerfile:ro redcoolbeans/dockerlint
docker run --rm --privileged -v ${PWD}/${DOCKERFILE_PATH}:/root/ projectatomic/dockerfile-lint dockerfile_lint -f ${DOCKERFILE}

docker-compose run --rm php composer diagnose || EXIT_CODE=1

docker-compose run --rm php vendor/bin/php-cs-fixer fix --dry-run --format=txt -v src || EXIT_CODE=1

docker run --rm -v "${HOST_APP_VOLUME}/build/scripts/lint.sh:/tmp/FileToBeChecked" chrisdaish/shellcheck || EXIT_CODE=1
docker run --rm -v "${HOST_APP_VOLUME}/build/scripts/build.sh:/tmp/FileToBeChecked" chrisdaish/shellcheck || EXIT_CODE=1
docker run --rm -v "${HOST_APP_VOLUME}/build/scripts/test.sh:/tmp/FileToBeChecked" chrisdaish/shellcheck || EXIT_CODE=1
docker run --rm -v "${HOST_APP_VOLUME}/build/scripts/deploy.sh:/tmp/FileToBeChecked" chrisdaish/shellcheck || EXIT_CODE=1
docker run --rm -v "${HOST_APP_VOLUME}/build/scripts/requirements.sh:/tmp/FileToBeChecked" chrisdaish/shellcheck || EXIT_CODE=1

set +v

exit ${EXIT_CODE}