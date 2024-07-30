from flask import Flask,jsonify,request
app = Flask(__name__)

@app.route("/api/recieve",methods = ["POST"])
def recievedata():
    global data
    try:
        data = request.json.get("recievedata")
        print(f"Received data from Flutter: {data}")
        return jsonify({'message': 'Data received successfully'})
    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'})

@app.route("/api/send",methods=["GET"])
def senddata():
    message = {
        'data': data
    }
    return jsonify(message)
if __name__ == '__main__':
    app.run(host = "192.168.0.5",port = "8080")