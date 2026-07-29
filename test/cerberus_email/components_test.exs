defmodule CerberusEmail.ComponentsTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import CerberusEmail.Components

  defp to_html(heex) do
    heex |> Phoenix.HTML.Safe.to_iodata() |> IO.iodata_to_binary()
  end

  describe "email_layout" do
    test "renders brand_name in header and footer" do
      assigns = %{}

      html =
        to_html(~H"""
        <.email_layout brand_name="Acme">
          <.email_text_row>hello</.email_text_row>
        </.email_layout>
        """)

      assert html =~ "Acme"
    end

    test "footer_text overrides brand_name in footer" do
      assigns = %{}

      html =
        to_html(~H"""
        <.email_layout brand_name="Acme" footer_text="Acme Inc — acme.example.com">
          <.email_text_row>hello</.email_text_row>
        </.email_layout>
        """)

      assert html =~ "Acme Inc — acme.example.com"
    end

    test "email_title falls back to brand_name" do
      assigns = %{}

      html =
        to_html(~H"""
        <.email_layout brand_name="Acme">
          <.email_text_row>hello</.email_text_row>
        </.email_layout>
        """)

      assert html =~ "<title>Acme</title>"
    end

    test "email_title can be set explicitly" do
      assigns = %{}

      html =
        to_html(~H"""
        <.email_layout brand_name="Acme" email_title="Custom Title">
          <.email_text_row>hello</.email_text_row>
        </.email_layout>
        """)

      assert html =~ "<title>Custom Title</title>"
    end

    test "renders preview_text when set" do
      assigns = %{}

      html =
        to_html(~H"""
        <.email_layout brand_name="Acme" preview_text="Check this out">
          <.email_text_row>hello</.email_text_row>
        </.email_layout>
        """)

      assert html =~ "Check this out"
    end

    test "omits preview_text div when nil" do
      assigns = %{}

      html =
        to_html(~H"""
        <.email_layout brand_name="Acme">
          <.email_text_row>hello</.email_text_row>
        </.email_layout>
        """)

      refute html =~ "mso-hide:all"
    end

    test "hides header when show_header is false" do
      assigns = %{}

      html =
        to_html(~H"""
        <.email_layout brand_name="Acme" show_header={false}>
          <.email_text_row>hello</.email_text_row>
        </.email_layout>
        """)

      refute html =~ "font-size: 24px"
    end

    test "primary_color appears in hover CSS" do
      assigns = %{}

      html =
        to_html(~H"""
        <.email_layout brand_name="Acme" primary_color="#ff0000">
          <.email_text_row>hello</.email_text_row>
        </.email_layout>
        """)

      assert html =~ "#ff0000"
    end

    test "renders outer table structure" do
      assigns = %{}

      html =
        to_html(~H"""
        <.email_layout brand_name="Acme">
          <.email_text_row>hello</.email_text_row>
        </.email_layout>
        """)

      assert html =~ ~s(role="presentation")
      assert html =~ "email-container"
    end
  end

  describe "email_content_block" do
    test "renders white background td with content" do
      assigns = %{}

      html =
        to_html(
          ~H"<.email_content_block><.email_text_row>content</.email_text_row></.email_content_block>"
        )

      assert html =~ "background-color: #ffffff"
      assert html =~ "content"
    end
  end

  describe "email_text_row" do
    test "renders content with base padding style" do
      assigns = %{}
      html = to_html(~H"<.email_text_row>my text</.email_text_row>")
      assert html =~ "my text"
      assert html =~ "padding: 20px"
    end

    test "appends custom style" do
      assigns = %{}
      html = to_html(~H[<.email_text_row style="color: red;">text</.email_text_row>])
      assert html =~ "color: red"
      assert html =~ "padding: 20px"
    end
  end

  describe "email_button_row" do
    test "renders link with url and text" do
      assigns = %{}
      html = to_html(~H[<.email_button_row url="https://example.com" text="Click me" />])
      assert html =~ ~s(href="https://example.com")
      assert html =~ "Click me"
    end

    test "primary_color applied to button background" do
      assigns = %{}

      html =
        to_html(
          ~H[<.email_button_row url="https://example.com" text="Go" primary_color="#ff0000" />]
        )

      assert html =~ "#ff0000"
    end
  end

  describe "email_secondary_button_row" do
    test "renders outlined button with url and text" do
      assigns = %{}
      html = to_html(~H[<.email_secondary_button_row url="https://example.com" text="Help" />])
      assert html =~ ~s(href="https://example.com")
      assert html =~ "Help"
      assert html =~ "button-td-secondary"
    end
  end

  describe "email_one_column_text_button" do
    test "renders heading, content, and button" do
      assigns = %{}

      html =
        to_html(~H"""
        <.email_one_column_text_button
          heading="Hello"
          button_text="Go"
          button_url="https://example.com"
        >
          <p>body text</p>
        </.email_one_column_text_button>
        """)

      assert html =~ "Hello"
      assert html =~ "body text"
      assert html =~ "Go"
      assert html =~ "https://example.com"
    end

    test "omits button when button_text is nil" do
      assigns = %{}

      html =
        to_html(~H"""
        <.email_one_column_text_button heading="Hello">
          <p>body text</p>
        </.email_one_column_text_button>
        """)

      refute html =~ "button-td"
    end

    test "omits heading when not set" do
      assigns = %{}

      html =
        to_html(~H"""
        <.email_one_column_text_button button_text="Go" button_url="https://example.com">
          <p>body text</p>
        </.email_one_column_text_button>
        """)

      refute html =~ "font-size: 25px"
    end
  end

  describe "email_one_column_text" do
    test "renders content inside white block" do
      assigns = %{}
      html = to_html(~H"<.email_one_column_text><p>hello</p></.email_one_column_text>")
      assert html =~ "hello"
      assert html =~ "background-color: #ffffff"
    end
  end

  describe "email_spacer" do
    test "renders with default height 20" do
      assigns = %{}
      html = to_html(~H"<.email_spacer />")
      assert html =~ ~s(height="20")
    end

    test "renders with custom height" do
      assigns = %{}
      html = to_html(~H[<.email_spacer height="40" />])
      assert html =~ ~s(height="40")
    end
  end
end
