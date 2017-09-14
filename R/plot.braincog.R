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

  # remove margin and extract slices centered at median cluster position
  combine_slices(color_arr,
                 center_color = tb$color,
                 crop = 20,
                 title = paste("Cluster",tb$id))
}
