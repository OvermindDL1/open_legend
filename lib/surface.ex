defmodule Surface.Dyn do
  defmacro dyn_import() do
    quote do
      import unquote(Application.get_env(:phoenix, :surface)[:error_helpers])
    end
  end
end

defmodule Surface do
  @moduledoc """
  Helpers to generate Surface-compatible HTML
  """

  require Surface.Dyn
  Surface.Dyn.dyn_import()
  import Phoenix.HTML
  import Phoenix.HTML.Form
  import Phoenix.HTML.Tag
  alias Phoenix.HTML.Form
  alias Phoenix.HTML.Link



  def icon_svg(max_size \\ "40px") do
    ~e"""
      <svg viewbox="0 0 1 1" style="max-height:<%= max_size %>;max-width:<%= max_size %>;">
        <g>
          <line x1="-0.5" y1="0" x2="0.5" y2="0"></line>
          <line x1="-0.5" y1="0" x2="0.5" y2="0"></line>
          <line x1="-0.5" y1="0" x2="0.5" y2="0"></line>
        </g>
      </svg>
    """
  end


  # def icon_button( path, btn_type, opts \\ []) when btn_type in [:flat, :float, :raised] do
  #   # {icon, opts} = Keyword.pop(opts, :do, "unknown")
  #   # button(path, btn_type, opts)
  #   # {class, opts} = Keyword.pop(opts, :class, "")
  #   # {method, opts} = Keyword.pop(opts, :method, :get)
  #   # {btn_color, opts} = Keyword.pop(opts, :btn, nil)
  #   # {max_size, opts} = Keyword.pop(opts, :max_size, "24px")
  #   # btn_color = if(btn_color == nil, do: "", else: " btn--"<>btn_color)
  #   # class = "btn--#{btn_type}#{btn_color} icon--#{icon} #{class}"
  #   # case path do
  #   #   :submit -> submit([class: class] ++ opts, do: icon_svg())
  #   #   _ -> button([to: path, method: method, class: class] ++ opts, do: icon_svg())
  #   # end
  # end


  def button(path, btn_type, opts \\ []) when btn_type in [:flat, :float, :raised] do
    {do_block, opts} = Keyword.pop(opts, :do, "")
    {class, opts} = Keyword.pop(opts, :class, "")
    {max_size, opts} = Keyword.pop(opts, :max_size, "24px")
    {do_block, class} = case do_block do
      {:icon, icon} -> {icon_svg(max_size), "icon--#{icon} #{class}"}
      _ -> {do_block, class}
    end
    {method, opts} = Keyword.pop(opts, :method, :get)
    {btn_color, opts} = Keyword.pop(opts, :btn, nil)
    btn_color = if(btn_color == nil, do: "", else: " btn--#{btn_color}")
    class = "btn--#{btn_type}#{btn_color} #{class}"
    case path do
      :submit -> Form.submit([class: class] ++ opts, do: do_block)
      _ -> Link.button([to: path, method: method, class: class] ++ opts, do: do_block)
    end
  end

  def submit(text, opts \\ []), do: button(:submit, opts[:btn_type] || :raised, [do: text] ++ opts ++ [btn: :primary])

  @doc """
  This must not be inside of another form!
  """
  def delete_button(path), do: delete_button(path, :raised, [])
  def delete_button(path, btn_type) when is_atom(btn_type), do: delete_button(path, btn_type, [])
  def delete_button(path, opts) when is_list(opts), do: delete_button(path, :raised, opts)
  def delete_button(path, btn_type, opts) do
    {form, opts} = Keyword.pop(opts, :form, [])
    {form_class, form} = Keyword.pop(form, :class, "")
    form = Enum.map(form, fn {k, v} -> ~E{ <%= dasherize(k) %>="<%= v %>"} end)
    opts = opts ++ [do: "Delete"]
    opts = Keyword.put(opts, :class, "btn--red #{opts[:class]}")
    # opts = Keyword.put(opts, :data_confirm, "Are you sure?")
    ~E"""
    <form action="<%= path %>" class="link <%= form_class %>" method="post"<%= form %>>
      <input name="_method" type="hidden" value="delete">
      <input name="_csrf_token" type="hidden" value="<%= get_csrf_token(path) %>">
      <%= button(:submit, btn_type, opts) %>
    </form>
    """
  end

  def delete_button_confirm(unique_id, path), do: delete_button_confirm(unique_id, path, :raised, [])
  def delete_button_confirm(unique_id, path, btn_type) when is_atom(btn_type), do: delete_button_confirm(unique_id, path, btn_type, [])
  def delete_button_confirm(unique_id, path, opts) when is_list(opts), do: delete_button_confirm(unique_id, path, :raised, opts)
  def delete_button_confirm(unique_id, path, btn_type, opts) do
    {confirm_opts, opts} = Keyword.pop(opts, :confirm_opts, [])
    collapsible(unique_id, confirm_opts) do
      delete_button(path, btn_type, opts)
    end
  end


  defp dasherize(value) when is_atom(value),   do: dasherize(Atom.to_string(value))
  defp dasherize(value) when is_binary(value), do: String.replace(value, "_", "-")


  def link(path, btn_type \\ :link, opts) when btn_type in [:link, :plain, :flat, :float, :raised, :text] and is_list(opts) do
    {do_block, opts} = Keyword.pop(opts, :do, nil)
    {class, opts} = Keyword.pop(opts, :class, "")
    {max_size, opts} = Keyword.pop(opts, :max_size, "24px")
    {do_block, class} = case do_block do
      {:icon, icon} -> {icon_svg(max_size), "icon--#{icon} #{class}"}
      _ -> {do_block, class}
    end
    {btn_color, opts} = Keyword.pop(opts, :btn, nil)
    btn_color = if(btn_color == nil, do: "", else: " btn--#{btn_color}")
    class =
      case btn_type do
        :plain -> class
        :text -> "link--unadorned #{class}"
        _ -> "btn--#{btn_type}#{btn_color} #{class}"
      end
    Link.link(do_block, [to: path, class: class] ++ opts)
  end


  defp generic_input(type, form, field, opts) when is_list(opts) do # is_atom(field) and
    opts =
      opts
      |> Keyword.put_new(:type, type)
      |> Keyword.put_new(:id, Form.input_id(form, field))
      |> Keyword.put_new(:name, Form.input_name(form, field))
      |> Keyword.put_new(:value, Form.input_value(form, field))
    tag(:input, opts)
  end

  defp get_changeset_from_form_or_opts(f, opts) do
    case Keyword.pop(opts, :changeset, nil) do
      {nil, opts} ->
        case f do
          %{impl: Phoenix.HTML.FormData.Ecto.Changeset, source: %Ecto.Changeset{} = changeset} -> {changeset, opts}
          _ -> {nil, opts}
        end
      {changeset, opts} -> {changeset, opts}
    end
  end

  defp selected(form, field, opts) do
    {value, opts} = Keyword.pop(opts, :value)
    {selected, opts} = Keyword.pop(opts, :selected)

    if value != nil do
      {value, opts}
    else
      param = to_string(field)

      case form do
        %{params: %{^param => sent}} ->
          {sent, opts}

        _ ->
          {selected || input_value(form, field), opts}
      end
    end
  end

  def form_input(f, type, id, opts \\ [])
  # Container div
  def form_input(f, type, id, opts) when type in [:text, :password, :number, :date, :time, :datetime_local, :month, :week, :email, :tel] do
    {nid, opts} = Keyword.pop(opts, :id, input_id(f, id)) # Node ID
    nid = if(nid == :unique, do: "U#{:erlang.unique_integer()}", else: nid)
    {eid, opts} = Keyword.pop(opts, :error_id, id)
    {required, opts} = Keyword.pop(opts, :required, false)
    {changeset, opts} = get_changeset_from_form_or_opts(f, opts)
    {input_opts, opts} = Keyword.pop(opts, :input_opts, [])
    {_label_opts, opts} = Keyword.pop(opts, :label_opts, [])
    {class, opts} = Keyword.pop(opts, :class, "")
    {label_do, opts} = Keyword.pop(opts, :do, humanize(id))
    input_opts = if(required, do: Keyword.put(input_opts, :required, required), else: input_opts)
    {value, opts} = Keyword.pop(opts, :value, nil)
    value =
      cond do
        value -> value
        changeset && (Map.get(changeset.data, id) || changeset.changes[id]) -> changeset.changes[id] || Map.get(changeset.data, id)
        true -> input_value(f, id)
      end
      |> case do
        %Date{} = value -> Timex.format!(value, "{ISOdate}")
        %DateTime{} = value -> Timex.format!(value, "{ISOdate}T{ISOtime}")
        # Hardcode Mountain time here
        %NaiveDateTime{} = value -> value |> Timex.to_datetime("Etc/UTC") |> Timex.to_datetime("America/Denver") |> Timex.format!("{ISOdate}T{ISOtime}")
        nil -> nil
        s when is_binary(s) -> s
        i when is_integer(i) -> to_string(i)
        f when is_float(f) -> to_string(f)
        a when is_atom(a) -> to_string(a)
        value -> IO.inspect(value, label: "Invalid Form Input")|>throw
      end
    {input_opts, opts} =
      case Keyword.pop(opts, :value, nil) do
        {nil, opts} -> {input_opts, opts}
        {inline_value, opts} -> {[{:value, inline_value} | input_opts], opts}
      end
    # changeset && changeset.action && not changeset.valid? && changeset.errors[eid]
    changeset_error =
      changeset &&
      changeset.action &&
      not changeset.valid? &&
      :proplists.get_value(eid, changeset.errors) != :undefined
    errstr =
      cond do
        changeset_error -> ~e"<span class=\"error\">(Errors with value `<%= String.slice(value, 0, 20) %><%= if(String.length(value)>20, do: \"...\") %>`: <%= error_string(changeset, id) %>)</span>"
        ((e = error_string(f, eid)) != "") and is_binary(e) -> ~e"<span class=\"error\">(Errors with value `<%= String.slice(value, 0, 20) %><%= if(String.length(value)>20, do: \"...\") %>`: <%= e %>)</span>"
        true -> ""
      end
    input_opts =
      if is_binary(errstr) and byte_size(errstr) === 0 do
        input_opts
      else
        # TODO:  This breaks when empty, is it even necessary otherwise?
        # input_opts = Keyword.put(input_opts, :pattern, Regex.escape(to_string(value)))
        input_opts =
          case opts[:error_value] do
            nil -> input_opts
            error_value -> Keyword.put(input_opts, :value, error_value)
          end
        input_opts
      end
    type = case type do
      :datetime_local -> "datetime-local"
      type -> to_string(type)
    end
    ~E"""
    <div class="lower-label-group <%= class %>">
      <%= generic_input type, f, id, [{:id, nid}, {:value, value} | input_opts] %>
      <%#= label f, id, "#{label_do} #{errstr}", [{:for, nid} | label_opts], :TODO_FIX %><label for="<%= nid %>"><%= label_do %> <%= errstr %></label>
      <%#= error_tag f, id %>
    </div>
    """
  end
  def form_input(f, type, id, opts) when type in [:file] do
    {nid, opts} = Keyword.pop(opts, :id, input_id(f, id))
    nid = if(nid == :unique, do: "U#{:erlang.unique_integer()}", else: nid)
    {required, opts} = Keyword.pop(opts, :required, false)
    {changeset, opts} = get_changeset_from_form_or_opts(f, opts)
    {multiple, opts} = Keyword.pop(opts, :multiple, false)
    {input_opts, opts} = Keyword.pop(opts, :input_opts, [])
    {_label_opts, opts} = Keyword.pop(opts, :label_opts, [])
    {class, opts} = Keyword.pop(opts, :class, "")
    {label_do, _opts} = Keyword.pop(opts, :do, humanize(id))
    input_opts = if(required, do: Keyword.put(input_opts, :required, required), else: input_opts)
    input_opts = if(multiple, do: Keyword.put(input_opts, :multiple, multiple), else: input_opts)
    errstr =
      cond do
        changeset && changeset.action && not changeset.valid? && changeset.errors[id] -> ~e"<span class=\"error\">(Errors with value: <%= error_string(changeset, id) %>)</span>"
        e = error_string(f, id) != "" -> ~e"<span class=\"error\">(Errors with value: <%= e %>)</span>"
        true -> ""
      end
    ~E"""
    <div class="lower-label-group <%= class %>">
      <%= file_input f, id, [{:id, nid} | input_opts] %>
      <%#= label f, id, label_str, [{:for, nid} | label_opts], :TODO_FIX %><label for="<%= input_id(f, id) %>"><%= label_do %> <%= errstr %></label>
      <%#= error_tag f, id %>
    </div>
    """
  end
  def form_input(f, type, id, opts) when type in [:multiple_select, :select] do
    {nid, opts} = Keyword.pop(opts, :id, input_id(f, id))
    nid = if(nid == :unique, do: "U#{:erlang.unique_integer()}", else: nid)
    {class, opts} = Keyword.pop(opts, :class, "")
    {label_opts, opts} = Keyword.pop(opts, :label_opts, [])
    {label_do, opts} = Keyword.pop(opts, :do, humanize(id))
    {readonly, opts} = Keyword.pop(opts, :readonly, false)
    opts = if(readonly, do: [{:disabled, true} | opts], else: opts)
    {changeset, opts} = get_changeset_from_form_or_opts(f, opts)
    errstr =
    cond do
      changeset && changeset.action && not changeset.valid? && changeset.errors[id] -> ~e"<span class=\"error\">(Errors: <%= error_string(changeset, id) %>)</span>"
      e = error_string(f, id) != "" -> ~e"<span class=\"error\">(Errors: <%= e %>)</span>"
      true -> ""
    end
    {values, opts} = Keyword.pop(opts, :values, input_value(f, id))
    if not is_list(values), do: throw "#{inspect type} has no values set #{id}: #{inspect values}"
    {selected, opts} = selected(f, id, opts)
    opts = [{:selected, selected} | opts]
    ~E"""
    <div class="lower-label-group <%= class %>">
      <%= case {type, selected} do %>
        <% _ when not readonly -> %>
        <% {_, nil} -> %>
        <% {_, selected} when is_binary(selected) -> %>
          <%= hidden_input f, id, id: nil, name: input_name(f, id), value: selected %>
        <% {:multiple_select, selected} when is_list(selected) -> %>
          <%= for v <- List.wrap(selected) do %>
            <%= hidden_input f, id, id: nil, name: input_name(f, id) <> "[]", value: v %>
          <% end %>
      <% end %>
      <%= case type do
        :select -> select f, id, values, [{:id, nid} | opts]
        :multiple_select -> multiple_select f, id, values, [{:id, nid} | opts]
      end %>
      <%#= label f, id, "#{label_do} #{errstr}", [{:for, nid} | label_opts] %><label for="<%= nid %>"><%= label_do %> <%= errstr %></label>
    </div>
    """
  end
  # Container label, probably all the above should migrate to this over time...
  def form_input(f, type, id, opts) when type in [:checkbox] do
    {nid, opts} = Keyword.pop(opts, :id, input_id(f, id))
    nid = if(nid == :unique, do: "U#{:erlang.unique_integer()}", else: nid)
    {required, opts} = Keyword.pop(opts, :required, nil)
    {value, opts} = Keyword.pop(opts, :value, nil)
    {title, opts} = Keyword.pop(opts, :title, nil)
    {input_opts, opts} = Keyword.pop(opts, :input_opts, [])
    {_label_opts, opts} = Keyword.pop(opts, :label_opts, [])
    {class, opts} = Keyword.pop(opts, :class, "")
    {label_do, _opts} = Keyword.pop(opts, :do, humanize(id))
    input_opts = if(required != nil, do: Keyword.put(input_opts, :required, required), else: input_opts)
    input_opts = if(value != nil, do: Keyword.put(input_opts, :value, value), else: input_opts)
    title = if(title not in [nil, false, ""], do: ~e" title=\"<%= title %>\"", else: "")
    ~e"""
    <label class="label-group <%= class %>"<%= title %>>
      <%= checkbox f, id, [{:id, nid} | input_opts] %>
      <%= label_do %>
      <%= error_tag f, id %>
    </label>
    """
  end
  def form_input(f, type, id, opts) when type in [:datetime_interval] do
    {nid, opts} = Keyword.pop(opts, :id, input_id(f, id))
    nid = if(nid == :unique, do: "U#{:erlang.unique_integer()}", else: nid) # TODO
    {label_do, _opts} = Keyword.pop(opts, :do, humanize(id))
    data = case input_value(f, id) do
      %{months: _, days: _, secs: _} = m -> m
      _ -> %{months: 0, days: 0, secs: 0}
    end
    nf = %Phoenix.HTML.Form{
      id: input_id(f, id),
      name: input_name(f, id),
      #errors: [],
      #source: nil,
      #impl: nil,
      #params: %{},
      data: data,
    }
    ~e"""
    <div class="lower-label-group card">
      <div id="<%= input_id(f, id) %>" class="grouping">
        <%= form_input(nf, :number, :months, required: true, input_opts: [min: 0, max: 999999]) %>
        <%= form_input(nf, :number, :days, required: true, input_opts: [min: 0, max: 999999]) %>
        <%= form_input(nf, :number, :secs, required: true, input_opts: [min: 0, max: 999999]) %>
      </div>
      <%= label f, id, label_do %>
      <%= error_tag f, id %>
    </div>
    """
  end
  def form_input(f, type, id, opts) when type in [:datetime_timezone] do
    {nid, opts} = Keyword.pop(opts, :id, input_id(f, id))
    nid = if(nid == :unique, do: "U#{:erlang.unique_integer()}", else: nid) # TODO
    {label_do, _opts} = Keyword.pop(opts, :do, humanize(id))
    datetime =
      input_value(f, id)
      |> Timex.to_datetime("Etc/UTC") # Take whatever naive time and say what it is
      |> Timex.to_datetime("America/Denver")
      |>throw
  end
  # def form_input(f, :toggle, id, opts) do
  #   {class, opts} = Keyword.pop(opts, :class, "")
  #   opts = Keyword.put(opts, :class, Enum.join(["toggle", class], " "))
  #   form_input(f, :checkbox, id, opts)
  # end
  # def form_input(f, :checkbox, id, opts) do
  #   {left_label, opts} = Keyword.pop(opts, :left_label, nil)
  #   {right_label, opts} = Keyword.pop(opts, :right_label, nil)
  #   {label, opts} = Keyword.pop(opts, :do, humanize(id))
  #   ~e"""
  #   <div class="label-group"><%= left_label %>
  #     <%= checkbox f, id, opts %>
  #     <%= label f, id, "" %><%= label %><%= right_label %>
  #     <%= error_tag f, id %>
  #   </div>
  #   """
  # end
  # def form_input(f, :checkbox, id, opts) do
  #   {label, opts} = Keyword.pop(opts, :do, humanize(id))
  #   ~e"""
  #   <div class="form-group">
  #     <%#= checkbox f, id, opts %>
  #     <%= generic_input :checkbox, f, id, input_opts %>
  #     <%= label f, id, label %>
  #     <%= error_tag f, id %>
  #   </div>
  #   """
  # end
  def form_input(_f, type, id, _opts), do: throw "Unhandled form type of '#{type}' on id: #{id}"


  def alert(id, opts) do
    id = to_string(id)
    dismiss_text = Keyword.get(opts, :dismiss_text, "Dismiss")
    body = Keyword.get(opts, :do, {:unknown, :alert})
    type = Keyword.get(opts, :type, id)
    theme = Keyword.get(opts, :theme, :light)
    class = Keyword.get(opts, :class, "")
    ~E"""
    <div class="alert alert-theme-<%= theme %> alert-<%= type %> <%= class %>">
      <input type="checkbox" id="<%= id %>">
      <label for="<%= id %>"><%= dismiss_text %></label>
      <div><%= body %></div>
    </div>
    """
  end


  def collapsible(unique_id, opts \\ [], [do: body]) do
    title = Keyword.get(opts, :title, humanize(unique_id))
    class = Keyword.get(opts, :class, "")
    expanded = Keyword.get(opts, :expanded, false)
    ~E"""
    <input type="checkbox" id="collapsible-<%= unique_id %>" checked="<%= expanded %>">
    <label for="collapsible-<%= unique_id %>" style="user-select:none;"><%= title %></label>
    <div class="<%= class %> collapsible-<%= unique_id %>-area">
      <%= body %>
    </div>
    """
  end


  ## Basic elements

  def hr(styles \\ []) do
    styles = build_styles(styles)
    tag("hr", style: styles)
  end

  def h(size, opts) when is_list(opts), do: h(size, opts, nil)
  def h(size, value), do: h(size, [], [do: value])
  def h(size, opts, body) when is_integer(size) and size >= 1 and size <= 6 do
    {opt_do, opts} = Keyword.pop(opts, :do, nil)
    value =
      case body do
        [do: value] -> value
        value -> opt_do || value
      end
    name =
      case size do # Why does Phoenix's `content_tag` only take atoms?  >.>
        1 -> :h1
        2 -> :h2
        3 -> :h3
        4 -> :h4
        5 -> :h5
        6 -> :h6
      end
    content_tag(name, opts, do: value)
  end

  def div(opts, [do: body]), do: div([{:do, body} | opts])
  def div(args) do
    {body, args} = Keyword.pop(args, :do, nil)
    content_tag(:div, args, do: body)
  end



  ## Extra Helpers

  defp dasherize_atom_to_string(value) when is_atom(value), do: String.replace(to_string(value), "_", "-")
  defp dasherize_atom_to_string(value), do: to_string(value)

  def build_styles(str) when is_binary(str), do: [str]
  def build_styles([]), do: []
  def build_styles([{key, value} | styles]) do
    key = dasherize_atom_to_string(key)
    value = dasherize_atom_to_string(value)
    [key, ?:, value, ?; | build_styles(styles)]
  end

  def format_date_wrong(%{year: year, month: month, day: day}) do
    year = String.pad_leading(to_string(year), 4, "0")
    month = String.pad_leading(to_string(month), 2, "0")
    day = String.pad_leading(to_string(day), 2, "0")
    "#{month}/#{day}/#{year}"
  end

  def format_time(nil, _resolution), do: ""
  def format_time(ndatetime, resolution) do
    formatter = case resolution do
      formatter when is_binary(formatter) -> formatter
      :second -> "{YYYY}-{M}-{D} {h24}:{m}:{s}"
      :minute -> "{YYYY}-{M}-{D} {h24}:{m}"
      :hour -> "{YYYY}-{M}-{D} {h24}"
    end
    ndatetime
    |> Timex.to_datetime("Etc/UTC") # Take whatever naive time and say what it is
    #|> Timex.Timezone.convert("America/Denver")
    |> Timex.to_datetime("America/Denver") # Then convert it to this timezone
    |> Timex.format!(formatter)
  rescue
    exc ->
      IO.inspect(exc, label: TimeFormatException)
      to_string(ndatetime)
  catch
    err ->
      IO.inspect(err, label: TimeFormatError)
      to_string(ndatetime)
  end



  ## Internal Utility functions

  defp get_csrf_token(path) do
    # {mod, fun, args} = Application.fetch_env!(:phoenix_html, :csrf_token_generator)
    # apply(mod, fun, args)
    Plug.CSRFProtection.get_csrf_token_for(path)
  end

end
