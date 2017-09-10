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

  # extract slices centered at median cluster position
  saggital = plot_cluster(color_arr,color = tb$color,axis = 1)
  coronal = plot_cluster(color_arr,color = tb$color,axis = 2)
  axial = plot_cluster(color_arr,color = tb$color,axis = 3)
  p = plot_grid(plotlist = list(coronal,saggital,axial,NULL),nrow = 2)
  title = ggdraw() + draw_label(paste("Cluster",tb$id))
  plot_grid(title, p, ncol=1, rel_heights=c(0.05, 1))
}
