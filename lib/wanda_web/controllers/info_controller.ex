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

    conn
    |> put_status(200)
    |> json(%{
      name: "wanda",
      version: version
    })
  end
end
