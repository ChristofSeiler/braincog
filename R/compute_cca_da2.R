#' Compute difference vector.
#'
#' @import PMA
#' @export
#'
compute_cca_da2 = function(fac,
                           morphometry,
                           cognition,
                           gray_matter,
                           penaltyz = NULL,
                           return_seg = FALSE,
                           top = 1000 # define max number of cluster sizes
                           ) {
  # need to load it here in case this function is run on the cluster
  library("braincog")

  # find optimal regulariztion parameter
  #penaltyzs = seq(0.1,0.5,0.1)
  penaltyzs = seq(0.1,0.5,0.4)
  bestpenaltyz = penaltyz
  if(is.null(bestpenaltyz)) {
    cca_perm = CCA.permute(x = cognition, z = morphometry,
                           typex = "standard",
                           typez = "standard",
                           penaltyxs = 1,
                           penaltyzs = penaltyzs,
                           standardize = FALSE,
                           #nperms = 20)
                           nperms = 3)
    bestpenaltyz = cca_perm$bestpenaltyz
  }

  # run two separate sparse CCA with common regulariztion parameter
  cca = CCA(x = cognition, z = morphometry,
            typex = "standard",
            typez = "standard",
            penaltyx = 1,
            penaltyz = bestpenaltyz,
            standardize = FALSE)

  # convert brain loadings to image
  delta_brain = ifelse(test = cca$v == 0,yes = 0,no = 1)
  delta_brain_arr = array(0, # background
                          dim = dim(gray_matter))
  delta_brain_arr[gray_matter==1] = delta_brain

  # label connected components
  seg = label_cluster(delta_brain_arr)

  # count component size (background is excluded)
  cs = tibble(perm = cluster_size(k = 1:top,arr = seg))

  # convert cognition laodings to vector
  delta_cog = as.tibble(abs(cca$u))
  names(delta_cog) = "perm"

  if(!return_seg) seg = NULL
  list(cs = cs,
       seg = seg,
       delta_cog = delta_cog,
       penaltyzs = penaltyzs,
       bestpenaltyz = bestpenaltyz)
}
