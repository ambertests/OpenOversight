FROM python:3.9-slim

WORKDIR /usr/src/app

ARG REQUIREMENTS_FILE=requirements-dev.txt

ENV PYTHONDONTWRITEBYTECODE=1
ENV DEBIAN-FRONTEND noninteractive
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1
RUN apt-get update && \
    apt-get install -y wget && \
    echo "deb http://deb.debian.org/debian stretch-backports main" > /etc/apt/sources.list.d/backports.list && \
    wget -O - https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get update && \
    apt-get install -y \
        gcc \
        libpq-dev \
        python3-dev \
        nodejs \
        libjpeg62-turbo-dev \
        zlib1g-dev && \
    apt-get install -y -t stretch-backports libsqlite3-0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g yarn && \
    mkdir /var/www ./node_modules /.cache /.yarn /.mozilla && \
    touch /usr/src/app/yarn-error.log
COPY yarn.lock /usr/src/app/
RUN chmod -R 777 /usr/src/app/ /.cache /.yarn

# Always add the prod req because the dev reqs depend on it for deduplication
COPY ${REQUIREMENTS_FILE} requirements.txt /usr/src/app/
RUN pip3 install -r ${REQUIREMENTS_FILE}

COPY package.json /usr/src/app/
RUN yarn
COPY create_db.py /usr/src/app/

WORKDIR /usr/src/app/OpenOversight

COPY OpenOversight .

CMD ["scripts/entrypoint.sh"]
