FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update && apt-get install -y libpq-dev gcc && rm -rf /var/lib/apt/lists/*

ARG ARTIFACT_PATH
COPY ${ARTIFACT_PATH} /tmp/app.tar.gz
RUN tar -xzf /tmp/app.tar.gz -C /app --strip-components=1 \
    && pip install --no-cache-dir -r /app/requirements-frozen.txt \
    && rm /tmp/app.tar.gz

EXPOSE 8000

CMD ["gunicorn", "book_shop.wsgi:application", "--bind", "0.0.0.0:8000"]
