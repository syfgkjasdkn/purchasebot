defmodule TGBot.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    load_tg_token!()
  end

  @doc false
  def load_tg_token! do
    token = System.get_env("TG_TOKEN") || raise(ArgumentError, "need TG_TOKEN to be set")
    Application.put_env(:tgbot, :token, token)
    Application.put_env(:nadia, :token, token)
  end
end
