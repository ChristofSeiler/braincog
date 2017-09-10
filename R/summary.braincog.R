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

  # cluster colors
  color = brewer.pal(n = 8, name = "Set1")[seq(pvalues)]
  color[is.na(color)] = "black"

  # make table to summarize everyting
  tibble(id = seq(pvalues),
         label = seq(pvalues)+1, # offset by one for background
         size = cs_perm[1,seq(pvalues)],
         color = color,
         pvalue = pvalues,
         pvalue_adj = pvalues %>%
           p.adjust(method = "BH") %>%
           round(digits = 2))
}
