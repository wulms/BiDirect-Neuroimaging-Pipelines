psmd <- function(dwi_input, bval, bvec, subject_path, skeleton_mask) {
  
  setwd(working_dir)
  foreach (i = 1:length(dwi_input)) %dopar% {
    
    setwd(subject_path[i])

    command <- paste0("bash /home/niklas/Downloads/installer/psmd/psmd/psmd.sh -t", 
                      " -d ", dwi_input[i], 
                      " -b ", bval[i],
                      " -r ", bvec[i],
                      " -s ", input_nii$skeleton_mask[i],
                      " > psmd.txt"
    )
    print(command)
    system(command)
  }
}