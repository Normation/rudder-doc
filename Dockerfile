FROM node:16-bullseye
ENV NODE_ENV=production

ARG USER_ID=1000
COPY ci/user.sh .
RUN ./user.sh $USER_ID

RUN npm install --global @antora/cli@2.3 @antora/site-generator-default@2.3
RUN apt-get update && apt-get install -y rsync graphviz ssh pandoc git && rm -rf /var/lib/apt/lists/*
