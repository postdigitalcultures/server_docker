#! /bin/bash

# @name: rewrite_onion_address.sh
# @creation_date: 2022-09-05
# @license: The MIT License <https://opensource.org/licenses/MIT>
# @author: Simon Bowie <ad7588@coventry.ac.uk>
# @purpose: Rewrites the onion addresses in our WordPress theme files to the correct onion address
# @cron: Set to run on root crontab at 1200 every day from Monday through Friday inclusive
# 00 12 * * 1-5 /home/cpc_admin/docker/rewrite_onion_address.sh

# VARIABLES
WORDPRESS_THEME_DIRECTORY='/home/cpc_admin/docker/wordpress/wp-content/themes/postdigital-cultures'
ONION_ADDRESS=`docker exec tor cat /var/lib/tor/onion_services/onion-nginx/hostname`
#ONION_ADDRESS='testing.onion'
SQL_QUERY='UPDATE wordpress.wp_domain_mapping SET domain="'$ONION_ADDRESS'" WHERE blog_id=1;'

# get secure variables from .env file
eval "$(
  cat .env | awk '!/^\s*#/' | awk '!/^\s*$/' | while IFS='' read -r line; do
    key=$(echo "$line" | cut -d '=' -f 1)
    value=$(echo "$line" | cut -d '=' -f 2-)
    echo "export $key=\"$value\""
  done
)"

# MAIN PROGRAM
# find the Onion-Location header and replace ONION_ADDRESS (or the .onion address) with the new onion address
# development version for macOS which implements 'sed' differently
#find ${WORDPRESS_THEME_DIRECTORY} \( -name "*.php" \) -exec gsed -Ei "s,[a-zA-Z0-9]+\.onion,${ONION_ADDRESS},gI" {} \;

# production version for Linux
find ${WORDPRESS_THEME_DIRECTORY} \( -name "*.php" \) -exec sed -Ei "s,[a-zA-Z0-9]+\.onion,${ONION_ADDRESS},gI" {} \;

# replace the value in the WordPress wp_domain_mapping database table with appropriate ONION_ADDRESS
docker exec mariadb mysql -u $MARIADB_USER -p$MARIADB_PASSWORD -e "$SQL_QUERY"

exit
