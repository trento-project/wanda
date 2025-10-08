defmodule WandaWeb.V1.ChecksCustomizationsController do
  use WandaWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias OpenApiSpex.Schema
  alias Wanda.Users.User

  alias WandaWeb.Auth.UserDetector
  alias WandaWeb.Schemas.V1.{BadRequest, Forbidden, NotFound, UnprocessableEntity}
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
    summary: "Apply custom values for a specific check.",
    description:
      "Allows users to apply custom values to a specific check for a selected group, enabling tailored validation.",
    tags: ["Checks Engine"],
    parameters: [
      check_id: [
        in: :path,
        description:
          "The unique identifier of the check to which custom values are being applied.",
        type: %Schema{
          type: :string
        },
        example: "ABC123"
      ],
      group_id: [
        in: :path,
        description:
          "The unique identifier of the group for which the custom value is being set.",
        type: %Schema{
          type: :string,
          format: :uuid
        },
        example: "c1a2b3c4-d5e6-7890-abcd-ef1234567890"
      ]
    ],
    request_body:
      {"The custom values to be applied to the specified check.", "application/json",
       CustomizationRequest},
    responses: [
      ok:
        {"A successful response containing the applied customizations for the specified check and group.",
         "application/json", CustomizationResponse},
      forbidden: Forbidden.response(),
      bad_request: BadRequest.response(),
      unprocessable_entity: UnprocessableEntity.response(),
      not_found: NotFound.response()
    ]

  def apply_custom_values(conn, %{check_id: check_id, group_id: group_id}) do
    %{values: custom_values} = OpenApiSpex.body_params(conn)

    %User{id: user_id} = UserDetector.current_user(conn)

    with {:ok, customization} <-
           ChecksCustomizations.customize(
             check_id,
             group_id,
             custom_values,
             user_id: user_id
           ) do
      render(conn, :check_customization, %{customization: customization})
    end
  end

  operation :reset_customization,
    summary: "Reset the customizations applied for a specific check.",
    description:
      "Removes all previously applied customizations for a check in a specific group, restoring default values.",
    tags: ["Checks Engine"],
    parameters: [
      check_id: [
        in: :path,
        description:
          "The unique identifier of the check for which the customization is being reset.",
        type: %Schema{
          type: :string
        },
        example: "ABC123"
      ],
      group_id: [
        in: :path,
        description:
          "The unique identifier of the group for which the check's customization is being reset.",
        type: %Schema{
          type: :string,
          format: :uuid
        },
        example: "c1a2b3c4-d5e6-7890-abcd-ef1234567890"
      ]
    ],
    responses: [
      no_content:
        "A successful response indicating the customization was reset and defaults restored.",
      not_found: NotFound.response()
    ]

  def reset_customization(conn, %{check_id: check_id, group_id: group_id}) do
    %User{id: user_id} = UserDetector.current_user(conn)

    with :ok <- ChecksCustomizations.reset_customization(check_id, group_id, user_id: user_id) do
      send_resp(conn, :no_content, "")
    end
  end
end
