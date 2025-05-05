defmodule Posta.Template do
  defstruct [
    :subject,
    :html_body,
    text_body: nil,
    from: nil,
    to: [],
    cc: [],
    bcc: [],
    attachments: [],
    reply_to: nil
  ]


if Code.loaded?(Swoosh.Email) do
  use Swoosh.Email

  def to_swoosh_email(%__MODULE__{} = template) do
    email = new()
    |> subject(template.subject)
    |> to(template.to)
    |> from(template.from)
    |> cc(template.cc)
    |> bcc(template.bcc)
    |> text_body(template.text_body)
    |> html_body(template.html_body)
    |> reply_to(template.reply_to)

    Enum.reduce(template.attachments, email, fn att, email -> attachment(email, att) end)
  end
end
  
end
