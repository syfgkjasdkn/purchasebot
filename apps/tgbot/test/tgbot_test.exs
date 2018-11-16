defmodule TGBotTest do
  use ExUnit.Case

  test "set webhook" do
    TGBot.set_webhook(url: "https://some.website/tgbot", certificate: "priv/somekey.pem")

    assert_receive {:webhook,
                    url: "https://some.website/tgbot/1263745172:iugyaksdfhjfgrgyuwekfhjsdb",
                    certificate: "priv/somekey.pem"}
  end
end
