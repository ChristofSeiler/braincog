#' Plot braincog object.
#'
#' @import EBImage
#' @import magrittr
#' @import RColorBrewer
#' @export
#'
plot.braincog = function(fit,axis = 3) {

  # extract from results
  seg_select = fit$seg_select
  gray_matter = fit$gray_matter

  # assign colors to cluster
  labels = as.integer(names(table(seg_select)))[-1] # exclude background
  color = colorRampPalette(brewer.pal(n = 9, name = "YlGnBu"))(length(labels))
  color_arr = array("white",dim = dim(seg_select))
  color_arr[gray_matter==1] = "darkgray"
  for(i in 1:length(labels))
    color_arr[seg_select==labels[i]] = color[i]
  array_dims = lapply(1:3,function(i) seq_len(dim(color_arr)[i]))
  array_dims[[axis]] = round(dim(color_arr)[axis]/2)
  slice = color_arr[array_dims[[1]],array_dims[[2]],array_dims[[3]]] %>%
    flip %>%
    flop
  display(EBImage::Image(slice),method = "raster",interpolate = FALSE)
}
