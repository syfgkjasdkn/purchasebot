## Build

1. Install [docker](https://docs.docker.com/install/)
2. Set `PURCHASE_BOT_TG_PROD_TOKEN` env var to the telegram bot token which you get from [@BotFather](https://t.me/BotFather)
3. Run `make build`

## Run

1. Push the container from `Build` to some kind of registry
2. On you host, pull the container from registry
3. Set `ADMIN_IDS` env var for the container to the telegram ids of the users who can interact with the bot. It should be something like `ADMIN_IDS=17286345,18723645,1827354,1923746`, that is, integers separated by commas. The bot would raise at runtime if it fails to parse this env var.
4. Run the container.
