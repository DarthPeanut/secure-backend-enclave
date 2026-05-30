FROM python:3.11-slim
WORKDIR /app


COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt


COPY main.py .


RUN useradd -u 1001 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8080


ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]