# =============================================================================
# plot_theme.R
#
# Shared ggplot2 theme and colour palette for Celon Pharma reports, per the
# conventions in CLAUDE.md ("Plot colour palette and theme"). Source this
# file after setup/sysfont_module.R (Calibri must be registered first).
#
# Requires the `hrbrthemes` package (already in renv.lock — `renv::restore()`
# installs it).
# =============================================================================

# Generic 2-3 level palette. Adjust the *names* to the project's grouping
# variable (e.g. treatment arm, dose) before use — the colour values are
# reusable across projects, the mapping is project-specific.
celon_palette <- c(
  "Group 1" = "darkgrey",
  "Group 2" = "#F17E00",
  "Group 3" = "black"
)

#' Celon Pharma ggplot2 theme
#'
#' Wraps `hrbrthemes::theme_ipsum()` with the Calibri font and a small set
#' of layout overrides used across reports. Override further with `+
#' theme(...)` in individual plots if needed.
#'
#' `theme_ipsum()` defaults its title/axis/caption sizes to fixed point values
#' that do not follow `base_size`, so each is derived from `base_size` here —
#' changing `base_size` then scales the whole plot consistently.
theme_celon <- function(base_size = 16, ...) {
  hrbrthemes::theme_ipsum(
    base_family = "Calibri",
    base_size = base_size,
    axis_title_size = round(base_size * 1.15),
    plot_title_size = round(base_size * 1.3),
    subtitle_size = round(base_size * 1.18),
    strip_text_size = round(base_size * 1.15),
    caption_size = round(base_size * 0.45),
    ...
  ) +
    ggplot2::theme(
      legend.position = "bottom",
      legend.text = ggplot2::element_text(
        size = ggplot2::rel(1),
        face = "plain"
      ),
      plot.margin = ggplot2::margin(10, 10, 10, 10),
      axis.text = ggplot2::element_text(size = ggplot2::rel(0.8)),
      axis.title = ggplot2::element_text(
        size = ggplot2::rel(0.9),
        face = "plain"
      ),
      plot.subtitle = ggplot2::element_text(lineheight = 0.5),
      plot.caption = ggplot2::element_text(colour = "#333333"),
      strip.text = ggplot2::element_text(face = "bold")
    )
}
