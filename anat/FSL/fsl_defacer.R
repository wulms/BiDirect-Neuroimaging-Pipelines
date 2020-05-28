fsl_reorient <- function(input, output) {
  initialize_parallel(not_use = 1)
  path_to_folder(unique(output))
  foreach(i = 1:length(input)) %dopar% {
    if(!file.exists(output[i])){
      command = paste0("fslreorient2std ", input[i], " ", output[i])
      print(command)
      system(command)
    }
  }
}

fsl_crop <- function(input, output) {
  initialize_parallel(not_use = 1)
  path_to_folder(unique(output))
  foreach(i = 1:length(input)) %dopar% {
    if(!file.exists(output[i])){
      command = paste0("robustfov -i ", input[i], " -r ", output[i])
      print(command)
      system(command)
    }
  }
}


defaceR <- function(input, output) {
  initialize_parallel(not_use = 1)
  path_to_folder(unique(output))
  foreach(i = 1:length(input)) %dopar% {
    if(!file.exists(output[i])){
      command = paste0("fsl_deface ", input[i], " ", output[i])
      print(command)
      system(command)
    }
  }
}

defaceR_bias <- function(input, output) {
  initialize_parallel(not_use = 1)
  path_to_folder(unique(output))
  foreach(i = 1:length(input)) %dopar% {
    if(!file.exists(output[i])){
      command = paste0("fsl_deface ", input[i], " -B ", output[i])
      print(command)
      system(command)
    }
  }
}

  fsl_remove_acquisitions <- function(input, output, volumes_to_remove, total_volumes)
  for (i in input) {
    if(!file.exists(output[i])){
      command = paste0("fslroi ", input, " ", output, " ", volumes_to_remove, " ", total_volumes)
      print(command)
    }
  }
  
  
  
          