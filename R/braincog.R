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
                    min_clustersize,
                    num_perm = 1000,
                    alpha = 0.05,
                    slurm = FALSE,
                    num_cores = 4,
                    seed = 0xdada) {

  # random permutations of levels
  fac_list = lapply(seq(num_perm-1),function(i) sample(fac))
  fac_list = append(list(fac),fac_list)

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
  perm_list = bplapply(fac_list,
                       compute_cca_da,
                       BPPARAM = param,
                       morphometry = morphometry,
                       cognition = cognition,
                       gray_matter = gray_matter,
                       penaltyz = penaltyz)
  # extract cluster sizes
  cs_perm = lapply(perm_list,function(perm) perm$cs) %>% bind_cols %>% t
  cs_perm[is.na(cs_perm)] = 0
  pvalues = sapply(seq(ncol(cs_perm)),
                   function(k) mean(cs_perm[1,k] <= cs_perm[,k]))
  # keep only pvalues that are bigger than predefined min detectable size
  pvalues = pvalues[cs_perm[1,] > min_clustersize]

  # extract cognitive scores abolute differences
  delta_cog_perm = lapply(perm_list,
                          function(perm) as.tibble(perm$delta_cog)) %>% bind_cols %>% t

  # save everything in result list
  res = NULL
  res$gray_matter = gray_matter
  res$penaltyz = penaltyz
  res$min_clustersize = min_clustersize
  res$num_perm = num_perm
  res$alpha = alpha
  res$slurm = slurm
  res$num_cores = num_cores
  res$seed = seed
  # recompute the unpermuted case
  res$seg = compute_cca_da(fac,morphometry,cognition,gray_matter,penaltyz,
                           return_seg = TRUE)$seg
  res$cs_perm = cs_perm
  res$pvalues = pvalues
  res$delta_cog_perm = delta_cog_perm

  # define class for plotting and summary
  class(res) = "braincog"
  res
}
