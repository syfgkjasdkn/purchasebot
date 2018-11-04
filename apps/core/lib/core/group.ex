defmodule Core.Group do
  @moduledoc false
  use GenServer

  require Logger
  require Record

  Record.defrecord(:state, [:group_id, message_acc: []])

  @doc false
  def start_link(opts) do
    group_id = opts[:group_id] || raise("need :group_id")
    GenServer.start_link(__MODULE__, opts, name: via(group_id))
  end

  @doc false
  def init(opts) do
    {:ok, state(group_id: opts[:group_id])}
  end

  @doc false
  def via(group_id) when is_integer(group_id) do
    {:via, Registry, {Core.Group.Registry, group_id}}
  end

  @doc false
  def handle_call(message, from, state)

  def handle_call({:handle_text, text}, _from, state(message_acc: message_acc) = state) do
    {:reply, :ok, state(state, message_acc: [message_acc | text])}
  end

  def handle_call(:start_message, _from, state) do
    {:reply, :ok, state(state, message_acc: [])}
  end

  def handle_call(:save_message, _from, state(group_id: group_id, message_acc: message) = state) do
    :ok = Storage.set_message(group_id, message)
    {:reply, {:ok, message}, state(state, message_acc: [])}
  end

  def handle_call({:set_schedule, schedule}, _from, state(group_id: group_id) = state) do
    :ok = Storage.set_schedule(group_id, schedule)
    {:reply, :ok, state}
  end
end
