initialize_parallel <- function() {
  # Calculate the number of cores
  no_cores <- detectCores() - 1
  
  # Initiate cluster
  cl <- makeCluster(no_cores, type = "FORK", outfile = "")
  
  registerDoParallel(cl)
  getDoParWorkers()
}


fsl_flirt <- function(input_volume,
                      input_reference,
                      prefix,
                      dof) {
  initialize_parallel()
  foreach (i = 1:length(input_volume)) %dopar% {
    output = str_replace(input_volume[i],
                         ".nii.gz",
                         paste0("_", prefix, "_", dof, ".nii.gz"))
    
    output_mat = str_replace(output, ".nii.gz", paste0(".mat"))
    path_to_folder(unique(output))
    command <- paste0(
      "flirt -in ",
      input_volume[i],
      " -ref ",
      input_reference[i],
      " -out ",
      output,
      " -omat ",
      output_mat,
      " -dof ",
      dof
    )
    command <- command[!file.exists(output)]
    
    lapply(command, system)
  }
  # stopCluster(cl)
}

fsl_convert_xfm <- function(input_mat) {
  initialize_parallel()
  output = str_replace(input_mat, "\\.mat", "_inverse.mat")
  foreach (i = 1:length(input_mat)) %dopar% {
    command <- paste0("convert_xfm -omat ", output[i],
                      " -inverse ", input_mat[i])
    if(!file.exists(output[i]))
    {
      system(command)
    }
  }
  #stopCluster(cl)
  
}

fsl_convert_xfm_add_masks <- function(input_mat1, input_mat2) {
  initialize_parallel()
  output = str_replace(input_mat1, "\\.mat", "_FLAIR_to_MNI.mat")
  foreach (i = 1:length(input_mat2)) %dopar% {
    command <- paste0("convert_xfm -omat ", output[i],
                      " -concat ", input_mat2[i], " ",
                      input_mat1[i])
    if(!file.exists(output[i]))
    {
      system(command)
    }
  }
  #stopCluster(cl)
  
}

fsl_flirt_to_space <-
  function(input_nii,
           input_ref,
           input_mat, 
           prefix) {
    initialize_parallel()
    
    output <- str_replace(input_nii, ".nii", paste0(prefix, ".nii"))
    path_to_folder(unique(output))
    
    #output_nii <- str_replace(input_mat, "T2", "T1") %>% str_replace(".mat", ".nii.gz")
    foreach (i = 1:length(input_nii)) %dopar% {
      command <- paste0(
        "flirt -in ",
        input_nii[i],
        " -ref ",
        input_ref[i],
        " -out ",
        output[i],
        " -init ",
        input_mat[i],
        " -applyxfm"
      )
      if(!file.exists(output[i]))
      {
        system(command)
      }
    }
    #stopCluster(cl)
    
  }


fslmaths_mask <- function(input_nii,
                          input_mask) {
    initialize_parallel()
    
    output_nii <- str_replace(input_mask, "(T1w|T1)_", "FLAIR_T1w_space_")
    head(output_nii)
    foreach (i = 1:length(input_nii)) %dopar% {
      command <- paste0(
        "fslmaths ",
        input_nii[i],
        " -mas ",
        input_mask[i],
        " ",
        output_nii[i]
      )
      print(command)
      if(!file.exists(output_nii[i]))
      {
        print(command)
        system(command)
      }
    }
    # stopCluster(cl)
    
  }

