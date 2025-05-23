# syntax=docker/dockerfile:1

FROM python:3.12-slim-bookworm@sha256:31a416db24bd8ade7dac5fd5999ba6c234d7fa79d4add8781e95f41b187f4c9a AS debian

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
