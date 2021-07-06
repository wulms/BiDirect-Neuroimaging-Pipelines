fsl_bet <- function(input, fval) {
  foreach (i = 1:length(input)) %dopar% {
    output = str_replace(input[i], "T2", paste0("T2_", fval)) %>%
      str_replace("//", "/") %>% 
      str_replace("derivatives/FSL/3-FSL_pipeline/", "derivatives/FSL/4-FSL_FLAIR_BET/") %>%
      str_replace("/anat.anat/", "_")
    
    path_to_folder(unique(output))
    
    command <- paste0("bet ", input[i], 
                      " ", output,
                      " -f ", fval,
                      " -R -S ")
    lapply(command, system)

    }
  
}