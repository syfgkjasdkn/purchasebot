defmodule Core.Group do
  @moduledoc false
  use GenServer

  alias Core.Schedule
  require Logger
  require Record

  Record.defrecord(:state, [:group_id, :timer, :schedule, message_acc: []])

  @doc false
  def start_link(opts) do
    group_id = opts[:group_id] || raise("need :group_id")
    GenServer.start_link(__MODULE__, opts, name: via(group_id))
  end

  @doc false
  def init(opts) do
    send(self(), :init)
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

  def handle_call(
        {:set_schedule, raw_schedule},
        _from,
        state(group_id: group_id, timer: timer) = state
      ) do
    case Schedule.parse(raw_schedule) do
      {:ok, %Schedule{} = schedule} ->
        :timer.cancel(timer)
        :ok = Storage.set_schedule(group_id, raw_schedule)
        {:reply, {:ok, Schedule.describe(schedule)}, state(state, schedule: schedule)}

      {:error, :invalid_format} = error ->
        {:reply, error, state}
    end
  end

  def handle_call({:set_message, message}, _from, state(group_id: group_id) = state) do
    :ok = Storage.set_message(group_id, message)
    {:reply, :ok, state}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  @doc false
  def handle_info(:init, state(group_id: group_id) = state) do
    %Storage.Group{schedule: raw_schedule} = Storage.group(group_id)

    schedule =
      if raw_schedule do
        {:ok, schedule} = Schedule.parse(raw_schedule)
        schedule
      end

    {:noreply, state(state, schedule: schedule)}
  end
end
