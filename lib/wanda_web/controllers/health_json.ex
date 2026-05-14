# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

defmodule WandaWeb.HealthJSON do
  def health(%{health: health}), do: health
end
