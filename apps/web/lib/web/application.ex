defmodule Web.Application do
  @moduledoc false
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Web.Endpoint, []),
      {Task, fn -> maybe_set_webhook() end}
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
  def maybe_set_webhook do
    if public_ip = System.get_env("PUBLIC_IP") do
      port = :ranch.get_port(Web.Endpoint.HTTPS) || raise("failed to get https port")
      url = "https://#{public_ip}:#{port}/tgbot"
      {:ok, _} = TGBot.set_webhook(url)
      Logger.info("set webhook to #{url}")
    else
      Logger.error("couldn't find PUBLIC_IP env var, skipping webhook setup")
    end
  end
end
