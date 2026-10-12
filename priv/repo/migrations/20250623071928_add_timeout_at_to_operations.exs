# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Wanda.Repo.Migrations.AddTimeoutAtToOperations do
  use Ecto.Migration

  def change do
    alter table(:operations) do
      add :timeout_at, :utc_datetime_usec
    end
  end
end
