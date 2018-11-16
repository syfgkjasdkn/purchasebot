defmodule TGBot.Adapter do
  @moduledoc false

  @typep chat_id :: integer

  @callback send_message(chat_id, String.t()) :: any
  @callback set_webhook(Keyword.t()) :: any
  @callback bot_id :: integer
end
