FROM httpd:2.4-alpine

# Installing python and dependencies
ENV PYTHONUNBUFFERED=1
RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools

RUN pip3 install requests
RUN pip3 install configparser

# Setting up feed processing folder
RUN mkdir -p /opt/tpot2csv
WORKDIR /opt/tpot2csv
COPY query.json tpot2csv.ini tpot2csv.py ./

# Adding cron job to update feed file
COPY --chmod=755 cronscript /etc/periodic/15min/

# Adding apache configuration
COPY httpd.conf /usr/local/apache2/conf/
COPY tpot2csv.conf /usr/local/apache2/conf/

# Setting up group to enable apache read feed file
RUN addgroup -g 2000 tpot
RUN addgroup www-data tpot

# Setting up startup script for the services
RUN sed -i -e 's/^set -e/set -e\ncrond -l 2\n/' /usr/local/bin/httpd-foreground

# Run apache together with cron
CMD ["/usr/local/bin/httpd-foreground"]
