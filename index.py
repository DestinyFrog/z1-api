from flask import Flask, make_response, request, jsonify
import subprocess
import sqlite3

app = Flask(__name__)

def get_conn():
    return sqlite3.connect('a.sqlite3')

fields = "uid, name"

def build_molecula(obj):
    (uid, name) = obj
    return {
        "uid": uid,
        "name": name
    }

@app.route("/")
def get_all_molecula():
    conn = get_conn()
    cursor = conn.cursor()
    cursor.execute(f"SELECT {fields} FROM molecula")
    
    moleculas = []
    for obj in cursor.fetchall(): 
        molecula = build_molecula(obj)
        moleculas.append(molecula)

    conn.commit()
    conn.close()
    return jsonify(moleculas)

@app.route("/<uuid:uid>")
def get_one_molecula_by_uid(uid:str):
    conn = get_conn()
    cursor = conn.cursor()
    cursor.execute(f"SELECT {fields} FROM molecula WHERE uid = '{uid}'")

    obj = cursor.fetchone()
    molecula = build_molecula(obj)

    conn.commit()
    conn.close()
    return jsonify(molecula)

@app.route("/<uuid:uid>/svg")
def get_svg(uid):
    mode = request.args.get("mode") or "standard"
    result = subprocess.run(["lua", "z1.lua", mode, str(uid)], capture_output=True, text=True)

    return_code = result.returncode

    if return_code != 0:
        err = result.stderr
        [status_code, message] = err.split("|")
        resp = make_response(message)
        resp.status_code = int(status_code)
        return resp

    content = result.stdout
    resp = make_response(content)
    return resp

if __name__ == '__main__':
    app.run( debug=True )