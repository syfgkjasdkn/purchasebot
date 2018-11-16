use Mix.Config

db_path =
  case Mix.env() do
    # tmp database is created
    :dev -> ""
    # in prod it is loaded from DB_PATH env var at runtime
    :prod -> nil
    # in test the database is started manually for each test run
    :test -> nil
  end

publisher =
  case Mix.env() do
    :test -> TGBot.TestAdapter
    env when env in [:prod, :dev] -> TGBot.NadiaAdapter
  end

admin_ids =
  case Mix.env() do
    :test -> [1]
    env when env in [:prod, :dev] -> nil
  end

config :core,
  db_path: db_path,
  publisher: publisher,
  admin_ids: admin_ids
