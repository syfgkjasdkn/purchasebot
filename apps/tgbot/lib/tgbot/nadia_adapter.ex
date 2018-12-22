defmodule TGBot.NadiaAdapter do
  @behaviour TGBot.Adapter

  @impl true
  def send_message(telegram_id, text) do
    Nadia.send_message(telegram_id, text)
  end

  @impl true
  def set_webhook(opts) do
    Nadia.API.request("setWebhook", opts, :certificate)
  end

  @impl true
  def bot_info do
    {:ok, %Nadia.Model.User{id: bot_id, username: bot_name}} = Nadia.get_me()

    %{id: bot_id, username: bot_name}
  end
end
