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
  pvalues = apply(cs_perm, 2, function(cs) {
    cs_student = (cs-mean(cs))/sd(cs)
    mean(cs_student[1] <= cs_student)
  })
  pvalues[is.na(pvalues)] = 1
  
  # keep only pvalues that are bigger than predefined min detectable size
  pvalues = pvalues[cs_perm[1,] > min_clustersize]

  # cluster colors
  color = brewer.pal(n = 8, name = "Set1")[seq(pvalues)]
  color[is.na(color)] = "black"

  # make table to summarize everyting
  tibble(id = seq(pvalues),
         label = seq(pvalues)+1, # offset by one for background
         size = as.numeric(cs_perm[1,seq(pvalues)]),
         color = color,
         pvalue = pvalues,
         pvalue_adj = pvalues %>%
           p.adjust(method = "BH") %>%
           round(digits = 2))
}
