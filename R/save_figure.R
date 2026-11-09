# save_figure.R
#
# Saves a plot as PNG (20 x 20 cm, 250 dpi per the project plot workflow).
# `generator` is the calling file; it is bound to `.generator` here because
# the ggsave() mask in setup/sysfont_module.R stamps it as source. Without it
# the stamp would name whichever file was sourced last.

save_figure <- function(plot, path, generator, width = 20, height = 20) {
  .generator <- generator
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  # Bare ggsave(), not ggplot2::ggsave(): the namespaced call bypasses the mask.
  ggsave(path, plot = plot, width = width, height = height, units = "cm",
         dpi = 250)
  invisible(path)
}
