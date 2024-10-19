# syntax=docker/dockerfile:1

FROM python:3.12-alpine@sha256:e75de178bc15e72f3f16bf75a6b484e33d39a456f03fc771a2b3abb9146b75f8 AS base

HEALTHCHECK NONE
LABEL project="Python Insecure App" service="FastAPI" stage="base"
ARG USER=appuser
ENV APPUSER=$USER \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV=/opt/venv \
    WORKDIR=/app
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"
WORKDIR $WORKDIR
RUN addgroup -S $APPUSER && adduser -S $APPUSER -G $APPUSER
RUN chown $APPUSER:$APPUSER $WORKDIR
COPY --chown=$APPUSER ./requirements/base.txt requirements/base.txt
COPY --chown=$APPUSER ./requirements/common.txt requirements/common.txt
RUN python3 -m venv $VIRTUAL_ENV \
    && chown -R $APPUSER:$APPUSER $VIRTUAL_ENV
USER $APPUSER
RUN python3 -m pip install --no-cache-dir -r requirements/base.txt \
    && python3 -m uv pip install --no-cache --no-deps -r requirements/common.txt

FROM base AS common

LABEL project="Python Insecure App" service="FastAPI" stage="common"
COPY --chown=$APPUSER . .
CMD [ "fastapi", "run", "app/main.py" ]
