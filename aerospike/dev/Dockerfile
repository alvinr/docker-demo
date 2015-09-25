FROM python:2.7
ADD . /code
WORKDIR /code
RUN apt-get update
RUN apt-get -y install python-dev
RUn apt-get -y install libssl-dev
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 5000
CMD python app.py