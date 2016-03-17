# Using official python runtime base image
FROM python:2.7

RUN apt-get update
RUN apt-get -y install python-dev
RUn apt-get -y install libssl-dev

# Set the application directory
WORKDIR /app

# Install our requirements.txt
ADD requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy our code from the current folder to /app inside the container
ADD . /app

# Make port 5000 available for links and/or publish
EXPOSE 5000

# Define our command to be run when launching the container
CMD ["python", "app.py"]
