#* Visualization Template
# [ENTER FILE DESCRIPTION — what type of plots does this file generate?]
# All functions in this file are sourced automatically via 00b_setup.R.
# Convention: separate plot generation from PDF/PNG compilation.

#' [Enter plot function title]
#'
#' [Enter description of what this plot shows and when to use it.]
#'
#' @param data A data frame or tibble containing the data to plot.
#' @param config Named list. The global config object from load_dynamic_config().
#'
#' @return A ggplot2 object.
#' @examples
#' \dontrun{
#' p <- plot_my_figure(data = my_df, config = config)
#' ggsave(file.path(config$paths$figures, "my_figure.png"), p, width = 7, height = 5)
#' }
plot_my_figure <- function(data, config) {
  # [ENTER GGPLOT2 CODE]
  p <- ggplot2::ggplot(data) +
    # [ADD LAYERS HERE]
    theme_minimal()
  p
}
