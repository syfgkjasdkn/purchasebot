# Build Stage

FROM bitwalker/alpine-elixir:1.7.4 as builder

ARG TG_BOT_TOKEN
ENV PURCHASEBOT_PROD_TG_TOKEN=${TG_BOT_TOKEN}

COPY rel ./rel
COPY config ./config
COPY apps ./apps
COPY mix.exs .
COPY mix.lock .

RUN apk update && \
    apk --no-cache --update add make g++ \
    rm -rf /var/cache/apk/*

RUN export MIX_ENV=prod && \
    mix deps.get --only prod && \
    mix release --warnings-as-errors --verbose

RUN APP_NAME="purchasebot" && \
    RELEASE_DIR=`ls -d _build/prod/rel/$APP_NAME/releases/*/` && \
    mkdir /export && \
    tar -xf "$RELEASE_DIR/$APP_NAME.tar.gz" -C /export

# Deployment Stage

FROM bitwalker/alpine-erlang:21.0.9

EXPOSE 4000

# TODO DB_PATH needs to point to a mounted volume
ENV REPLACE_OS_VARS=true \
    DB_PATH="/opt/app/db.sqlite3" \
    PORT=4000

COPY --from=builder /export/ .

ENTRYPOINT ["/opt/app/bin/purchasebot"]
CMD ["foreground"]
