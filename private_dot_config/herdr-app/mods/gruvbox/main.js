import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { theme, settings, run, props, closeOverlay } from "herdr";

const VARIANTS = [
  {
    id: "gruvbox",
    name: "Dark Hard",
    bg: "#1d2021",
    fg: "#ebdbb2",
    contrast: "High",
    swatches: ["#cc241d", "#98971a", "#d79921", "#458588", "#b16286", "#689d6a", "#d65d0e"],
  },
  {
    id: "gruvbox-medium",
    name: "Dark Medium",
    bg: "#282828",
    fg: "#ebdbb2",
    contrast: "Medium",
    swatches: ["#fb4934", "#b8bb26", "#fabd2f", "#83a598", "#d3869b", "#8ec07c", "#fe8019"],
  },
  {
    id: "gruvbox-soft",
    name: "Dark Soft",
    bg: "#32302f",
    fg: "#ebdbb2",
    contrast: "Soft",
    swatches: ["#fb4934", "#b8bb26", "#fabd2f", "#83a598", "#d3869b", "#8ec07c", "#fe8019"],
  },
  {
    id: "gruvbox-light",
    name: "Light Hard",
    bg: "#f9f5d7",
    fg: "#3c3836",
    contrast: "High",
    swatches: ["#9d0006", "#79740e", "#b57614", "#076678", "#8f3f71", "#427b58", "#af3a03"],
  },
  {
    id: "gruvbox-light-medium",
    name: "Light Medium",
    bg: "#fbf1c7",
    fg: "#3c3836",
    contrast: "Medium",
    swatches: ["#cc241d", "#98971a", "#d79921", "#458588", "#b16286", "#689d6a", "#d65d0e"],
  },
  {
    id: "gruvbox-light-soft",
    name: "Light Soft",
    bg: "#f2e5bc",
    fg: "#3c3836",
    contrast: "Soft",
    swatches: ["#cc241d", "#98971a", "#d79921", "#458588", "#b16286", "#689d6a", "#d65d0e"],
  },
];

export default class Gruvbox extends View {
  init(_props, cx) {
    this.handle = cx.focus_handle();
    this.handle.focus();
    const current = settings()?.theme;
    const index = VARIANTS.findIndex((v) => v.id === current);
    this.selected = index >= 0 ? index : 0;
  }

  dismiss() {
    closeOverlay(props().overlay);
  }

  select(variant) {
    run("app.theme", { name: variant.id });
    this.dismiss();
  }

  key(e, cx) {
    cx.stop_propagation();
    if (e.key === "escape") return this.dismiss();

    if (e.key === "up") {
      this.selected = (this.selected - 1 + VARIANTS.length) % VARIANTS.length;
      cx.notify();
      return;
    }
    if (e.key === "down") {
      this.selected = (this.selected + 1) % VARIANTS.length;
      cx.notify();
      return;
    }
    if (e.key === "enter") {
      return this.select(VARIANTS[this.selected]);
    }

    const digit = parseInt(e.key, 10);
    if (!isNaN(digit) && digit >= 1 && digit <= VARIANTS.length) {
      return this.select(VARIANTS[digit - 1]);
    }
  }

  render() {
    const t = theme();
    const currentTheme = settings()?.theme;

    return v_flex()
      .id("gruvbox-theme-picker")
      .track_focus(this.handle)
      .on_key_down((e, cx) => this.key(e, cx))
      .p(14)
      .gap(10)
      .bg(t.popover ?? t.surface)
      .border_1()
      .border_color(t.border)
      .rounded(8)
      .text_color(t.foreground)
      .text_size(12)
      .child(
        h_flex()
          .justify_between()
          .items_center()
          .child(div().font_semibold().text_size(13).child("Gruvbox Theme & Contrast"))
          .child(div().text_color(t.muted).text_size(11).child("1–6 switch · ↑/↓ navigate · Esc close"))
      )
      .child(
        v_flex()
          .gap(4)
          .children(
            VARIANTS.map((variant, index) => {
              const isSelected = this.selected === index;
              const isActive = currentTheme === variant.id;

              return h_flex()
                .id(variant.id)
                .items_center()
                .justify_between()
                .p(6)
                .rounded(4)
                .cursor_pointer()
                .when(isSelected, (el) => el.bg(t.accent_subtle ?? "#3c3836").border_1().border_color(t.accent ?? "#fe8019"))
                .hover((s) => s.bg(t.hover ?? "#3c3836"))
                .on_click(() => this.select(variant))
                .child(
                  h_flex()
                    .items_center()
                    .gap(10)
                    .child(
                      div()
                        .w(18)
                        .h(18)
                        .rounded(3)
                        .items_center()
                        .justify_center()
                        .bg(isSelected ? (t.accent ?? "#fe8019") : (t.muted ?? "#504945"))
                        .text_color(isSelected ? (t.accent_foreground ?? "#1d2021") : (t.foreground ?? "#ebdbb2"))
                        .child(String(index + 1))
                    )
                    .child(
                      div()
                        .font_semibold()
                        .child(variant.name)
                    )
                    .child(
                      div()
                        .text_color(t.dim ?? "#7c6f64")
                        .text_size(11)
                        .child(`(${variant.contrast})`)
                    )
                )
                .child(
                  h_flex()
                    .items_center()
                    .gap(6)
                    .child(
                      h_flex()
                        .gap(3)
                        .p(2)
                        .rounded(3)
                        .bg(variant.bg)
                        .border_1()
                        .border_color("#504945")
                        .children(
                          variant.swatches.map((color) =>
                            div().w(8).h(8).rounded(2).bg(color)
                          )
                        )
                    )
                    .when(isActive, (el) =>
                      el.child(
                        div()
                          .text_color(t.accent ?? "#fe8019")
                          .font_semibold()
                          .text_size(11)
                          .child("Active")
                      )
                    )
                );
            })
          )
      )
      .child(
        h_flex()
          .justify_between()
          .text_color(t.muted)
          .text_size(11)
          .pt(4)
          .border_t(1)
          .border_color(t.border)
          .child(div().child(`Current: ${currentTheme ?? "gruvbox"}`))
          .child(div().child("Gruvbox Suite + Monochrome Icons"))
      );
  }
}
