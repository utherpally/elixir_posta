defmodule PostaTest do
  use ExUnit.Case
  doctest Posta

  use Posta
  use Phoenix.Component

  slot :inner_block, required: true

  def layout(assigns) do
    ~MJML"""
    <mjml>
      <mj-body>
        <mj-section>
          <mj-column>
            {render_slot(@inner_block)}
          </mj-column>
        </mj-section>
      </mj-body>
    </mjml>
    """
  end

  template :test_template,
    subject: "test",
    html: """
      <.layout>
            <mj-text>hello</mj-text>
      </.layout>
    """

  template :simple_text,
    subject: "greet",
    html: """
    <mjml>
      <mj-body>
        <mj-section>
          <mj-column>
            <%= for _ <- 1..10 do %>
            <mj-text>hello</mj-text>
            <% end %>
          </mj-column>
        </mj-section>
      </mj-body>
    </mjml>
    """

  describe "rendering" do
    test "handles text" do
      mail = test_template(%{})
      assert mail.subject == "test"
      assert mail.html_body =~ "hello"
    end
  end
end
