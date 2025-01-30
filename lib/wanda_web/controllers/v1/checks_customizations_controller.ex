defmodule WandaWeb.V1.ChecksCustomizationsController do
  use WandaWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.{BadRequest, Forbidden}
  alias WandaWeb.Schemas.V1.ChecksCustomizations.{CustomizationRequest, CustomizationResponse}

  alias Wanda.ChecksCustomizations

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true
  action_fallback WandaWeb.FallbackController

  operation :apply_custom_values,
    summary: "Apply custom values for a specific check",
    parameters: [
      check_id: [
        in: :path,
        description: "Identifier of the specific check that is being customized",
        type: %Schema{
          type: :string
        },
        example: "ABC123"
      ],
      group_id: [
        in: :path,
        description: "Identifier of the group for which a custom value should be applied",
        type: %Schema{
          type: :string,
          format: :uuid
        },
        example: "00000000-0000-0000-0000-000000000001"
      ]
    ],
    request_body: {"Custom Values", "application/json", CustomizationRequest},
    responses: [
      ok: {"Check Customizations", "application/json", CustomizationResponse},
      forbidden: Forbidden.response(),
      bad_request: BadRequest.response(),
      unprocessable_entity: OpenApiSpex.JsonErrorResponse.response()
    ]

  def apply_custom_values(conn, %{check_id: check_id, group_id: group_id}) do
    %{values: custom_values} = OpenApiSpex.body_params(conn)

    with {:ok, customization} <- ChecksCustomizations.customize(check_id, group_id, custom_values) do
      render(conn, :check_customization, %{customization: customization})
    end
  end
end
