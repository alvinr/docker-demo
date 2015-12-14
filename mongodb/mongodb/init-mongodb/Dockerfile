FROM alvinr/mongo:latest
ADD . /code
WORKDIR /code
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

