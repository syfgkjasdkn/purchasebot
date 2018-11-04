defmodule StorageTest do
  use ExUnit.Case
  alias Storage.Group

  setup do
    {:ok, pid} = Storage.start_link(path: "")
    {:ok, pid: pid}
  end

  test "group", %{pid: pid} do
    telegram_id = -1_132_412_341_234_123

    assert Storage.groups(pid) == []
    assert Storage.group(pid, telegram_id) == nil

    assert :ok = Storage.insert_group(pid, telegram_id)

    assert Storage.groups(pid) == [
             %Group{telegram_id: telegram_id, message: nil, schedule: nil, last_repost: nil}
           ]

    message = """
    #autosell 13 Lambo for 13 TRX
    #autosell 1 Alivio for 3 TRX
    #autosell 26714 ActivEightCoin for 30 TRX
    #autosell 1920 TronSilver for 30 TRX
    """

    assert :ok = Storage.set_message(pid, telegram_id, message)

    assert {:error, {:constraint, 'UNIQUE constraint failed: groups.telegram_id'}} ==
             Storage.insert_group(pid, telegram_id)

    assert %Group{telegram_id: ^telegram_id, message: ^message, schedule: nil, last_repost: nil} =
             Storage.group(pid, telegram_id)

    schedule = "* * * 5"

    assert :ok = Storage.set_schedule(pid, telegram_id, schedule)

    assert %Group{
             telegram_id: ^telegram_id,
             message: ^message,
             schedule: ^schedule,
             last_repost: nil
           } = Storage.group(pid, telegram_id)

    last_repost = NaiveDateTime.utc_now()
    assert :ok = Storage.set_last_repost(pid, telegram_id, last_repost)

    assert %Group{
             telegram_id: ^telegram_id,
             message: ^message,
             schedule: ^schedule,
             last_repost: ^last_repost
           } = Storage.group(pid, telegram_id)
  end

  test "multiple groups", %{pid: pid} do
    telegram_ids = 200..300

    groups =
      Enum.map(telegram_ids, fn telegram_id ->
        %Group{
          telegram_id: telegram_id,
          message: "asjkdfghkajshdfg #{telegram_id}",
          schedule: "aksdfygaisudycgaksjd #{telegram_id}"
        }
      end)

    Enum.each(groups, fn group ->
      assert :ok == Storage.insert_group(pid, group.telegram_id)
      assert :ok == Storage.set_schedule(pid, group.telegram_id, group.schedule)
      assert :ok == Storage.set_message(pid, group.telegram_id, group.message)
    end)

    pid
    |> Storage.groups()
    |> Enum.zip(groups)
    |> Enum.each(fn {fetched_group, expected_group} ->
      assert fetched_group == expected_group
    end)
  end
end
