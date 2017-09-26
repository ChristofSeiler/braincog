#' Plot null distribution of test statistic.
#'
#' @import reshape2
#' @import dplyr
#' @export
#'
plot_statistic = function(fit,cluster_id = 1) {

  # extract from results
  tb = as.tibble(fit$cs_perm_weighted)

  # reshape table
  names(tb) = 1:ncol(tb)
  tb %<>% add_column(permutation = 1:nrow(tb))
  tb_long = reshape2::melt(tb,id.vars = "permutation")
  tb_long %<>% dplyr::rename(cluster = "variable")
  tb_long %<>% dplyr::rename(size = "value")
  tb_long %<>% dplyr::filter(cluster == cluster_id)

  ggplot(tb_long,aes(x = size)) +
    geom_histogram(binwidth = (tb_long$size %>% range %>% diff) / 50) +
    geom_vline(xintercept = with(tb_long,size[which(permutation == 1)]),
               color = "red",
               size = 1) +
    ggtitle(paste("Cluster",cluster_id))
}
