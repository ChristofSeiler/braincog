#' Summarize cogntion part of braincog object.
#'
#' @import tibble
#' @export
#'
summary_cognition = function(fit) {
  # extract from fit object
  delta_cog_perm = as.tibble(fit$delta_cog_perm)

  # compute pvalues
  tibble(
    test = names(delta_cog_perm),
    pvalue = apply(delta_cog_perm, 2, function(v) mean(abs(v[1]) <= abs(v))),
    pvalue_adj = p.adjust(pvalue,method = "BH")
  )
}
