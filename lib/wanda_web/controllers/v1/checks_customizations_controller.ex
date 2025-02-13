defmodule WandaWeb.V1.ChecksCustomizationsController do
  use WandaWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias OpenApiSpex.Schema

  alias WandaWeb.Schemas.{BadRequest, Forbidden, NotFound}
  alias WandaWeb.Schemas.V1.ChecksCustomizations.{CustomizationRequest, CustomizationResponse}

  alias Wanda.ChecksCustomizations

  plug Bodyguard.Plug.Authorize,
    policy: Wanda.Catalog.CustomizationPolicy,
    action: {Phoenix.Controller, :action_name},
    user: {WandaWeb.Auth.UserDetector, :current_user},
    params: Wanda.Catalog.CheckCustomization,
    fallback: WandaWeb.FallbackController

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
      unprocessable_entity: OpenApiSpex.JsonErrorResponse.response(),
      not_found: NotFound.response()
    ]

  def apply_custom_values(conn, %{check_id: check_id, group_id: group_id}) do
    %{values: custom_values} = OpenApiSpex.body_params(conn)

    with {:ok, customization} <- ChecksCustomizations.customize(check_id, group_id, custom_values) do
      render(conn, :check_customization, %{customization: customization})
    end
  end

  operation :reset_customization,
    summary: "Reset the customizations applied for a specific check",
    description: "Removes all previously applied customizations for a check in a specific group",
    parameters: [
      check_id: [
        in: :path,
        description:
          "Identifier of the specific check for which the customization is being reset",
        type: %Schema{
          type: :string
        },
        example: "ABC123"
      ],
      group_id: [
        in: :path,
        description:
          "Identifier of the group for which the specific check's customization is being reset",
        type: %Schema{
          type: :string,
          format: :uuid
        },
        example: "00000000-0000-0000-0000-000000000001"
      ]
    ],
    responses: [
      no_content: "Customization successfully reset",
      not_found: NotFound.response()
    ]

  def reset_customization(conn, %{check_id: check_id, group_id: group_id}) do
    with :ok <- ChecksCustomizations.reset_customization(check_id, group_id) do
      send_resp(conn, :no_content, "")
    end
  end
end
