ARG WP_VER 'latest'
FROM wordpress:${WP_VER}

ARG INSTALL_ZSH true
COPY library-scripts/* /tmp/library-scripts/
RUN bash -x /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" vscode 1000 1000 true true; \
  bash -x /tmp/library-scripts/docker-debian.sh; \
  apt-get update; \  
	apt-get install -y \
    gpg \
		curl \
		git \
		ssh \
		rsync \
		silversearcher-ag \
		sudo \
		psmisc \	
    zsh\
    mariadb-client\
    strace\
	; \
	rm -rf /var/lib/apt/lists/*


ENV APACHE_RUN_USER=$USERNAME
ENV APACHE_RUN_GROUP=$USERNAME
RUN chown $USERNAME:$USERNAME -R /var/www/html; \
    chsh -s /bin/bash vscode 

# from wordpres:wpcli
ENV WORDPRESS_CLI_GPG_KEY 63AF7AA15067C05616FDDD88A3A2E8F226F0BC06
ENV WORDPRESS_CLI_VERSION 2.5.0
ENV WORDPRESS_CLI_SHA512 08dd9035fda1d529807380d5b757839e2809e289eb1a698fe33e7e21a1431d3f77c551c2b2db5adc55083d5075ea4137407994111890f765e790a97e6d9ca7af

RUN set -ex; \
	\
	curl -o /usr/local/bin/wp.gpg -fL "https://github.com/wp-cli/wp-cli/releases/download/v${WORDPRESS_CLI_VERSION}/wp-cli-${WORDPRESS_CLI_VERSION}.phar.gpg"; \
	\
	GNUPGHOME="$(mktemp -d)"; export GNUPGHOME; \
	gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$WORDPRESS_CLI_GPG_KEY"; \
  rm -f /usr/local/bin/wp; \
	gpg --batch --decrypt --output /usr/local/bin/wp /usr/local/bin/wp.gpg; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME" /usr/local/bin/wp.gpg; unset GNUPGHOME; \
	\
	echo "$WORDPRESS_CLI_SHA512 */usr/local/bin/wp" | sha512sum -c -; \
	chmod +x /usr/local/bin/wp; \
	\
	wp --allow-root --version

# install xdebug
RUN cd /tmp && \
	git clone https://github.com/xdebug/xdebug.git && \
    	cd xdebug && \
	git checkout xdebug_3_0 && \
	phpize && \
	./configure --enable-xdebug && \
	make && \
	make install && \
    rm -rf /tmp/xdebug ; \
  \
  { \
	echo 'zend_extension=xdebug.so'; \
	echo 'xdebug.mode=debug'; \
	echo 'xdebug.client_port=9003'; \
	echo 'xdebug.start_with_request = yes'; \
  } > /usr/local/etc/php/conf.d/xdebug.ini; \
  \
  docker-php-ext-enable xdebug;

# install php composer 
RUN printf "# composer php cli ini settings\n\
date.timezone=UTC\n\
memory_limit=-1\n\
" > $PHP_INI_DIR/php-cli.ini

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /home/vscode/.composer
ENV COMPOSER_VERSION 2.1.11

RUN set -eux ; \
  # install https://github.com/mlocati/docker-php-extension-installer
  curl \
    --silent \
    --fail \
    --location \
    --retry 3 \
    --output /usr/local/bin/install-php-extensions \
    --url https://github.com/mlocati/docker-php-extension-installer/releases/download/1.2.58/install-php-extensions \
  ; \
  echo 182011b3dca5544a70fdeb587af44ed1760aa9a2ed37d787d0f280a99f92b008e638c37762360cd85583830a097665547849cb2293c4a0ee32c2a36ef7a349e2 /usr/local/bin/install-php-extensions | sha512sum --strict --check ; \
  chmod +x /usr/local/bin/install-php-extensions ; \
  # install necessary/useful extensions not included in base image
  install-php-extensions \
    bz2 \
    zip \
  ; \
  # install public keys for snapshot and tag validation, see https://composer.github.io/pubkeys.html
  curl \
    --silent \
    --fail \
    --location \
    --retry 3 \
    --output /tmp/keys.dev.pub \
    --url https://raw.githubusercontent.com/composer/composer.github.io/e7f28b7200249f8e5bc912b42837d4598c74153a/snapshots.pub \
  ; \
  echo 572b963c4b7512a7de3c71a788772440b1996d918b1d2b5354bf8ba2bb057fadec6f7ac4852f2f8a8c01ab94c18141ce0422aec3619354b057216e0597db5ac2 /tmp/keys.dev.pub | sha512sum --strict --check ; \
  curl \
    --silent \
    --fail \
    --location \
    --retry 3 \
    --output /tmp/keys.tags.pub \
    --url https://raw.githubusercontent.com/composer/composer.github.io/e7f28b7200249f8e5bc912b42837d4598c74153a/releases.pub \
  ; \
  echo 47f374b8840dcb0aa7b2327f13d24ab5f6ae9e58aa630af0d62b3d0ea114f4a315c5d97b21dcad3c7ffe2f0a95db2edec267adaba3f4f5a262abebe39aed3a28 /tmp/keys.tags.pub | sha512sum --strict --check ; \
  # download installer.php, see https://getcomposer.org/download/
  curl \
    --silent \
    --fail \
    --location \
    --retry 3 \
    --output /tmp/installer.php \
    --url https://raw.githubusercontent.com/composer/getcomposer.org/f24b8f860b95b52167f91bbd3e3a7bcafe043038/web/installer \
  ; \
  echo 3137ad86bd990524ba1dedc2038309dfa6b63790d3ca52c28afea65dcc2eaead16fb33e9a72fd2a7a8240afaf26e065939a2d472f3b0eeaa575d1e8648f9bf19 /tmp/installer.php | sha512sum --strict --check ; \
  # install composer phar binary
  php /tmp/installer.php \
    --no-ansi \
    --install-dir=/usr/bin \
    --filename=composer \
    --version=${COMPOSER_VERSION} \
  ; \
  composer --ansi --version --no-interaction ; \
  composer diagnose ; \
  rm -f /tmp/installer.php ; \
  find /tmp -type d -exec chmod -v 1777 {} +

RUN echo path: /var/www/html >> /wp-cli.yml
RUN echo -e '#!/bin/sh bash\nexec $@' >> /usr/bin/RUN && chmod +x /usr/bin/RUN
