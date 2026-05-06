# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

defmodule Wanda.Repo do
  use Ecto.Repo,
    otp_app: :wanda,
    adapter: Ecto.Adapters.Postgres
end
