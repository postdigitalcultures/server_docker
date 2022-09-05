The Centre for Postdigital Cultures site is available at https://postdigitalcultures.org. The site is hosted on an Njalla virtual private server registered to Simon Bowie <ad7588@coventry.ac.uk>. The server and domain name can be administered through [Njalla's website](https://njal.la/).

**Server admin:**

Simon Bowie (Open-Source Software Developer) - ad7588@coventry.ac.uk

# Technical details

Hostname: postdigitalcultures.org

IPv4 address: 80.78.22.120

IPv6 address: 2a0a:3840:8078:22::504e:1678:1337

Location:

Operating system: Ubuntu 22.04.1 LTS

Processors: 3 cores

RAM: 4.5 GB

Hard disk space: 45 GB

Bandwidth: 4.5 TB

# Email

Email was set up on the server using Postfix and an SMTP relay at Sendinblue. This was set up following instructions at https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-postfix-as-a-send-only-smtp-server-on-ubuntu-20-04, https://www.linuxbabe.com/mail-server/setup-basic-postfix-mail-sever-ubuntu, and https://www.linuxbabe.com/mail-server/postfix-smtp-relay-ubuntu-sendinblue. 

WordPress' email was configured using the Post SMTP Mailer plugin: https://wordpress.org/plugins/post-smtp/

# Docker

Docker is running containers on the server for all the services that the server runs: MariaDB, WordPress, Nginx, and GoAccess. This runs from /home/cpc_admin/docker with the containers specified in the docker-compose.yml file in that directory.

ctop can be used to show htop-like information on running containers including CPU usage, memory usage, etc. This can also be used to restart single containers, view logs, and enter containers in shell sessions.

## Docker volumes

Data for the various Docker volumes is contained in /var/lib/docker/volumes. Each directory represents a volume used for permanent data storage for containers.

## Basic Docker Compose commands

Start and stop Docker Compose with:

```
docker-compose up -d
docker-compose down
docker-compose restart
```

View current Docker Compose config with:

```
docker-compose config
```

Enter a Docker container in shell using:

```
sudo docker exec -it <container name> /bin/bash
```

## Docker containers

### GoAccess

The goaccess container runs GoAccess visual real-time web log analyzer (<https://goaccess.io/>). This analyses the access_log that Nginx produces for postdigitalcultures.org and provides a real-time analysis.

This Docker setup is based on icamys' setup for Nginx and GoAccess in Docker on GitHub: <https://github.com/icamys/docker-goaccess-nginx>. Persistent data is turned on in goaccess.conf to ensure that log data is kept when Docker Compose is turned off and on again: this data is retained in /home/cpc_admin/docker/goaccess/data/database/.

The GeoLite2-City.mmdb database file in /home/cpc_admin/docker/goaccess is used to determine what city users are visiting the site from based on their IP address. This was obtained by registering at <https://dev.maxmind.com/geoip/geolite2-free-geolocation-data?lang=en> to download a copy of the database.

To restrict what personal data we collect on users, ./nginx.conf zeroes the final octet of a user's IP address in access_log:

```
    map $remote_addr $remote_addr_anon {
        ~(?P<ip>\d+\.\d+\.\d+)\.    $ip.0;
        ~(?P<ip>[^:]+:[^:]+):       $ip::;
        127.0.0.1                   $remote_addr;
        ::1                         $remote_addr;
        default                     0.0.0.0;
    }

    log_format  main  '$remote_addr_anon - $remote_user [$time_local] "$request" '
        '$status $body_bytes_sent "$http_referer" '
        '"$http_user_agent" "$http_x_forwarded_for"';
```

Further, a cron job on the root crontab ('sudo crontab -e') runs /home/cpc_admin/bin/anonymize-logs every week. This script anonymizes the IP addresses of users in log files older than 2 months. This is based on instructions and a script available at <https://www.supertechcrew.com/anonymizing-logs-nginx-apache/>

### onion service containers

The production Docker Compose configuration also provides an onion service version of the WordPress site. This uses torservers' Onionize container (https://github.com/torservers/onionize-docker) to automatically exposes other selected Docker containers as onion services. It uses a 'faraday' network to only expose services on that internal network outwards to the Tor network. A separate version of Nginx labelled onion-nginx exposes the website on that internal network.

To output the onion address that has been assigned, run the command:

docker exec onionize cat /var/lib/tor/onion_services/<ONIONSERVICE_NAME>/hostname

(in our case): docker exec onionize cat /var/lib/tor/onion_services/onion-nginx/hostname

WordPress dynamically rewrites permalinks using a function derived from https://blog.paranoidpenguin.net/2017/09/how-to-configure-wordpress-as-a-tor-hidden-service/. Every time the Tor Onionize container is restarted, you should run rewrite_onion_address.sh to update the onion address in WordPress to the latest address.
