#' A test style for bookdown
#' @importFrom rmarkdown output_format knitr_options pandoc_options
#' @export
#' @param ... additionol options
bookdown_test <- function(...){
  template <- system.file("pandoc/bookdown_test.tex", package = "bookdowntest")
  args <- c(
    "--template", template,
    "--latex-engine", "xelatex"
  )
  opts_chunk <- list(
    dev = 'pdf',
    dpi = 300,
    fig.width = 4.5,
    fig.height = 2.9
  )
  output_format(
    knitr = knitr_options(
      opts_knit = list(
        width = 60,
        concordance = TRUE
      ),
      opts_chunk = opts_chunk
    ),
    pandoc = pandoc_options(
      to = "latex",
      args = args,
      keep_tex = TRUE
    ),
    clean_supporting = FALSE
  )
}