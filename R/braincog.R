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
                           resources = list(ntasks=1,ncpus=1,mem=10000,walltime=180),
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
                       compute_cca_da2,
                       BPPARAM = param,
                       morphometry = morphometry,
                       cognition = cognition,
                       gray_matter = gray_matter)
  # extract cluster sizes
  cs_perm = lapply(perm_list,function(perm) perm$cs) %>% bind_rows
  cs_perm[is.na(cs_perm)] = 0

  # extract cognitive scores abolute differences
  delta_cog_perm = lapply(perm_list, function(perm) perm$delta_cog) %>% bind_rows

  # save everything in result list
  res = NULL
  res$gray_matter = gray_matter
  res$penaltyx = perm_list[[1]]$bestpenaltyx
  res$penaltyz = perm_list[[1]]$bestpenaltyz
  res$min_clustersize = min_clustersize
  res$num_perm = num_perm
  res$alpha = alpha
  res$slurm = slurm
  res$num_cores = num_cores
  res$seed = seed
  # recompute the unpermuted case
  res$seg = compute_cca_da2(fac,morphometry,cognition,gray_matter,
                            penaltyx = res$penaltyx,
                            penaltyz = res$penaltyz,
                            return_seg = TRUE)$seg
  res$cs_perm = cs_perm
  res$delta_cog_perm = delta_cog_perm
  res$fac_list = fac_list

  # define class for plotting and summary
  class(res) = "braincog"
  res
}
