FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --retries 10 torch --index-url https://download.pytorch.org/whl/cpu && \
    pip install --retries 10 -r requirements.txt

COPY src/ ./src/

RUN mkdir -p /app/data/chroma

EXPOSE 5002

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "5002"]
