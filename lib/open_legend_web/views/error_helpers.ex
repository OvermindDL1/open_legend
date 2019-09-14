defmodule OpenLegendWeb.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field) do
    Enum.map(Keyword.get_values(form.errors, field), fn error ->
      content_tag(:span, translate_error(error), class: "help-block")
    end)
  end

  @doc """
  Gets a single formatted line of error text for a field
  """
  def error_string(%{errors: errors} = _form, field) do
    :proplists.get_all_values(field, errors)
    |> Enum.map(&translate_error/1)
    |> Enum.join("; ")
  end
  def error_string(_form, _field) do
    ""
  end

  @doc """
  Gets a single formatted line of error text
  """
  def error_string(%{errors: errors}) do
    errors
    |> Enum.map(&"#{elem(&1, 0)}: #{translate_error(elem(&1, 1))}")
    |> Enum.join("; ")
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(OpenLegendWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(OpenLegendWeb.Gettext, "errors", msg, opts)
    end
  end
end
