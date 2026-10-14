# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Wanda.Repo.Migrations.AddCatalogOperationIdToOperation do
  use Ecto.Migration

  def change do
    alter table(:operations) do
      add :catalog_operation_id, :string, null: false
    end
  end
end
