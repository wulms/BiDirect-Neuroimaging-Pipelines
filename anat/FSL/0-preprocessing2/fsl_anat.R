fsl_anat <- function(input, output_folder) {
  foreach (i = 1:length(input)) %dopar% {

  # Apply realignment matrix to image
  command = paste0("fsl_anat ",
                   "-i ", input[i], " ",
                   "-o ", output_folder[i], " ",
                   "-t T1")
  
  system(command)
  
  
  
  }
}
  

fsl_anat_t2 <- function(input, output_folder) {
  foreach (i = 1:length(input)) %dopar% {
    
    # Apply realignment matrix to image
    command = paste0("fsl_anat ",
                     "-i ", input[i], " ",
                     "-o ", output_folder[i], " ",
                     "-t T2 --nononlinreg --nosubcortseg")
    
    system(command)
    
    
    
  }
}
