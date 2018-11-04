defmodule Core.ScheduleTest do
  use ExUnit.Case
  alias Core.Schedule

  test "parse" do
    assert Schedule.parse("0,6,12,18 0") ==
             {:ok,
              %Schedule{
                hours: [0, 6, 12, 18],
                minutes: [0]
              }}

    assert Schedule.parse("0 0") ==
             {:ok,
              %Schedule{
                hours: [0],
                minutes: [0]
              }}

    assert Schedule.parse("0,12 0,30") == {:ok, %Schedule{hours: [0, 12], minutes: [0, 30]}}

    assert Schedule.parse("alsdfgasdlf") == {:error, :invalid_format}

    assert Schedule.parse("0") == {:error, :invalid_format}

    assert Schedule.parse("0 70,70,70") == {:error, :invalid_format}

    assert Schedule.parse("12,3004 0") == {:error, :invalid_format}

    assert Schedule.parse("12,4 0-1234-asdf") == {:error, :invalid_format}
  end

  test "describe" do
    assert Schedule.describe(%Schedule{
             hours: [0, 6, 12, 18],
             minutes: [0]
           }) == """
           00:00
           06:00
           12:00
           18:00\
           """

    assert Schedule.describe(%Schedule{hours: [0, 12], minutes: [0, 30]}) == """
           00:00
           00:30
           12:00
           12:30\
           """
  end
end
