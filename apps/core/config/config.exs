use Mix.Config

db_path =
  case Mix.env() do
    :dev -> ""
    :prod -> ""
    :test -> nil
  end

config :core,
  db_path: db_path
