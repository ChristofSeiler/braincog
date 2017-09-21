#' Plot permutation results of cognitive tests.
#'
#' @import magrittr
#' @import ggplot2
#' @import reshape2
#' @import dplyr
#' @import tibble
#' @export
#'
plot_cognition = function(fit,domain_mapping,alpha = 0.05,studentize = TRUE) {

  # extract from fit object
  delta_cog_perm = abs(fit$delta_cog_perm)
  if(studentize)
    delta_cog_perm %<>% mutate_all(function(v) (v-mean(v))/sd(v))
  
  # add diagnosis
  domain_mapping %<>% add_row(test = "Diagnosis", domain = "Diagnosis")

  # compute pvalues
  selection = summary_cognition(fit)
  selection %<>% add_column(
    FDR = ifelse(test = selection$pvalue_adj <= alpha,
                 yes = paste("FDR <=",alpha),
                 no = paste("FDR >",alpha))
  )
  
  # merge domain with main table
  delta_long = delta_cog_perm %>% add_column(permutation = 1:nrow(delta_cog_perm))
  delta_long %<>% reshape2::melt(id.vars = "permutation")
  delta_long %<>% dplyr::rename(test = "variable")
  delta_long$test %<>% as.character
  delta_long %<>% inner_join(domain_mapping, by = "test")
  delta_long %<>% inner_join(selection, by = "test")
  delta_long$test = factor(delta_long$test, levels = domain_mapping$test)

  # overlay obvserved statistics onto null distribuiton
  delta_obsv = tibble(test = names(delta_cog_perm),
                      score = as.numeric(delta_cog_perm[1,]))
  delta_obsv %<>% inner_join(selection, by = "test")
  ggplot(delta_long,aes(x = test, y = value, color = domain)) +
    #geom_boxplot() +
    geom_violin() +
    geom_point(data = delta_obsv, aes(x = test, y = score),colour = "black") +
    xlab("cognitive tests") +
    ylab("coefficients") +
    labs(title = "Test Statistic of Cognition and Diagnosis") +
    theme(axis.text.x=element_text(angle=45, hjust=1)) +
    coord_flip() +
    facet_wrap(~FDR)
}
