#' Summarize braincog object.
#'
#' @import magrittr
#' @import tibble
#' @import RColorBrewer
#' @export
#'
summary.braincog = function(fit) {

  # extract from results
  cs_perm = fit$cs_perm
  min_clustersize = fit$min_clustersize

  # compute pvalues for morphometry
  pvalues = sapply(seq(ncol(cs_perm)),
                   function(k) mean(cs_perm[1,k] <= cs_perm[,k]))
  # keep only pvalues that are bigger than predefined min detectable size
  pvalues = pvalues[cs_perm[1,] > min_clustersize]

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
