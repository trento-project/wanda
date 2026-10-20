# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Wanda.Repo do
  use Ecto.Repo,
    otp_app: :wanda,
    adapter: Ecto.Adapters.Postgres
end
