# gt_table.R
#
# Shared `gt` table formatting for Celon Pharma reports, per the conventions
# in CLAUDE.md ("GT table pattern"). Caption and label come from Quarto chunk
# options (#| tbl-cap, #| label: tbl-...), not from this wrapper.
#
# fmt_number()/fmt_integer() mask the gt versions (same pattern as ggsave() in
# setup/sysfont_module.R), so bare calls use the report-wide "." decimal /
# " " thousands convention. Call gt::fmt_number() to bypass.

#' Celon Pharma gt table wrapper: font and sizing
#'
#' Do not use `gt::tab_header()` (duplicates the Quarto caption, breaks
#' cross-referencing); use `gt::tab_footnote()` for model/technical details.
celon_gt <- function(data, ...) {
  gt::gt(data, ...) |>
    gt::opt_table_font(font = "Calibri") |>
    gt::tab_options(
      table.font.size = gt::px(12),
      heading.align = "left"
    )
}

#' gt::fmt_number() with "." decimal and " " thousands marks
fmt_number <- function(..., sep_mark = " ", dec_mark = ".") {
  gt::fmt_number(..., sep_mark = sep_mark, dec_mark = dec_mark)
}

#' gt::fmt_integer() with " " as the thousands mark, matching fmt_number()
fmt_integer <- function(..., sep_mark = " ") {
  gt::fmt_integer(..., sep_mark = sep_mark)
}

#' Bold column labels, spanners and row-group labels (opt-in)
#'
#' Spanners are also centered explicitly: any style on them replaces gt's
#' default centering in the LaTeX output.
bold_headers <- function(gt_tbl) {
  gt_tbl |>
    gt::tab_style(
      style = gt::cell_text(weight = "bold"),
      locations = list(
        gt::cells_column_labels(),
        gt::cells_row_groups(),
        gt::cells_stubhead()
      )
    ) |>
    gt::tab_style(
      style = gt::cell_text(weight = "bold", align = "center"),
      locations = gt::cells_column_spanners()
    )
}
