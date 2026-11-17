defmodule CerberusEmail.Responsive do
  @moduledoc """
  Phoenix components porting the Cerberus **responsive** email template
  (https://github.com/emailmonday/Cerberus, `cerberus-responsive.html`).

  A 600px layout that reconfigures with media queries. Cerberus notes it works on *some*
  mobile clients: clients without media query or `<style>` support (some Gmail and Yahoo
  versions, several international clients) show a shrunk desktop layout. Prefer
  `CerberusEmail.Components` (hybrid) for the widest coverage.

  Layout is Cerberus verbatim; only colors and fonts come from `CerberusEmail.Theme`.

      import CerberusEmail.Responsive

      <.email_layout brand_name="Acme">
        <.email_one_column_text><p style="margin: 0;">Hello!</p></.email_one_column_text>
      </.email_layout>
  """
  use Phoenix.Component

  import CerberusEmail.Markup

  alias CerberusEmail.Components
  alias CerberusEmail.Theme

  @doc "`CerberusEmail.Components.email_layout/1` with `template: :responsive` (600px). Same attrs."
  def email_layout(assigns),
    do: Components.email_layout(Map.put(assigns, :template, :responsive))

  @doc "Same markup as hybrid; see `CerberusEmail.Components.email_content_block/1`."
  defdelegate email_content_block(assigns), to: Components

  @doc "Same markup as hybrid; see `CerberusEmail.Components.email_text_row/1`."
  defdelegate email_text_row(assigns), to: Components

  @doc "Same markup as hybrid; see `CerberusEmail.Components.email_button_row/1`."
  defdelegate email_button_row(assigns), to: Components

  @doc "Same markup as hybrid; see `CerberusEmail.Components.email_secondary_button_row/1`."
  defdelegate email_secondary_button_row(assigns), to: Components

  @doc "Same markup as hybrid; see `CerberusEmail.Components.email_one_column_text_button/1`."
  defdelegate email_one_column_text_button(assigns), to: Components

  @doc "Same markup as hybrid; see `CerberusEmail.Components.email_one_column_text/1`."
  defdelegate email_one_column_text(assigns), to: Components

  @doc "Same markup as hybrid; see `CerberusEmail.Components.email_spacer/1`."
  defdelegate email_spacer(assigns), to: Components

  @doc "Same 600px markup as fluid; see `CerberusEmail.Fluid.email_hero_image/1`."
  defdelegate email_hero_image(assigns), to: CerberusEmail.Fluid

  @doc """
  Renders Cerberus responsive "Background Image with Text", with the VML fallback for Outlook.

  ## Examples

      <.email_background_image_text image_url="https://example.com/bg.png">
        <p style="margin: 0;">Text over the image.</p>
      </.email_background_image_text>
  """
  attr(:theme, Theme, default: %Theme{}, doc: "Colors and fonts")
  attr(:image_url, :string, required: true, doc: "Background image URL (600px wide)")
  attr(:background_color, :string, default: "#222222", doc: "Fallback color behind the image")
  attr(:color, :string, default: "#ffffff", doc: "Text color")

  attr(:height, :string,
    default: "175px",
    doc: "Block height in Outlook (VML needs a fixed size)"
  )

  slot(:inner_block, required: true)

  def email_background_image_text(assigns) do
    url = escape(assigns.image_url)
    bg = escape(assigns.background_color)

    assigns =
      assign(assigns,
        td_style:
          raw_style(
            "text-align: center; background-image: url('#{url}'); background-color: #{bg}; background-position: center center !important; background-size: cover !important;"
          ),
        vml_open:
          Phoenix.HTML.raw("""
          <!--[if gte mso 9]>
          <v:rect xmlns:v="urn:schemas-microsoft-com:vml" fill="true" stroke="false" style="width:600px;height:#{escape(assigns.height)}; background-position: center center !important;">
          <v:fill type="tile" src="#{url}" color="#{bg}" />
          <v:textbox inset="0,0,0,0">
          <![endif]-->
          """)
      )

    ~H"""
    <!-- Background Image with Text : BEGIN -->
    <tr>
      <td valign="middle" style={@td_style}>
        {@vml_open}
        <div>
          <table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
              <td
                valign="middle"
                style={"text-align: center; padding: 40px; font-family: #{@theme.font_family}; font-size: 15px; line-height: 20px; color: #{@color};"}
              >
                {render_slot(@inner_block)}
              </td>
            </tr>
          </table>
        </div>
        <!--[if gte mso 9]>
        </v:textbox>
        </v:rect>
        <![endif]-->
      </td>
    </tr>
    <!-- Background Image with Text : END -->
    """
  end

  @doc """
  Renders Cerberus responsive "2 Even Columns" or "3 Even Columns": each column is an image
  above text, stacking via media queries. Exactly 2 or 3 columns. Use 2x images (540px wide
  for 2 columns, 340px for 3).

  ## Examples

      <.email_columns>
        <:column image_src="https://example.com/a.png" image_alt="A"><p style="margin: 0;">A</p></:column>
        <:column image_src="https://example.com/b.png" image_alt="B"><p style="margin: 0;">B</p></:column>
      </.email_columns>
  """
  attr(:theme, Theme, default: %Theme{}, doc: "Colors and fonts")

  slot :column, required: true, doc: "2 or 3 th columns; inner content is the text" do
    attr(:image_src, :string, required: true, doc: "540px wide (2 cols) or 340px (3 cols)")
    attr(:image_alt, :string, required: true)
  end

  def email_columns(assigns) do
    {width, image_px} =
      case length(assigns.column) do
        2 -> {"50%", 270}
        3 -> {"33.33%", 170}
        n -> raise ArgumentError, "email_columns supports 2 or 3 columns (Cerberus), got #{n}"
      end

    assigns = assign(assigns, width: width, image_px: image_px)

    ~H"""
    <!-- Even Columns : BEGIN -->
    <tr>
      <td style={"padding: 10px; background-color: #{@theme.content_background};"} class="darkmode-bg">
        <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
          <tr>
            <%= for col <- @column do %>
              <!-- Column : BEGIN -->
              <th valign="top" width={@width} class="stack-column-center">
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                  <tr>
                    <td style="padding: 10px; text-align: center">
                      <img
                        src={col.image_src}
                        width={@image_px}
                        height=""
                        alt={col.image_alt}
                        border="0"
                        style={"width: 100%; max-width: #{@image_px}px; height: auto; background: #{@theme.image_placeholder_color}; #{image_text_style(@theme, "15px")}"}
                      />
                    </td>
                  </tr>
                  <tr>
                    <td
                      style={"#{text_style(@theme)} padding: 0 10px 10px; text-align: left;"}
                      class="center-on-narrow"
                    >
                      {render_slot(col)}
                    </td>
                  </tr>
                </table>
              </th>
              <!-- Column : END -->
            <% end %>
          </tr>
        </table>
      </td>
    </tr>
    <!-- Even Columns : END -->
    """
  end

  @doc """
  Renders Cerberus responsive "Thumbnail Left, Text Right" (`side="left"`) or
  "Thumbnail Right, Text Left" (`side="right"`). Use a 340px-wide (2x) thumbnail.

  ## Examples

      <.email_thumbnail_row image_src="https://example.com/t.png" image_alt="Thumb" heading="Title">
        <p style="margin: 0 0 10px 0;">Text beside the thumbnail.</p>
      </.email_thumbnail_row>
  """
  attr(:image_src, :string, required: true)
  attr(:image_alt, :string, required: true)
  attr(:side, :string, default: "left", values: ["left", "right"], doc: "Thumbnail side")
  attr(:heading, :string, default: nil)
  attr(:button_url, :string, default: nil)
  attr(:button_text, :string, default: nil, doc: "Button shown only with button_url")
  attr(:theme, Theme, default: %Theme{}, doc: "Colors and fonts")
  slot(:inner_block, required: true)

  def email_thumbnail_row(assigns) do
    ~H"""
    <!-- Thumbnail Row : BEGIN -->
    <tr>
      <td
        dir={if @side == "right", do: "rtl", else: "ltr"}
        width="100%"
        style={"padding: 10px; background-color: #{@theme.content_background};"}
        class="darkmode-bg"
      >
        <table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100%">
          <tr>
            <!-- Column : BEGIN -->
            <th width="33.33%" class="stack-column-center">
              <table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr>
                  <td dir="ltr" valign="top" style="padding: 0 10px;">
                    <img
                      src={@image_src}
                      width="170"
                      height="170"
                      alt={@image_alt}
                      border="0"
                      class="center-on-narrow"
                      style={"height: auto; background: #{@theme.image_placeholder_color}; #{image_text_style(@theme, "15px")}"}
                    />
                  </td>
                </tr>
              </table>
            </th>
            <!-- Column : END -->
            <!-- Column : BEGIN -->
            <th width="66.66%" class="stack-column-center">
              <table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr>
                  <td
                    dir="ltr"
                    valign="top"
                    style={"#{text_style(@theme)} padding: 10px; text-align: left;"}
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
            </th>
            <!-- Column : END -->
          </tr>
        </table>
      </td>
    </tr>
    <!-- Thumbnail Row : END -->
    """
  end
end
