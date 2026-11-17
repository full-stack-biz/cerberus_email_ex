defmodule CerberusEmail.Fluid do
  @moduledoc """
  Phoenix components porting the Cerberus **fluid** email template
  (https://github.com/emailmonday/Cerberus, `cerberus-fluid.html`).

  A 600px layout that shrinks with percentage widths and never reconfigures — Cerberus's pick
  for simple transactional emails and single-column layouts. Its 2 columns stay side by side
  on every screen. Fluid has no 3-column, thumbnail or background-image blocks; use
  `CerberusEmail.Components` (hybrid) for those.

  Layout is Cerberus verbatim; only colors and fonts come from `CerberusEmail.Theme`.

      import CerberusEmail.Fluid

      <.email_layout brand_name="Acme">
        <.email_one_column_text_button heading="Hi" button_text="Go" button_url="https://acme.example.com">
          <p style="margin: 0;">Hello!</p>
        </.email_one_column_text_button>
      </.email_layout>
  """
  use Phoenix.Component

  import CerberusEmail.Markup

  alias CerberusEmail.Components
  alias CerberusEmail.Theme

  @doc "`CerberusEmail.Components.email_layout/1` with `template: :fluid` (600px). Same attrs."
  def email_layout(assigns), do: Components.email_layout(Map.put(assigns, :template, :fluid))

  @doc "Same markup in all Cerberus templates; see `CerberusEmail.Components.email_content_block/1`."
  defdelegate email_content_block(assigns), to: Components

  @doc "Same markup in all Cerberus templates; see `CerberusEmail.Components.email_text_row/1`."
  defdelegate email_text_row(assigns), to: Components

  @doc "Same markup in all Cerberus templates; see `CerberusEmail.Components.email_one_column_text/1`."
  defdelegate email_one_column_text(assigns), to: Components

  @doc "Same markup in all Cerberus templates; see `CerberusEmail.Components.email_spacer/1`."
  defdelegate email_spacer(assigns), to: Components

  @doc """
  Renders a centered Cerberus button row with fluid's `0 20px` cell padding.

  ## Examples

      <.email_button_row url="https://example.com/confirm" text="Confirm Email" />
  """
  attr(:variant, :string, default: "primary", values: ["primary", "secondary"])
  attr(:theme, Theme, default: %Theme{}, doc: "Colors and fonts")
  attr(:url, :string, required: true, doc: "Button destination URL")
  attr(:text, :string, required: true, doc: "Button text (cell padding: fluid's `0 20px`)")
  attr(:primary_color, :string, default: nil, doc: "Overrides theme.primary_color")
  attr(:style, :string, default: nil, doc: "Additional styles on the button link")

  def email_button_row(assigns) do
    assigns = resolve_theme(assigns, [:primary_color])

    ~H"""
    <.button_row
      theme={@theme}
      url={@url}
      text={@text}
      style={@style}
      variant={@variant}
      padding="0 20px"
    />
    """
  end

  @doc "Outlined variant of `email_button_row/1` (same attrs)."
  def email_secondary_button_row(assigns),
    do: email_button_row(Map.put(assigns, :variant, "secondary"))

  @doc """
  Renders Cerberus fluid "1 Column Text + Button": optional heading, text, button, and an
  optional `:after_button` text cell below the button (as in Cerberus fluid).

  ## Examples

      <.email_one_column_text_button heading="Welcome!" button_text="Start" button_url="https://example.com">
        <p style="margin: 0;">Click below to get started.</p>
        <:after_button><p style="margin: 0;">Questions? Just reply.</p></:after_button>
      </.email_one_column_text_button>
  """
  attr(:theme, Theme, default: %Theme{}, doc: "Colors and fonts")
  attr(:heading, :string, default: nil, doc: "Optional heading text")
  attr(:button_text, :string, default: nil, doc: "Button shown only with button_url")
  attr(:button_url, :string, default: nil)
  attr(:primary_color, :string, default: nil, doc: "Overrides theme.primary_color for the button")
  slot(:inner_block, required: true)
  slot(:after_button, doc: "Optional text cell below the button")

  def email_one_column_text_button(assigns) do
    assigns = resolve_theme(assigns, [:primary_color])

    ~H"""
    <.one_column_text_button
      theme={@theme}
      heading={@heading}
      button_text={@button_text}
      button_url={@button_url}
      h1_font={true}
      button_padding="0 20px"
    >
      {render_slot(@inner_block)}
      <:after_button :if={@after_button != []}>{render_slot(@after_button)}</:after_button>
    </.one_column_text_button>
    """
  end

  @doc """
  Renders Cerberus fluid/responsive "Hero Image, Flush" at 600px. Use a 1200px-wide (2x) image.

  ## Examples

      <.email_hero_image src="https://example.com/hero.png" alt="Spring sale" />
  """
  attr(:theme, Theme, default: %Theme{}, doc: "Colors and fonts")
  attr(:src, :string, required: true, doc: "Image URL (1200px wide for retina)")
  attr(:alt, :string, required: true, doc: "Alt text, shown when images are blocked")

  def email_hero_image(assigns) do
    ~H"""
    <.hero_image theme={@theme} src={@src} alt={@alt} width={600} />
    """
  end

  @doc """
  Renders Cerberus fluid "2 Even Columns": two image-above-text columns that stay side by side
  (fluid never stacks). Exactly 2 columns. Use 400px-wide (2x) images.

  ## Examples

      <.email_columns>
        <:column image_src="https://example.com/a.png" image_alt="A"><p style="margin: 0;">A</p></:column>
        <:column image_src="https://example.com/b.png" image_alt="B"><p style="margin: 0;">B</p></:column>
      </.email_columns>
  """
  attr(:theme, Theme, default: %Theme{}, doc: "Colors and fonts")

  slot :column, required: true, doc: "Exactly 2 columns; inner content is the text" do
    attr(:image_src, :string, required: true)
    attr(:image_alt, :string, required: true)
  end

  def email_columns(assigns) do
    case assigns.column do
      [_, _] -> :ok
      cols -> raise ArgumentError, "Cerberus fluid has 2 even columns only, got #{length(cols)}"
    end

    ~H"""
    <!-- 2 Even Columns : BEGIN -->
    <tr>
      <td
        style={"padding: 0 10px 40px 10px; background-color: #{@theme.content_background};"}
        class="darkmode-bg"
      >
        <table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100%">
          <tr>
            <td :for={col <- @column} valign="top" width="50%">
              <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                <tr>
                  <td style="text-align: center; padding: 0 10px;">
                    <img
                      src={col.image_src}
                      width="200"
                      height=""
                      alt={col.image_alt}
                      border="0"
                      style={"width: 100%; max-width: 200px; background: #{@theme.image_placeholder_color}; #{image_text_style(@theme, "15px")}"}
                    />
                  </td>
                </tr>
                <tr>
                  <td style={"text-align: left; #{text_style(@theme)} padding: 10px 10px 0;"}>
                    {render_slot(col)}
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
      </td>
    </tr>
    <!-- 2 Even Columns : END -->
    """
  end
end
