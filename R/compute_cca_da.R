#' Compute difference vector.
#'
#' @import PMA
#' @export
#'
compute_cca_da = function(fac,
                          morphometry,
                          cognition,
                          gray_matter,
                          penaltyz,
                          return_seg = FALSE,
                          top = 1000 # define max number of cluster sizes
                          ) {
  # need to load it here in case this function is run on the cluster
  library("braincog")

  # split groups into two data
  data_list = lapply(levels(fac),function(group) {
    data = NULL
    data$X = cognition[fac == group, ]
    data$Z = morphometry[fac == group, ]
    data
  })

  # find optimal regularization parameter
  res_cca_perm_list = lapply(data_list,function(data) {
    penaltyzs = seq(0.1,0.5,0.1)
    CCA.permute(x = data$X, z = data$Z,
                typex = "standard",
                typez = "standard",
                penaltyxs = 1,
                penaltyzs = penaltyzs,
                standardize = FALSE,
                nperms = 20)
  })

  # match regularization parameter: take the minimum
  penaltyz = sapply(res_cca_perm_list,
                    function(res_cca_perm) res_cca_perm$bestpenaltyz)
  bestpenaltyz = min(penaltyz)

  # run two separate sparse CCA with common regulariztion parameter
  res_cca_list = lapply(data_list,function(data) {
    CCA(x = data$X, z = data$Z,
      typex = "standard",
        typez = "standard",
        penaltyx = 1,
        penaltyz = bestpenaltyz,
        standardize = FALSE)
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
  delta_brain = sapply(seq_along(res_cca_list[[1]]$v),
                     function(i) delta_v(res_cca_list[[1]]$v[i],
                                         res_cca_list[[2]]$v[i]))
  delta_cog = as.tibble(abs(res_cca_list[[1]]$u) - abs(res_cca_list[[2]]$u))
  names(delta_cog) = "perm"

  # convert to image
  delta_brain_arr = array(0, # background
                          dim = dim(gray_matter))
  delta_brain_arr[gray_matter==1] = delta_brain

  # label connected components
  seg = label_cluster(delta_brain_arr)

  # count component size (background is excluded)
  cs = tibble(perm = cluster_size(k = 1:top,arr = seg))

  if(!return_seg) seg = NULL
  list(cs = cs,
       seg = seg,
       delta_cog = delta_cog,
       penaltyz = penaltyz,
       bestpenaltyz = bestpenaltyz)
}
