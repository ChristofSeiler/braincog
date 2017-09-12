#' Plot cluster array.
#'
#' @import ggplot2
#' @import magrittr
#' @import reshape2
#' @export
#'
plot_cluster = function(color_arr,color,axis) {

  # get median slice
  position = which(color_arr == color,arr.ind = TRUE)
  xyz = apply(position,2,median)
  slice_no = xyz[axis]

  # extract slice
  array_dims = lapply(1:3,function(i) seq_len(dim(color_arr)[i]))
  array_dims[[axis]] = slice_no
  slice = color_arr[array_dims[[1]],
                    array_dims[[2]],
                    array_dims[[3]]] %>% flop

  # reshape and plot
  slice_long = reshape2::melt(slice)
  x_labl = y_lab = ""
  if (axis ==  1) {
    x_lab = "anterior <-> posterior"
    y_lab = "inferior <-> superior"
  } else if (axis == 2) {
    x_lab = "right <-> left"
    y_lab = "inferior <-> superior"
  } else if (axis == 3) {
    x_lab = "right <-> left"
    y_lab = "posterior <-> anterior"
  }
  ggplot(slice_long, aes(x = Var1, y = Var2, fill = value)) +
    geom_raster() +
    scale_fill_manual(values = levels(slice_long$value)) +
    coord_fixed(ratio = 1) +
    xlim(0, dim(slice)[1]) +
    ylim(0, dim(slice)[2]) +
    theme_bw() +
    theme(#plot.title = element_text(hjust = 0.5),
      legend.position = "none",
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank()) +
    labs(x = x_lab, y = y_lab)
  #theme(panel.border = element_blank(),
  #      axis.line = element_blank())

}
