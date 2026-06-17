import logging
import os
import psycopg2
import psycopg2.extras
from werkzeug.security import check_password_hash
from flask import Flask, session, redirect, url_for, request, render_template, abort
from prometheus_flask_exporter import PrometheusMetrics


app = Flask(__name__)
app.secret_key = os.environ["SECRET_KEY"]
metrics = PrometheusMetrics(app)
app.logger.setLevel(logging.INFO)


def get_db_connection():
    return psycopg2.connect(
        host=os.environ["DB_HOST"],
        dbname=os.environ["DB_NAME"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        cursor_factory=psycopg2.extras.RealDictCursor,
    )


def is_authenticated():
    if "username" in session:
        return True
    return False


def authenticate(username, password):
    connection = get_db_connection()
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM users WHERE username = %s", (username,)) # fetch one instead of every user
    user = cursor.fetchone()
    cursor.close()
    connection.close()

    if user and check_password_hash(user["password"], password):  # check hash instead of plaintext password
        app.logger.info(f"the user '{username}' logged in successfully") # removed password from logs
        session["username"] = username
        return True

    app.logger.warning(f"the user '{username}' failed to log in") # removed password from logs
    abort(401)


@app.route("/")
def index():
    return render_template("index.html", is_authenticated=is_authenticated())


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        username = request.form.get("username")
        password = request.form.get("password")
        if authenticate(username, password):
            return redirect(url_for("index"))
    return render_template("login.html")


@app.route("/logout")
def logout():
    session.pop("username", None)
    return redirect(url_for("index"))
