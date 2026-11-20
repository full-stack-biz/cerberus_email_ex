defmodule CerberusEmail.Theme do
  @moduledoc """
  Colors and fonts for all components.

  Only colors and fonts are themeable — layout (structure, widths, padding, sizes) is the
  Cerberus hybrid template verbatim and is not configurable.

  Build one theme and pass it to every component as `theme={@theme}`. Explicit attrs on a
  component (e.g. `primary_color`) override the theme, which overrides these defaults:

      theme = CerberusEmail.Theme.new(primary_color: "#e11d48", font_family: "Georgia, serif", font_url: nil)

      <.email_layout brand_name="Acme" theme={theme}>
        <.email_one_column_text_button theme={theme} button_text="Go" button_url="...">
          ...
        </.email_one_column_text_button>
      </.email_layout>

  Phoenix function components share no context, so the theme has to be passed explicitly.

  `nil` button colors fall back to `primary_color`. Dark mode colors apply in clients that
  support `prefers-color-scheme`; set `dark_mode: false` to drop the dark mode styles
  (Cerberus documents this as safe to remove).

  `image_placeholder_color` is the background images show while blocked or loading;
  `nil` drops it, so transparent images (a logo) show the page color in light and dark mode.
  """

  defstruct primary_color: "#3b82f6",
            button_text_color: "#ffffff",
            button_border_color: nil,
            button_hover_color: nil,
            font_family: "'Inter', sans-serif",
            font_url:
              "https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap",
            fallback_font_family: "sans-serif",
            text_color: "#374151",
            heading_color: "#333333",
            brand_color: "#1f2937",
            muted_color: "#6b7280",
            border_color: "#d1d5db",
            background_color: "#f8fafc",
            content_background: "#ffffff",
            image_placeholder_color: "#dddddd",
            border_radius: "4px",
            dark_mode: true,
            dark_background_color: "#111111",
            dark_content_background: "#222222",
            dark_text_color: "#F7F7F9",
            dark_muted_color: "#aaaaaa",
            dark_button_color: "#ffffff",
            dark_button_text_color: "#222222",
            dark_button_hover_color: "#cccccc",
            dark_footer_text_color: "#aaaaaa",
            dark_full_bleed_background: "#0F3016"

  @type t :: %__MODULE__{}

  @doc "Builds a theme, raising on unknown keys."
  @spec new(keyword()) :: t()
  def new(attrs \\ []), do: struct!(__MODULE__, attrs)
end
