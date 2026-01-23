from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Vulnerable Python/Flask App (Python 3.7) - Running OK'

@app.route('/health')
def health():
    return {
        'status': 'running',
        'python': '3.7.0',
        'vulnerable': True
    }

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
