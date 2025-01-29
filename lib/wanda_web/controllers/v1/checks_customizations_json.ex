defmodule WandaWeb.V1.ChecksCustomizationsJSON do
  alias Wanda.Catalog.CheckCustomization

  def check_customization(%{
        customization: %CheckCustomization{
          custom_values: values
        }
      }) do
    %{
      values: values
    }
  end
end
