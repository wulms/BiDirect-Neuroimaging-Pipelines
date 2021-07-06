fsl_anat <- function(input, output_folder) {
  foreach (i = 1:length(input)) %dopar% {

  # Apply realignment matrix to image
  command = paste0("fsl_anat --betfparam=.5 ",
                   "-i ", input[i], " ",
                   "-o ", output_folder[i], " ",
                   "-t T1")
  
  system(command)
  
  
  
  }
}
  