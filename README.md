## Build

1. Install [docker](https://docs.docker.com/install/)
2. Run `make build` to build a `purchasebot` container

## Run

1. Push the container from `Build` to some kind of registry
2. On you host, pull the container from registry
3. Set `ADMIN_IDS` env var for the container to the telegram ids of the users who can interact with the bot. It should be something like `ADMIN_IDS=17286345,18723645,1827354,1923746`, that is, integers separated by commas. The bot would raise at runtime if it fails to parse this env var.
4. Set `TG_TOKEN` env var to the telegram bot token which you get from [@BotFather](https://t.me/BotFather)
5. Set `DB_PATH` to where sqlite will write its data. Should be a mounted volume (see the next step for more info on that).
6. Run the container. Note that since the container uses sqlite to persist data on disk, you need to add a [mounted volume](https://docs.docker.com/storage/volumes/) to be used from the container, otherwise all the data would be lost when the container is stopped.

With that in mind, a possible command to run a container is:

```sh
docker run purchasebot \
  -name purchasebot \
  -v purchasebot.sqlite3:/opt/app/db.sqlite3 \
  -e ADMIN_IDS=1726345,1723654,2435 \
  -e TG_TOKEN=17623456:euygafkjsdhfasdf \
  -e DB_PATH=/opt/app/db.sqlite3 \
  -p 4000:80
```

But you'd probably want to use some kind of container orchestrator like [docker compose](https://docs.docker.com/compose/) or maybe even [kubernetes](https://kubernetes.io/) instead.
