defmodule CerberusEmail.ThemeAndBlocksTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import CerberusEmail.Components

  alias CerberusEmail.Theme

  defp to_html(heex), do: heex |> Phoenix.HTML.Safe.to_iodata() |> IO.iodata_to_binary()

  defp layout(theme) do
    assigns = %{theme: theme}
    to_html(~H[<.email_layout theme={@theme}><.email_spacer /></.email_layout>])
  end

  describe "theme" do
    test "Theme.new/1 rejects unknown keys" do
      assert_raise KeyError, fn -> Theme.new(nope: 1) end
    end

    test "theme reaches inline styles, with no default color or font left" do
      assigns = %{theme: Theme.new(primary_color: "#e11d48", font_family: "Georgia, serif")}

      html =
        to_html(~H"""
        <.email_layout brand_name="Acme" theme={@theme}>
          <.email_one_column_text_button theme={@theme} button_text="Go" button_url="https://x.io">
            <p>hi</p>
          </.email_one_column_text_button>
        </.email_layout>
        """)

      assert html =~ "background: #e11d48"
      assert html =~ "font-family: Georgia, serif"
      refute html =~ "#3b82f6"
      refute html =~ "&#39;Inter&#39;"
    end

    test "explicit attr overrides theme" do
      assigns = %{theme: Theme.new(primary_color: "#e11d48")}

      html =
        to_html(
          ~H[<.email_button_row theme={@theme} primary_color="#00ff00" url="https://x.io" text="Go" />]
        )

      assert html =~ "#00ff00"
      refute html =~ "#e11d48"
    end

    test "button hover falls back to primary_color, or uses button_hover_color" do
      assert layout(Theme.new(primary_color: "#e11d48")) =~ "background: #e11d48 !important"
      assert layout(Theme.new(button_hover_color: "#555555")) =~ "background: #555555 !important"
    end

    test "Outlook gets the safe fallback font, not the web font" do
      html = layout(Theme.new(font_family: "'Lobster', cursive"))
      assert html =~ ~r/\[if mso\]>\s*<style>\s*\* \{\s*font-family: sans-serif !important;/
    end

    test "font_url nil drops the web font link; custom url is escaped" do
      refute layout(Theme.new(font_url: nil)) =~ "<link"

      assert layout(Theme.new(font_url: "https://f.io/a?x=1&y=2")) =~
               ~s(href="https://f.io/a?x=1&amp;y=2")
    end

    test "dark mode styles use theme colors and can be dropped" do
      html = layout(Theme.new(dark_content_background: "#123456"))
      assert html =~ "prefers-color-scheme: dark"
      assert html =~ "background: #123456 !important"
      refute layout(Theme.new(dark_mode: false)) =~ "prefers-color-scheme"
    end

    test "darkmode-muted gets dark_muted_color" do
      assert layout(Theme.new(dark_muted_color: "#777777")) =~
               ~r/\.darkmode-muted \{\s*color: #777777 !important;/
    end

    test "secondary button and text brand name follow dark mode" do
      html = layout(Theme.new(dark_content_background: "#123456"))
      assert html =~ ~r/td\.button-td-secondary a \{\s*background: #123456 !important;/
      assert html =~ ~s(<div class="darkmode-text")
    end

    test "Outlook wrapper and body use theme background" do
      html = layout(Theme.new(background_color: "#101010"))

      assert html =~
               ~s(<!--[if mso | IE]><table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100%" style="background-color: #101010;" class="email-bg">)

      assert html =~ "mso-line-height-rule: exactly; background-color: #101010"
    end
  end

  describe "email_layout header" do
    test "logo_src renders the Cerberus header image with brand_name as alt" do
      assigns = %{}

      html =
        to_html(~H"""
        <.email_layout brand_name="Acme" logo_src="https://x.io/logo.png"><.email_spacer /></.email_layout>
        """)

      assert html =~ ~s(src="https://x.io/logo.png" width="200" height="50" alt="Acme")
      assert html =~ "background: #dddddd"
    end

    test "image_placeholder_color nil drops the image background" do
      assigns = %{theme: Theme.new(image_placeholder_color: nil)}

      html =
        to_html(~H"""
        <.email_layout brand_name="Acme" logo_src="https://x.io/logo.png" theme={@theme}>
          <.email_hero_image theme={@theme} src="https://x.io/h.png" alt="h" />
        </.email_layout>
        """)

      assert html =~ ~s(style="height: auto; font-family:)
      refute html =~ "background: ;"
      refute html =~ "#dddddd"
    end
  end

  describe "email_columns (hybrid)" do
    test "2 columns: 330px inline-block divs, Outlook ghost table, 310px images" do
      assigns = %{}

      html =
        to_html(~H"""
        <.email_columns>
          <:column image_src="a.png" image_alt="A">ta</:column>
          <:column image_src="b.png" image_alt="B">tb</:column>
        </.email_columns>
        """)

      assert html =~
               ~s(<!--[if mso]><table role="presentation" border="0" cellspacing="0" cellpadding="0" width="660"><tr><td valign="top" width="330"><![endif]-->)

      assert [_, _] =
               String.split(html, ~s(<!--[if mso]></td><td valign="top" width="330"><![endif]-->))

      assert [_, _, _] = String.split(html, "min-width:200px; max-width:330px;")
      assert [_, _, _] = String.split(html, "max-width: 310px")
      assert html =~ "font-size:0; padding: 10px;"
    end

    test "3 columns: 220px divs and 200px images" do
      assigns = %{}

      html =
        to_html(~H"""
        <.email_columns>
          <:column image_src="a.png" image_alt="A">ta</:column>
          <:column image_src="b.png" image_alt="B">tb</:column>
          <:column image_src="c.png" image_alt="C">tc</:column>
        </.email_columns>
        """)

      assert [_, _, _, _] = String.split(html, ~s(<td valign="top" width="220">))
      assert [_, _, _, _] = String.split(html, "max-width: 220px; min-width:160px;")
      assert [_, _, _, _] = String.split(html, "max-width: 200px")
    end

    test "rejects column counts Cerberus does not provide" do
      assigns = %{}

      assert_raise ArgumentError, fn ->
        to_html(
          ~H[<.email_columns><:column image_src="a" image_alt="a">x</:column></.email_columns>]
        )
      end
    end
  end

  describe "email_thumbnail_row (hybrid)" do
    test "220/440 columns with ghost table; side sets dir" do
      assigns = %{}

      left =
        to_html(
          ~H[<.email_thumbnail_row image_src="t.png" image_alt="T">txt</.email_thumbnail_row>]
        )

      assert left =~ ~s(dir="ltr" height="100%" valign="top" width="100%")
      assert left =~ ~s(<td valign="top" width="440" style="width: 440px;">)
      assert left =~ "max-width: 440px; min-width:280px;"

      right =
        to_html(
          ~H[<.email_thumbnail_row side="right" image_src="t.png" image_alt="T">txt</.email_thumbnail_row>]
        )

      assert right =~ ~s(dir="rtl" height="100%")
    end

    test "heading and floated Cerberus button only when given" do
      assigns = %{}

      bare =
        to_html(
          ~H[<.email_thumbnail_row image_src="t.png" image_alt="T">txt</.email_thumbnail_row>]
        )

      refute bare =~ "<h2"
      refute bare =~ "button-td"

      full =
        to_html(~H"""
        <.email_thumbnail_row image_src="t.png" image_alt="T" heading="Hi" button_text="Go" button_url="https://x.io">
          txt
        </.email_thumbnail_row>
        """)

      assert full =~ ~r{<h2 [^>]*>\s*Hi\s*</h2>}
      assert full =~ ~s(style="float:left;")
      assert full =~ "padding: 13px 17px"
    end
  end

  describe "email_hero_image" do
    test "renders flush 680px image with alt" do
      assigns = %{}
      html = to_html(~H[<.email_hero_image src="https://x.io/h.png" alt="Sale" />])
      assert html =~ ~s(src="https://x.io/h.png" width="680" height="" alt="Sale")
      assert html =~ "g-img"
      assert html =~ "darkmode-bg"
    end
  end

  describe "email_background_image_text (hybrid)" do
    test "renders v:image + v:rect VML with escaped values and 500px inner table" do
      assigns = %{}

      html =
        to_html(~H"""
        <.email_background_image_text image_url="https://x.io/bg.png?a=1&b=2" height="230px">
          <p>over image</p>
        </.email_background_image_text>
        """)

      assert html =~ "over image"
      assert html =~ ~s(width: 680px; height: 230px;" src="https://x.io/bg.png?a=1&amp;b=2" />)
      assert html =~ ~s(<v:fill opacity="0%" color="#222222" />)
      assert html =~ "max-width:500px; margin: auto;"
      assert html =~ "</v:image>"
    end
  end

  describe "full_bleed slot" do
    test "renders band after footer with its own color and dark mode class" do
      assigns = %{}

      html =
        to_html(~H"""
        <.email_layout brand_name="Acme" footer_text="FOOTER">
          <.email_spacer />
          <:full_bleed background_color="#709f2b">band text</:full_bleed>
        </.email_layout>
        """)

      assert html =~ "background-color: #709f2b"
      assert html =~ "darkmode-fullbleed-bg"
      [_, after_footer] = String.split(html, "FOOTER")
      assert after_footer =~ "band text"
    end
  end
end
