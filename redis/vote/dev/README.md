# 'dev' directory

# Images
Various images are used by the 'dev' demo, see README.md in each of the following directories for build instructions
    - schema

To build the demo application

    $ export DOCKER_UN=alvinr
    $ docker build -t $DOCKER_UN/demo-webapp-vote:redis .

If you want to share the image, push to docker hub

    $ docker push $DOCKER_UN/demo-webapp-vote:redis


## Running demo - Part One: Develop the app

To start app in development:

    $ cd vote/dev/
    $ source scripts/setup.sh
    $ docker-compose build
    $ docker-compose up -d

The app will be available at http://dev.myapp.com:5000. You can inspect the database

    $ docker exec -it dev_redis_1 redis-cli

    127.0.0.1:6379> hgetall votes
    1) "13101f318c858bc5"
    2) "b"

    127.0.0.1:6379> lrange vote_history:13101f318c858bc5 0 -1
    1) "{\"vote\": \"a\", \"ts\": 1513625979.843801}"
    2) "{\"vote\": \"b\", \"ts\": 1513625981.601455}"
    3) "{\"vote\": \"c\", \"ts\": 1513625982.437384}"
    4) "{\"vote\": \"a\", \"ts\": 1513625983.856157}"
    5) "{\"vote\": \"b\", \"ts\": 1513625984.677327}"

    127.0.0.1:6379> get total_votes
    "6"

    127.0.0.1:6379> hgetall vote_summary
    1) "172.18.0.3"
    2) "5"
