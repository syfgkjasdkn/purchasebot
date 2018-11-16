use Mix.Config

adapter =
  case Mix.env() do
    :test -> TGBot.TestAdapter
    env when env in [:dev, :prod] -> TGBot.NadiaAdapter
  end

token =
  case Mix.env() do
    :test ->
      "1263745172:iugyaksdfhjfgrgyuwekfhjsdb"

    # in prod it's loaded from TG_TOKEN env var at runtime
    :prod ->
      nil

    :dev ->
      if adapter == TGBot.NadiaAdapter do
        System.get_env("PURCHASEBOT_DEV_TG_TOKEN") || raise("need PURCHASEBOT_DEV_TG_TOKEN")
      else
        ""
      end
  end

config :tgbot,
  adapter: adapter

config :nadia,
  token: token,
  recv_timeout: 20
