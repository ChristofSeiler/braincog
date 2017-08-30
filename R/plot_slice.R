#' Extract mid-plane slice and display.
#'
#' @import EBImage
#' @import magrittr
#' @export
#'
plot_slice = function(arr,axis = 3) {
  array_dims = lapply(1:3,function(i) seq_len(dim(arr)[i]))
  array_dims[[axis]] = round(dim(arr)[axis]/2)
  slice = arr[array_dims[[1]],array_dims[[2]],array_dims[[3]]] %>%
    flip %>%
    flop %>%
    normalize
  display(EBImage::Image(slice),method = "raster",interpolate = FALSE)
}
