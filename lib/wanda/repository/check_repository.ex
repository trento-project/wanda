defmodule Wanda.ChecksRepository do
  @moduledoc """
  Allows to interact with Checks loaded in the system, aka the Checks Catalog
  """

  require Logger

  def load_check(check_id) do
    # TODO: a Check needs to be loaded from somewhere in order to be able to extract the facts to be gathered for this check
    Logger.info("Loading Check #{check_id} from the Catalog")

    Path.join(File.cwd!(), "lib/wanda/dsl/check-definition.yaml")
    |> YamlElixir.read_from_file!()
  end
end
