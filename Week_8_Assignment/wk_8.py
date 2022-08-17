from flask import Flask
app = Flask(__name__)
@app.route('/')

def hello():
    return "Hello Jenkins, this is week 8!"

if __name__ == "__main__":
    app.run()