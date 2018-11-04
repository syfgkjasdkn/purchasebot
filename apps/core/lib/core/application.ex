defmodule Core.Application do
  @moduledoc false
  use Application

  storage =
    if Mix.env() in [:prod, :dev] do
      quote do
        {Storage, path: db_path!(), name: Storage}
      end
    end

  def start(_type, _args) do
    children =
      Enum.reject(
        [
          unquote(storage),
          {Registry, keys: :unique, name: Core.Group.Registry},
          Core.Group.Supervisor,
          {Task, fn -> start_groups() end}
        ],
        &is_nil/1
      )

    opts = [strategy: :one_for_one, name: Core.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc false
  def db_path! do
    Application.get_env(:core, :db_path) || raise("need db path")
  end

  def start_groups do
    Enum.each(Storage.groups(), fn %Storage.Group{telegram_id: group_id} ->
      Core.Group.Supervisor.start_group(group_id)
    end)
  end
end
