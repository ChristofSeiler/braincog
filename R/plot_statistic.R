#' Extract mid-plane slice and display.
#'
#' @import reshape2
#' @import dplyr
#' @export
#'
plot_statistic = function(fit,cluster_id = 1) {

  # extract from results
  tb = as.tibble(fit$cs_perm)

  # reshape table
  names(tb) = 1:ncol(tb)
  tb %<>% add_column(permutation = 1:nrow(tb))
  tb_long = melt(tb,id.vars = "permutation")
  tb_long %<>% dplyr::rename(cluster = "variable")
  tb_long %<>% dplyr::rename(size = "value")
  tb_long %<>% dplyr::filter(cluster == cluster_id)

  ggplot(tb_long,aes(x = size)) +
    geom_histogram(bins = nrow(tb)/5) +
    facet_wrap(~cluster) +
    geom_vline(xintercept = as.integer(tb[1,cluster_id]),
               color = "red",
               size = 1)
}
