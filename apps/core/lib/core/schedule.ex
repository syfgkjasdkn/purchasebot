defmodule Core.Schedule do
  defstruct [:hours, :minutes]

  def parse(schedule) do
    with [hours, minutes] <- :binary.split(schedule, " ", [:global]),
         {:ok, hours} <- parse(:hours, hours),
         {:ok, minutes} <- parse(:minutes, minutes) do
      {:ok, %__MODULE__{hours: hours, minutes: minutes}}
    else
      _other ->
        {:error, :invalid_format}
    end
  end

  def describe(%__MODULE__{hours: hours, minutes: minutes}) do
    schedule =
      for hour <- hours, minute <- minutes do
        hour = String.pad_leading(to_string(hour), 2, "0")
        minute = String.pad_leading(to_string(minute), 2, "0")
        "#{hour}:#{minute}"
      end

    Enum.join(schedule, "\n")
  end

  defp parse(type, hours_or_minutes) do
    {min, max} =
      case type do
        :hours -> {0, 24}
        :minutes -> {0, 60}
      end

    hours_or_minutes =
      hours_or_minutes
      |> :binary.split(",", [:global])
      |> Enum.map(fn hour_or_minute ->
        case Integer.parse(hour_or_minute) do
          {hour_or_minute, ""} ->
            if hour_or_minute >= min and hour_or_minute < max do
              hour_or_minute
            else
              throw(:error)
            end

          _error ->
            throw(:error)
        end
      end)
      |> Enum.uniq()

    {:ok, hours_or_minutes}
  catch
    _ -> :error
  end
end
