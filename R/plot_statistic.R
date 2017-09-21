#' Plot null distribution of test statistic.
#'
#' @import reshape2
#' @import dplyr
#' @export
#'
plot_statistic = function(fit,cluster_id = 1,studentize = TRUE) {

  # extract from results
  tb = as.tibble(fit$cs_perm_weighted)
  if(studentize)
    tb %<>% mutate_all(function(cs) (cs-mean(cs))/sd(cs))

  # reshape table
  names(tb) = 1:ncol(tb)
  tb %<>% add_column(permutation = 1:nrow(tb))
  tb_long = reshape2::melt(tb,id.vars = "permutation")
  tb_long %<>% dplyr::rename(cluster = "variable")
  tb_long %<>% dplyr::rename(size = "value")
  tb_long %<>% dplyr::filter(cluster == cluster_id)

  ggplot(tb_long,aes(x = size)) +
    geom_histogram(bins = nrow(tb)/5) +
    geom_vline(xintercept = as.integer(tb[1,cluster_id]),
               color = "red",
               size = 1) +
    ggtitle(paste("Cluster",cluster_id))
}
