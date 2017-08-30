#' Label cluster in image.
#'
#' @import SimpleITK
#' @import magrittr
#' @export
#'
label_cluster = function(arr) {
  arr %>%
    as.image %>%
    ScalarConnectedComponent %>%
    RelabelComponent %>%
    as.array
}
