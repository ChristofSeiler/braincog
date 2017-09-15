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

  # add and scale factor
  cognition = cognition %>%
    as.tibble %>%
    add_column(Diagnosis = as.numeric(fac)) %>%
    scale(center = TRUE,scale = TRUE)

  # find optimal regulariztion parameter
  #penaltyzs = seq(0.1,0.5,0.1)
  penaltyzs = seq(0.05,0.3,0.05)
  bestpenaltyz = penaltyz
  if(is.null(bestpenaltyz)) {
    cca_perm = CCA.permute(x = cognition, z = morphometry,
                           typex = "standard",
                           typez = "standard",
                           penaltyxs = 1,
                           penaltyzs = penaltyzs,
                           standardize = FALSE,
                           nperms = 20)
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
  cs = cluster_size(k = 1:top,arr = seg) %>% as.vector %>% t %>% as.tibble
  names(cs) = paste0("cluster_",1:top)

  # convert cognition loadings into a tibble
  delta_cog = cca$u %>% t %>% as.tibble
  names(delta_cog) = colnames(cognition)

  if(!return_seg) seg = NULL
  list(cs = cs,
       seg = seg,
       delta_cog = delta_cog,
       penaltyzs = penaltyzs,
       bestpenaltyz = bestpenaltyz)
}
