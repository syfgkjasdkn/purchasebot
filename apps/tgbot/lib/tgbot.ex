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
          "from" => %{"id" => telegram_id},
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
          "chat" => %{"type" => "private"}
        }
      }) do
    # if Core.admin?(telegram_id) do
    #   handle_private_text(text, telegram_id)
    # end
    :ignore
  end

  def handle(other) do
    Logger.error("unhandled request:\n\n#{inspect(other)}")
  end

  defp handle_public_text("/message", chat_id) do
    :ok = Core.start_message(chat_id)

    @adapter.send_message(chat_id, """
    👍 Started a new message editing session for the current group.
    """)
  end

  defp handle_public_text("/save", chat_id) do
    {:ok, message} = Core.save_message(chat_id)

    @adapter.send_message(chat_id, """
    👍 Saved the following message for the current group:

    #{message}
    """)
  end

  defp handle_public_text("/time " <> schedule, chat_id) do
    :ok = Core.set_schedule(chat_id, schedule)

    @adapter.send_message(chat_id, """
    👍 Saved the new schedule.
    """)
  end

  defp handle_public_text(text, chat_id) do
    :ok = Core.handle_text(chat_id, text)
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
    if bot_id = Application.get_env(:tgbot, :bot_id) do
      bot_id
    else
      bot_id = @adapter.bot_id()
      Application.put_env(:tgbot, :bot_id, bot_id)
      bot_id
    end
  end

  def set_webhook(url) do
    url
    |> Path.join(token())
    |> @adapter.set_webhook()
  end
end
