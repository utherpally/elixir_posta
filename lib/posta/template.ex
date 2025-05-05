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
end
