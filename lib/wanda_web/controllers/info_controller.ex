defmodule WandaWeb.InfoController do
  use WandaWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias WandaWeb.Schemas.V1.Info

  operation :info,
    summary: "Wanda service information.",
    tags: ["Checks/Operations Platform"],
    description:
      "This endpoint returns information about this Wanda instance for service discovery purposes, including name and version",
    security: [],
    responses: [
      ok:
        {"This response provides service discovery information about the current Wanda instance.",
         "application/json", Info}
    ]

  def info(conn, _) do
    version = to_string(Application.spec(:wanda, :vsn))
    checks_version = read_checks_version()

    conn
    |> put_status(200)
    |> json(%{
      name: "wanda",
      version: version,
      checks_version: checks_version
    })
  end

  defp read_checks_version do
    catalog_paths = Application.fetch_env!(:wanda, Wanda.Catalog)[:catalog_paths]
    checks_path = List.first(catalog_paths)
    version_file = Path.join(checks_path, "VERSION")

    case File.read(version_file) do
      {:ok, content} -> String.trim(content)
      {:error, _} -> nil
    end
  end
end
