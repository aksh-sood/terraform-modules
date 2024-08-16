import requests
import sys,json
from requests_aws4auth import AWS4Auth

def register_repository(bucket, region, es_url, es_user, es_password, role_arn, aws_access_key, aws_secret_key):
    host = "https://vpc-durga-zk7qamsikixubikoklrbodvbvu.us-east-1.es.amazonaws.com/"
    es_auth=(es_user,es_password)
    region = region
    headers = {"Content-Type": "application/json"}
    service = 'es'
    awsauth = AWS4Auth(aws_access_key, aws_secret_key, region, service)
    session = requests.Session()
    session.auth = es_auth
    auth = session.post(host, verify=False)


    path = '_snapshot/s3-snapshot' # the OpenSearch API endpoint
    url = host + path

    payload = {
    "type": "s3",
    "settings": {
        "bucket": bucket,
        "region": region,
        "role_arn": role_arn
    }
    }
    response = session.put(url, auth=awsauth, json=payload, headers=headers, verify=False)

    if response.status_code == 200:
            print(json.dumps({"success": "True", "message": response.text}))
    else:
            print(json.dumps({"success": "False", "message": response.text})) 

if __name__ == '__main__':
    input_data = json.load(sys.stdin)
    bucket = input_data['bucket']
    region = input_data['region']
    es_url = input_data['es_url']
    es_user = input_data['es_user']
    es_password = input_data['es_password']
    role_arn = input_data['role_arn']
    aws_access_key = input_data['aws_access_key']
    aws_secret_key = input_data['aws_secret_key']
    register_repository(bucket, region, es_url, es_user, es_password, role_arn, aws_access_key, aws_secret_key)