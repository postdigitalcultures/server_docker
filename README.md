The Centre for Postdigital Cultures site is available at https://postdigitalcultures.org. The site is hosted on an Njalla virtual private server registered to Simon Bowie <ad7588@coventry.ac.uk>. The server and domain name can be administered through [Njalla's website](https://njal.la/).

**Server admin:**

Simon Bowie (Open-Source Software Developer) - ad7588@coventry.ac.uk

# Technical details

Hostname: postdigitalcultures.org

IPv4 address: 80.78.22.120

IPv6 address: 2a0a:3840:8078:22::504e:1678:1337

Location:

Operating system: Ubuntu 24.04.1 LTS

Processors: 3 cores

RAM: 4.5 GB

Hard disk space: 45 GB

Bandwidth: 4.5 TB

# Email

Email was set up on the server using Postfix and an SMTP relay at Sendinblue. This was set up following instructions at https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-postfix-as-a-send-only-smtp-server-on-ubuntu-20-04, https://www.linuxbabe.com/mail-server/setup-basic-postfix-mail-sever-ubuntu, and https://www.linuxbabe.com/mail-server/postfix-smtp-relay-ubuntu-sendinblue. 

WordPress' email was configured using the Post SMTP Mailer plugin: https://wordpress.org/plugins/post-smtp/

# SSL

All websites on the *.postdigitalcultures.org domain are SSL secured. This was done by setting up a wildcard certificate for the postdigitalcultures.org domain name (https://medium.com/@utkarsh_verma/how-to-obtain-a-wildcard-ssl-certificate-from-lets-encrypt-and-setup-nginx-to-use-wildcard-cfb050c8b33f).

## Lego

As of 2024-08-29, the *.postdigitalcultures.org SSL certificate is managed using [Lego](https://go-acme.github.io/lego/). This runs Let's Encrypt requests and automates the process of adding DNS records for domain challenges. 

This runs using:

`docker-compose -f /home/cpc_admin/docker/docker-compose-lego.yml up lego-renew`

This SSL certificate is now kept in the directory /etc/letsencrypt/lego_cert_store which is mirrored as a volume in the Nginx webserver Docker container.

There's another SSL certificate for a different domain that is set up to auto-renew through Certbot and WordPress ACME challenges but in the event that it does not renew, run:

`certbot certonly --webroot -w /home/kwalker/curatorial -d curatorial-research.com -d www.curatorial-research.com`

## deprecated SSL process

Run this command to get a wildcard SSL certificate from Let's Encrypt:

`sudo certbot --server https://acme-v02.api.letsencrypt.org/directory -d *.postdigitalcultures.org,postdigitalcultures.org --manual --preferred-challenges dns-01 certonly`

All SSL certificates are kept in the directory /etc/letsencrypt which is mirrored as a volume in the Nginx webserver Docker container.

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

`docker exec tor cat /var/lib/tor/onion_services/<ONIONSERVICE_NAME>/hostname`

(in our case): `docker exec tor cat /var/lib/tor/onion_services/onion-nginx/hostname`

WordPress dynamically rewrites permalinks using a function derived from https://blog.paranoidpenguin.net/2017/09/how-to-configure-wordpress-as-a-tor-hidden-service/. Every time the Tor Onionize container is restarted, you should run rewrite_onion_address.sh to update the onion address in WordPress to the latest address.

### WordPress

Most sites on the server (postdigitalcultures.org, radicaloa.postdigitalcultures.org) are running on a WordPress Multisite installation in Docker Compose.

# Other sites

The postdigitalcultures.org server also serves the following sites for staff and postgraduate research. All these sites are run through the NGINX running on Docker Compose with configuration files for each subdomain in /home/cpc_admin/docker/nginx-conf.

- yurisearch.postdigitalcultures.org. This site was moved over from yurisearch.coventry.ac.uk and is the research output of former PhD student Jurij Smrke (uree@samponuniverzal.xyz). It lives in /home/cpc_admin/yurisearch and consists of two Docker Compose installations brought up in ./linqr and ./radovan. Linqr and Radovan are both available on Juirj's GitHub at https://github.com/uree/linqr and https://github.com/uree/radovan. This site is also backed up on GitHub at https://github.com/postdigitalcultures/yurisearch.

- ai.postdigitalcultures.org. This site was set up by Kevin Walker for his research into AI in 2023. It is a HTML and JavaScript site served from /home/kwalker/ai_site. This folder is set up as an SFTP folder and Kevin manages all the files in there himself. 

- networkednarratives.postdigitalcultures.org. This site was set up by Godswill Ezeonyeka (ezeonyekag@uni.coventry.ac.uk) and Abhiram Thiruthummal (thiruthuma@uni.coventry.ac.uk) as an interactive introduction to the story of the #EndSARS protests in Nigeria. It is a HTML and JavaScript site served from /home/gezeonyeka/networked_narratives.

- ghost.postdigitalcultures.org. This site was a test of Ghost, the open source alternative to Substack, and was set up by Simon Bowie. It's a Docker Compose application running from /home/cpc_admin/ghost. 

