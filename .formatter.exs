# Used by "mix format"
[
  import_deps: [:ecto, :phoenix, :open_api_spex],
  inputs: ["*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test,demo}/**/*.{ex,exs}"],
  subdirectories: ["priv/*/migrations"]
]
