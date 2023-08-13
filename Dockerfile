#
# Dockerfile
#

From alpine:latest As ci-dagger-test

# app + args
# Executes `entrypoint.sh` when the Docker container starts up
ENTRYPOINT ["echo"]

# Extra args
CMD []
