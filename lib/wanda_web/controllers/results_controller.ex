defmodule WandaWeb.ResultsController do
  use WandaWeb, :controller

  def results(conn, _params), do: json(conn, %{result: "ok"})
end
