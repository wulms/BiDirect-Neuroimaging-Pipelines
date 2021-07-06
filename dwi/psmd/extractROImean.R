extract_ROI_mean <- function(dti_image, skeleton_mask, atlas, path, roinum, roiname) {
  
  ROI_name_nii <- paste0(roiname, "_", roinum, ".nii.gz")
  
  path <- path %>% str_replace("dwi", "dwi/ROI")
  
  skeleton_mask_id <- str_replace(skeleton_mask, "/home/niklas/MATLAB_Neuroimaging/template/fsl/", "")
  
  ROI_individual <- paste0(roiname, "_", roinum, "_", skeleton_mask_id[1])
  ROI_name_txt <- paste0(path, "/", roiname, "_", roinum, ".txt")
  
  # Writes the general ROI mask
  command <- paste0("fslmaths ", atlas[1], " -thr ", roinum, " -uthr ", roinum, " -bin ", ROI_name_nii)
  
  # Applies mask (for every subject the same) - White matter, Brain, Skeleton
  command2 <- paste0("fslmaths ", ROI_name_nii," -mas ", skeleton_mask[1], " -bin ", ROI_individual)
  
  #print(command)
  system(command)
  
  #print(command2)
  system(command2)
  
  for (i in 1:length(dti_image)) {
    
    dir.create(path[i], recursive = TRUE, showWarnings = FALSE)
    
    # Uses skeleton masked ROI mask for extraction of mean
    command3 <- paste0("fslmeants -i ", dti_image[i], " -m ", ROI_individual," -o ", ROI_name_txt[i])
    
    #print(command3)
    system(command3)
    
  }
}
