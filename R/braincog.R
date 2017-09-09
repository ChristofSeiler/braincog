#' Differential sparse canonical correlation analysis.
#'
#' @import PMA
#' @import SimpleITK
#' @import magrittr
#' @import tibble
#' @import dplyr
#' @import BiocParallel
#' @import parallel
#' @import BatchJobs
#' @export
#'
braincog = function(fac,
                    morphometry,
                    cognition,
                    gray_matter,
                    penaltyz,
                    top = 100,
                    num_perm = 1000,
                    alpha = 0.05,
                    slurm = FALSE,
                    num_cores = 4,
                    seed = 0xdada) {

  # random permutations of levels
  fac_list = lapply(seq(num_perm-1),function(i) sample(fac))
  fac_list = append(list(fac),fac_list)

  # for cluster
  fun = function(fac,morphometry,cognition,gray_matter,penaltyz,top = top,return_seg = FALSE) {
    library("braincog")

    # compute the difference vector
    sign_diff = compute_cca_da(fac = fac,
                               morphometry = morphometry,
                               cognition = cognition,
                               penaltyz = penaltyz)

    # convert to image
    sign_diff_arr = array(0, # background
                          dim = dim(gray_matter))
    sign_diff_arr[gray_matter==1] = sign_diff

    # label connected components
    seg = label_cluster(sign_diff_arr)

    # count component size (background is excluded)
    cs = tibble(cluster_size(k = 1:100,arr = seg))

    if(return_seg) return(seg) else return(cs)
  }

  # run either on slurm cluster or multi-threaded
  param = NULL
  if(slurm) {
    slurm_settings = system.file("exec", "slurm.tmpl", package = "braincog")
    param = BatchJobsParam(workers = length(fac_list),
                           resources = list(ntasks=1,ncpus=1,mem=8000,walltime=10),
                           cluster.functions = makeClusterFunctionsSLURM(slurm_settings),
                           log = TRUE,
                           logdir = ".",
                           progressbar = TRUE,
                           cleanup = FALSE,
                           seed = seed)
  } else {
    param = MulticoreParam(workers = num_cores,
                           tasks = length(fac_list),
                           log = TRUE,
                           logdir = ".",
                           progressbar = TRUE,
                           cleanup = FALSE,
                           seed = seed)
  }
  cs_perm = bplapply(fac_list,
                     fun,
                     BPPARAM = param,
                     morphometry = morphometry,
                     cognition = cognition,
                     gray_matter = gray_matter,
                     penaltyz = penaltyz,
                     top = top) %>% bind_cols %>% t
  cs_perm[is.na(cs_perm)] = 0
  pvalues = sapply(seq(ncol(cs_perm)),
                   function(k) mean(cs_perm[1,k] <= cs_perm[,k]))
  cluster_labels = which(p.adjust(pvalues,method = "BH") < alpha) +
    1 # add one to account for background

  # save everything in result list
  res = NULL
  res$gray_matter = gray_matter
  res$penaltyz = penaltyz
  res$top = top
  res$num_perm = num_perm
  res$alpha = alpha
  res$slurm = slurm
  res$num_cores = num_cores
  # recompute the unpermuted case
  seg = fun(fac,morphometry,cognition,gray_matter,penaltyz,top,return_seg = TRUE)
  res$seg = seg
  seg_select = array(0,dim = dim(gray_matter))
  for(label in cluster_labels) seg_select[seg==label] = label
  res$seg_select = seg_select
  res$cs_perm = cs_perm
  res$pvalues = pvalues
  res$cluster_labels = cluster_labels

  # define class for plotting and summary
  class(res) = "braincog"
  res
}
