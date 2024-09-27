defmodule WandaWeb.ErrorJSON do
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

  def render(template, _assigns) do
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
