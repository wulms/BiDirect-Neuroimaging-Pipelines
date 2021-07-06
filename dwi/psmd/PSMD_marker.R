psmd <- function(dwi_input) {
  # Starting parallel cluster
  # Calculate the number of cores
  no_cores <- detectCores() - 2
  # Initiate cluster
  cl <- makeCluster(no_cores, type="FORK", outfile = "")
  getDoParWorkers()
  registerDoParallel(cl)
  
  # Input filenames
  bval = str_replace(dwi_input, ".nii.gz", ".bval")
  bvec = str_replace(dwi_input, ".nii.gz", ".bvec")
  
  dwi_input = dwi_input[file.exists(bval)]
  head(dwi_input)

    # Output file and foldernames
  psmd_txt <- str_replace(dwi_input, "dwi.nii.gz", "psmd.txt") 
  msmd_txt <- str_replace(dwi_input, "dwi.nii.gz", "msmd.txt")  
  
  folder <- sub("[/][^/]+$", "", dwi_input)
  
  foreach (i = 1:length(dwi_input)) %dopar% {
    # Shell command
    command_psmd <- paste0("bash ", psmd_script, " -t ", 
                      " -d ", dwi_input[i], 
                      " -b ", bval[i],
                      " -r ", bvec[i],
                      " -s ", skeleton_mask,
                      " > ", psmd_txt[i])
    
    command_msmd <- paste0("bash ", psmd_script, " -o -t ", 
                      " -d ", dwi_input[i], 
                      " -b ", bval[i],
                      " -r ", bvec[i],
                      " -s ", skeleton_mask,
                      " > ", msmd_txt[i])
    
    print(command_psmd)
    print(command_msmd)
    
    if(!file.exists(psmd_txt[i])){
      setwd(folder[i])
      system(command_psmd)
    }
    if(!file.exists(msmd_txt[i])){
      setwd(folder[i])
      system(command_msmd)
    }
    
  }
  stopCluster(cl)
}