fsl_bet <- function(input, fval) {
  initialize_parallel()
  foreach (i = 1:length(input)) %dopar% {
    output = str_replace(input[i], ".nii", paste0("_bet_", fval, ".nii")) 
    
    path_to_folder(unique(output))
    
    command <- paste0("bet ", input[i], 
                      " ", output,
                      " -f ", fval,
                      " -R -S ")
    
    command <- command[!file.exists(output)]
    
    lapply(command, system)
    
  }
  
}
