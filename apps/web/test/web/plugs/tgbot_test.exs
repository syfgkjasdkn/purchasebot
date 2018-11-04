defmodule Web.Plugs.TGBotTest do
  use Web.ConnCase

  setup do
    {:ok, _pid} = Storage.start_link(path: ":memory:", name: Storage)
    :ok
  end

  test "invalid token", %{conn: conn} do
    conn = post(conn, "/tgbot/aksdjhfg")
    assert conn.status == 200
    assert_receive(:invalid_token)
    refute_receive {:message, _telegram_id, _text}
  end

  test "no token", %{conn: conn} do
    conn = post(conn, "/tgbot")
    assert conn.status == 200
    assert_receive(:invalid_token)
    refute_receive {:message, _telegram_id, _text}
  end

  test "valid token", %{conn: conn} do
    conn =
      post(conn, "/tgbot/#{TGBot.token()}", %{
        "message" => %{
          "text" => "/help",
          "from" => %{"id" => 123},
          "chat" => %{"id" => 123, "type" => "private"}
        }
      })

    assert conn.status == 200

    assert_receive {:message,
                    telegram_id: 123,
                    text: """
                    /bet <amount> to play

                    /trade to get SatBet

                    /freeroll to roll for free

                    /balance to check your balance

                    /key to see your private key

                    /address to see your TRON address

                    /help to get this message
                    """}
  end
end
