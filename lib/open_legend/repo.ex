defmodule OpenLegend.Repo do
  use Ecto.Repo,
    otp_app: :open_legend,
    adapter: Ecto.Adapters.Postgres


  defmodule Migration do
    defmacro __using__([]) do
      quote do
        use Ecto.Migration
        import OpenLegend.Repo.Migration
      end
    end

    def timestamps_with_removed_at(opts \\ []) do
      import Ecto.Migration
      opts = Keyword.merge(Ecto.Migration.Runner.repo_config(:migration_timestamps, []), opts)
      opts = Keyword.put_new(opts, :null, false)

      {type, opts} = Keyword.pop(opts, :type, :naive_datetime)
      {inserted_at, opts} = Keyword.pop(opts, :inserted_at, :inserted_at)
      {updated_at, opts} = Keyword.pop(opts, :updated_at, :updated_at)
      {removed_at, opts} = Keyword.pop(opts, :removed_at, :removed_at)

      {inserted_at_opts, opts} = Keyword.pop(opts, :inserted_at_opts, [])
      {updated_at_opts, opts} = Keyword.pop(opts, :updated_at_opts, [])
      {removed_at_opts, opts} = Keyword.pop(opts, :removed_at_opts, [])

      if inserted_at != false, do: add(inserted_at, type, inserted_at_opts ++ opts)
      if updated_at != false, do: add(updated_at, type, updated_at_opts ++ opts)
      if removed_at != false, do: add(removed_at, type, removed_at_opts ++ [null: true] ++ opts)
    end
  end

  defmodule Schema do
    defmacro __using__([]) do
      quote do
        use Ecto.Schema
        import Ecto.Changeset
        import OpenLegend.Repo.Schema

        # http://blog.plataformatec.com.br/2018/10/a-sneak-peek-at-ecto-3-0-breaking-changes/?utm_campaign=blog-post-promotion&utm_medium=email&utm_source=subscribers-list
        @timestamps_opts [type: :naive_datetime_usec]
      end
    end

    defmacro timestamps_with_removed_at(opts \\ []) do
      quote bind_quoted: binding() do
        timestamps =
          [
            inserted_at: :inserted_at,
            updated_at: :updated_at,
            removed_at: :removed_at,
            type: :naive_datetime
          ]
          |> Keyword.merge(@timestamps_opts)
          |> Keyword.merge(opts)

        type = Keyword.get(timestamps, :type, :naive_datetime)
        autogen = timestamps[:autogenerate] || {Ecto.Schema, :__timestamps__, [type]}

        inserted_at = Keyword.fetch!(timestamps, :inserted_at)
        updated_at = Keyword.fetch!(timestamps, :updated_at)
        removed_at = Keyword.fetch!(timestamps, :removed_at)

        if inserted_at do
          opts = if source = timestamps[:inserted_at_source], do: [source: source], else: []
          Ecto.Schema.field(inserted_at, type, opts)
        end

        if updated_at do
          opts = if source = timestamps[:updated_at_source], do: [source: source], else: []
          Ecto.Schema.field(updated_at, type, opts)
          Module.put_attribute(__MODULE__, :ecto_autoupdate, {[updated_at], autogen})
        end

        if removed_at do
          opts = if source = timestamps[:removed_at_source], do: [source: source], else: []
          Ecto.Schema.field(removed_at, type, opts)
        end

        with [_ | _] = fields <- Enum.filter([inserted_at, updated_at], & &1) do
          Module.put_attribute(__MODULE__, :ecto_autogenerate, {fields, autogen})
        end

        :ok
      end
    end
  end

end
