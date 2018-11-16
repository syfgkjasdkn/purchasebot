defmodule Core do
  @moduledoc false
  alias Core.Group
  require Group

  def add_group(group_id) when is_integer(group_id) do
    Storage.insert_group(group_id)
    Group.Supervisor.start_group(group_id)
  end

  def admin?(user_id) do
    user_id in Application.get_env(:core, :admin_ids)
  end

  def start_message(group_id) do
    call_group(group_id, :start_message)
  end

  def save_message(group_id) do
    call_group(group_id, :save_message)
  end

  def set_schedule(group_id, schedule) do
    call_group(group_id, {:set_schedule, schedule})
  end

  def set_message(group_id, message) do
    call_group(group_id, {:set_message, message})
  end

  def handle_text(group_id, text) do
    call_group(group_id, {:handle_text, text})
  end

  @doc false
  def _group_state(group_id) do
    group_id
    |> call_group(:state)
    |> Group.state()
  end

  defp call_group(group_id, message) when is_integer(group_id) do
    group_id
    |> Group.via()
    |> GenServer.call(message)
  end
end
