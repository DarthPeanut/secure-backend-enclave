FROM python:3.11-slim
WORKDIR /app

ARG CACHE_BUSTER=1
ENV DYNAMIC_BUILD_REF=$CACHE_BUSTER


RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir fastapi uvicorn==0.30.1


RUN groupadd -r appgroup && useradd -r -g appgroup -s /sbin/nologin appuser


COPY --chown=appuser:appgroup main.py .

EXPOSE 8080

ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app


USER appuser

CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
