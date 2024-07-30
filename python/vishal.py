from flask import Flask,jsonify,request
app = Flask(__name__)

@app.route("/getval" , methods=["GET"])
def hello_world():
    a= [1,2,3,4]
    mssg ={
        "ans":a
    }
    # print("jei")
    return jsonify(mssg)
if __name__ == '__main__':
    app.run(host="192.168.102.133",port=8080)
# a = [1,2,3,4] 
# mssg = {
#     "ans":a
# }
# print(mssg["ans"])