FROM ubuntu:bionic

ENV MONGODB_VERSION=4.2.13

RUN apt-get update \
    && apt-get install -y curl gnupg \
    && curl https://www.mongodb.org/static/pgp/server-4.2.asc -o - | apt-key add - \
    && echo 'deb http://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse' > /etc/apt/sources.list.d/mongodb.list \
    && apt-get update \
    && apt-get install -y mongodb-org-tools=$MONGODB_VERSION s3cmd ca-certificates \
    && apt-get update \
    && apt-get install cron

WORKDIR /root/

ADD backup.sh /root/

RUN chmod +x backup.sh

RUN sed -i -e 's/\r$//' backup.sh

# Configure the cron
# Copy cron job file to cron directory
COPY crontab /etc/cron.d/container_cronjob

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/container_cronjob

RUN sed -i -e 's/\r$//' /etc/cron.d/container_cronjob

# Apply cron job
RUN crontab /etc/cron.d/container_cronjob

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Running commands for the startup of a container.
CMD ["/bin/bash", "-c", "cron && tail -f /var/log/cron.log"]

# CMD /root/backup.sh
