FROM php:apache

ENV ACCEPT_EULA=Y

#Set Server name
CMD echo "ServerName localhost" >> /etc/apache2/apache2.conf

#Missing?
RUN apt-get update && apt-get install -y --no-install-recommends gnupg1 zlib1g-dev

# Microsoft SQL Server Prerequisites
RUN apt-get update \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/9/prod.list \
        > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get install -y --no-install-recommends \
        locales \
        apt-transport-https \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && apt-get update \
    && apt-get -y --no-install-recommends install \
        unixodbc-dev \
        msodbcsql17
        
RUN docker-php-ext-install pdo \
    && pecl install sqlsrv pdo_sqlsrv xdebug
    
# Memcached for API caching
RUN apt-get update && apt-get install -y libmemcached-dev \
    && pecl install memcached \
    && docker-php-ext-enable memcached
    
RUN docker-php-ext-enable sqlsrv pdo_sqlsrv xdebug

COPY . /var/www/html
WORKDIR /var/www/html

EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND"]
