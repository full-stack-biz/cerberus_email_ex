defmodule CerberusEmail.Components do
  @moduledoc """
  Phoenix components porting the Cerberus **hybrid** email template
  (https://github.com/emailmonday/Cerberus, `cerberus-hybrid.html`) — Cerberus's recommendation
  for the widest client support. For the other Cerberus templates use
  `CerberusEmail.Responsive` or `CerberusEmail.Fluid`.

  Layout markup — tables, ghost tables for Outlook, widths, padding, classes — is Cerberus
  verbatim: it is what Cerberus has tested across email clients, so it is not configurable.
  Only colors and fonts come from `CerberusEmail.Theme`. Pass the same theme to every
  component; explicit color attrs override it.
  """
  use Phoenix.Component

  import CerberusEmail.Markup

  alias CerberusEmail.Markup
  alias CerberusEmail.Theme

  @doc """
  Renders the email shell: `<head>` (CSS reset, progressive enhancements, dark mode),
  background, preheader, container, header, footer and optional full-bleed bands.

  `template` selects which Cerberus template the shell and head CSS come from: `:hybrid`
  (680px, default), `:responsive` or `:fluid` (600px). Use the blocks from the matching module
  (`CerberusEmail.Components`, `CerberusEmail.Responsive`, `CerberusEmail.Fluid`), whose
  `email_layout` presets this attr.

  ## Examples

      <.email_layout brand_name="Acme" footer_text="Acme Inc — acme.example.com" preview_text="Welcome!">
        <.email_one_column_text>
          <p style="margin: 0;">Hello</p>
        </.email_one_column_text>
        <:full_bleed background_color="#709f2b">
          <p style="margin: 0;">Edge-to-edge band below the footer.</p>
        </:full_bleed>
      </.email_layout>
  """
  attr(:template, :atom,
    default: :hybrid,
    values: [:hybrid, :responsive, :fluid],
    doc: "Cerberus template"
  )

  attr(:theme, Theme, default: %Theme{}, doc: "Colors and fonts")
  attr(:preview_text, :string, default: nil, doc: "Preview text shown in email clients")
  attr(:email_title, :string, default: nil, doc: "Email <title>; falls back to brand_name")
  attr(:show_header, :boolean, default: true, doc: "Whether to show the header")
  attr(:brand_name, :string, default: "App", doc: "Header text (or logo alt) and footer fallback")

  attr(:logo_src, :string,
    default: nil,
    doc: "Header logo URL; when set, replaces the brand_name text (Cerberus header image)"
  )

  attr(:logo_width, :string, default: "200", doc: "Logo display width (use a 2x image)")
  attr(:logo_height, :string, default: "50", doc: "Logo display height")

  attr(:footer_text, :any,
    default: nil,
    doc:
      "Footer content; falls back to brand_name. Accepts a string or Phoenix.HTML.raw/1 for HTML."
  )

  attr(:primary_color, :string, default: nil, doc: "Overrides theme.primary_color")
  attr(:font_family, :string, default: nil, doc: "Overrides theme.font_family")

  slot(:inner_block, required: true)

  slot :full_bleed, doc: "Edge-to-edge background bands rendered after the footer" do
    attr(:background_color, :string, doc: "Defaults to theme.primary_color")
    attr(:color, :string, doc: "Text color; defaults to #ffffff")
  end

  def email_layout(assigns) do
    assigns =
      assigns
      |> resolve_theme([:primary_color, :font_family])
      |> assign(:email_title, assigns.email_title || assigns.brand_name)
      |> assign(:footer_text, assigns.footer_text || assigns.brand_name)
      |> assign(:width, Markup.template!(assigns.template).width)

    assigns = assign(assigns, :_head_styles, head_styles(assigns.theme, assigns.template))

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
        <meta name="color-scheme" content="light dark" />
        <meta name="supported-color-schemes" content="light dark" />
        <title>{@email_title}</title>
        {@_head_styles}
      </head>
      <body
        width="100%"
        style={"margin: 0; padding: 0 !important; mso-line-height-rule: exactly; background-color: #{@theme.background_color};"}
        class="email-bg"
      >
        <center
          role="article"
          aria-roledescription="email"
          lang="en"
          style={"width: 100%; background-color: #{@theme.background_color};"}
          class="email-bg"
        >
          {mso_ie_open(@theme)}

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

          <%= if @template == :responsive do %>
            <%!-- Responsive: the body table itself is the 600px container (no wrapper div). --%>
            <!-- Email Body : BEGIN -->
            <table
              align="center"
              role="presentation"
              cellspacing="0"
              cellpadding="0"
              border="0"
              width="600"
              style="margin: auto;"
              class="email-container"
            >
              <.header_row
                :if={@show_header}
                theme={@theme}
                brand_name={@brand_name}
                logo_src={@logo_src}
                logo_width={@logo_width}
                logo_height={@logo_height}
              />
              {render_slot(@inner_block)}
            </table>
            <!-- Email Body : END -->

            <!-- Email Footer : BEGIN -->
            <table
              align="center"
              role="presentation"
              cellspacing="0"
              cellpadding="0"
              border="0"
              width="600"
              style="margin: auto;"
              class="footer"
            >
              <.footer_cell theme={@theme} footer_text={@footer_text} />
            </table>
            <!-- Email Footer : END -->
          <% else %>
            <%!-- Hybrid (680px) and fluid (600px): max-width div plus fixed width for Outlook. --%>
            <div style={"max-width: #{@width}px; margin: 0 auto;"} class="email-container">
              {mso_open_table(@width, ~s( align="center"))}

              <!-- Email Body : BEGIN -->
              <table
                align={if @template == :fluid, do: "center"}
                role="presentation"
                cellspacing="0"
                cellpadding="0"
                border="0"
                width="100%"
                style="margin: auto;"
              >
                <.header_row
                  :if={@show_header}
                  theme={@theme}
                  brand_name={@brand_name}
                  logo_src={@logo_src}
                  logo_width={@logo_width}
                  logo_height={@logo_height}
                />
                {render_slot(@inner_block)}
              </table>
              <!-- Email Body : END -->

              <!-- Email Footer : BEGIN -->
              <table
                align={if @template == :fluid, do: "center"}
                role="presentation"
                cellspacing="0"
                cellpadding="0"
                border="0"
                width="100%"
                style={if @template == :fluid, do: "margin: auto;", else: "max-width: 680px;"}
                class="footer"
              >
                <.footer_cell theme={@theme} footer_text={@footer_text} />
              </table>
              <!-- Email Footer : END -->

              <!--[if mso]>
              </td>
              </tr>
              </table>
              <![endif]-->
            </div>
          <% end %>

          <.full_bleed theme={@theme} bands={@full_bleed} width={@width} />

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
  Renders a content block (Cerberus content `<td>` with background) wrapping rows.

  ## Examples

      <.email_content_block>
        <.email_text_row>
          <p style="margin: 0;">Your email content here</p>
        </.email_text_row>
      </.email_content_block>
  """
  attr(:theme, Theme, default: %Theme{}, doc: "Colors and fonts")
  slot(:inner_block, required: true)

  def email_content_block(assigns) do
    ~H"""
    <tr>
      <td style={"background-color: #{@theme.content_background};"} class="darkmode-bg">
        <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
          {render_slot(@inner_block)}
        </table>
      </td>
    </tr>
    """
  end

  @doc """
  Renders a text row (Cerberus 1 Column Text cell). Use inside `email_content_block`.

  ## Examples

      <.email_text_row>
        <p style="margin: 0 0 10px;">Thank you for joining!</p>
      </.email_text_row>
  """
  attr(:theme, Theme, default: %Theme{}, doc: "Colors and fonts")
  attr(:style, :string, default: nil, doc: "Additional inline styles")
  slot(:inner_block, required: true)

  def email_text_row(assigns) do
    assigns =
      assign(
        assigns,
        :final_style,
        join_style("padding: 20px; #{text_style(assigns.theme)}", assigns.style)
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
  Renders a centered primary button row (Cerberus Button). Use inside `email_content_block`.

  ## Examples

      <.email_button_row url="https://example.com/confirm" text="Confirm Email" />
  """
  attr(:theme, Theme, default: %Theme{}, doc: "Colors and fonts")
  attr(:url, :string, required: true, doc: "Button destination URL")
  attr(:text, :string, required: true, doc: "Button text")
  attr(:primary_color, :string, default: nil, doc: "Overrides theme.primary_color")
  attr(:style, :string, default: nil, doc: "Additional styles on the button link")

  def email_button_row(assigns) do
    assigns = resolve_theme(assigns, [:primary_color])

    ~H"""
    <.button_row theme={@theme} url={@url} text={@text} style={@style} padding="0 20px 20px" />
    """
  end

  @doc """
  Renders a centered outlined button row: the Cerberus Button markup with secondary colors.

  ## Examples

      <.email_secondary_button_row url="https://example.com/help" text="Need Help?" />
  """
  attr(:url, :string, required: true, doc: "Button destination URL")
  attr(:text, :string, required: true, doc: "Button text")
  attr(:style, :string, default: nil, doc: "Additional styles on the button link")
  attr(:theme, Theme, default: %Theme{}, doc: "Colors and fonts")

  def email_secondary_button_row(assigns) do
    ~H"""
    <.button_row
      theme={@theme}
      url={@url}
      text={@text}
      style={@style}
      variant="secondary"
      padding="0 20px 20px"
    />
    """
  end

  @doc """
  Renders Cerberus "1 Column Text + Button": optional heading, text and button.

  ## Examples

      <.email_one_column_text_button
        heading="Welcome!"
        button_text="Get Started"
        button_url="https://example.com/start">
        <p style="margin: 0 0 10px;">Click below to get started.</p>
      </.email_one_column_text_button>
  """
  attr(:theme, Theme, default: %Theme{}, doc: "Colors and fonts")
  attr(:heading, :string, default: nil, doc: "Optional heading text")
  attr(:button_text, :string, default: nil, doc: "Button text (button only shown if provided)")
  attr(:button_url, :string, default: nil, doc: "Button URL (required if button_text provided)")
  attr(:primary_color, :string, default: nil, doc: "Overrides theme.primary_color for the button")

  slot(:inner_block, required: true)

  def email_one_column_text_button(assigns) do
    assigns = resolve_theme(assigns, [:primary_color])

    ~H"""
    <.one_column_text_button
      theme={@theme}
      heading={@heading}
      button_text={@button_text}
      button_url={@button_url}
      h1_font={false}
      button_padding="0 20px 20px"
    >
      {render_slot(@inner_block)}
    </.one_column_text_button>
    """
  end

  @doc """
  Renders Cerberus "1 Column Text".

  ## Examples

      <.email_one_column_text>
        <p style="margin: 0 0 10px 0;">This is a simple text block.</p>
      </.email_one_column_text>
  """
  attr(:theme, Theme, default: %Theme{}, doc: "Colors and fonts")
  slot(:inner_block, required: true)

  def email_one_column_text(assigns) do
    ~H"""
    <.email_content_block theme={@theme}>
      <.email_text_row theme={@theme}>
        {render_slot(@inner_block)}
      </.email_text_row>
    </.email_content_block>
    """
  end

  @doc """
  Renders Cerberus "Hero Image, Flush": a full-width image. Use a 1360px-wide (2x) image.

  ## Examples

      <.email_hero_image src="https://example.com/hero.png" alt="Spring sale" />
  """
  attr(:theme, Theme, default: %Theme{}, doc: "Colors and fonts")
  attr(:src, :string, required: true, doc: "Image URL (1360px wide for retina)")
  attr(:alt, :string, required: true, doc: "Alt text, shown when images are blocked")

  def email_hero_image(assigns) do
    ~H"""
    <.hero_image theme={@theme} src={@src} alt={@alt} width={680} />
    """
  end

  @doc """
  Renders Cerberus "Background Image with Text", with the VML fallback for Outlook.

  ## Examples

      <.email_background_image_text image_url="https://example.com/bg.png">
        <p style="margin: 0;">Text over the image.</p>
      </.email_background_image_text>
  """
  attr(:theme, Theme, default: %Theme{}, doc: "Colors and fonts")
  attr(:image_url, :string, required: true, doc: "Background image URL (680px wide)")
  attr(:background_color, :string, default: "#222222", doc: "Fallback color behind the image")
  attr(:color, :string, default: "#ffffff", doc: "Text color")

  attr(:height, :string,
    default: "180px",
    doc: "Image height for Outlook's VML; set to the full height of your image"
  )

  slot(:inner_block, required: true)

  def email_background_image_text(assigns) do
    assigns =
      assign(
        assigns,
        :_vml_open,
        vml_open(assigns.image_url, assigns.background_color, assigns.height)
      )

    ~H"""
    <!-- Background Image with Text : BEGIN -->
    <tr>
      <%!-- Pre-escaped and marked safe so the url('...') quotes stay literal, as in Cerberus. --%>
      <td style={
        Phoenix.HTML.raw(
          "text-align: center; background-image: url('#{escape(@image_url)}'); background-color: #{escape(@background_color)}; background-position: center center !important; background-size: cover !important;"
        )
      }>
        {@_vml_open}
        <div>
          <!--[if mso]>
          <table align="center" role="presentation" border="0" cellspacing="0" cellpadding="0" width="500">
          <tr>
          <td width="500">
          <![endif]-->
          <table
            role="presentation"
            border="0"
            cellpadding="0"
            cellspacing="0"
            width="100%"
            style="max-width:500px; margin: auto;"
          >
            <tr>
              <td style={"text-align: center; padding: 40px 20px; font-family: #{@theme.font_family}; font-size: 15px; line-height: 20px; color: #{@color};"}>
                {render_slot(@inner_block)}
              </td>
            </tr>
          </table>
          <!--[if mso]>
          </td>
          </tr>
          </table>
          <![endif]-->
        </div>
        <!--[if gte mso 9]>
        </v:fill>
        </v:rect>
        </v:image>
        <![endif]-->
      </td>
    </tr>
    <!-- Background Image with Text : END -->
    """
  end

  # Cerberus hybrid "2 Even Columns" / "3 Even Columns" — fixed per count:
  # {Outlook ghost cell width, column div style, image width}
  @even_columns %{
    2 =>
      {330,
       "display:inline-block; margin: 0 -1px; width:100%; min-width:200px; max-width:330px; vertical-align:top;",
       310},
    3 =>
      {220,
       "display:inline-block; margin: 0 -1px; max-width: 220px; min-width:160px; vertical-align:top; width:100%;",
       200}
  }

  @doc """
  Renders Cerberus hybrid "2 Even Columns" or "3 Even Columns": each column is an image above
  text. Columns stack on narrow screens without media queries (hybrid), with ghost tables for
  Outlook. Exactly 2 or 3 columns — the counts Cerberus provides. Use 2x images
  (620px wide for 2 columns, 400px for 3).

  ## Examples

      <.email_columns>
        <:column image_src="https://example.com/a.png" image_alt="A">
          <p style="margin: 0;">Text under image A.</p>
        </:column>
        <:column image_src="https://example.com/b.png" image_alt="B">
          <p style="margin: 0;">Text under image B.</p>
        </:column>
      </.email_columns>
  """
  attr(:theme, Theme, default: %Theme{}, doc: "Colors and fonts")

  slot :column, required: true, doc: "2 or 3 columns; inner content is the text" do
    attr(:image_src, :string, required: true)
    attr(:image_alt, :string, required: true)
  end

  def email_columns(assigns) do
    count = length(assigns.column)

    {cell, div_style, image_px} =
      Map.get(@even_columns, count) ||
        raise ArgumentError, "email_columns supports 2 or 3 columns (Cerberus), got #{count}"

    assigns =
      assign(assigns,
        cell: cell,
        div_style: div_style,
        image_px: image_px,
        columns: Enum.with_index(assigns.column)
      )

    ~H"""
    <!-- Even Columns : BEGIN -->
    <tr>
      <td
        align="center"
        valign="top"
        style={"font-size:0; padding: 10px; background-color: #{@theme.content_background};"}
        class="darkmode-bg"
      >
        {Phoenix.HTML.raw(
          ~s(<!--[if mso]><table role="presentation" border="0" cellspacing="0" cellpadding="0" width="660"><tr><td valign="top" width="#{@cell}"><![endif]-->)
        )}
        <%= for {col, i} <- @columns do %>
          {if i > 0,
            do:
              Phoenix.HTML.raw(
                ~s(<!--[if mso]></td><td valign="top" width="#{@cell}"><![endif]-->)
              )}
          <div style={@div_style} class="stack-column">
            <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
              <tr>
                <td style="padding: 10px;">
                  <table
                    role="presentation"
                    cellspacing="0"
                    cellpadding="0"
                    border="0"
                    width="100%"
                    style="font-size: 14px; text-align: left;"
                  >
                    <tr>
                      <td>
                        <img
                          src={col.image_src}
                          width={@image_px}
                          height=""
                          border="0"
                          alt={col.image_alt}
                          style={"width: 100%; max-width: #{@image_px}px; height: auto; #{image_style(@theme, "20px")}"}
                          class="center-on-narrow"
                        />
                      </td>
                    </tr>
                    <tr>
                      <td
                        style={"#{text_style(@theme)} padding-top: 10px;"}
                        class="stack-column-center"
                      >
                        {render_slot(col)}
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>
            </table>
          </div>
        <% end %>
        <!--[if mso]>
        </td>
        </tr>
        </table>
        <![endif]-->
      </td>
    </tr>
    <!-- Even Columns : END -->
    """
  end

  @doc """
  Renders Cerberus hybrid "Thumbnail Left, Text Right" (`side="left"`) or
  "Thumbnail Right, Text Left" (`side="right"`). Use a 400px-wide (2x) thumbnail.

  ## Examples

      <.email_thumbnail_row
        image_src="https://example.com/t.png"
        image_alt="Thumb"
        heading="Class aptent"
        button_text="Read more"
        button_url="https://example.com"
      >
        <p style="margin: 0 0 10px 0;">Text beside the thumbnail.</p>
      </.email_thumbnail_row>
  """
  attr(:theme, Theme, default: %Theme{}, doc: "Colors and fonts")
  attr(:side, :string, default: "left", values: ["left", "right"], doc: "Thumbnail side")
  attr(:image_src, :string, required: true)
  attr(:image_alt, :string, required: true)
  attr(:heading, :string, default: nil)
  attr(:button_text, :string, default: nil, doc: "Button shown only with button_url")
  attr(:button_url, :string, default: nil)
  slot(:inner_block, required: true)

  def email_thumbnail_row(assigns) do
    ~H"""
    <!-- Thumbnail Row : BEGIN -->
    <tr>
      <td
        style={"font-size:0; padding: 10px; text-align: left; background-color: #{@theme.content_background};"}
        class="darkmode-bg"
      >
        <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
          <tr>
            <td
              dir={if @side == "right", do: "rtl", else: "ltr"}
              height="100%"
              valign="top"
              width="100%"
            >
              <!--[if mso]>
              <table role="presentation" border="0" cellspacing="0" cellpadding="0" width="660" style="width: 660px;">
              <tr>
              <td valign="top" width="220" style="width: 220px;">
              <![endif]-->
              <div
                style="display:inline-block; margin: 0 -1px; max-width: 220px; min-width:160px; vertical-align:top; width:100%;"
                class="stack-column"
              >
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                  <tr>
                    <td dir="ltr" style="padding: 0 10px 10px 10px;">
                      <img
                        src={@image_src}
                        width="200"
                        height=""
                        border="0"
                        alt={@image_alt}
                        class="center-on-narrow"
                        style={"width: 100%; max-width: 200px; height: auto; #{image_style(@theme, "15px")}"}
                      />
                    </td>
                  </tr>
                </table>
              </div>
              <!--[if mso]>
              </td>
              <td valign="top" width="440" style="width: 440px;">
              <![endif]-->
              <div
                style="display:inline-block; margin: 0 -1px; max-width: 440px; min-width:280px; vertical-align:top;"
                class="stack-column"
              >
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                  <tr>
                    <td
                      dir="ltr"
                      style={"#{text_style(@theme)} padding: 10px 10px 0; text-align: left;"}
                      class="center-on-narrow"
                    >
                      <h2
                        :if={@heading}
                        style={"margin: 0 0 10px 0; font-family: #{@theme.font_family}; font-size: 18px; line-height: 22px; color: #{@theme.heading_color}; font-weight: bold;"}
                      >
                        {@heading}
                      </h2>
                      {render_slot(@inner_block)}
                      <%= if @button_text && @button_url do %>
                        <!-- Button : BEGIN -->
                        <table
                          role="presentation"
                          cellspacing="0"
                          cellpadding="0"
                          border="0"
                          class="center-on-narrow"
                          style="float:left;"
                        >
                          <tr>
                            <.button_cell theme={@theme} url={@button_url} text={@button_text} />
                          </tr>
                        </table>
                        <!-- Button : END -->
                      <% end %>
                    </td>
                  </tr>
                </table>
              </div>
              <!--[if mso]>
              </td>
              </tr>
              </table>
              <![endif]-->
            </td>
          </tr>
        </table>
      </td>
    </tr>
    <!-- Thumbnail Row : END -->
    """
  end

  @doc """
  Renders a Cerberus spacer for vertical space between rows.

  ## Examples

      <.email_spacer height="40" />
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

  # HEEx does not interpolate inside HTML comments, so the Outlook VML opener is built as a
  # raw string with escaped values. Markup is Cerberus hybrid verbatim.
  defp vml_open(image_url, background_color, height) do
    url = escape(image_url)
    height = escape(height)

    Phoenix.HTML.raw("""
    <!--[if gte mso 9]>
    <v:image xmlns:v="urn:schemas-microsoft-com:vml" fill="true" stroke="false" style="border: 0; display: inline-block; width: 680px; height: #{height};" src="#{url}" />
    <v:rect xmlns:v="urn:schemas-microsoft-com:vml" fill="true" stroke="false" style="border: 0; display: inline-block; position: absolute; width: 680px; height: #{height};">
    <v:fill opacity="0%" color="#{escape(background_color)}" />
    <![endif]-->
    """)
  end
end
