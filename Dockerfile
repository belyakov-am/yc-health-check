FROM python:3.8

# set workdir
WORKDIR /app

# copy deps
COPY Pipfile ./Pipfile
COPY Pipfile.lock ./Pipfile.lock

# install deps
RUN pip install --upgrade pip
RUN pip install pipenv && pipenv install --system --deploy

# copy app
COPY /src /app/
