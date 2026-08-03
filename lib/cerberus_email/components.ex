defmodule CerberusEmail.Components do
  @moduledoc """
  Cerberus-based responsive email components for Phoenix.

  Cross-client-tested layout built on the Cerberus email framework (table-based layout,
  MSO/Outlook conditional comments, mobile stacking via media queries). Branding is passed
  as attrs — not hardcoded — so the same components work for any product.
  """
  use Phoenix.Component

  @doc """
  Renders the main email layout with Cerberus styling.

  ## Examples

      <.email_layout brand_name="Acme" footer_text="Acme Inc — acme.example.com" preview_text="Welcome!">
        <.email_content_block>
          <!-- email content here -->
        </.email_content_block>
      </.email_layout>
  """
  attr(:preview_text, :string, default: nil, doc: "Preview text shown in email clients")
  attr(:email_title, :string, default: nil, doc: "Email <title>; falls back to brand_name")
  attr(:show_header, :boolean, default: true, doc: "Whether to show the header with brand name")
  attr(:brand_name, :string, default: "App", doc: "Product name shown in header and footer")

  attr(:footer_text, :any,
    default: nil,
    doc:
      "Footer content; falls back to brand_name. Accepts a string or Phoenix.HTML.raw/1 for HTML."
  )

  attr(:primary_color, :string, default: "#3b82f6", doc: "Button/accent color")

  attr(:font_family, :string,
    default: "'Inter', sans-serif",
    doc: "Font stack used across the email"
  )

  slot(:inner_block, required: true)

  def email_layout(assigns) do
    assigns =
      assigns
      |> assign(:email_title, assigns.email_title || assigns.brand_name)
      |> assign(:footer_text, assigns.footer_text || assigns.brand_name)
      |> assign(:_head_styles, head_styles(assigns.font_family, assigns.primary_color))

    ~H"""
    <!DOCTYPE html>
    <html
      lang="en"
      xmlns="http://www.w3.org/1999/xhtml"
      xmlns:v="urn:schemas-microsoft-com:vml"
      xmlns:o="urn:schemas-microsoft-com:office:office"
    >
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <meta name="x-apple-disable-message-reformatting" />
        <meta name="format-detection" content="telephone=no,address=no,email=no,date=no,url=no" />
        <meta name="color-scheme" content="light" />
        <meta name="supported-color-schemes" content="light" />
        <title>{@email_title}</title>
        {@_head_styles}
      </head>

      <body
        width="100%"
        style="margin: 0; padding: 0 !important; mso-line-height-rule: exactly; background-color: #f8fafc;"
      >
        <center
          role="article"
          aria-roledescription="email"
          lang="en"
          style="width: 100%; background-color: #f8fafc;"
        >
          <!--[if mso | IE]>
      <table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100%" style="background-color: #f8fafc;">
        <tr>
          <td>
      <![endif]-->

          <%= if @preview_text do %>
            <!-- Visually Hidden Preheader Text : BEGIN -->
            <div style="max-height:0; overflow:hidden; mso-hide:all;" aria-hidden="true">
              {@preview_text}
            </div>
            <!-- Visually Hidden Preheader Text : END -->

      <!-- Preview Text Spacing Hack : BEGIN -->
            <div style="display: none; font-size: 1px; line-height: 1px; max-height: 0px; max-width: 0px; opacity: 0; overflow: hidden; mso-hide: all; font-family: sans-serif;">
              &zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;
            </div>
            <!-- Preview Text Spacing Hack : END -->
          <% end %>

          <div style="max-width: 680px; margin: 0 auto;" class="email-container">
            <!--[if mso]>
        <table align="center" role="presentation" cellspacing="0" cellpadding="0" border="0" width="680">
          <tr>
            <td>
        <![endif]-->

        <!-- Email Body : BEGIN -->
            <table
              role="presentation"
              cellspacing="0"
              cellpadding="0"
              border="0"
              width="100%"
              style="margin: auto;"
            >
              <%= if @show_header do %>
                <!-- Email Header : BEGIN -->
                <tr>
                  <td style="padding: 20px 0; text-align: center">
                    <div style="font-family: 'Inter', sans-serif; font-size: 24px; font-weight: 700; color: #1f2937;">
                      {@brand_name}
                    </div>
                  </td>
                </tr>
                <!-- Email Header : END -->
              <% end %>

              {render_slot(@inner_block)}
            </table>
            <!-- Email Body : END -->

        <!-- Email Footer : BEGIN -->
            <table
              role="presentation"
              cellspacing="0"
              cellpadding="0"
              border="0"
              width="100%"
              style="max-width: 680px;"
            >
              <tr>
                <td style="padding: 20px; font-family: 'Inter', sans-serif; font-size: 12px; line-height: 15px; text-align: center; color: #6b7280; font-weight: 400;">
                  {@footer_text}
                </td>
              </tr>
            </table>
            <!-- Email Footer : END -->

        <!--[if mso]>
        </td>
        </tr>
        </table>
        <![endif]-->
          </div>

    <!--[if mso | IE]>
      </td>
      </tr>
      </table>
      <![endif]-->
        </center>
      </body>
    </html>
    """
  end

  @doc """
  Renders a content block with white background for email content.

  ## Examples

      <.email_content_block>
        <.email_text_row>
          <p>Your email content here</p>
        </.email_text_row>
      </.email_content_block>
  """
  slot(:inner_block, required: true)

  def email_content_block(assigns) do
    ~H"""
    <tr>
      <td style="background-color: #ffffff;">
        <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
          {render_slot(@inner_block)}
        </table>
      </td>
    </tr>
    """
  end

  @doc """
  Renders a text content row with standard padding and typography.

  ## Examples

      <.email_text_row>
        <h1 style="margin: 0 0 10px; font-size: 25px; line-height: 30px; color: #333333; font-weight: normal;">
          Welcome!
        </h1>
        <p style="margin: 0 0 10px;">Thank you for joining!</p>
      </.email_text_row>
  """
  attr(:style, :string, default: nil, doc: "Additional inline styles")
  slot(:inner_block, required: true)

  def email_text_row(assigns) do
    base_style =
      "padding: 20px; font-family: 'Inter', sans-serif; font-size: 15px; line-height: 20px; color: #374151;"

    assigns =
      assign(
        assigns,
        :final_style,
        if(assigns.style, do: "#{base_style} #{assigns.style}", else: base_style)
      )

    ~H"""
    <tr>
      <td style={@final_style}>
        {render_slot(@inner_block)}
      </td>
    </tr>
    """
  end

  @doc """
  Renders a button row with centered primary action button.

  ## Examples

      <.email_button_row url="https://example.com/confirm" text="Confirm Email" />
  """
  attr(:url, :string, required: true, doc: "Button destination URL")
  attr(:text, :string, required: true, doc: "Button text")
  attr(:primary_color, :string, default: "#3b82f6", doc: "Button background color")
  attr(:style, :string, default: nil, doc: "Additional button styles")

  def email_button_row(assigns) do
    button_style =
      "background: #{assigns.primary_color}; " <>
        "border: 1px solid #{assigns.primary_color}; " <>
        "font-family: 'Inter', sans-serif; " <>
        "font-size: 16px; " <>
        "line-height: 20px; " <>
        "text-decoration: none; " <>
        "padding: 15px 35px; " <>
        "color: #ffffff; " <>
        "display: block; " <>
        "border-radius: 8px; " <>
        "font-weight: 600; " <>
        "text-align: center;"

    assigns =
      assign(
        assigns,
        :button_style,
        if(assigns.style, do: "#{button_style} #{assigns.style}", else: button_style)
      )

    ~H"""
    <tr>
      <td style="padding: 0 20px 20px;">
        <!-- Button : BEGIN -->
        <table
          align="center"
          role="presentation"
          cellspacing="0"
          cellpadding="0"
          border="0"
          style="margin: auto;"
        >
          <tr>
            <td
              class="button-td button-td-primary"
              style={"border-radius: 8px; background: #{@primary_color};"}
            >
              <a href={@url} class="button-a button-a-primary" style={@button_style}>
                {@text}
              </a>
            </td>
          </tr>
        </table>
        <!-- Button : END -->
      </td>
    </tr>
    """
  end

  @doc """
  Renders a secondary button row with outlined styling.

  ## Examples

      <.email_secondary_button_row url="https://example.com/help" text="Need Help?" />
  """
  attr(:url, :string, required: true, doc: "Button destination URL")
  attr(:text, :string, required: true, doc: "Button text")
  attr(:style, :string, default: nil, doc: "Additional button styles")

  def email_secondary_button_row(assigns) do
    button_style = """
    background: #ffffff; \
    border: 1px solid #d1d5db; \
    font-family: 'Inter', sans-serif; \
    font-size: 16px; \
    line-height: 20px; \
    text-decoration: none; \
    padding: 15px 35px; \
    color: #374151; \
    display: block; \
    border-radius: 8px; \
    font-weight: 600; \
    text-align: center;\
    """

    assigns =
      assign(
        assigns,
        :button_style,
        if(assigns.style, do: "#{button_style} #{assigns.style}", else: button_style)
      )

    ~H"""
    <tr>
      <td style="padding: 0 20px 20px;">
        <!-- Secondary Button : BEGIN -->
        <table
          align="center"
          role="presentation"
          cellspacing="0"
          cellpadding="0"
          border="0"
          style="margin: auto;"
        >
          <tr>
            <td
              class="button-td button-td-secondary"
              style="border-radius: 8px; background: #ffffff; border: 1px solid #d1d5db;"
            >
              <a href={@url} class="button-a button-a-secondary" style={@button_style}>
                {@text}
              </a>
            </td>
          </tr>
        </table>
        <!-- Secondary Button : END -->
      </td>
    </tr>
    """
  end

  @doc """
  Renders a one-column text block with optional heading and button.

  ## Examples

      <.email_one_column_text_button
        heading="Welcome!"
        button_text="Get Started"
        button_url="https://example.com/start">
        <p>Click below to get started.</p>
      </.email_one_column_text_button>
  """
  attr(:heading, :string, default: nil, doc: "Optional heading text")
  attr(:button_text, :string, default: nil, doc: "Button text (button only shown if provided)")
  attr(:button_url, :string, default: nil, doc: "Button URL (required if button_text provided)")

  attr(:primary_color, :string,
    default: "#3b82f6",
    doc: "Button color, passed through to email_button_row"
  )

  slot(:inner_block, required: true)

  def email_one_column_text_button(assigns) do
    ~H"""
    <.email_content_block>
      <.email_text_row>
        <%= if @heading do %>
          <h1 style="margin: 0 0 10px; font-size: 25px; line-height: 30px; color: #333333; font-weight: normal;">
            {@heading}
          </h1>
        <% end %>
        {render_slot(@inner_block)}
      </.email_text_row>
      <%= if @button_text && @button_url do %>
        <.email_button_row url={@button_url} text={@button_text} primary_color={@primary_color} />
      <% end %>
    </.email_content_block>
    """
  end

  @doc """
  Renders a simple one-column text block without buttons.

  ## Examples

      <.email_one_column_text>
        <p>This is a simple text block.</p>
      </.email_one_column_text>
  """
  slot(:inner_block, required: true)

  def email_one_column_text(assigns) do
    ~H"""
    <.email_content_block>
      <.email_text_row>
        {render_slot(@inner_block)}
      </.email_text_row>
    </.email_content_block>
    """
  end

  @doc """
  Renders a spacer for adding vertical space between email sections.

  ## Examples

      <.email_spacer height="20" />
  """
  attr(:height, :string, default: "20", doc: "Height of spacer in pixels")

  def email_spacer(assigns) do
    ~H"""
    <tr>
      <td aria-hidden="true" height={@height} style="font-size: 0px; line-height: 0px;">
        &nbsp;
      </td>
    </tr>
    """
  end

  # HEEx does not interpolate inside <style> or HTML comment blocks, so font_family
  # and primary_color are injected via Elixir string interpolation into a raw HTML string.
  defp head_styles(font_family, primary_color) do
    Phoenix.HTML.raw("""
    <!--[if gte mso 9]>
      <xml>
        <o:OfficeDocumentSettings>
          <o:AllowPNG/>
          <o:PixelsPerInch>96</o:PixelsPerInch>
        </o:OfficeDocumentSettings>
      </xml>
      <![endif]-->

      <!--[if mso]>
      <style>
        * {
          font-family: #{font_family} !important;
        }
      </style>
      <![endif]-->

      <!--[if !mso]><!-->
        <link
          href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap"
          rel="stylesheet"
          type="text/css"
        />
        <!--<![endif]-->

        <style>
          * {
            font-family: #{font_family} !important;
          }

          :root {
            color-scheme: light;
            supported-color-schemes: light;
          }

          html, body {
            margin: 0 auto !important;
            padding: 0 !important;
            height: 100% !important;
            width: 100% !important;
          }

          * {
            -ms-text-size-adjust: 100%;
            -webkit-text-size-adjust: 100%;
          }

          div[style*="margin: 16px 0"] {
            margin: 0 !important;
          }

          #MessageViewBody, #MessageWebViewDiv{
            width: 100% !important;
          }

          table, td {
            mso-table-lspace: 0pt !important;
            mso-table-rspace: 0pt !important;
          }

          table {
            border-spacing: 0 !important;
            border-collapse: collapse !important;
            table-layout: fixed !important;
            margin: 0 auto !important;
          }

          img {
            -ms-interpolation-mode:bicubic;
          }

          a {
            text-decoration: none;
          }

          a[x-apple-data-detectors], .unstyle-auto-detected-links a, .aBn {
            border-bottom: 0 !important;
            cursor: default !important;
            color: inherit !important;
            text-decoration: none !important;
            font-size: inherit !important;
            font-family: inherit !important;
            font-weight: inherit !important;
            line-height: inherit !important;
          }

          .im {
            color: inherit !important;
          }

          .a6S {
            display: none !important;
            opacity: 0.01 !important;
          }

          img.g-img + div {
            display: none !important;
          }

          @media only screen and (min-device-width: 320px) and (max-device-width: 374px) {
            u ~ div .email-container {
              min-width: 320px !important;
            }
          }

          @media only screen and (min-device-width: 375px) and (max-device-width: 413px) {
            u ~ div .email-container {
              min-width: 375px !important;
            }
          }

          @media only screen and (min-device-width: 414px) {
            u ~ div .email-container {
              min-width: 414px !important;
            }
          }

          .button-td, .button-a {
            transition: all 100ms ease-in;
          }

          .button-td-primary:hover, .button-a-primary:hover {
            background: #{primary_color} !important;
            border-color: #{primary_color} !important;
            filter: brightness(0.85);
          }

          @media screen and (max-width: 480px) {
            .stack-column, .stack-column-center {
              display: block !important;
              width: 100% !important;
              max-width: 100% !important;
              direction: ltr !important;
            }

            .stack-column-center {
              text-align: center !important;
            }

            .center-on-narrow {
              text-align: center !important;
              display: block !important;
              margin-left: auto !important;
              margin-right: auto !important;
              float: none !important;
            }

            table.center-on-narrow {
              display: inline-block !important;
            }

            .email-container p {
              font-size: 17px !important;
            }
          }
        </style>
    """)
  end
end
