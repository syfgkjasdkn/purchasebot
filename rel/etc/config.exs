use Mix.Config

env! = fn var, type ->
  val = System.get_env(var) || raise("need #{var} set")

  try do
    case type do
      :string -> val
      :integer -> String.to_integer(val)
    end
  rescue
    _error ->
      raise(ArgumentError, "couldn't parse #{val} as #{type}")
  end
end

config :core,
  db_path: env!.("DB_PATH", :string)

config :web, Web.Endpoint, http: [:inet6, port: env!.("PORT", :integer)]
