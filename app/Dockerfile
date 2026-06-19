# lichte versie van python
FROM python:3.11-slim AS build

WORKDIR /app

# eerst alleen requirements kopiëren
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# de rest van de applicatiebestanden kopiëren
FROM gcr.io/distroless/python3-debian12

WORKDIR /app

COPY --from=build /install /usr/local

COPY . /app/

EXPOSE 5000

CMD ["/usr/local/bin/gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "application:app"].ansible/inventory