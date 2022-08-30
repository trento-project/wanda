defmodule Wanda.Support.CloudEventsHelper do
  @moduledoc false

  def load_event(filename) do
    File.read!("test/fixtures/events/#{filename}.json")
    |> String.replace(["\r", "\n", " "], "")
  end
end
