# light version of python
FROM python:3.11-slim AS build

WORKDIR /app

# first only copy requirements.txt
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# get distroless iamge and run the app on that
FROM gcr.io/distroless/python3-debian12

WORKDIR /app

COPY --from=build /install /usr/local

COPY . /app/

# distroless doesnt look at /usr/local/lib/.../site-packages automaticly
ENV PYTHONPATH=/usr/local/lib/python3.11/site-packages

EXPOSE 5000

# no shell in distroless so laucnh gunicorn via python
ENTRYPOINT ["/usr/bin/python3.11", "-m", "gunicorn"]
CMD ["-w", "4", "-b", "0.0.0.0:5000", "application:app"]