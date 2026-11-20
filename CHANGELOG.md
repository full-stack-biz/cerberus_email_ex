# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.4] - 2026-11-20

### Added

- `Theme` `dark_muted_color` (default `#aaaaaa`) and the `darkmode-muted` class: muted text
  (e.g. a grey note in a `p`) keeps a muted color in dark mode instead of turning
  `dark_text_color` like body text.
- `usage-rules.md` documents Cerberus's `darkmode-text` class for text outside `p`, `li` and
  `h1`–`h3`.

### Changed

- Dark mode: the secondary button gets `dark_content_background`, a `dark_muted_color` border
  and `dark_text_color` text instead of staying a white box.
- Dark mode: the text brand name (header without `logo_src`) gets `dark_text_color` instead of
  staying `brand_color`, which was near-invisible on the dark background.

## [0.2.3] - 2026-11-20

### Added

- `Theme` `image_placeholder_color: nil` drops the placeholder `background` from every image
  (header logo, hero, columns, thumbnails), so a transparent logo shows the page color in light
  and dark mode instead of a `#dddddd` box. The default is unchanged.

## [0.2.2] - 2026-11-18

### Changed

- `usage-rules.md`: testing note that HEEx renders quotes in inline styles as `&#39;`
  (`font-family: &#39;Inter&#39;, sans-serif`), and what to assert on instead.

## [0.2.1] - 2026-11-17

### Added

- `usage-rules.md` in the package: how to pick a template, pass the theme to every component,
  and write content, for coding agents in projects that depend on cerberus_email.

## [0.2.0] - 2026-11-17

### Added

- `CerberusEmail.Theme`: colors, fonts and dark mode colors in one struct, passed to every
  component as `theme={@theme}`. Explicit color attrs (`primary_color`, `font_family`) still
  override it. `font_url: nil` drops the web font link; `dark_mode: false` drops the dark mode
  styles; `button_hover_color` sets the button hover color.
- `CerberusEmail.Responsive` and `CerberusEmail.Fluid`: ports of the Cerberus responsive and
  fluid templates (600px), with the same component names as `CerberusEmail.Components`.
- `email_layout` attr `template` (`:hybrid` default, `:responsive`, `:fluid`); the modules above
  preset it.
- `email_layout` attrs `logo_src`, `logo_width`, `logo_height` (Cerberus header image instead
  of the brand name text) and slot `:full_bleed` (edge-to-edge band below the footer).
- Blocks: `email_columns` (2 or 3 even columns, image above text), `email_thumbnail_row`
  (thumbnail left or right, with optional heading and button), `email_hero_image`,
  `email_background_image_text` (with the Outlook VML fallback).
- Fluid `email_one_column_text_button` slot `:after_button` (the text cell Cerberus fluid puts
  below the button).

### Changed

- `CerberusEmail.Components` is now the Cerberus hybrid template verbatim: head CSS, 680px
  container, Outlook ghost tables, and columns that stack without media queries. Only colors and
  fonts are configurable.
- Buttons use Cerberus sizing: 15px text, `13px 17px` padding, 4px radius (was 16px,
  `15px 35px`, 8px). Hover uses `button_hover_color` (default: `primary_color`) instead of a
  brightness filter.
- Dark mode styles are included (`color-scheme: light dark`); the layout previously forced light.
- Windows Outlook gets the theme's `fallback_font_family` (default `sans-serif`) instead of the
  web font, as Cerberus does; the extra `* { font-family: … !important }` rule for other clients
  is removed.
- `primary_color` and `font_family` attrs default to `nil` and override the theme.

### Fixed

- `email_layout`'s `primary_color` and `font_family` did not reach the components inside it:
  buttons stayed `#3b82f6` and inline styles stayed Inter unless set on each component.

### Removed

- The `AllowPNG` Outlook document setting and the footer's `font-weight`, which are not in
  Cerberus.

[0.2.4]: https://github.com/full-stack-biz/cerberus_email_ex/compare/v0.2.3...v0.2.4
[0.2.3]: https://github.com/full-stack-biz/cerberus_email_ex/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/full-stack-biz/cerberus_email_ex/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/full-stack-biz/cerberus_email_ex/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/full-stack-biz/cerberus_email_ex/compare/v0.1.2...v0.2.0
