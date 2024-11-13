FROM mediawiki:latest

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

RUN git clone --depth 1 https://github.com/StarCitizenWiki/mediawiki-extensions-EmbedVideo /var/www/html/extensions/EmbedVideo

#RUN git clone --depth 1 https://gerrit.wikimedia.org/r/mediawiki/extensions/UserMerge /var/www/html/extensions/UserMerge

#RUN git clone --branch REL1_42 --single-branch https://gerrit.wikimedia.org/r/mediawiki/extensions/intersection /var/www/html/extensions/intersection

#RUN git clone --depth 1 https://gerrit.wikimedia.org/r/mediawiki/extensions/DynamicPageListEngine /var/www/html/extensions/DynamicPageListEngine

RUN git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/ExternalData /var/www/html/extensions/ExternalData

RUN cd /var/www/html/extensions/ExternalData && composer install --prefer-source

RUN git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/Widgets.git /var/www/html/extensions/Widgets

RUN cd /var/www/html/extensions/Widgets && composer update --no-dev

RUN chown -R www-data:www-data /var/www/html/extensions/Widgets && chmod -R 775 /var/www/html/Widgets

#RUN git clone https://github.com/SimonXIX/CategoryTranscluder /var/www/html/extensions/CategoryTranscluder

COPY ./CategoryTranscluder /var/www/html/extensions/CategoryTranscluder

