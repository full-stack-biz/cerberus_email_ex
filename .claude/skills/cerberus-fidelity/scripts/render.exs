# Renders every block of one Cerberus template, in the upstream file's block order, so the
# output can be diffed against cerberus-<template>.html.
#
# Usage (from the project root): mix run <this file> <hybrid|responsive|fluid> <out.html>
#
# Keep block order and block set in sync with the upstream template when either changes.

import Phoenix.Component

[template, out] = System.argv()
assigns = %{}

html =
  case template do
    "hybrid" ->
      import CerberusEmail.Components

      ~H"""
      <.email_layout brand_name="Company" logo_src="https://via.placeholder.com/200x50" footer_text="Company Name" preview_text="Preview">
        <.email_hero_image src="https://via.placeholder.com/1360x600" alt="alt_text" />
        <.email_one_column_text_button heading="Heading" button_text="Centered Primary Button" button_url="https://google.com/">
          <p style="margin: 0 0 10px;">Text.</p>
        </.email_one_column_text_button>
        <.email_background_image_text image_url="https://via.placeholder.com/680x180/222222/666666">
          <p style="margin: 0;">Text.</p>
        </.email_background_image_text>
        <.email_columns>
          <:column image_src="https://via.placeholder.com/310" image_alt="alt_text"><p style="margin: 0;">A</p></:column>
          <:column image_src="https://via.placeholder.com/310" image_alt="alt_text"><p style="margin: 0;">B</p></:column>
        </.email_columns>
        <.email_columns>
          <:column image_src="https://via.placeholder.com/200" image_alt="alt_text"><p style="margin: 0;">A</p></:column>
          <:column image_src="https://via.placeholder.com/200" image_alt="alt_text"><p style="margin: 0;">B</p></:column>
          <:column image_src="https://via.placeholder.com/200" image_alt="alt_text"><p style="margin: 0;">C</p></:column>
        </.email_columns>
        <.email_thumbnail_row image_src="https://via.placeholder.com/200" image_alt="alt_text" heading="Heading" button_text="Primary Button" button_url="https://google.com/">
          <p style="margin: 0 0 10px 0;">Text.</p>
        </.email_thumbnail_row>
        <.email_thumbnail_row side="right" image_src="https://via.placeholder.com/200" image_alt="alt_text" heading="Heading" button_text="Primary Button" button_url="https://google.com/">
          <p style="margin: 0 0 10px 0;">Text.</p>
        </.email_thumbnail_row>
        <.email_spacer height="40" />
        <.email_one_column_text><p style="margin: 0 0 10px 0;">Text.</p></.email_one_column_text>
        <:full_bleed background_color="#709f2b"><p style="margin: 0;">Full bleed.</p></:full_bleed>
      </.email_layout>
      """

    "responsive" ->
      import CerberusEmail.Responsive

      ~H"""
      <.email_layout brand_name="Company" logo_src="https://via.placeholder.com/200x50" footer_text="Company Name" preview_text="Preview">
        <.email_hero_image src="https://via.placeholder.com/1200x600" alt="alt_text" />
        <.email_one_column_text_button heading="Heading" button_text="Centered Primary Button" button_url="https://google.com/">
          <p style="margin: 0 0 10px;">Text.</p>
        </.email_one_column_text_button>
        <.email_background_image_text image_url="https://via.placeholder.com/600x230/222222/666666">
          <p style="margin: 0;">Text.</p>
        </.email_background_image_text>
        <.email_columns>
          <:column image_src="https://via.placeholder.com/270" image_alt="alt_text"><p style="margin: 0;">A</p></:column>
          <:column image_src="https://via.placeholder.com/270" image_alt="alt_text"><p style="margin: 0;">B</p></:column>
        </.email_columns>
        <.email_columns>
          <:column image_src="https://via.placeholder.com/170" image_alt="alt_text"><p style="margin: 0;">A</p></:column>
          <:column image_src="https://via.placeholder.com/170" image_alt="alt_text"><p style="margin: 0;">B</p></:column>
          <:column image_src="https://via.placeholder.com/170" image_alt="alt_text"><p style="margin: 0;">C</p></:column>
        </.email_columns>
        <.email_thumbnail_row image_src="https://via.placeholder.com/170" image_alt="alt_text" heading="Heading" button_text="Primary Button" button_url="https://google.com/">
          <p style="margin: 0 0 10px 0;">Text.</p>
        </.email_thumbnail_row>
        <.email_thumbnail_row side="right" image_src="https://via.placeholder.com/170" image_alt="alt_text" heading="Heading" button_text="Primary Button" button_url="https://google.com/">
          <p style="margin: 0 0 10px 0;">Text.</p>
        </.email_thumbnail_row>
        <.email_spacer height="40" />
        <.email_one_column_text><p style="margin: 0;">Text.</p></.email_one_column_text>
        <:full_bleed background_color="#709f2b"><p style="margin: 0;">Full bleed.</p></:full_bleed>
      </.email_layout>
      """

    "fluid" ->
      import CerberusEmail.Fluid

      ~H"""
      <.email_layout brand_name="Company" logo_src="https://via.placeholder.com/200x50" footer_text="Company Name" preview_text="Preview">
        <.email_hero_image src="https://via.placeholder.com/1200x600" alt="alt_text" />
        <.email_one_column_text_button heading="Heading" button_text="Primary Button" button_url="https://google.com/">
          <p style="margin: 0;">Text.</p>
          <:after_button><h2 style="margin: 0 0 10px 0;">Heading 2</h2></:after_button>
        </.email_one_column_text_button>
        <.email_columns>
          <:column image_src="https://via.placeholder.com/200" image_alt="alt_text"><p style="margin: 0;">A</p></:column>
          <:column image_src="https://via.placeholder.com/200" image_alt="alt_text"><p style="margin: 0;">B</p></:column>
        </.email_columns>
        <.email_spacer height="40" />
        <.email_one_column_text><p style="margin: 0;">Text.</p></.email_one_column_text>
        <:full_bleed background_color="#709f2b"><p style="margin: 0;">Full bleed.</p></:full_bleed>
      </.email_layout>
      """
  end

File.write!(out, html |> Phoenix.HTML.Safe.to_iodata() |> IO.iodata_to_binary())
