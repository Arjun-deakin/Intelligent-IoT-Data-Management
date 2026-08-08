FROM python:3.11-slim

WORKDIR /app

COPY data_science/archive/development /app
COPY algorithms /app/algorithms

RUN pip install --no-cache-dir flask pandas numpy matplotlib seaborn prometheus-client

EXPOSE 5000

CMD ["python", "server.py"]
