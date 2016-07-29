FROM java:openjdk-8-jre-alpine

MAINTAINER Martin Kolek <kolek@modpreneur.com>

RUN apk update && \
    apk add \
        ca-certificates \
        wget \
    && update-ca-certificates

ENV APP_VERSION 3.0
ENV APP_BUILD 4396
ENV APP_PORT 8081
ENV APP_USER upsource
ENV APP_SUFFIX upsource

ENV APP_DISTNAME upsource-${APP_VERSION}.${APP_BUILD}
ENV APP_DISTFILE ${APP_DISTNAME}.zip
ENV APP_PREFIX /opt
ENV APP_DIR $APP_PREFIX/$APP_SUFFIX
ENV APP_HOME /var/lib/$APP_SUFFIX

# preparing home (data) directory and user+group
RUN mkdir $APP_HOME
#&& \
#    addgroup -S $APP_USER && \
#    adduser -S -G $APP_USER -h $APP_HOME $APP_USER && \
#    chown -R $APP_USER:$APP_USER $APP_HOME

# downloading and unpacking the distribution, removing bundled JVMs
WORKDIR $APP_PREFIX
#RUN wget https://download.jetbrains.com/upsource/$APP_DISTFILE
ADD ./upsource-3.0.4396.zip ./$APP_DISTFILE
RUN unzip -q $APP_DISTFILE && \
    mv $APP_DISTNAME $APP_SUFFIX && \
#    chown -R $APP_USER:$APP_USER $APP_DIR && \
    rm -rf $APP_DIR/internal/java && \
    rm $APP_DISTFILE

WORKDIR $APP_DIR
#USER $APP_USER

RUN bin/upsource.sh configure \
    --backups-dir $APP_HOME/backups \
    --data-dir    $APP_HOME/data \
    --logs-dir    $APP_HOME/log \
    --temp-dir    $APP_HOME/tmp \
    --listen-port $APP_PORT \
    --base-url    http://localhost/

ENTRYPOINT ["bin/upsource.sh"]
CMD ["run"]
EXPOSE $APP_PORT
VOLUME ["$APP_HOME"]