FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app/vendor

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends libpq-dev \
    && rm -rf /var/lib/apt/lists/*

ARG ARTIFACT_NAME
COPY artifacts/${ARTIFACT_NAME} /tmp/artifact.tar.gz
RUN tar -xzf /tmp/artifact.tar.gz --strip-components=1 -C /app \
    && rm /tmp/artifact.tar.gz

EXPOSE 8000

CMD ["python", "-m", "gunicorn", "book_shop.wsgi:application", "--bind", "0.0.0.0:8000"]
