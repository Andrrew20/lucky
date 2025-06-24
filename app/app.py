from flask import Flask, jsonify, render_template
import tomli as tomllib
import psycopg2
import time

app = Flask(__name__)

with open('config.toml', 'rb') as f:
    config = tomllib.load(f)
db_config = config['database']

def db_health():
    try:
        conn = psycopg2.connect(
            database=db_config['database'],
            user=db_config['user'],
            password=db_config['password'],
            host=db_config['host'],
            port=db_config['port']
        )
        conn.close()
        return True
    except:
        return False

@app.route('/status')
def status():
    return jsonify({
        'status': 'ok',
        'db_connected': db_health(),
        'timestamp': time.time()
    })

@app.route('/')
def home():
    return render_template('index.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=config['server']['port'])