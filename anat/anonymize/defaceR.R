add_nii_suffix <- function(input, suffix){
  output <- str_replace(input, ".nii", paste0("_", suffix, ".nii"))
  return(output)
}

defaceR <- function(input, tool) {
  foreach (i = 1:length(input)) %dopar% {
    
    # change the paths here to your local files
    pydeface_path = "~/pydeface/pydeface"
    mri_deface_path = "/usr/local/freesurfer/bin/mri_deface"
    mri_deface_template = "/mnt/458e8a35-865f-4f0e-ab7e-8b4ac8684363/WML121/templates/mri_deface/talairach_mixed_with_skull.gca"
    mri_deface_face = "/mnt/458e8a35-865f-4f0e-ab7e-8b4ac8684363/WML121/templates/mri_deface/face.gca"
    
      if (tool == "pydeface") {
        output[i] = add_nii_suffix(input[i], "pydeface")
        
        
        # by Poldrack
        command = paste0("python3.7 ", 
                         pydeface_path, " ",
                         input[i], " ",
                         "--outfile " , output[i], " ",
                         "--verbose")
        
      } else if (tool == "mri_deface") {
        output[i] = add_nii_suffix(input[i], "mri_deface")
        
        # by Freesurfer
        command = paste0(mri_deface_path, " ",
                         input[i], " ",
                         mri_deface_template, " ",
                         mri_deface_face, " ",
                         output[i])
        
      } else if (tool == "fsl_deface") {
        output[i] = add_nii_suffix(input[i], "fsl_deface")
        
        # by FSL
        command = paste0("fsl_deface ",
                         input[i], " ",
                         output[i])
        
      }
    
    
    
      print(command)
      if(!file.exists(output[i])){
        system(command)
    } else {
      print(paste0("The file ", output[i], " already exists."))
    }
  }
}