#' Summarize braincog object.
#'
#' @import magrittr
#' @import tibble
#' @export
#'
summary.braincog = function(fit) {

  # extract from results
  pvalues = fit$pvalues

  # make table to summarize everyting
  tibble(cluster = 1:length(pvalues),
         size = res$cs_perm[1,1:length(pvalues)],
         pvalue = pvalues,
         pvalue_adj = pvalues %>%
           p.adjust(method = "BH") %>%
           round(digits = 2))
}
