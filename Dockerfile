FROM node:9.11
WORKDIR /app
COPY package*.json /app/
RUN npm install
COPY fsasync.js /app/
COPY server.js /app/
RUN mkdir /app/stuff
RUN mkdir /app/template
RUN mkdir /app/blog
COPY stuff /app/stuff/
COPY template /app/template/
COPY blog /app/blog/
EXPOSE 8082
CMD ["npm", "start"]
