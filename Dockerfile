FROM python:3.10-alpine3.13
LABEL maintainer="ajconnectprime.com"

ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./scripts /scripts
COPY ./app /app
WORKDIR /app
EXPOSE 8000

#the dev for the Dev and add if statement in the run
ARG DEV=false
#this run the run command when building docker image
# first you create virtual env while (&& \ -- break multi line for docker image)
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client jpeg-dev && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev zlib zlib-dev linux-headers && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    #remove the tmp directions
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    #to add new user is best practice not to use the root user.
    adduser \
        --disabled-password \
        --no-create-home \
        django-user && \
    mkdir -p /vol/web/media && \
    mkdir -p /vol/web/static && \
    chown -R django-user:django-user /vol && \
    chmod -R 755 /vol && \
    chmod -R +x /scripts

#update the variable throught the path
ENV PATH="/scripts:/py/bin:$PATH"

#the last line to switch to the user create
USER django-user

CMD ["run.sh"]