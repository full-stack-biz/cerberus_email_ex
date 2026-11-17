# CerberusEmail

Cross-client-tested email components for Phoenix: a port of all three [Cerberus](https://www.cerberusemail.com/) templates ([source](https://github.com/emailmonday/Cerberus)).

Layout is Cerberus verbatim — tables, Outlook ghost tables, column stacking, dark mode styles — and is not configurable, because its cross-client behavior is what Cerberus has tested. Only colors and fonts are themeable.

## Templates

Import one module; all share component names and the `Theme`.

| Module | Cerberus template | Width | Use when |
|--------|-------------------|-------|----------|
| `CerberusEmail.Components` | hybrid | 680px | Default. Columns stack without media queries, so it works in clients that ignore them (some Gmail apps). Cerberus's pick for widest coverage. |
| `CerberusEmail.Responsive` | responsive | 600px | Media-query layouts; clients without media query support show a shrunk desktop layout. |
| `CerberusEmail.Fluid` | fluid | 600px | Simple transactional / single-column emails. Never reconfigures; 2 columns only, no thumbnails or background images. |

## Installation

```elixir
def deps do
  [
    {:cerberus_email, "~> 0.1"}
  ]
end
```

## Usage

```heex
<.email_layout brand_name="Acme" footer_text="Acme Inc" preview_text="Welcome!">
  <.email_one_column_text_button
    heading="Welcome to Acme"
    button_text="Get Started"
    button_url="https://acme.example.com/start"
  >
    <p style="margin: 0 0 10px;">Click below to get started.</p>
  </.email_one_column_text_button>
</.email_layout>
```

Render to an HTML string for use with a mailer:

```elixir
import CerberusEmail.Components
import Phoenix.Component

html =
  ~H"""
  <.email_layout brand_name="Acme" footer_text="Acme Inc" preview_text="Welcome!">
    <.email_one_column_text>
      <p style="margin: 0;">Hello!</p>
    </.email_one_column_text>
  </.email_layout>
  """
  |> Phoenix.HTML.Safe.to_iodata()
  |> IO.iodata_to_binary()
```

## Components

| Component | Description |
|-----------|-------------|
| `email_layout` | Shell: `<head>` CSS, preheader, 680px container, header (text or `logo_src`), footer |
| `email_content_block` | Content background wrapper |
| `email_text_row` | Text cell (Cerberus 1 Column Text) |
| `email_button_row` | Centered Cerberus button |
| `email_secondary_button_row` | Cerberus button markup in outlined colors |
| `email_one_column_text_button` | 1 Column Text + Button |
| `email_one_column_text` | 1 Column Text |
| `email_spacer` | Spacer |
| `email_columns` | 2 or 3 Even Columns (image + text each); fluid: 2 only |
| `email_thumbnail_row` | Thumbnail Left/Right (`side`) with text, optional heading and button |
| `email_hero_image` | Hero Image, Flush (2x image: 1360px hybrid, 1200px responsive/fluid) |
| `email_background_image_text` | Background Image with Text, with Outlook VML |
| `:full_bleed` slot on `email_layout` | Full Bleed Background Section below the footer |

## Theme

Colors and fonts — including dark mode colors — come from `CerberusEmail.Theme`. Build one and pass it to every component — explicit attrs still override it. `dark_mode: false` drops the dark mode styles; `button_hover_color` sets a visible hover (defaults to `primary_color`):

```elixir
theme = CerberusEmail.Theme.new(primary_color: "#e11d48", font_family: "Georgia, serif", font_url: nil)
```

```heex
<.email_layout brand_name="Acme" theme={@theme}>
  <.email_one_column_text_button theme={@theme} button_text="Go" button_url="https://acme.example.com">
    <p style="margin: 0;">Hello!</p>
  </.email_one_column_text_button>
</.email_layout>
```

## Branding attrs (`email_layout`)

| Attr | Default | Description |
|------|---------|-------------|
| `brand_name` | `"App"` | Shown in header and footer |
| `footer_text` | falls back to `brand_name` | Footer line |
| `logo_src` | `nil` | Header logo image (`logo_width`/`logo_height`, default 200×50) instead of text |
| `primary_color` | `nil` | Overrides `theme.primary_color` |
| `font_family` | `nil` | Overrides `theme.font_family` |
| `preview_text` | `nil` | Preview text shown in email clients |
| `show_header` | `true` | Whether to render the brand name header |

## License

MIT
