from os import environ
from flask import Flask
import boto3

app = Flask(__name__)
app.config['ec2_instance_id'] = environ.get('EC2_INSTANCE_ID')
app.config['region'] = environ.get('REGION')
ec2 = boto3.resource('ec2', app.config['region'])

def getInstance():
    return ec2.Instance(app.config['ec2_instance_id'])

def getInstanceTags():
    tags = getInstance().tags
    return tags

@app.route("/")
def home():
    return "<p>Server is up...</p>"


@app.route("/tags")
def tags():
    tags = getInstanceTags()
    html = ''
    for tag in tags:
        html += f"<p><b>{tag['Key']}:</b> <small>{tag['Value']}</small></p>"
    return html

@app.route('/shutdown')
def shutdownInstance():
    result = getInstance().stop()
    return f"<p><b>Server [{app.config['ec2_instance_id']}] was shutdown</b></p>"

if __name__ == '__main__':
    port = int(environ.get('SERVER_PORT'))
    app.run(host="0.0.0.0", port=port, debug=True)