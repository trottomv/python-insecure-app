# syntax=docker/dockerfile:1

FROM python:3.12-slim-bookworm@sha256:032c52613401895aa3d418a4c563d2d05f993bc3ecc065c8f4e2280978acd249 AS base
# FROM python:3.12-alpine@sha256:38e179a0f0436c97ecc76bcd378d7293ab3ee79e4b8c440fdc7113670cb6e204 AS base

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
RUN useradd --no-create-home $APPUSER
# RUN addgroup -S $APPUSER && adduser -S $APPUSER -G $APPUSER
RUN chown $APPUSER:$APPUSER $WORKDIR
COPY --chown=$APPUSER ./requirements/base.txt requirements/base.txt
COPY --chown=$APPUSER ./requirements/common.txt requirements/common.txt
RUN python3 -m venv $VIRTUAL_ENV \
    && chown -R $APPUSER:$APPUSER $VIRTUAL_ENV
# USER $APPUSER
RUN python3 -m pip install --no-cache-dir -r requirements/base.txt \
    && python3 -m uv pip install --no-cache --no-deps -r requirements/common.txt
COPY --chown=$APPUSER . .
ENTRYPOINT [ "" ]
CMD [ "fastapi", "run", "app/main.py" ]
