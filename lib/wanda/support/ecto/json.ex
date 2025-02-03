defmodule Wanda.Support.Ecto.Json do
  @moduledoc """
  Ecto Type that represents JSON data.
  """

  use Ecto.Type

  def type, do: {:array, :map}

  def cast(data) when is_list(data) or is_map(data), do: {:ok, data}

  def cast(_), do: :error

  def load(data) when is_list(data) or is_map(data) do
    {:ok, atomize_map_keys(data)}
  end

  def dump(data) when is_list(data) or is_map(data), do: {:ok, data}
  def dump(_), do: :error

  defp atomize_map_keys(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {String.to_existing_atom(k), atomize_map_keys(v)} end)
  end

  defp atomize_map_keys(map) when is_list(map) do
    Enum.map(map, &atomize_map_keys/1)
  end

  defp atomize_map_keys(value), do: value
end
