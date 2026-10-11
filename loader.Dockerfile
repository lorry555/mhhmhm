FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY loader.py .
COPY utils.py .
COPY chains.py .
COPY images ./images

EXPOSE 8502

HEALTHCHECK CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8502/_stcore/health')"

ENTRYPOINT ["streamlit", "run", "loader.py", "--server.port=8502", "--server.address=0.0.0.0"]
