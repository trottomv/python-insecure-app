import sqlite3
import os
from flask import Flask, request

app = Flask(__name__)

@app.route("/user")
def get_user():
    user_id = request.args.get("id")
    conn = sqlite3.connect("users.db")
    cursor = conn.cursor()
    # FAILLE 1 (SQL Injection)
    query = f"SELECT * FROM users WHERE id = '{user_id}'"
    cursor.execute(query)
    return cursor.fetchall()

@app.route("/ping")
def ping_host():
    target = request.args.get("ip")
    # FAILLE 2 (Command Injection)
    os.system("ping -c 1 " + target)
    return "Ping triggered"

if __name__ == "__main__":
    app.run(port=5000)
