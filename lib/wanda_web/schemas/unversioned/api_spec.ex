# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule WandaWeb.Schemas.Unversioned.ApiSpec do
  @moduledoc """
  OpenApi specification entry point for unversioned endpoints
  """

  use WandaWeb.Schemas.ApiSpec,
    api_version: "unversioned"
end
