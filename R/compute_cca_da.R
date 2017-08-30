#' Compute difference vector.
#'
#' @import PMA
#' @export
#'
compute_cca_da = function(morphometry, cognition) {
  res_cca_list = lapply(list(data1,data2),function(data) {
    penaltyzs = seq(0.1,0.5,0.1)
    perm_out = CCA.permute(x = data$X, z = data$Z,
                           typex = "standard",
                           typez = "standard",
                           penaltyxs = 1,
                           penaltyzs = penaltyzs,
                           standardize = FALSE,
                           nperms = 20)
    out = CCA(x = data$X, z = data$Z,
              typex = "standard",
              typez = "standard",
              penaltyx = 1,
              penaltyz = perm_out$bestpenaltyz,
              standardize = FALSE,
              v = perm_out$v.init)
  })

  # difference in coefficients
  delta_v = function(v1,v2) {
    delta = 0
    if(sign(v1)== 0 & sign(v2)==-1) delta = 1
    else if(sign(v1)== 0 & sign(v2)== 1) delta = 2
    else if(sign(v1)==-1 & sign(v2)== 0) delta = 3
    else if(sign(v1)== 1 & sign(v2)== 0) delta = 4
    delta
  }
  sign_diff = sapply(seq_along(res_cca_list[[1]]$v),
                     function(i) delta_v(res_cca_list[[1]]$v[i],
                                         res_cca_list[[2]]$v[i]))
  sign_diff
}
