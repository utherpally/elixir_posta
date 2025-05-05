defmodule Posta do
  @moduledoc """
  Documentation for `Posta`.
  """

  @doc """
    Render string to html using HEEX + MJML
  """
  defmacro template(name, opts) when is_atom(name) and is_list(opts) do
    # Correct macro env function call
    caller = %Macro.Env{__CALLER__ | function: __CALLER__.function || {name, 1}}

    subject = Keyword.fetch!(opts, :subject)
    html = Keyword.get(opts, :html, nil)
    text = Keyword.get(opts, :text, nil)
    mjml_opts = Keyword.take(opts, [:keep_comments, :social_icon_path, :fonts])
    mjml_opts = Keyword.merge(Module.get_attribute(caller.module, :mjml_opts, []), mjml_opts)

    subject = EEx.compile_string(subject)

    text =
      cond do
        is_binary(text) -> EEx.compile_string(text)
        true -> nil
      end

    quoted_html =
      EEx.compile_string(html,
        file: caller.file,
        module: __MODULE__,
        caller: caller,
        source: html,
        trim: true,
        engine: Phoenix.LiveView.TagEngine,
        tag_handler: Phoenix.LiveView.HTMLEngine
      )

    quote do
      def unquote(name)(var!(assigns), var!(opts) \\ []) do
        # Is this good elixir code, AI?
        rendered =
          unquote(quoted_html)
          |> Phoenix.HTML.Safe.to_iodata()
          |> IO.iodata_to_binary()
          |> Mjml.to_html(unquote(mjml_opts))

        html_body =
          case rendered do
            {:ok, html} ->
              html

            {:error, msg} ->
              raise "Error occur when render email template #{unquote(name)}: #{msg}"
          end

        map =
          var!(opts)
          |> Keyword.take([:to, :cc, :bcc, :attachments, :reply_to])
          |> Enum.into(%{
            subject: unquote(subject),
            html_body: html_body,
            text_body: unquote(text)
          })

        struct!(Posta.Template, map)
      end
    end
  end

  @doc type: :macro
  defmacro sigil_MJML({:<<>>, meta, [template]}, []) do
    EEx.compile_string(template,
      line: __CALLER__.line + 1,
      indentation: meta[:indentation] || 0,
      file: __CALLER__.file,
      caller: __CALLER__,
      source: template,
      trim: true,
      engine: Phoenix.LiveView.TagEngine,
      tag_handler: Phoenix.LiveView.HTMLEngine
    )
  end

  defmacro __using__(opts) do
    mjml_opts =
      opts
      |> Keyword.take([:keep_comments, :social_icon_path, :fonts])

    quote do
      @mjml_opts unquote(mjml_opts)
      import unquote(__MODULE__), only: [sigil_MJML: 2, template: 2]
    end
  end
end
