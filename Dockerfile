# syntax=docker/dockerfile:1

FROM python:3.13-slim-bookworm@sha256:4c2cf9917bd1cbacc5e9b07320025bdb7cdf2df7b0ceaccb55e9dd7e30987419 AS debian

LABEL project="Python Insecure App" service="FastAPI" stage="debian"
ENV APPUSER=nonroot \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV=/opt/venv \
    WORKDIR=/app
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"
WORKDIR $WORKDIR
COPY --chown=$APPUSER ./requirements/base.txt requirements/base.txt
COPY --chown=$APPUSER ./requirements/common.txt requirements/common.txt
RUN useradd --no-create-home $APPUSER \
    && chown $APPUSER:$APPUSER $WORKDIR \
    && python3 -m venv $VIRTUAL_ENV \
    && chown -R $APPUSER:$APPUSER $VIRTUAL_ENV \
    && python3 -m pip install --no-cache-dir -r requirements/base.txt \
    && python3 -m uv pip install --no-cache --no-deps -r requirements/common.txt
USER $APPUSER
COPY --chown=$APPUSER app app
ENTRYPOINT [ "" ]
CMD [ "python3", "-m", "fastapi", "run", "app/main.py" ]
