# syntax=docker/dockerfile:1

FROM python:3.13-slim-trixie@sha256:58c30f5bfaa718b5803a53393190b9c68bd517c44c6c94c1b6c8c172bcfad040 AS debian

LABEL project="Python Insecure App" service="FastAPI" stage="debian"
ENV NONROOT=nonroot \
	LANG=C.UTF-8 \
	LC_ALL=C.UTF-8 \
	PYTHONDONTWRITEBYTECODE=1 \
	PYTHONUNBUFFERED=1 \
	VIRTUAL_ENV=/opt/venv \
	WORKDIR=/app
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"
WORKDIR $WORKDIR
COPY --chown=$NONROOT ./requirements/base.txt requirements/base.txt
COPY --chown=$NONROOT ./requirements/common.txt requirements/common.txt
RUN useradd --no-create-home $NONROOT \
	&& chown $NONROOT:$NONROOT $WORKDIR \
	&& python3 -m venv $VIRTUAL_ENV \
	&& chown -R $NONROOT:$NONROOT $VIRTUAL_ENV \
	&& python3 -m pip install --no-cache-dir -r requirements/base.txt \
	&& python3 -m uv pip install --no-cache --no-deps -r requirements/common.txt
USER $NONROOT
COPY --chown=$NONROOT app app
ENTRYPOINT [ "" ]
CMD [ "python3", "-m", "fastapi", "run", "app/main.py", "--port", "1337" ]
