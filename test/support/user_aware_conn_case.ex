defmodule WandaWeb.UserAwareConnCase do
  @moduledoc """
  Test case to deal with users and their abilities.
  """

  use ExUnit.CaseTemplate

  import Plug.Conn

  setup %{conn: conn} = context do
    abilities =
      Map.get(context, :abilities, [
        %{
          name: "all",
          resource: "all"
        }
      ])

    {:ok,
     conn:
       conn
       |> put_private(:user_id, 1)
       |> put_private(:abilities, abilities)}
  end
end
