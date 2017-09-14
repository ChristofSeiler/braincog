#' Combine slices.
#'
#' @import magrittr
#' @import cowplot
#' @export
#'
combine_slices = function(color_arr,center_color,crop,title) {

  # remove margin
  crop_x = crop
  crop_y = crop
  crop_z = crop
  dims = dim(color_arr)
  color_arr = color_arr[(crop_x+1):(dims[1]-crop_x),
                        (crop_y+1):(dims[2]-crop_y),
                        (crop_z+1):(dims[3]-crop_z)]

  # extract slices centered at median cluster position
  saggital = plot_cluster(color_arr,color = center_color,axis = 1)
  coronal = plot_cluster(color_arr,color = center_color,axis = 2)
  axial = plot_cluster(color_arr,color = center_color,axis = 3)
  p = plot_grid(plotlist = list(coronal,saggital,axial,NULL),nrow = 2)
  p_title = ggdraw() + draw_label(title)
  plot_grid(p_title, p, ncol=1, rel_heights=c(0.05, 1))
}
