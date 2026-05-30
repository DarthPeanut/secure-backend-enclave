FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .


RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir --target=/usr/local/lib/python3.11/site-packages -r requirements.txt


COPY main.py /app/main.py

EXPOSE 8080

ENV PYTHONUNBUFFERED=1

ENV PYTHONPATH=/usr/local/lib/python3.11/site-packages


CMD ["/usr/local/lib/python3.11/site-packages/bin/uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]