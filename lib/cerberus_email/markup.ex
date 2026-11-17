defmodule CerberusEmail.Markup do
  @moduledoc false
  # Markup shared by the Cerberus hybrid, responsive and fluid ports. Every string here is
  # Cerberus verbatim; only colors and fonts are interpolated from the theme.

  use Phoenix.Component

  alias CerberusEmail.Theme

  # Per-template differences in <head> CSS and container width. The order flags keep each
  # template's reset rules in upstream order.
  @templates %{
    hybrid: %{
      width: 680,
      breakpoint: 480,
      th_rule: false,
      container_rule: false,
      stacking: true,
      a_before_img: false,
      a6s_before_im: false
    },
    responsive: %{
      width: 600,
      breakpoint: 600,
      th_rule: true,
      container_rule: true,
      stacking: true,
      a_before_img: true,
      a6s_before_im: false
    },
    fluid: %{
      width: 600,
      breakpoint: 600,
      th_rule: false,
      container_rule: false,
      stacking: false,
      a_before_img: false,
      a6s_before_im: true
    }
  }

  @img_rule "img {\n    -ms-interpolation-mode:bicubic;\n}"
  @a_rule "a {\n    text-decoration: none;\n}"
  @im_rule ".im {\n    color: inherit !important;\n}"
  @a6s_rule ".a6S {\n    display: none !important;\n    opacity: 0.01 !important;\n}"

  defp ordered(first, second, true), do: second <> "\n" <> first
  defp ordered(first, second, false), do: first <> "\n" <> second

  def template!(name) do
    Map.get(@templates, name) ||
      raise ArgumentError, "unknown template #{inspect(name)}; use :hybrid, :responsive or :fluid"
  end

  # Precedence: explicit attr > theme > Theme defaults.
  def resolve_theme(assigns, keys) do
    theme =
      Enum.reduce(keys, assigns.theme, fn key, theme ->
        case assigns[key] do
          nil -> theme
          value -> Map.put(theme, key, value)
        end
      end)

    assign(assigns, :theme, theme)
  end

  def text_style(theme),
    do:
      "font-family: #{theme.font_family}; font-size: 15px; line-height: 20px; color: #{theme.text_color};"

  # Cerberus styles img alt text (shown when images are blocked); line-height varies by block.
  def image_text_style(theme, line_height),
    do:
      "font-family: #{theme.font_family}; font-size: 15px; line-height: #{line_height}; color: #{theme.text_color};"

  def join_style(base, nil), do: base
  def join_style(base, extra), do: "#{base} #{extra}"

  def escape(value), do: value |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string()

  # Inline style with literal quotes (e.g. url('...')): values pre-escaped, then marked safe so
  # HEEx does not turn the quotes into entities.
  def raw_style(style), do: Phoenix.HTML.raw(style)

  @doc false
  # Cerberus Button cell (td + a). Callers supply the wrapping table.
  attr(:theme, Theme, required: true)
  attr(:url, :string, required: true)
  attr(:text, :string, required: true)
  attr(:style, :string, default: nil)
  attr(:variant, :string, default: "primary")

  def button_cell(assigns) do
    t = assigns.theme

    {bg, border, color} =
      case assigns.variant do
        "primary" ->
          {t.primary_color, t.button_border_color || t.primary_color, t.button_text_color}

        "secondary" ->
          {t.content_background, t.border_color, t.text_color}
      end

    assigns =
      assign(assigns,
        bg: bg,
        link_style:
          join_style(
            "background: #{bg}; border: 1px solid #{border}; font-family: #{t.font_family}; " <>
              "font-size: 15px; line-height: 15px; text-decoration: none; padding: 13px 17px; " <>
              "color: #{color}; display: block; border-radius: #{t.border_radius};",
            assigns.style
          )
      )

    ~H"""
    <td
      class={"button-td button-td-#{@variant}"}
      style={"border-radius: #{@theme.border_radius}; background: #{@bg};"}
    >
      <a class={"button-a button-a-#{@variant}"} href={@url} style={@link_style}>{@text}</a>
    </td>
    """
  end

  @doc false
  # Centered Cerberus button row. Padding is "0 20px 20px" (hybrid, responsive) or
  # "0 20px" (fluid).
  attr(:theme, Theme, required: true)
  attr(:url, :string, required: true)
  attr(:text, :string, required: true)
  attr(:style, :string, default: nil)
  attr(:variant, :string, default: "primary")
  attr(:padding, :string, required: true)

  def button_row(assigns) do
    ~H"""
    <tr>
      <td style={"padding: #{@padding};"}>
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
            <.button_cell theme={@theme} url={@url} text={@text} style={@style} variant={@variant} />
          </tr>
        </table>
        <!-- Button : END -->
      </td>
    </tr>
    """
  end

  @doc false
  # Cerberus "1 Column Text + Button". Fluid differs from hybrid/responsive only in the h1
  # carrying font-family and the button cell padding.
  attr(:theme, Theme, required: true)
  attr(:heading, :string, default: nil)
  attr(:button_text, :string, default: nil)
  attr(:button_url, :string, default: nil)
  attr(:h1_font, :boolean, required: true)
  attr(:button_padding, :string, required: true)
  slot(:inner_block, required: true)
  slot(:after_button, doc: "Fluid only: Cerberus's text cell below the button")

  def one_column_text_button(assigns) do
    t = assigns.theme

    h1_style =
      if assigns.h1_font,
        do:
          "margin: 0 0 10px 0; font-family: #{t.font_family}; font-size: 25px; line-height: 30px; color: #{t.heading_color}; font-weight: normal;",
        else:
          "margin: 0 0 10px; font-size: 25px; line-height: 30px; color: #{t.heading_color}; font-weight: normal;"

    assigns = assign(assigns, h1_style: h1_style)

    ~H"""
    <!-- 1 Column Text + Button : BEGIN -->
    <tr>
      <td style={"background-color: #{@theme.content_background};"} class="darkmode-bg">
        <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
          <tr>
            <td style={"padding: 20px; #{text_style(@theme)}"}>
              <h1 :if={@heading} style={@h1_style}>{@heading}</h1>
              {render_slot(@inner_block)}
            </td>
          </tr>
          <.button_row
            :if={@button_text && @button_url}
            theme={@theme}
            url={@button_url}
            text={@button_text}
            padding={@button_padding}
          />
          <tr :if={@after_button != []}>
            <td style={"padding: 20px; #{text_style(@theme)}"}>
              {render_slot(@after_button)}
            </td>
          </tr>
        </table>
      </td>
    </tr>
    <!-- 1 Column Text + Button : END -->
    """
  end

  @doc false
  # Cerberus "Hero Image, Flush" at the template's container width.
  attr(:theme, Theme, required: true)
  attr(:src, :string, required: true)
  attr(:alt, :string, required: true)
  attr(:width, :integer, required: true)

  def hero_image(assigns) do
    ~H"""
    <!-- Hero Image, Flush : BEGIN -->
    <tr>
      <td style={"background-color: #{@theme.content_background};"} class="darkmode-bg">
        <img
          src={@src}
          width={@width}
          height=""
          alt={@alt}
          border="0"
          style={"width: 100%; max-width: #{@width}px; height: auto; background: #{@theme.image_placeholder_color}; #{image_text_style(@theme, "15px")} margin: auto; display: block;"}
          class="g-img"
        />
      </td>
    </tr>
    <!-- Hero Image, Flush : END -->
    """
  end

  @doc false
  # Cerberus header cell: logo image when given, else brand name text.
  attr(:theme, Theme, required: true)
  attr(:brand_name, :string, required: true)
  attr(:logo_src, :string, default: nil)
  attr(:logo_width, :string, required: true)
  attr(:logo_height, :string, required: true)

  def header_row(assigns) do
    ~H"""
    <!-- Email Header : BEGIN -->
    <tr>
      <td style="padding: 20px 0; text-align: center">
        <%= if @logo_src do %>
          <img
            src={@logo_src}
            width={@logo_width}
            height={@logo_height}
            alt={@brand_name}
            border="0"
            style={"height: auto; background: #{@theme.image_placeholder_color}; #{image_text_style(@theme, "15px")}"}
          />
        <% else %>
          <div style={"font-family: #{@theme.font_family}; font-size: 24px; font-weight: 700; color: #{@theme.brand_color};"}>
            {@brand_name}
          </div>
        <% end %>
      </td>
    </tr>
    <!-- Email Header : END -->
    """
  end

  @doc false
  attr(:theme, Theme, required: true)
  attr(:footer_text, :any, required: true)

  def footer_cell(assigns) do
    ~H"""
    <tr>
      <td style={"padding: 20px; font-family: #{@theme.font_family}; font-size: 12px; line-height: 15px; text-align: center; color: #{@theme.muted_color};"}>
        {@footer_text}
      </td>
    </tr>
    """
  end

  @doc false
  # Cerberus "Full Bleed Background Section" bands at the template's container width.
  attr(:theme, Theme, required: true)
  attr(:bands, :list, required: true)
  attr(:width, :integer, required: true)

  def full_bleed(assigns) do
    ~H"""
    <%= for band <- @bands do %>
      <!-- Full Bleed Background Section : BEGIN -->
      <table
        role="presentation"
        cellspacing="0"
        cellpadding="0"
        border="0"
        width="100%"
        style={"background-color: #{band[:background_color] || @theme.primary_color};"}
        class="darkmode-fullbleed-bg"
      >
        <tr>
          <td>
            <div
              align="center"
              style={"max-width: #{@width}px; margin: auto;"}
              class="email-container"
            >
              {mso_open_table(@width, ~s( align="center"))}
              <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                <tr>
                  <td style={"padding: 20px; text-align: left; font-family: #{@theme.font_family}; font-size: 15px; line-height: 20px; color: #{band[:color] || "#ffffff"};"}>
                    {render_slot(band)}
                  </td>
                </tr>
              </table>
              <!--[if mso]>
              </td>
              </tr>
              </table>
              <![endif]-->
            </div>
          </td>
        </tr>
      </table>
      <!-- Full Bleed Background Section : END -->
    <% end %>
    """
  end

  # Outlook-only fixed-width table opener (HEEx can't interpolate inside comments).
  def mso_open_table(width, extra \\ "") do
    Phoenix.HTML.raw(
      ~s(<!--[if mso]><table role="presentation" cellspacing="0" cellpadding="0" border="0" width="#{width}"#{extra}><tr><td><![endif]-->)
    )
  end

  def mso_ie_open(theme) do
    Phoenix.HTML.raw(
      ~s(<!--[if mso | IE]><table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100%" style="background-color: #{escape(theme.background_color)};" class="email-bg"><tr><td><![endif]-->)
    )
  end

  defp font_link(nil), do: ""
  defp font_link(url), do: ~s(<link href="#{escape(url)}" rel="stylesheet" type="text/css">)

  defp dark_mode_styles(%Theme{dark_mode: false}), do: ""

  defp dark_mode_styles(t) do
    """
    /* Dark Mode Styles : BEGIN */
    @media (prefers-color-scheme: dark) {
        .email-bg {
            background: #{t.dark_background_color} !important;
        }
        .darkmode-bg {
            background: #{t.dark_content_background} !important;
        }
        h1,
        h2,
        h3,
        p,
        li,
        .darkmode-text,
        .email-container a:not([class]) {
            color: #{t.dark_text_color} !important;
        }
        td.button-td-primary,
        td.button-td-primary a {
            background: #{t.dark_button_color} !important;
            border-color: #{t.dark_button_color} !important;
            color: #{t.dark_button_text_color} !important;
        }
        td.button-td-primary:hover,
        td.button-td-primary a:hover {
            background: #{t.dark_button_hover_color} !important;
            border-color: #{t.dark_button_hover_color} !important;
        }
        .footer td {
            color: #{t.dark_footer_text_color} !important;
        }
        .darkmode-fullbleed-bg {
            background-color: #{t.dark_full_bleed_background} !important;
        }
    }
    /* Dark Mode Styles : END */
    """
  end

  defp th_rule(true), do: "th {\n    font-weight: normal;\n}"
  defp th_rule(false), do: ""

  defp container_rule(true),
    do: ".email-container {\n    width: 100% !important;\n    margin: auto !important;\n}"

  defp container_rule(false), do: ""

  defp stacking_rules(false), do: ""

  defp stacking_rules(true) do
    """
    .stack-column,
    .stack-column-center {
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
    """
  end

  # Cerberus <head> (explanatory comments dropped). HEEx does not interpolate inside <style>
  # or HTML comments, so theme values go in via string interpolation.
  def head_styles(%Theme{} = t, template) do
    tpl = template!(template)
    hover = t.button_hover_color || t.primary_color

    Phoenix.HTML.raw("""
    <!--[if gte mso 9]>
    <xml>
        <o:OfficeDocumentSettings>
            <o:PixelsPerInch>96</o:PixelsPerInch>
        </o:OfficeDocumentSettings>
    </xml>
    <![endif]-->

    <!-- Web Font / @font-face : BEGIN -->
    <!--[if mso]>
        <style>
            * {
                font-family: #{t.fallback_font_family} !important;
            }
        </style>
    <![endif]-->

    <!--[if !mso]><!-->
    #{font_link(t.font_url)}
    <!--<![endif]-->
    <!-- Web Font / @font-face : END -->

    <!-- CSS Reset : BEGIN -->
    <style>
        :root {
          color-scheme: light dark;
          supported-color-schemes: light dark;
        }
        html,
        body {
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
        table,
        td {
            mso-table-lspace: 0pt !important;
            mso-table-rspace: 0pt !important;
        }
        #{th_rule(tpl.th_rule)}
        table {
            border-spacing: 0 !important;
            border-collapse: collapse !important;
            table-layout: fixed !important;
            margin: 0 auto !important;
        }
        #{ordered(@img_rule, @a_rule, tpl.a_before_img)}
        a[x-apple-data-detectors],
        .unstyle-auto-detected-links a,
        .aBn {
            border-bottom: 0 !important;
            cursor: default !important;
            color: inherit !important;
            text-decoration: none !important;
            font-size: inherit !important;
            font-family: inherit !important;
            font-weight: inherit !important;
            line-height: inherit !important;
        }
        #{ordered(@im_rule, @a6s_rule, tpl.a6s_before_im)}
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
    </style>
    <!-- CSS Reset : END -->

    <!-- Progressive Enhancements : BEGIN -->
    <style>
        .button-td,
        .button-a {
            transition: all 100ms ease-in;
        }
        .button-td-primary:hover,
        .button-a-primary:hover {
            background: #{hover} !important;
            border-color: #{hover} !important;
        }
        @media screen and (max-width: #{tpl.breakpoint}px) {
            #{container_rule(tpl.container_rule)}
            #{stacking_rules(tpl.stacking)}
            .email-container p {
                font-size: 17px !important;
            }
        }
        #{dark_mode_styles(t)}
    </style>
    <!-- Progressive Enhancements : END -->
    """)
  end
end
