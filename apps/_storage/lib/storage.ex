defmodule Storage do
  @moduledoc false

  use GenServer
  alias Storage.Group

  require Record
  Record.defrecordp(:state, [:conn, :statements])

  @typep connection :: {:connection, reference(), term()}

  @typep statement :: {:statement, term(), connection()}

  @typep sql :: iodata

  @typep statements :: %{sql() => statement()}
  @typep state ::
           record(:state,
             conn: connection(),
             statements: statements
           )

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  @doc false
  def init(opts) do
    path = opts[:path] || raise("need path for the database")

    conn =
      case :esqlite3.open(to_charlist(path)) do
        {:ok, conn} -> conn
        error -> raise("failed to open the database with error: #{inspect(error)}")
      end

    send(self(), :migrate)

    {:ok, state(conn: conn, statements: %{})}
  end

  @doc false
  def conn(pid \\ __MODULE__) do
    GenServer.call(pid, :conn)
  end

  @spec insert_group(integer) :: :ok | other :: any
  @spec insert_group(module | pid, integer) :: :ok | other :: any
  def insert_group(pid \\ __MODULE__, telegram_id) do
    GenServer.call(pid, {:insert_group, telegram_id})
  end

  @spec groups :: [Group.t()]
  @spec groups(module | pid) :: [Group.t()]
  def groups(pid \\ __MODULE__) do
    pid
    |> GenServer.call(:groups)
    |> Enum.map(fn {telegram_id, message, schedule} ->
      %Group{
        telegram_id: telegram_id,
        message: _maybe_nilify(message),
        schedule: _maybe_nilify(schedule)
      }
    end)
  end

  defp _maybe_nilify(:undefined), do: nil
  defp _maybe_nilify(other), do: other

  @spec set_message(integer, String.t()) :: :ok | other :: any
  @spec set_message(module | pid, integer, String.t()) :: :ok | other :: any
  def set_message(pid \\ __MODULE__, telegram_id, message) do
    GenServer.call(pid, {:set_message, telegram_id, message})
  end

  @spec set_schedule(integer, String.t()) :: :ok | other :: any
  @spec set_schedule(module | pid, integer, String.t()) :: :ok | other :: any
  def set_schedule(pid \\ __MODULE__, telegram_id, schedule) do
    GenServer.call(pid, {:set_schedule, telegram_id, schedule})
  end

  @doc false
  def handle_call(message, from, state)

  def handle_call({:insert_group, telegram_id}, _from, state) do
    sql = "INSERT INTO groups (telegram_id) VALUES (?)"
    {:ok, statement, state} = prepared_statement(sql, state)
    :ok = :esqlite3.bind(statement, [telegram_id])
    {:reply, run(statement), state}
  end

  @spec handle_call(:groups, GenServer.from(), state) :: {:reply, [tuple()], state}
  def handle_call(:groups, _from, state) do
    sql = "SELECT telegram_id, message, schedule FROM groups"
    {:ok, statement, state} = prepared_statement(sql, state)
    {:reply, :esqlite3.fetchall(statement), state}
  end

  def handle_call({:set_message, telegram_id, message}, _from, state) do
    sql = "UPDATE groups SET message = ? WHERE telegram_id = ?"
    {:ok, statement, state} = prepared_statement(sql, state)
    :ok = :esqlite3.bind(statement, [message, telegram_id])
    {:reply, run(statement), state}
  end

  def handle_call({:set_schedule, telegram_id, schedule}, _from, state) do
    sql = "UPDATE groups SET schedule = ? WHERE telegram_id = ?"
    {:ok, statement, state} = prepared_statement(sql, state)
    :ok = :esqlite3.bind(statement, [schedule, telegram_id])
    {:reply, run(statement), state}
  end

  def handle_call(:conn, _from, state(conn: conn) = state) do
    {:reply, conn, state}
  end

  @doc false
  def handle_info(:migrate, state(conn: conn) = state) do
    migrations = """
    -- TODO: CREATE TABLE migrations

    BEGIN;

    CREATE TABLE IF NOT EXISTS groups (
      telegram_id INTEGER PRIMARY KEY,
      schedule TEXT,
      message TEXT
    );

    COMMIT;
    """

    :ok = :esqlite3.exec(migrations, conn)
    {:noreply, state}
  end

  @spec prepared_statement(sql, state) :: {:ok, statement, state} | {:error, reason :: any, state}
  defp prepared_statement(sql, state(conn: conn, statements: statements) = state) do
    if statement = Map.get(statements, sql) do
      {:ok, statement, state}
    else
      case :esqlite3.prepare(sql, conn) do
        {:ok, statement} ->
          {:ok, statement, state(state, statements: Map.put(statements, sql, statement))}

        other ->
          other
      end
    end
  end

  @spec run(statement) :: :ok | tuple()
  defp run(statement) do
    case :esqlite3.step(statement) do
      :"$done" -> :ok
      :"$busy" -> {:error, :busy}
      other -> other
    end
  end
end
