#' kth largest cluster size measured in absolute values of coefficients from segmented array.
#'
cluster_size_weighted = function(k,seg_arr,coeff_arr) {
  cluster_label = 1+k # first element is background
  sum(abs(coeff_arr[seg_arr==cluster_label]))
}
