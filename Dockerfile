# syntax=docker/dockerfile:1

ARG PYTHON_TAG=3.10-alpine3.22

FROM python:${PYTHON_TAG} AS base

RUN apk add --no-cache \
  ffmpeg \
  git \
  imagemagick \
  openssh-client-default \
  rclone \
  rsync

# Approximate size of each addition (incl. dependencies):
#
#         rsync:   2 MB
#   imagemagick: 126 MB
#        ffmpeg:  38 MB
#           npm:  76 MB

# Build
FROM base AS build
RUN apk add --no-cache npm esbuild make
WORKDIR /build
COPY . .
#RUN cd frontend && \
#        npm install && \
#        esbuild

ARG LEKTOR_VERSION
ENV SETUPTOOLS_SCM_PRETEND_VERSION="${LEKTOR_VERSION:-0.0a0+docker}"
RUN make build-js
RUN pip install --no-cache-dir .
RUN pip install lektor-datetime-helpers lektor-git-src-publisher lektor-git-timestamp mistune
RUN cp -auv /build/lektor /usr/local/lib/python3.10/site-packages/

FROM base AS lektor
COPY --from=build /usr/local /usr/local/
RUN addgroup -g 1000 lektor
RUN adduser -h /home/lektor -D -u 1000 lektor

# Site source code
VOLUME /project /output
WORKDIR /project
COPY example .
ENV LEKTOR_OUTPUT_PATH=/output

# Other useful environment variables
# LEKTOR_DEPLOY_USERNAME
# LEKTOR_DEPLOY_PASSWORD
# LEKTOR_DEPLOY_KEY_FILE
# LEKTOR_DEPLOY_KEY

# lektor server
EXPOSE 5000

# ENTRYPOINT ["entrypoint.sh"]
CMD ["lektor", "server", "--host", "0.0.0.0"]
