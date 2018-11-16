defmodule TGBot.NadiaAdapter do
  @behaviour TGBot.Adapter

  @impl true
  def send_message(telegram_id, text) do
    Nadia.send_message(telegram_id, text, parse_mode: "Markdown")
  end

  @impl true
  def set_webhook(opts) do
    Nadia.API.request("setWebhook", opts, :certificate)
  end

  @impl true
  def bot_id do
    {:ok, %Nadia.Model.User{id: bot_id}} = Nadia.get_me()

    bot_id
  end
end
