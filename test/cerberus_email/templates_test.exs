defmodule CerberusEmail.TemplatesTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  defp to_html(heex), do: heex |> Phoenix.HTML.Safe.to_iodata() |> IO.iodata_to_binary()

  describe "CerberusEmail.Fluid" do
    import CerberusEmail.Fluid

    test "layout is the 600px fluid shell with fluid head CSS" do
      assigns = %{}
      html = to_html(~H[<.email_layout brand_name="Acme"><.email_spacer /></.email_layout>])

      assert html =~ ~s(<div style="max-width: 600px; margin: 0 auto;" class="email-container">)
      assert html =~ "@media screen and (max-width: 600px)"
      refute html =~ ".stack-column"
    end

    test "1 column text + button: h1 font, 0 20px button cell, optional after_button cell" do
      assigns = %{}

      html =
        to_html(~H"""
        <.email_one_column_text_button heading="Hi" button_text="Go" button_url="https://x.io">
          body
          <:after_button>after</:after_button>
        </.email_one_column_text_button>
        """)

      assert html =~ ~r/<h1 style="margin: 0 0 10px 0; font-family:/
      assert html =~ ~s(<td style="padding: 0 20px;">)
      assert html =~ "after"
    end

    test "2 even columns never stack and reject other counts" do
      assigns = %{}

      html =
        to_html(~H"""
        <.email_columns>
          <:column image_src="a.png" image_alt="A">ta</:column>
          <:column image_src="b.png" image_alt="B">tb</:column>
        </.email_columns>
        """)

      assert [_, _, _] = String.split(html, ~s(<td valign="top" width="50%">))
      assert html =~ "padding: 0 10px 40px 10px;"
      refute html =~ "stack-column"

      assert_raise ArgumentError, fn ->
        to_html(~H"""
        <.email_columns>
          <:column image_src="a" image_alt="a">x</:column>
          <:column image_src="b" image_alt="b">x</:column>
          <:column image_src="c" image_alt="c">x</:column>
        </.email_columns>
        """)
      end
    end

    test "secondary button uses the fluid padding" do
      assigns = %{}
      html = to_html(~H[<.email_secondary_button_row url="https://x.io" text="Help" />])
      assert html =~ "button-td-secondary"
      assert html =~ ~s(<td style="padding: 0 20px;">)
    end
  end

  describe "CerberusEmail.Responsive" do
    import CerberusEmail.Responsive

    test "layout: body table is the 600px container; head has th rule and stacking" do
      assigns = %{}
      html = to_html(~H[<.email_layout brand_name="Acme"><.email_spacer /></.email_layout>])

      assert html =~ ~r/<table align="center"[^>]*width="600"[^>]*class="email-container">/
      assert html =~ "font-weight: normal;"
      assert html =~ "@media screen and (max-width: 600px)"
      assert html =~ ".stack-column"
    end

    test "even columns are th cells with Cerberus responsive image widths" do
      assigns = %{}

      html =
        to_html(~H"""
        <.email_columns>
          <:column image_src="a.png" image_alt="A">ta</:column>
          <:column image_src="b.png" image_alt="B">tb</:column>
          <:column image_src="c.png" image_alt="C">tc</:column>
        </.email_columns>
        """)

      assert [_, _, _, _] =
               String.split(
                 html,
                 ~s(<th valign="top" width="33.33%" class="stack-column-center">)
               )

      assert html =~ "max-width: 170px"
    end

    test "background image uses the v:rect + v:textbox VML at 600px" do
      assigns = %{}

      html =
        to_html(~H"""
        <.email_background_image_text image_url="https://x.io/bg.png?a=1&b=2">text</.email_background_image_text>
        """)

      assert html =~
               "style=\"width:600px;height:175px; background-position: center center !important;\""

      assert html =~
               ~s(<v:fill type="tile" src="https://x.io/bg.png?a=1&amp;b=2" color="#222222" />)

      assert html =~ "background-image: url('https://x.io/bg.png?a=1&amp;b=2')"
    end

    test "thumbnail row: 33.33/66.66 th columns, rtl for right side" do
      assigns = %{}

      html =
        to_html(
          ~H[<.email_thumbnail_row side="right" image_src="t.png" image_alt="T">txt</.email_thumbnail_row>]
        )

      assert html =~ ~s(dir="rtl" width="100%")
      assert html =~ ~s(<th width="66.66%" class="stack-column-center">)
      assert html =~ ~s(width="170" height="170")
    end

    test "hero is 600px" do
      assigns = %{}
      html = to_html(~H[<.email_hero_image src="h.png" alt="H" />])
      assert html =~ ~s(width="600" height="")
    end
  end

  test "unknown template is rejected" do
    assert_raise ArgumentError, fn -> CerberusEmail.Markup.template!(:nope) end
  end
end
