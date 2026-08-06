FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# 1. Install Apache, mod_wsgi, and dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        build-essential \
        default-libmysqlclient-dev \
        pkg-config \
        curl \
        apache2 \
        libapache2-mod-wsgi-py3 \
    && rm -rf /var/lib/apt/lists/*

# 2. Setup Virtual Environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 3. Copy application code
COPY . .

# 4. Copy Apache configuration file into the container
COPY ./docker/apache/default.conf /etc/apache2/sites-available/000-default.conf

# 5. Enable necessary Apache modules
RUN a2enmod rewrite ssl wsgi

# 6. Ensure permissions for Apache (www-data)
RUN chown -R www-data:www-data /app /opt/venv \
    && chmod -R 755 /app

COPY ./docker/scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2ctl", "-D", "FOREGROUND"]