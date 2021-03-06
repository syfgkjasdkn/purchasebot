defmodule Core.Group.Supervisor do
  @moduledoc false
  use DynamicSupervisor

  @doc false
  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc false
  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec start_group(integer) :: DynamicSupervisor.on_start_child()
  def start_group(group_id) when is_integer(group_id) do
    DynamicSupervisor.start_child(__MODULE__, {Core.Group, group_id: group_id})
  end

  @spec stop_group(integer) :: :ok | {:error, :not_found}
  def stop_group(group_id) when is_integer(group_id) do
    case Registry.lookup(Core.Group.Registry, group_id) do
      [{pid, _}] -> DynamicSupervisor.terminate_child(__MODULE__, pid)
      [] -> {:error, :not_found}
    end
  end
end
