initialize_parallel <- function() {
  # Calculate the number of cores
  no_cores <- detectCores() - 1
  
  # Initiate cluster
  cl <- makeCluster(no_cores, type="FORK", outfile = "")
  
  registerDoParallel(cl)
  getDoParWorkers()
}




qc_fsleyes <- function(input, output, mask = NULL, tool) {
  foreach (i = 1:length(input)) %dopar% {
    
    if (tool == "T1" & is.null(mask)) {
      print("T1 missing mask")
      command <- paste0("fsleyes render -slightbox -zx Z -nr 3 -nc 8 -ss 7",
                        " -of ", output[i], " --size 1920 1200 ",
                        input[i]
                        )
    } else if (tool == "T2" & is.null(mask)) {
      print("T2 missing mask")
      command <- paste0("fsleyes render -slightbox -zx Z -nr 3 -nc 7 -zr 20 140",
                        " -of ", output[i], " --size 1920 1200 ",
                        input[i]
                        )
    } else if (tool == "T1") {
      print("T1")
      command <- paste0("fsleyes render -slightbox -zx Z -nr 3 -nc 8 -ss 7",
                        " -of ", output[i], " --size 1920 1200 ",
                        input[i], " ",
                        mask[i], " -a 30 -cm gist_rainbow"
                        )      
    } else if (tool == "T2") {
      print("T2")
      command <- paste0("fsleyes render -slightbox -zx Z -nr 3 -nc 7 -zr 20 140",
                        " -of ", output[i], " --size 1920 1200 ",
                        input[i], " ",
                        mask[i], " -a 30 -cm gist_rainbow"
                        )      
    }   
    
    print(i)
    print(command)
    system(command)
    
  }
}


qc_fsleyes_defacing_1 <- function(input_t1, input_mask_1, output_t1, slice_spacing) {
  foreach (i = 1:length(input_t1)) %dopar% {
    
    if(!file.exists(output_t1[i])) {
      
      ## crop-comparison (py vs mri_deface)
      command <- paste0("
    fsleyes render --scene lightbox -of ", output_t1[i], "  --size 1280 600 --worldLoc -5.170595138970214 2.1532757546884227 -1.7973756930368552 
    --displaySpace ", input_t1[i], " 
    --zaxis 2 --sliceSpacing ", slice_spacing, " --zrange 0 260 --ncols 8 --nrows 3 
    --hideCursor --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 
    --labelSize 12 

    --performance 3 ", input_t1[i], " 
    --overlayType volume --alpha 100.0 --brightness 65 --contrast 80 
    --cmap greyscale --negativeCmap greyscale --displayRange 28.066404171041086 1599.7849710952087 --clippingRange 28.066404171041086 4252.060053710938 
    --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 100 --blendFactor 0.1 --smoothing 0 --resolution 100 --numInnerSteps 10 
    --clipMode intersection 
    
    --volume 0 ", input_mask_1[i], "
    --overlayType volume --alpha 50 --brightness 50.0 --contrast 50.0 
    --cmap blue --negativeCmap greyscale --displayRange 0.0 4209.96044921875 --clippingRange 0.0 4252.060053710938 
    --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 100 --blendFactor 0.1 --smoothing 0 --resolution 100 --numInnerSteps 10 
    --clipMode intersection --volume 0  ")  
      
      command <- str_replace_all(command, "\n", "")
      
      system(command)
    } else {
      print(paste0("File ", output_t1[i], " does already exists. Delete it to create new output"))
    }
    
  }
}



qc_fsleyes_defacing <- function(input_t1, input_mask_1, input_mask_2, output_t1, slice_spacing) {
  foreach (i = 1:length(input_t1)) %dopar% {
    
    if(!file.exists(output_t1[i])) {
    
    ## crop-comparison (py vs mri_deface)
    command <- paste0("
    fsleyes render --scene lightbox -of ", output_t1[i], "  --size 1280 600 --worldLoc -5.170595138970214 2.1532757546884227 -1.7973756930368552 
    --displaySpace ", input_t1[i], " 
    --zaxis 2 --sliceSpacing ", slice_spacing, " --zrange 0 260 --ncols 8 --nrows 3 
    --hideCursor --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 
    --labelSize 12 

    --performance 3 ", input_t1[i], " 
    --overlayType volume --alpha 100.0 --brightness 65 --contrast 80 
    --cmap greyscale --negativeCmap greyscale --displayRange 28.066404171041086 1599.7849710952087 --clippingRange 28.066404171041086 4252.060053710938 
    --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 100 --blendFactor 0.1 --smoothing 0 --resolution 100 --numInnerSteps 10 
    --clipMode intersection 
    
    --volume 0 ", input_mask_1[i], "
    --overlayType volume --alpha 50 --brightness 50.0 --contrast 50.0 
    --cmap blue --negativeCmap greyscale --displayRange 0.0 4209.96044921875 --clippingRange 0.0 4252.060053710938 
    --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 100 --blendFactor 0.1 --smoothing 0 --resolution 100 --numInnerSteps 10 
    --clipMode intersection 
    
    --volume 0 ", input_mask_2[i], " 
    --overlayType volume --alpha 50 --brightness 50.0 --contrast 50.0 
    --cmap red-yellow --negativeCmap greyscale --displayRange 0.0 4209.96044921875 --clippingRange 0.0 4252.060053710938 
    --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 100 --blendFactor 0.1 --smoothing 0 --resolution 100 --numInnerSteps 10 
    --clipMode intersection --volume 0  ")  
    
    command <- str_replace_all(command, "\n", "")
    
    system(command)
    } else {
      print(paste0("File ", output_t1[i], " does already exists. Delete it to create new output"))
    }
    
  }
}


collage_nine <- function(raw, raw_mri_def, raw_pydef, r2std_raw, r2std_mri_def, r2std_pydef, crop_raw, crop_mri_def, crop_pydef, output_name, h_res = FALSE, l_res = TRUE) {
  
  for (i in 1:length(raw)) {
    

    high_res <- paste0("montage -label %f ", raw[i], " ", raw_mri_def[i], " ", raw_pydef[i], " ", 
                       r2std_raw[i]," ", r2std_mri_def[i], " ", r2std_pydef[i], " ",
                       crop_raw[i]," ", crop_mri_def[i], " ", crop_pydef[i], " ",
                       "-tile 3x3 -geometry '1000x500x5x5>' -pointsize 20 ", paste0("high_res_", output_name[i]))
    
    low_res <- paste0("montage -label %f ", raw[i], " ", raw_mri_def[i], " ", raw_pydef[i], " ", 
                      r2std_raw[i]," ", r2std_mri_def[i], " ", r2std_pydef[i], " ",
                      crop_raw[i]," ", crop_mri_def[i], " ", crop_pydef[i], " ",
                      "-tile 3x3 -geometry '500x250x5x5>' -pointsize 10 ", paste0("low_res_", output_name[i]))
    
    
    print(high_res)

    if (h_res == TRUE) {
      print(high_res)
      system(high_res)
    }
    if (l_res == TRUE) {
      print(low_res)
      system(low_res)
    }
  }
}

collage_four <- function(nat_ax, norm_ax, nat_sag, norm_sag, output_name, h_res = FALSE, l_res = TRUE) {
  
  for (i in 1:length(nat_ax)) {
    
    high_res <- paste0("montage -label %f ", 
                       nat_ax[i], " ", norm_ax[i], " ", 
                       nat_sag[i], " ", norm_sag[i]," ", 
                       "-tile 2x2 -geometry '1000x500x5x5>' -pointsize 20 ", output_name[i])
    
    low_res <- paste0("montage -label %f ", 
                      nat_ax[i], " ", norm_ax[i], " ", 
                      nat_sag[i], " ", norm_sag[i]," ",
                      "-tile 2x2 -geometry '500x250x5x5>' -pointsize 10 ", output_name[i])
    
    print(high_res)
    
    if (h_res == TRUE) {
      print(high_res)
      system(high_res)
    }
    if (l_res == TRUE) {
      print(low_res)
      system(low_res)
    }
  }
}



qc_fsleyes_dwi_nativ <- function(input_dwi_nativ, output_axial_png, output_sagittal_png) {
  
  foreach (i = 1:length(input_dwi_nativ)) %dopar% {
    
    # Axial
    axial <- paste0("fsleyes render --scene lightbox -of ", output_axial_png[i], " --size 1280 600 ",
                    "--worldLoc 4.031099449069302 8.501767812756896 -8.315426364178052 ",
                    "--displaySpace ", input_dwi_nativ[i], " ",
                    "--zaxis 2 --sliceSpacing 7 --zrange 10 115 --hideCursor ",
                    "--ncols 5 --nrows 3")
    # Sagittal
    sagittal <- paste0("fsleyes render --scene lightbox -of ", output_sagittal_png[i], " --size 1280 600 ",
                       "--worldLoc 4.031099449069302 8.501767812756896 -8.315426364178052 ",
                       "--displaySpace ", input_dwi_nativ[i], " ",
                       "--zaxis 0 --sliceSpacing 8 --zrange 60 210 --hideCursor ",
                       "--ncols 5 --nrows 3")
    
    system(axial)
    system(sagittal)
  }
}


qc_fsleyes_dwi_norm <- function(input_dwi_nativ, output_axial_png, output_sagittal_png) {
  
  foreach (i = 1:length(input_dwi_nativ)) %dopar% {
    
    # Axial
    axial <- paste0("fsleyes render --scene lightbox -of ", output_axial_png[i], " --size 1280 600 ",
                    "--worldLoc 4.031099449069302 8.501767812756896 -8.315426364178052 ",
                    "--displaySpace ", input_dwi_nativ[i], " ",
                    "--zaxis 2 --sliceSpacing 6 --zrange 50 170 --hideCursor ",
                    "--ncols 5 --nrows 3")
    # Sagittal
    sagittal <- paste0("fsleyes render --scene lightbox -of ", output_sagittal_png[i], " --size 1280 600 ",
                       "--worldLoc 4.031099449069302 8.501767812756896 -8.315426364178052 ",
                       "--displaySpace ", input_dwi_nativ[i], " ",
                       "--zaxis 0 --sliceSpacing 7 --zrange 30 150 --hideCursor ",
                       "--ncols 5 --nrows 3")
    
    system(axial)
    system(sagittal)
  }
}


mask_volume <- function(binary_mask){
  
  output <- system(paste0(
    "fslstats ", binary_mask, " -V"
  ), intern = TRUE)
  
}

mask_mean <- function(binary_mask){
  
  output <- system(paste0(
    "fslstats ", binary_mask, " -M"
  ), intern = TRUE)
  
}

mask_sd <- function(binary_mask){
  
  output <- system(paste0(
    "fslstats ", binary_mask, " -S"
  ), intern = TRUE)
  
}


create_mean_mask_native <- function(input1, input2, input3, input4, input5, input6, output_native){
  initialize_parallel()
  foreach (i = 1:length(input1)) %dopar% {
    
    system(paste0(
      "fslmaths '", 
      input1[i], "' -add '",
      input2[i], "' -add '",
      input3[i], "' -add '",
      input4[i], "' -add '",
      input5[i], "' -add '",
      input6[i], "' '",
      output_native[i], "'"
  ))
  }
}

create_mean_mask_cropped <- function(input1, input2, input3, output_cropped){
  initialize_parallel()
  foreach (i = 1:length(input1)) %dopar% {
    
    system(paste0(
      "fslmaths '", 
      input1[i], "' -add '",
      input2[i], "' -add '",
      input3[i], "' '",
      output_cropped[i], "'"
  ))
  }
}

create_mean_mask <- function(input1, input2, output_cropped){
  initialize_parallel()
  foreach (i = 1:length(input1)) %dopar% {
    
    system(paste0(
      "fslmaths '", 
      input1[i], "' -add '",
      input2[i], "' '",
      output_cropped[i], "'"
    ))
  }
}


flirt_files <- function(input, reference, output) {
  initialize_parallel()
  foreach (i = 1:length(input)) %dopar% {
    system(paste0(
      "flirt ",
      "-ref ", reference[i], " ",
      "-in ", input[i], " ",
      "-out ", output[i], " ",
      "-2D"))
  }
}

divide_number <- function(input, number, output){
  initialize_parallel()
  foreach (i = 1:length(input)) %dopar% {
    
    system(paste0(
      "fslmaths '", 
      input[i], "' -div '",
      number, "' '",
      output[i], "'"
    ))
  }
}

subtract_number <- function(input, number, output){
  initialize_parallel()
  foreach (i = 1:length(input)) %dopar% {
    
    system(paste0(
      "fslmaths '", 
      input[i], "' -sub ",
      number, " '",
      output[i], "'"
    ))
  }
}

threshold <- function(input, thresh_low, thresh_up, output){
  initialize_parallel()
  foreach (i = 1:length(input)) %dopar% {
    
    system(paste0(
      "fslmaths '", input[i],
      "' -thr ", thresh_low, 
      " -uthr ", thresh_up,
      " '", output[i], "'"
    ))
  }
}


threshold_upper <- function(input, thresh_up, output){
  initialize_parallel()
  foreach (i = 1:length(input)) %dopar% {
    
    system(paste0(
      "fslmaths '", input[i],
      "' -uthr ", thresh_up,
      " '", output[i], "'"
    ))
  }
}


threshold_lower <- function(input, thresh_low, output){
  initialize_parallel()
  foreach (i = 1:length(input)) %dopar% {
    
    system(paste0(
      "fslmaths '", input[i],
      "' -thr ", thresh_low, 
      " '", output[i], "'"
    ))
  }
}



qc_vertical <- function(input) {
  initialize_parallel()
  
  output <- str_replace(input, "derivatives", "qualitycontrol") %>% 
    str_replace("nii.gz", "png")
  
  path_to_folder(output)
  
  foreach (i = 1:length(input)) %dopar% {
    
    # Axial
    command <- paste0("fsleyes render --scene lightbox -of ", output[i], " --size 150 1200 ",
                    "--displaySpace ", input[i], " ",
                    "--zaxis 2 --sliceSpacing 10 --zrange 0 127 --hideCursor ",
                    "--ncols 1 --nrows 13")
    
    system(command)

  }
}

qc_vertical_masks <- function(input, mask) {
  initialize_parallel()
  
  output <- str_replace(input, "derivatives", "qualitycontrol") %>% 
    str_replace("nii.gz", "png")
  
  path_to_folder(output)
  
  foreach (i = 1:length(input)) %dopar% {
    
    # Axial
    command <- paste0("fsleyes render --scene lightbox -of ", output[i], " --size 1200 150 ",
                      "--displaySpace ", input[i], " ",
                      "--zaxis 2 --sliceSpacing 10 --zrange 0 127 --hideCursor ",
                      "--ncols 13 --nrows 1 --movieSync ", input[i], " --overlayType volume ",
                      
                      "--volume 0 ", mask[i], " --overlayType volume --cmap yellow ")
    
    system(command)
    
  }
}

collage_nine_vertical <- function(raw, raw_mri_def, raw_pydef, 
                                  r2std_raw, r2std_mri_def, r2std_pydef, 
                                  crop_raw, crop_mri_def, crop_pydef, 
                                  output_name, h_res = FALSE, l_res = TRUE) {
  
  for (i in 1:length(raw)) {
    
    
    high_res <- paste0("montage -label %f ", raw[i], " ", raw_mri_def[i], " ", raw_pydef[i], " ", 
                       r2std_raw[i]," ", r2std_mri_def[i], " ", r2std_pydef[i], " ",
                       crop_raw[i]," ", crop_mri_def[i], " ", crop_pydef[i], " ",
                       "-tile 9x1 -geometry '2000x2000+1+1>' -pointsize 20 ", output_name[i])
    
    low_res <- paste0("montage -label %f ", raw[i], " ", raw_mri_def[i], " ", raw_pydef[i], " ", 
                      r2std_raw[i]," ", r2std_mri_def[i], " ", r2std_pydef[i], " ",
                      crop_raw[i]," ", crop_mri_def[i], " ", crop_pydef[i], " ",
                      "-tile 9x1 -geometry '100x1000+1+1>' -pointsize 10 ", output_name[i])
    
    
    print(high_res)
    
    if (h_res == TRUE) {
      print(high_res)
      system(high_res)
    }
    if (l_res == TRUE) {
      print(low_res)
      system(low_res)
    }
  }
}


collage_eight_horizontal <- function(raw, raw_mri_def, raw_pydef, r2std_raw, 
                                     r2std_mri_def, r2std_pydef, crop_raw, crop_mri_def, 
                                  output_name) {
  path_to_folder(unique(output_name))
  for (i in 1:length(raw)) {
    
    
    high_res <- paste0("montage -label %f ", 
                       raw[i], " ", raw_mri_def[i], " ", raw_pydef[i], " ", r2std_raw[i]," ", 
                       r2std_mri_def[i], " ", r2std_pydef[i], " ", crop_raw[i]," ", crop_mri_def[i], " ",
                       "-tile 1x8 -geometry '1000x120+1+1>' -pointsize 20 ", output_name[i])
    
    print(high_res)
    system(high_res)
  }
}

