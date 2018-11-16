use Mix.Config

env! = fn var, type ->
  val = System.get_env(var) || raise("need #{var} set")

  try do
    case type do
      :string ->
        val

      :integer ->
        String.to_integer(val)

      {:list, :integer} ->
        val
        |> :binary.split(",", [:global])
        |> Enum.map(&String.to_integer/1)
    end
  rescue
    _error ->
      raise(ArgumentError, "couldn't parse #{val} as #{inspect(type)}")
  end
end

config :nadia,
  token: env!.("TG_TOKEN", :string)

config :core,
  db_path: env!.("DB_PATH", :string),
  admin_ids: env!.("ADMIN_IDS", {:list, :integer})

config :web,
  public_ip: env!.("PUBLIC_IP", :string),
  port: env!.("WEB_PORT", :integer)
