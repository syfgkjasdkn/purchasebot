defmodule Web.Plugs.TGBotTest do
  use ExUnit.Case
  use Plug.Test

  @opts Web.Router.init([])

  setup do
    {:ok, _pid} = Storage.start_link(path: ":memory:", name: Storage)
    :ok
  end

  test "invalid token" do
    conn = Web.Router.call(conn(:post, "/tgbot/aksdjhfg"), @opts)
    assert conn.status == 200
    assert_receive(:invalid_token)
    refute_receive {:message, _telegram_id, _text}
  end

  test "no token" do
    conn = Web.Router.call(conn(:post, "/tgbot"), @opts)
    assert conn.status == 200
    assert_receive(:invalid_token)
    refute_receive {:message, _telegram_id, _text}
  end

  test "valid token" do
    conn =
      Web.Router.call(
        conn(:post, "/tgbot/#{TGBot.token()}", %{
          "message" => %{
            "text" => "/time",
            "from" => %{"id" => 1},
            "chat" => %{"id" => -123, "type" => "supergroup"}
          }
        }),
        @opts
      )

    assert conn.status == 200

    assert_receive {:message,
                    telegram_id: -123,
                    text: """
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
                    """}
  end
end
