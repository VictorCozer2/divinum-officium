FROM perl:5.36

# Install Apache web server
RUN apt-get update && apt-get install -y apache2 && rm -rf /var/lib/apt/lists/*

# Enable CGI in Apache
RUN a2enmod cgi

# Set working directory
WORKDIR /usr/src/app

# Copy repo contents into the container
COPY . .

# Make CGI scripts executable
RUN chmod -R 755 ./web/cgi-bin

# Configure Apache to use the repo's web root and cgi-bin
RUN sed -i 's|/var/www/html|/usr/src/app/web|g' /etc/apache2/sites-enabled/000-default.conf
RUN echo 'ScriptAlias /cgi-bin/ /usr/src/app/web/cgi-bin/' >> /etc/apache2/sites-enabled/000-default.conf \
 && echo '<Directory "/usr/src/app/web/cgi-bin">\nOptions +ExecCGI\nAddHandler cgi-script .pl\nRequire all granted\n</Directory>' >> /etc/apache2/sites-enabled/000-default.conf

EXPOSE 80

CMD ["apache2ctl", "-D", "FOREGROUND"]
