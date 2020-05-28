fsl_bet <- function(input, fval) {
  initialize_parallel()
  foreach (i = 1:length(input)) %dopar% {
    output = str_replace(input[i], "T2", paste0("T2_", fval)) %>%
      str_replace("//", "/") %>% 
      str_replace("/fsl_anat_pipeline/", "/fsl_bet_pipeline/") %>%
      str_replace("/anat.T2/", "_")
    
    path_to_folder(unique(output))
    
    command <- paste0("bet ", input[i], 
                      " ", output,
                      " -f ", fval,
                      " -R -S ")
    
    command <- command[!file.exists(output)]
    
    lapply(command, print)
    
  }
  
}
