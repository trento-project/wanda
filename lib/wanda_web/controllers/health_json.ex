# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule WandaWeb.HealthJSON do
  def health(%{health: health}), do: health
end
