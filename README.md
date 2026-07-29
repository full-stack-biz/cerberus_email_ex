# CerberusEmail

Cross-client-tested responsive email components for Phoenix, built on the [Cerberus](https://tedgoas.github.io/Cerberus/) email framework.

Table-based layout with MSO/Outlook conditional comments and mobile stacking via media queries. Branding (product name, footer, colors, font) is passed as attrs — not hardcoded — so the same components work for any product.

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
| `email_layout` | Outer HTML shell with `<head>`, MSO comments, preview text, header, footer |
| `email_content_block` | White-background content wrapper |
| `email_text_row` | Text row with standard padding and typography |
| `email_button_row` | Centered primary action button |
| `email_secondary_button_row` | Outlined secondary button |
| `email_one_column_text_button` | Combined heading + text + button block |
| `email_one_column_text` | Text-only block |
| `email_spacer` | Vertical spacer |

## Branding attrs (`email_layout`)

| Attr | Default | Description |
|------|---------|-------------|
| `brand_name` | `"App"` | Shown in header and footer |
| `footer_text` | falls back to `brand_name` | Footer line |
| `primary_color` | `"#3b82f6"` | Button/accent color |
| `font_family` | `"'Inter', sans-serif"` | Font stack |
| `preview_text` | `nil` | Preview text shown in email clients |
| `show_header` | `true` | Whether to render the brand name header |

## License

MIT
