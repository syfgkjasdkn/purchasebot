defmodule TGBot.TestAdapter do
  @moduledoc false
  @behaviour TGBot.Adapter

  @impl true
  def send_message(telegram_id, text) do
    send(self(), {:message, telegram_id: telegram_id, text: text})
  end

  @impl true
  def set_webhook(opts) do
    send(self(), {:webhook, opts})
  end

  @impl true
  def bot_id do
    123
  end
end
