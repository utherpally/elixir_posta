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
  def to_swoosh_email(%__MODULE__{} = template) do
    email = Swoosh.Email.new()
    |> Swoosh.Email.subject(template.subject)
    |> Swoosh.Email.to(template.to)
    |> Swoosh.Email.from(template.from)
    |> Swoosh.Email.cc(template.cc)
    |> Swoosh.Email.bcc(template.bcc)
    |> Swoosh.Email.text_body(template.text_body)
    |> Swoosh.Email.html_body(template.html_body)
    |> Swoosh.Email.reply_to(template.reply_to)

    Enum.reduce(template.attachments, email, fn attachment, email -> Swoosh.Email.attachment(email, attachment) end)
  end
end
  
end
