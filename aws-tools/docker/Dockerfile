# Dockerfile
FROM python:3.9

WORKDIR /usr/app

COPY requirements.txt ./

# Install Python Requirements
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

CMD ["aws", "--version"]