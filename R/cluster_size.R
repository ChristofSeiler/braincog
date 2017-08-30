#' kth largest cluster size from segmented array.
#'
#' @export
#'
cluster_size = function(k,arr) {
  cluster_label = 1+k # first element is background
  seg_table = table(arr)
  if(length(seg_table) == 1) {
    return(0)
  } else {
    return(seg_table[cluster_label])
  }
}
