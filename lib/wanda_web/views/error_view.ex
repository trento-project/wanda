defmodule WandaWeb.ErrorView do
  use WandaWeb, :view

  def render("422.json", %{reason: reason}) do
    %{
      errors: [
        %{
          title: "Unprocessable Entity",
          detail: reason
        }
      ]
    }
  end

  def render("404.json", _) do
    %{
      errors: [
        %{
          title: "Not Found",
          detail: "The requested resource was not found."
        }
      ]
    }
  end

  def template_not_found(template, _assigns) do
    %{
      errors: [
        %{
          title: Phoenix.Controller.status_message_from_template(template),
          detail: "An error has occurred."
        }
      ]
    }
  end
end
