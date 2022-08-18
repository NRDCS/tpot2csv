# tpot2csv
This docker creates CSV feed from the T-POT collected data in the ElasticSearch database.

Docker is based on official apache2.4 alpine docker image with python install and cron job configured. `tpot2csv.py` connects to elasticsearch service (being on the same network as t-pot containers), retrieves data based on saved query (`query.json` file), saves timestamp and source IP columns into CSV file. `query.json` is adjusted in a way query aggregates data for each unique IP with the latest timestamp seen. Content for the `query.json` can be taken from Kibana interface Inspect screen.

## Usage:
Use `.env.dist` to create actual `.env` file (adjust virtual host name and email address for Apache configuration) and run `install.sh` to build and launch container.
```bash
cp .env.dist .env
vi .env
./install.sh
```

## Notes:
- t-pot's nginx SSL certificate is being used from files `/data/nginx/cert/nginx.{crt,key}`. Restart container if you replacing certificate.
```bash
docker restart tpot2csv
```
- apache service logs goes to `/data/tpot2csv/log`
