defmodule TGBot do
  @moduledoc false
  require Logger

  @adapter Application.get_env(:tgbot, :adapter) || raise("need tgbot adapter set")

  @spec handle(map) :: any
  def handle(request)

  def handle(%{
        "message" => %{
          "chat" => %{"id" => chat_id},
          "from" => %{"id" => from_id},
          "new_chat_member" => %{"id" => new_chat_member_id}
        }
      }) do
    if new_chat_member_id == bot_id() and Core.admin?(from_id) do
      Core.add_group(chat_id)
    end
  end

  def handle(%{
        "message" => %{
          "from" => %{"id" => telegram_id, "username" => username},
          "chat" => %{"id" => chat_id, "type" => type},
          "text" => text
        }
      })
      when type in ["group", "supergroup", "channel"] do
    if Core.admin?(telegram_id) do
      handle_public_text(text, chat_id)
    end
  end

  def handle(%{
        "message" => %{
          "from" => %{"id" => telegram_id},
          "chat" => %{"id" => telegram_id, "type" => "private"},
          "text" => text
        }
      }) do
    if Core.admin?(telegram_id) do
      handle_private_text(text, telegram_id)
    end
  end

  def handle(other) do
    Logger.error("unhandled request:\n\n#{inspect(other)}")
  end

  defp handle_public_text("/message", chat_id) do
    chat_id
    |> Core.start_message()
    |> maybe_reply(chat_id)
  end

  defp handle_public_text("/save", chat_id) do
    chat_id
    |> Core.save_message()
    |> maybe_reply(chat_id)
  end

  defp handle_public_text("/time " <> schedule, chat_id) do
    chat_id
    |> Core.set_schedule(schedule)
    |> maybe_reply(chat_id)
  end

  defp handle_public_text(text, chat_id) do
    chat_id
    |> Core.handle_text(text)
    |> maybe_reply(chat_id)
  end

  defp maybe_reply({:reply, reply}, chat_id) do
    @adapter.send_message(chat_id, reply)
  end

  defp maybe_reply(:noreply, _chat_id) do
    :ignore
  end

  # @token Application.get_env(:tgbot, :token) || raise(":tgbot needs :token")
  Application.get_env(:tgbot, :token) || raise(":tgbot needs :token")

  @spec token :: String.t()
  def token do
    # @token
    Application.get_env(:tgbot, :token)
  end

  @doc false
  def adapter do
    @adapter
  end

  def bot_id do
    @adapter.bot_id()
  end

  def set_webhook(url) do
    url
    |> Path.join(token())
    |> @adapter.set_webhook()
  end
end
