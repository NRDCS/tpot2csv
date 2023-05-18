#!/usr/bin/python3
'''
Export CSV file from T-POT collected information.
CSV purpose is to serve as a data feed for MISP instance.
Setup configuration file tpot2csv.ini before use
'''
import requests
import json
import csv
import syslog
import configparser
import os

config=configparser.ConfigParser()
config.read('tpot2csv.ini')
host=config.get('ElasticSearch','host')
port=config.get('ElasticSearch','port')
proto=config.get('ElasticSearch','proto')
index=config.get('ElasticSearch','index')
elastic_url="{}://{}:{}/{}/_search".format(proto, host, port, index) 
queryfile=config.get('ElasticSearch','filterfile')

folder=config.get('Output','folder')
filename=config.get('Output','filename')
outputfile = "{}/{}".format(folder, filename)


headers = {'Content-Type': 'application/json'}
query = json.load(open(queryfile))

try:
    response = requests.get(elastic_url, data=json.dumps(query), headers=headers, verify=False)
except (requests.exceptions.RequestException, ConnectionError) as error:
    raise SystemExit(error)


if response.status_code == 200 and 'took' in response.text:
    result = json.loads(response.text)
    aggs = next(iter(result['aggregations']))
    with open(outputfile, 'w') as csvfile:
        filewriter = csv.writer(csvfile, delimiter=',',
                            quotechar='|', quoting=csv.QUOTE_MINIMAL)
        filewriter.writerow(["Lastseen", "IP"])    
        for item in result['aggregations'][aggs]['buckets']:
            col1 = item['1']['value_as_string']
            col2 = item['key']
            filewriter.writerow([col1,col2])
        os.chmod(outputfile, 0o644)
else:
    syslog.syslog(syslog.LOG_ERR, response.text)