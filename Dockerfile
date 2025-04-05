FROM ubuntu:24.04

WORKDIR /app

# Dependencies
RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get autoremove -y \
    && apt-get install -y --no-install-recommends software-properties-common \
        git \
        build-essential \
        libuuid1 \
        uuid-dev \
        libreadline-dev \
        libncurses5-dev \
        libpcre3-dev \
        libssl-dev \
        perl \
        make \
        unzip \
        wget \
        curl \
        libsqlite3-dev \
        sqlite3 \
        python3 \
        python3-pip \
        python3.12-venv \
        nodejs \
        npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Lua
RUN wget http://www.lua.org/ftp/lua-5.4.7.tar.gz \
    && tar zxf lua-5.4.7.tar.gz \
    && cd lua-5.4.7 \
    && make linux test \
    && make install \
    && cd .. && rm -rf lua-5.4.7*

# Install LuaRocks
RUN wget https://luarocks.github.io/luarocks/releases/luarocks-3.11.1.tar.gz \
    && tar zxf luarocks-3.11.1.tar.gz \
    && cd luarocks-3.11.1 \
    && ./configure --with-lua-include=/usr/local/include \
    && make build \
    && make install \
    && cd .. && rm -rf luarocks-3.11.1*

COPY up.sql .
RUN sqlite3 z1.sqlite3 < up.sql

# Setup lua
RUN luarocks install lsqlite3 && \
    luarocks install uuid

COPY z1 ./z1
COPY setup.lua .

RUN lua setup.lua
RUN rm -r z1

COPY web ./web
COPY package.json .
COPY package-lock.json .
COPY vite.config.js .
RUN npm install && npm run build

# Setup python
COPY requirements.txt .
RUN python3 -m venv .venv
RUN ./.venv/bin/pip3 install --no-cache-dir -r requirements.txt

EXPOSE 3000

COPY . .

CMD ["./.venv/bin/python3", "main.py"]
