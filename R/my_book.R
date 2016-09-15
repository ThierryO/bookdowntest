#' A test for rendering bookdown pdf
#' @inheritParams rmarkdown::pdf_document
#' @inheritParams bookdown::pdf_book
#' @export
my_book <- function(
  toc = TRUE, number_sections = TRUE, fig_caption = TRUE, ...,
  base_format = bookdown_test
){
  base_format = bookdown:::get_base_format(base_format)
  config = base_format(
    toc = toc, number_sections = number_sections, fig_caption = fig_caption, ...
  )
  config$pandoc$ext = '.tex'
  post = config$post_processor  # in case a post processor have been defined
  config$post_processor = function(metadata, input, output, clean, verbose) {
    if (is.function(post)) output = post(metadata, input, output, clean, verbose)
    f = bookdown:::with_ext(output, '.tex')
    x = bookdown:::resolve_refs_latex(bookdown:::readUTF8(f))
    x = bookdown:::restore_part_latex(x)
    x = bookdown:::restore_appendix_latex(x)
    bookdown:::writeUTF8(x, f)
    bookdown:::latexmk(f, config$pandoc$latex_engine)
    unlink(bookdown:::with_ext(output, 'bbl'))  # not sure why latexmk left a .bbl there

    output = bookdown:::with_ext(output, '.pdf')
    o = bookdown:::opts$get('output_dir')
    keep_tex = isTRUE(config$pandoc$keep_tex)
    if (!keep_tex) file.remove(f)
    if (is.null(o)) return(output)

    output2 = file.path(o, output)
    file.rename(output, output2)
    if (keep_tex) file.rename(f, file.path(o, f))
    output2
  }
  # always enable tables (use packages booktabs, longtable, ...)
  pre = config$pre_processor
  config$pre_processor = function(...) {
    c(if (is.function(pre)) pre(...), '--variable', 'tables=yes', '--standalone')
  }
  config$bookdown_output_format = 'latex'
  config = bookdown:::set_opts_knit(config)
  config
}
