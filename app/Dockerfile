# lichte versie van python
FROM python:3.11-slim

WORKDIR /app

# eerst alleen requirements kopiëren
COPY . requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# de rest van de applicatiebestanden kopiëren
COPY . /app/

EXPOSE 5000

CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "application:app"]