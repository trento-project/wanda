defmodule Wanda.JsonSchema do
  @moduledoc """
  TODO: move to separate repo.
  """

  @schema_path Path.join(File.cwd!(), "priv/json_schema/")

  for schema_file <- File.ls!(@schema_path) do
    @external_resource schema_file

    schema =
      @schema_path
      |> Path.join(schema_file)
      |> File.read!()
      |> Jason.decode!()
      |> ExJsonSchema.Schema.resolve()

    def validate(unquote(Path.basename(schema_file, ".schema.json")), data),
      do: ExJsonSchema.Validator.validate(unquote(Macro.escape(schema)), data)
  end

  def validate(_, _), do: {:error, :schema_not_found}
end
