#' Summarize braincog object.
#'
#' @import magrittr
#' @import tibble
#' @import RColorBrewer
#' @export
#'
summary.braincog = function(fit) {

  # extract from results
  pvalues = fit$pvalues
  cs_perm = fit$cs_perm

  # make table to summarize everyting
  tibble(id = 1:length(pvalues),
         label = 2:(length(pvalues)+1), # offset by one for background
         size = cs_perm[1,1:length(pvalues)],
         color = brewer.pal(n = length(pvalues), name = "Set1"),
         pvalue = pvalues,
         pvalue_adj = pvalues %>%
           p.adjust(method = "BH") %>%
           round(digits = 2))
}
