#' Differential sparse canonical correlation analysis.
#'
#' @import PMA
#' @import SimpleITK
#' @import magrittr
#' @import tidyverse
#' @export
#'
braincog = function(fac,
                    morphometry,
                    cognition,
                    gray_matter,
                    top = 100,
                    num_perm = 1000,
                    alpha = 0.05) {

  # random permutations of levels
  fac_list = lapply(seq(num_perm-1),function(i) sample(fac))
  fac_list = append(list(fac),fac_list)

  # for cluster
  fun = function(fac,morphometry,cognition,gray_matter,top = top,return_seg = FALSE) {
    library("braincog")

    # compute the difference vector
    sign_diff = compute_cca_da(fac = fac,
                               morphometry = morphometry,
                               cognition = cognition)

    # convert to image
    sign_diff_arr = array(0, # background
                          dim = dim(gray_matter))
    sign_diff_arr[gray_matter==1] = sign_diff

    # label connected components
    seg = label_cluster(sign_diff_arr)

    # count component size (background is excluded)
    cs = cluster_size(k = 1:100,arr = seg)

    if(return_seg) return(seg) else return(cs)
  }

  # run in parallel
  param = BatchJobsParam(workers = length(fac_list),
                         resources = list(ntasks=1,ncpus=1,mem=4000,walltime=180),
                         cluster.functions = makeClusterFunctionsSLURM("slurm.tmpl"),
                         log = TRUE,
                         logdir = ".",
                         progressbar = TRUE,
                         cleanup = FALSE,
                         seed = 0xdada)
  cs_perm = bplapply(fac_list,
                     fun,
                     BPPARAM = param,
                     morphometry = morphometry,
                     cognition = cognition,
                     gray_matter = gray_matter,
                     top = top) %>% do.call(rbind,.)

  pvalues = sapply(seq(ncol(cs_perm)),
                   function(k)
                     sum(cs_perm[1,k] <= cs_perm[,k])/nrow(cs_perm))
  significant_clusters = which(pvalues %>% p.adjust(method = "BH") < alpha)
  res = NULL
  if(length(significant_clusters) > 0) {
    # recompute the unpermuted case
    seg = fun(fac,morphometry,cognition,gray_matter,top,return_seg = TRUE)
    significant_clusters = significant_clusters+1 # add background
    seg_select = array(0,dim = dim(gray_matter))
    for(label in significant_clusters) seg_select[seg==label] = label
    res$seg = seg_select
  }

  # define class for plotting and summary
  class(res) = "braincog"
  res
}
