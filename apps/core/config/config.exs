use Mix.Config

db_path =
  case Mix.env() do
    :dev -> ""
    :prod -> ""
    :test -> nil
  end

publisher =
  case Mix.env() do
    :test -> TGBot.TestAdapter
    env when env in [:prod, :dev] -> TGBot.NadiaAdapter
  end

config :core,
  db_path: db_path,
  publisher: publisher
