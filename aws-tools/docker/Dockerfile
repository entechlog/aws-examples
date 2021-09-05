# Dockerfile
FROM python:3.9-slim-buster

WORKDIR /usr/app

COPY requirements.txt ./

# Install Python Requirements
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends git curl && \
    apt-get purge -y --auto-remove

RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

CMD ["aws", "--version"]