# lichte versie van python
FROM python:3.11-slim AS build

WORKDIR /app

# eerst alleen requirements kopiëren
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# distroless image pakken en daar de app op runnen
FROM gcr.io/distroless/python3-debian12

WORKDIR /app

COPY --from=build /install /usr/local

COPY . /app/

ENV PYTHONPATH=/usr/local/lib/python3.11/site-packages

EXPOSE 5000

ENTRYPOINT ["/usr/bin/python3.11", "-m", "gunicorn"]
CMD ["-w", "4", "-b", "0.0.0.0:5000", "application:app"]