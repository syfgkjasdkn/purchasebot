defmodule Web.Application do
  @moduledoc false
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Web.Endpoint, []),
      {Task, fn -> set_webhook!() end}
    ]

    opts = [strategy: :one_for_one, name: Web.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Web.Endpoint.config_change(changed, removed)
    :ok
  end

  @doc false
  def set_webhook! do
    addr = _addr!()
    port = :ranch.get_port(Web.Endpoint.HTTPS) || raise("failed to get https port")
    url = "https://#{addr}:#{port}/tgbot"
    {:ok, _} = TGBot.set_webhook(url)
    Logger.info("set webhook to #{url}")
  end

  defp _addr! do
    {:ok, [{addr, _, _} | _rest]} = :inet.getif()

    addr
    |> :inet.ntoa()
    |> to_string()
  end
end
