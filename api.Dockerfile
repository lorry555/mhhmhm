FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY api.py .
COPY utils.py .
COPY chains.py .

HEALTHCHECK CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8504')"

ENTRYPOINT [ "uvicorn", "api:app", "--host", "0.0.0.0", "--port", "8504" ]
