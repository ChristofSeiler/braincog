#' Plot braincog object.
#'
#' @import magrittr
#' @import cowplot
#' @export
#'
plot.braincog = function(fit,cluster_id) {

  # extract from results
  seg = fit$seg
  gray_matter = fit$gray_matter

  # get summary table with cluster to color assignment
  tb = summary(fit) %>% filter(id == cluster_id)

  # color background and gray matter
  color_arr = array("white",dim = dim(seg))
  color_arr[gray_matter==1] = "darkgray"

  # color cluster
  color_arr[ seg == tb$label ] = tb$color

  # remove margin
  crop_x = 20
  crop_y = 20
  crop_z = 20
  dims = dim(color_arr)
  color_arr = color_arr[(crop_x+1):(dims[1]-crop_x),
                        (crop_y+1):(dims[2]-crop_y),
                        (crop_z+1):(dims[3]-crop_z)]

  # extract slices centered at median cluster position
  saggital = plot_cluster(color_arr,color = tb$color,axis = 1)
  coronal = plot_cluster(color_arr,color = tb$color,axis = 2)
  axial = plot_cluster(color_arr,color = tb$color,axis = 3)
  p = plot_grid(plotlist = list(coronal,saggital,axial,NULL),nrow = 2)
  title = ggdraw() + draw_label(paste("Cluster",tb$id))
  plot_grid(title, p, ncol=1, rel_heights=c(0.05, 1))
}
