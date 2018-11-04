defmodule Storage.Group do
  use TypedStruct

  typedstruct do
    field(:telegram_id, pos_integer, enforce: true)
    field(:message, String.t())
    field(:schedule, String.t())
    field(:last_repost, NaiveDateTime.t())
  end
end
