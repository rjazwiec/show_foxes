# render_helpers.R
#
# Output-format workarounds for gt tables, called from report chunks so the
# table builders stay free of format-specific code.
# Each helper acts in PDF (LaTeX) output only and returns the table unchanged
# otherwise.

#' Break "AEs N = 5"-style column labels before "N =" in PDF output
#'
#' gt ignores "\n" in LaTeX and md("<br>") widens the table; raw \shortstack
#' works.
#'
#' @param tbl a gt_tbl whose labels of `columns` contain " N = "
#' @param columns tidyselect for the labelled columns
#' @return a gt_tbl
latex_break_n_labels <- function(
  tbl,
  columns = c(starts_with("ae_"), starts_with("sub_"))
) {
  if (!knitr::is_latex_output()) {
    return(tbl)
  }
  tbl |>
    cols_label_with(
      columns = {{ columns }},
      fn = \(x) {
        parts <- strsplit(x, " N = ", fixed = TRUE)
        latex(map_chr(
          parts,
          \(p) paste0("\\shortstack[r]{", p[1], "\\\\N = ", p[2], "}")
        ))
      }
    )
}

#' Rotate column labels 90 degrees counterclockwise in PDF output
#'
#' gt has no label rotation; raw \rotatebox does. Rotated labels do not wrap,
#' so a long label makes the header row tall.
#'
#' @param tbl a gt_tbl
#' @param columns tidyselect for the columns whose labels are rotated
#' @param stubhead also rotate the stubhead label
#' @return a gt_tbl
latex_rotate_labels <- function(tbl, columns, stubhead = FALSE) {
  if (!knitr::is_latex_output()) {
    return(tbl)
  }
  rotate <- \(x) latex(paste0("\\rotatebox[origin=c]{90}{", x, "}"))
  tbl <- tbl |> cols_label_with(columns = {{ columns }}, fn = rotate)
  if (stubhead && length(tbl[["_stubhead"]]$label) > 0) {
    tbl <- tbl |> tab_stubhead(label = rotate(tbl[["_stubhead"]]$label))
  }
  tbl
}

#' Hang wrapped stub lines by the stub indent in PDF output
#'
#' gt's LaTeX output indents only the first line of an indented stub label.
#' Reads the indent set by `tab_stub_indent()` (gt: indent n = 3.75n pt) and
#' adds a matching \hangindent.
#'
#' @param tbl a gt_tbl with indented stub rows
#' @return a gt_tbl
latex_hang_stub <- function(tbl) {
  if (!knitr::is_latex_output()) {
    return(tbl)
  }
  indent <- as.numeric(tbl[["_stub_df"]]$indent)
  for (n in unique(na.omit(indent))) {
    tbl <- tbl |>
      text_transform(
        locations = cells_stub(rows = which(indent == n)),
        fn = \(x) paste0("\\hangindent=", 3.75 * n, "pt\\hangafter=1 ", x)
      )
  }
  tbl
}
