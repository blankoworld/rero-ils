# -*- coding: utf-8 -*-
#
# RERO ILS
# Copyright (C) 2019 RERO
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

FROM python:3.6-alpine3.9

# Install Invenio
ENV WORKING_DIR=/invenio
ENV INVENIO_INSTANCE_PATH=${WORKING_DIR}/var/instance
RUN mkdir -p ${INVENIO_INSTANCE_PATH}

# what about files mountpoints (data, archive, static)?

ENV INVENIO_COLLECT_STORAGE='flask_collect.storage.file'

# create user
RUN adduser -D -u 1000 -h ${WORKING_DIR} invenio invenio
RUN chown invenio:invenio ${WORKING_DIR}

# set the locale thanks to icu-libs
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# copy uwsgi config files
COPY ./docker/uwsgi/ ${INVENIO_INSTANCE_PATH}

# copy everything inside /src
RUN mkdir -p ${WORKING_DIR}/src
COPY --chown=invenio:invenio . ${WORKING_DIR}/src
WORKDIR ${WORKING_DIR}/src

# Why +w?
# RUN chmod -R go+w ${WORKING_DIR}

# --no-cache option do `apk update` and delete /var/apk/cache content.
# Does vim-tiny really needed?
# ca-certificates is already present (in python:3.6-alpine3.9).
# {WORKING_DIR}/.cache contains pip and pipenv cache. ~140MB
# `npm cache clean` deletes ${WORKING_DIR}/.npm/_cacache directory. ~130MB
RUN set -ex \
  && apk --no-cache add --virtual .build-deps \
    build-base \
    curl \
    git \
    libffi-dev \
    libpq \
    libxml2-dev \
    libxslt-dev \
    openssl-dev \
    postgresql-dev \
    python3-dev \
  && apk --no-cache add \
    bash \
    icu-libs \
    nodejs \
    npm \
  && pip install --no-cache-dir --upgrade pip \
  && pip install --no-cache-dir --upgrade pipenv setuptools wheel \
  && su -c "cd ${WORKING_DIR}/src && $(which bash) ./scripts/bootstrap --deploy \
  && rm -fr ui/node_modules \
  && npm cache clean -f" - invenio \
  && apk del .build-deps \
  && rm -rf ${WORKING_DIR}/.cache \

USER 1000
