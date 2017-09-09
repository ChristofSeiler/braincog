#' Summarize braincog object.
#'
#' @import magrittr
#' @import tibble
#' @export
#'
summary.braincog = function(fit) {
  tibble(cluster = 1:fit$top,
         size = res$cs_perm[1,],
         pvalue = fit$pvalues,
         pvalue_adj = fit$pvalues %>%
           p.adjust(method = "BH") %>%
           round(digits = 2)) %>%
    print(n = Inf)
}
