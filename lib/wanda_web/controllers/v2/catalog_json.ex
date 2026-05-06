# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

defmodule WandaWeb.V2.CatalogJSON do
  alias WandaWeb.V1.CatalogJSON

  def catalog(%{catalog: catalog}) do
    %{items: Enum.map(catalog, &CatalogJSON.check/1)}
  end
end
