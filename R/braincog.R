#' Differential sparse canonical correlation analysis.
#'
#' @import PMA
#' @import SimpleITK
#' @import magrittr
#' @import tidyverse
#' @export
#'
braincog = function(morphometry, cognition) {
  img_sign_diff = compute_cca_da(data1_perm,data2_perm) %>% array(dim = dim(img1))
  arr_seg = label_cluster(img_sign_diff)
  cs = cluster_size(k = 1,arr = arr_seg) # background is excluded
  class(cs) = "braincog"
  cs
}
