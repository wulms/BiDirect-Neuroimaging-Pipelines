fsl_anat <- function(input, output_folder) {
  initialize_parallel(not_use = 1)
  path_to_folder(unique(output_folder))

  output_file <- paste0(output_folder, ".anat/T1_subcort_seg.nii.gz")
  
  foreach (i = 1:length(input)) %dopar% {
    # Apply realignment matrix to image
    command = paste0("fsl_anat ",
                     "-i ", input[i], " ",
                     "-o ", output_folder[i], " ",
                     "-t T1")
    
    if(!file.exists(output_file[i]))
    {
      system(command, intern = TRUE)
    }
    stopCluster(cl)
  }
}


fsl_anat_t2 <- function(input, output_folder) {
  initialize_parallel(not_use = 1)
  path_to_folder(unique(output_folder))
  output_file <- paste0(output_folder, ".anat/T1_subcort_seg.nii.gz") ????
  
  foreach (i = 1:length(input)) %dopar% {
    
    # Apply realignment matrix to image
    command = paste0("fsl_anat ",
                     "-i ", input[i], " ",
                     "-o ", output_folder[i], " ",
                     "-t T2 --nononlinreg --nosubcortseg")
    if(!file.exists(output_file[i]))
    {
      system(command, intern = TRUE)
    }
    stopCluster(cl)
  }
}


