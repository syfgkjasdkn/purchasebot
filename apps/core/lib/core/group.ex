defmodule Core.Group do
  @moduledoc false
  use GenServer

  alias Core.Schedule
  require Logger
  require Record

  Record.defrecord(:state, [:group_id, :schedule])

  @sleep 60 * 1000

  @doc false
  def start_link(opts) do
    group_id = opts[:group_id] || raise("need :group_id")
    GenServer.start_link(__MODULE__, opts, name: via(group_id))
  end

  @doc false
  def init(opts) do
    send(self(), :init)
    Process.send_after(self(), :maybe_publish, @sleep)
    {:ok, state(group_id: opts[:group_id])}
  end

  @doc false
  def via(group_id) when is_integer(group_id) do
    {:via, Registry, {Core.Group.Registry, group_id}}
  end

  @doc false
  def handle_call(message, from, state)

  def handle_call(
        {:set_schedule, raw_schedule},
        _from,
        state(group_id: group_id) = state
      ) do
    case Schedule.parse(raw_schedule) do
      {:ok, %Schedule{} = schedule} ->
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

  def handle_info(:maybe_publish, state(group_id: group_id, schedule: schedule) = state) do
    Process.send_after(self(), :maybe_publish, @sleep)

    if schedule do
      maybe_publish(schedule, Time.utc_now(), group_id)
    end

    {:noreply, state}
  end

  def maybe_publish(
        %Schedule{hours: hours, minutes: minutes},
        %Time{
          hour: current_hour,
          minute: current_minute
        },
        group_id
      ) do
    Enum.each(hours, fn hour ->
      if hour - current_hour == 0 do
        Enum.each(minutes, fn minute ->
          if minute - current_minute == 0 do
            %Storage.Group{message: message} = Storage.group(group_id)
            Application.get_env(:core, :publisher).send_message(group_id, message)
          end
        end)
      end
    end)
  end
end
