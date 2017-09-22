#' Summarize cogntion part of braincog object.
#'
#' @import tibble
#' @export
#'
summary_cognition = function(fit) {
  
  # extract from fit object
  delta_cog_perm = fit$delta_cog_perm
  
  # compute pvalues
  statistic = delta_cog_perm %>% 
    abs %>%
    mutate_all(function(v) (v-mean(v))/sd(v)) %>% 
    abs
  pvalue = apply(statistic, 2, function(stat) mean(stat[1] <= stat))

  # adjust pvalues and combine all in one table
  tibble(
    test = names(delta_cog_perm),
    coeff = as.numeric(delta_cog_perm[1,]),
    pvalue = pvalue,
    pvalue_adj = p.adjust(pvalue,method = "BH")
  )
}
