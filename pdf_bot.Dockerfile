FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY pdf_bot.py .
COPY utils.py .
COPY chains.py .

EXPOSE 8503

HEALTHCHECK CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8503/_stcore/health')"

ENTRYPOINT ["streamlit", "run", "pdf_bot.py", "--server.port=8503", "--server.address=0.0.0.0"]
