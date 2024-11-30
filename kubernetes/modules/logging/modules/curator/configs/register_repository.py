import os
import requests
import sys,json
from requests_aws4auth import AWS4Auth

def register_repository(bucket, region, es_url, es_user, es_password, role_arn, aws_access_key, aws_secret_key):
    host = "https://"+es_url+"/"
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
    es_url = os.getenv('OPENSEARCH_ENDPOINT')
    es_user=os.getenv('OPENSEARCH_USERNAME')
    es_password = os.getenv('OPENSEARCH_PASSWORD')
    region = os.getenv('REGION')
    bucket = os.getenv('S3_BUCKET')
    role_arn = os.getenv('IAM_ROLE')
    aws_access_key = os.getenv('ACCESS_KEY')
    aws_secret_key = os.getenv('SECRET_KEY')

    register_repository(bucket, region, es_url, es_user, es_password, role_arn, aws_access_key, aws_secret_key)