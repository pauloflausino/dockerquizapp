# pego uma imagem já pronta com o PHP e Apache
FROM php:8.1-apache

# variáveis de ambiente do Apache
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
ENV APACHE_LOG_DIR /var/log/apache2

# instala dependências de extensões, vim e supervisor
RUN apt-get update && apt-get install git libzip-dev vim supervisor -y

# instala as extensões
RUN docker-php-ext-install zip mysqli pdo pdo_mysql

# instala e configura o XDebug
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug
RUN echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.client_port=9003" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.discover_client_host=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.idekey=docker" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
EXPOSE 9003

# ativa o mod_rewrite do Apache
RUN a2enmod rewrite

# cria o diretório de logs para o Supervisor
RUN mkdir /var/log/webhook

# copia os arquivos de configuração do Supervisor
COPY ./.docker/supervisor/conf.d /etc/supervisor/conf.d

# copia o entreypoint
COPY ./.docker/entrypoint /var/www/entrypoint

# adiciona permissão de execução para o Entrypoint
RUN chmod +x /var/www/entrypoint

# instala o Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
#RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
#RUN php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
#RUN php composer-setup.php --install-dir=/usr/bin --filename=composer
#RUN php -r "unlink('composer-setup.php');"

# seta o document root configurado anteriormente nas variáveis de ambiente
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# copia o projeto para o Docker
COPY ./app /var/www/html

# informa o diretório raiz do Docker
WORKDIR /var/www/html

# informa o Entrypoint
ENTRYPOINT [ "/var/www/entrypoint" ]