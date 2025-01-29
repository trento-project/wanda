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

  def render("404.json", %{reason: reason} = context) when not is_map_key(context, :status) do
    %{
      errors: [
        %{
          title: "Not Found",
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

  def render("400.json", %{reason: reason}) do
    %{
      errors: [
        %{
          title: "Bad Request",
          detail: reason
        }
      ]
    }
  end

  def render("403.json", %{reason: reason}) do
    %{
      errors: [
        %{
          title: "Forbidden",
          detail: reason
        }
      ]
    }
  end

  def render("403.json", _) do
    %{
      errors: [
        %{
          title: "Forbidden",
          detail: "Unauthorized to perform operation."
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
