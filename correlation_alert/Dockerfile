FROM python:3.11-slim

WORKDIR /app

COPY . /app

RUN pip install --no-cache-dir flask flask-cors pandas numpy prometheus-client

EXPOSE 5001

CMD ["python", "server.py"]
