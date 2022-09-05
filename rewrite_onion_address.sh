#! /bin/bash

# @name: rewrite_onion_address.sh
# @creation_date: 2022-09-05
# @license: The MIT License <https://opensource.org/licenses/MIT>
# @author: Simon Bowie <ad7588@coventry.ac.uk>
# @purpose: Rewrites the onion addresses in our WordPress theme files to the correct onion address

# define variables
WORDPRESS_THEME_DIRECTORY='/home/cpc_admin/docker/wordpress/wp-content/themes/postdigital-cultures'
ONION_ADDRESS=`docker exec tor cat /var/lib/tor/onion_services/onion-nginx/hostname`
#ONION_ADDRESS='testing.onion'

# find the Onion-Location header and replace ONION_ADDRESS (or the .onion address) with the new onion address
# development version for macOS which implements 'sed' differently
#find ${WORDPRESS_THEME_DIRECTORY} \( -name "*.php" \) -exec gsed -Ei "s,[a-zA-Z0-9]+\.onion,${ONION_ADDRESS},gI" {} \;

# production version for Linux
find ${WORDPRESS_THEME_DIRECTORY} \( -name "*.php" \) -exec sed -Ei "s,[a-zA-Z0-9]+\.onion,${ONION_ADDRESS},gI" {} \;

exit
