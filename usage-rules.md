# CerberusEmail Usage Rules

CerberusEmail is Phoenix function components for HTML email: a port of the three
[Cerberus](https://github.com/emailmonday/Cerberus) templates. The layout (tables, Outlook ghost
tables, widths, padding) is Cerberus verbatim and is what Cerberus has tested across email
clients; it is not configurable. Only colors and fonts are.

## Pick the template

Import one module. They share component names.

- `CerberusEmail.Components` — use this. Cerberus hybrid, 680px. Columns stack without media
  queries, so it works in clients that ignore them (some Gmail apps).
- `CerberusEmail.Responsive` — 600px, stacks with media queries; clients without them show a
  shrunk desktop layout. Same blocks as hybrid.
- `CerberusEmail.Fluid` — 600px single column that only shrinks. For simple transactional mail.
  Has `email_columns` (2 only, never stacks) but no thumbnail or background-image blocks.

Do not mix blocks from one module with another module's `email_layout`.

## Render to a binary

```elixir
import Phoenix.Component
import CerberusEmail.Components

assigns = %{theme: CerberusEmail.Theme.new(primary_color: "#e11d48")}

html =
  ~H"""
  <.email_layout brand_name="Acme" footer_text="Acme Inc" preview_text="Your order shipped" theme={@theme}>
    <.email_one_column_text_button theme={@theme} heading="Shipped" button_text="Track" button_url={@url}>
      <p style="margin: 0 0 10px;">Your order is on its way.</p>
    </.email_one_column_text_button>
  </.email_layout>
  """
  |> Phoenix.HTML.Safe.to_iodata()
  |> IO.iodata_to_binary()
```

## Theme

- Build one `CerberusEmail.Theme.new(opts)` and pass it as `theme={@theme}` to `email_layout`
  **and to every block**. Function components share no context: a block without `theme` uses the
  defaults, whatever the layout was given.
- `Theme.new/1` raises on unknown keys. Fields: `primary_color`, `button_text_color`,
  `button_border_color`, `button_hover_color`, `font_family`, `font_url`,
  `fallback_font_family`, `text_color`, `heading_color`, `brand_color`, `muted_color`,
  `border_color`, `background_color`, `content_background`, `image_placeholder_color`,
  `border_radius`, `dark_mode`, and `dark_*` colors.
- Precedence: a component's explicit attr (`primary_color`, `font_family`) > theme > defaults.
- `font_url` defaults to Google Fonts Inter; set `font_url: nil` (and a system `font_family`)
  to load no web font. Windows Outlook always gets `fallback_font_family` (default `sans-serif`).
- Dark mode styles are on by default (`color-scheme: light dark`). `dark_mode: false` removes
  them; colors under dark mode come from the `dark_*` fields.
- `image_placeholder_color` (default `#dddddd`) is the background every image shows while
  blocked or loading. A transparent logo shows it as a box; set `image_placeholder_color: nil`
  to drop it so the page color shows through in light and dark mode.
- `button_hover_color` defaults to `primary_color` (no visible hover); set it for one.

## Blocks

Blocks are `<tr>` rows and go directly inside `email_layout` (or `email_content_block`).

| Component | Use |
|---|---|
| `email_one_column_text` | text block |
| `email_one_column_text_button` | `heading`, text, optional `button_text` + `button_url` (fluid: optional `:after_button` slot) |
| `email_content_block` + `email_text_row` / `email_button_row` / `email_secondary_button_row` | compose a block from rows; `email_text_row`/button rows take `style` to append inline CSS |
| `email_columns` | `:column` slots with `image_src`, `image_alt`; exactly 2 or 3 (fluid: 2), otherwise `ArgumentError` |
| `email_thumbnail_row` | `image_src`, `image_alt`, `side` (`"left"`/`"right"`), optional `heading`, button |
| `email_hero_image` | `src`, `alt`; use a 2x image (1360px hybrid, 1200px responsive/fluid) |
| `email_background_image_text` | `image_url`, `background_color`, `color`, `height` (VML height for Outlook: set to the image's height) |
| `email_spacer` | `height` in px |

`email_layout` attrs: `brand_name`, `footer_text` (string or `Phoenix.HTML.raw/1`),
`preview_text`, `email_title`, `show_header`, `logo_src`/`logo_width`/`logo_height` (logo image
instead of brand text), `theme`, `template`; slot `:full_bleed` (edge-to-edge band below the
footer, attrs `background_color`, `color`).

## Content

- Write text as `<p style="margin: 0 0 10px;">`, `<h1 style="margin: 0 0 10px;">`, lists with
  inline margins. Email clients add default margins; Cerberus zeroes them inline. Don't rely on
  `<style>` or CSS inheritance across tables (Outlook resets fonts and colors per table).
- Images: PNG/JPG/GIF, never SVG; always `alt` (`alt=""` for decorative); absolute `https://`
  URLs; 2x the display size.
- Do not build your own layout tables, flex or grid inside blocks, and do not override block
  widths or padding through `style`. If a layout isn't covered, it is not a tested Cerberus
  pattern.
- Content is escaped by HEEx; pass trusted HTML with `Phoenix.HTML.raw/1` only.
- No CSS inliner is needed (Cerberus advises against one): styles are already inline.

## Testing

Rendering proves nothing about how Gmail, Outlook or Apple Mail show the email. Send changed
templates through Litmus or Email on Acid before shipping.

When asserting on the rendered binary, remember HEEx escapes quotes inside attributes: the
default font renders as `font-family: &#39;Inter&#39;, sans-serif` in inline `style`s (valid HTML;
clients decode it). Assert on the escaped form, on a theme value without quotes (a color), or on
the font link (`fonts.googleapis.com/css2?family=Inter`) instead of the literal `'Inter'`.
