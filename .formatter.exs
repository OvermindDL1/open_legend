[
  import_deps: [:ecto, :phoenix],
  inputs: [".formatter.exs", "*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs}"],
  subdirectories: ["priv/*/migrations"],
  single_clause_on_do: true,
  trailing_comma: true,
]
