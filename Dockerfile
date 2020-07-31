FROM node:14.4.0-alpine

ARG WORKDIR
ARG CONTAINER_PORT

ENV HOME=/${WORKDIR} \
    LANG=C.UTF-8 \
    TZ=Asia/Tokyo \
    HOST=0.0.0.0 \
    API_URL=${API_URL} \
    NPM_CONFIG_PRODUCTION=false

RUN echo ${HOME}
RUN echo ${CONTAINER_PORT}
RUN echo ${API_URL}

WORKDIR ${HOME}

COPY package*.json ./
RUN yarn install

COPY . .

RUN yarn run build

RUN apk update && apk add \
    python\
    make\
    g++

EXPOSE ${CONTAINER_PORT}
