# Using official python runtime base image
FROM python:2.7

RUN apt-get update
RUN apt-get -y install python-dev
RUN apt-get -y install libssl-dev

RUN pip install MySQL-python

CMD ["python"]