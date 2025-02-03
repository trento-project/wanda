defmodule WandaWeb.V1.ChecksSelectionJSON do
  def selectable_checks(%{
        selectable_checks: selectable_checks
      }) do
    %{
      items: selectable_checks
    }
  end
end
