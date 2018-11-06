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
    load_admins!()

    children =
      Enum.reject(
        [
          unquote(storage),
          {Registry, keys: :unique, name: Core.Group.Registry},
          Core.Group.Supervisor,
          unless unquote(Mix.env() == :test) do
            {Task, fn -> start_groups() end}
          end
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

  @doc false
  def load_admins! do
    admins =
      (System.get_env("ADMIN_IDS") || raise(ArgumentError, "need ADMIN_IDS to be set"))
      |> String.split(",", trim: true)
      |> Enum.map(fn admin_id ->
        try do
          String.to_integer(admin_id)
        rescue
          _ ->
            raise(ArgumentError, "couldn't parse ADMIN_IDS as integers")
        end
      end)

    Application.put_env(:core, :admins, admins)
  end

  def start_groups do
    Enum.each(Storage.groups(), fn %Storage.Group{telegram_id: group_id} ->
      Core.Group.Supervisor.start_group(group_id)
    end)
  end
end
