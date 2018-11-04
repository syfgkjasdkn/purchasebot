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
          "from" => %{"id" => from_id},
          "chat" => %{"id" => chat_id, "type" => type},
          "text" => text
        }
      })
      when type in ["group", "supergroup", "channel"] do
    if Core.admin?(from_id) do
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

  defp handle_public_text("/message " <> message, chat_id) do
    # :ok = Core.start_message(chat_id)

    :ok = Core.set_message(chat_id, message)

    # @adapter.send_message(chat_id, """
    # 👍 Started a new message editing session for the current group.
    # """)

    @adapter.send_message(chat_id, """
    👍 Saved the following message for the current group:

    #{message}
    """)
  end

  defp handle_public_text("/save", chat_id) do
    {:ok, message} = Core.save_message(chat_id)

    @adapter.send_message(chat_id, """
    👍 Saved the following message for the current group:

    #{message}
    """)
  end

  defp handle_public_text("/time", chat_id) do
    @adapter.send_message(chat_id, """
    Provide the minutes at hours (UTC) when the message needs to be reposted.
    Format: /time <hours> <minutes>

    Example:

    /time 0,6,12,18 0

    Would repost the message at:

    00:00
    06:00
    12:00
    18:00

    Other valid examples:

    /time 0 0
    /time 0,12 0,30
    """)
  end

  defp handle_public_text("/time " <> schedule, chat_id) do
    case Core.set_schedule(chat_id, String.trim(schedule)) do
      {:ok, description} ->
        @adapter.send_message(chat_id, """
        👍 Saved the new schedule.

        The messages will be sent at (UTC):

        #{description}
        """)

      {:error, :invalid_format} ->
        @adapter.send_message(chat_id, """
        🚨 Couldn't parse the schedule
        """)
    end
  end

  defp handle_public_text(_text, _chat_id) do
    # :ok = Core.handle_text(chat_id, text)
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
