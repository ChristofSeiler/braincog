#' Summarize cogntion part of braincog object.
#'
#' @import tibble
#' @export
#'
summary_cognition = function(fit) {
  # extract from fit object
  delta_cog_perm = abs(fit$delta_cog_perm)
    
  # compute pvalues
  tibble(
    test = names(delta_cog_perm),
    pvalue = apply(delta_cog_perm, 2, function(v) {
      v_student = (v-mean(v))/sd(v)
      mean(v_student[1] <= v_student)
    }),
    pvalue_adj = p.adjust(pvalue,method = "BH")
  )
}
