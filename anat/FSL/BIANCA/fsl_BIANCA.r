initialize_parallel <- function(not_use = 2) {
  # Calculate the number of cores
  no_cores <- detectCores() - not_use
  
  # Initiate cluster
  cl <- makeCluster(no_cores, type = "FORK", outfile = "")
  
  registerDoParallel(cl)
  getDoParWorkers()
  return(cl)
}

# BIANCA LOO function

bianca_r <- function(masterfile, model_name, cores_not_used = 2) {
  initialize_parallel(not_use = cores_not_used)
  #path_to_folder(unique(output_name))
  
  output_name <- read_delim(masterfile, delim = "\t", col_names = FALSE)[[1]] %>% as.list() %>% lapply(., str_replace, ".nii.gz", paste0("_mask_", model_name, ".nii.gz"))
  
  foreach (i = 1:length(output_name)) %dopar% {
    
    
    if (!file.exists(output_name[[i]])) {
      command <- paste0("bianca --singlefile=", masterfile, 
                        " --labelfeaturenum=4 --brainmaskfeaturenum=1 --querysubjectnum=", i,
                        " --trainingnums=all --featuresubset=1,2 --matfeaturenum=3 --trainingpts=2000 --nonlespts=10000 --selectpts=noborder -o '", output_name[[i]],
                        "'"#, " --saveclassifierdata ", output_name[i] 
                        #" -v"
      )
      cat("\014")  
      print(command)
      system(command)
    }
  }
}


# BIANCA training function

train_bianca <- function(masterfile, output_name, output_classifier) {
  initialize_parallel()
  foreach (i = 1:length(output_classifier)) %dopar% {
    query_subject <- read_table(masterfile[i], col_names = FALSE) %>% nrow()
    command <- paste0("bianca --singlefile=", masterfile[i], 
                      " --labelfeaturenum=4 --brainmaskfeaturenum=1 --querysubjectnum=", query_subject,
                      " --trainingnums=all --featuresubset=1,2 --matfeaturenum=3 --trainingpts=2000 --nonlespts=10000 --selectpts=noborder -o '", output_name[i],
                      "' --saveclassifierdata ", output_classifier[i]
                      #" -v"
    )
    
    #print(command)
    system(command)
    #cat("\014")
  }
}

# BIANCA test function

test_bianca <- function(masterfile, output_name, input_classifier, cores_not_used = 2) {
  initialize_parallel(not_use = cores_not_used)
  
  foreach (i = 1:length(output_name)) %dopar% {
    path_to_folder(output_name[i])
    command <- paste0("bianca --singlefile=", masterfile, 
                      " --loadclassifierdata=", input_classifier,
                      " --brainmaskfeaturenum=1 --querysubjectnum=", i,
                      " --featuresubset=1,2 --matfeaturenum=3 -o ", output_name[i] 
                      #" -v"
    )
    
    print(command)
    #system(command)
    cat("\014")
  }
}

application_bianca_classifiers <- function(trained_models, test_sets, prefix){
  for (i in 1:length(trained_models)) {
    # Clear terminal
    cat("\014")
    
    # Creation of output folders
    output_folder <- paste0("/mnt/Vierer/BIDS/derivatives_temp/FSL/fsl_bianca_pipeline/", prefix)
    print(output_folder)
    # Reading in of file list for model application
    output_masks <- read.table(test_sets[i], sep = '\t', header = FALSE)[,1] %>% as.character() %>%
      str_replace("/mnt/Vierer/BIDS/derivatives_temp/FSL/fsl_deface_pipeline/", output_folder) %>% 
      str_replace("/mnt/Vierer/BIDS/derivatives_temp/FSL/fsl_deface_anat_pipeline/", output_folder) %>%
      str_replace("/mnt/Vierer/BIDS/derivatives_temp/FSL/fsl_bianca_pipeline2/bet/", output_folder) %>%
      str_replace(".nii.gz", "_BIANCA_mask.nii.gz")
    # print(length(output_masks))
    # print(head(output_masks))
    
    cl <- initialize_parallel(not_use = 2)
    
    
    #for (j in 1:length(output_masks)){
    
    
    foreach(j = 1:length(output_masks)) %dopar% {
    #foreach(j = 1:length(10)) %dopar% # for debug
        
      path_to_folder(output_masks[j])
      cat("\014")
      
      command <- paste0("bianca --singlefile=", test_sets[i], 
                        " --loadclassifierdata=", trained_models[i],
                        " --brainmaskfeaturenum=1 --querysubjectnum=", j,
                        " --featuresubset=1,2 --matfeaturenum=3 -o ", output_masks[j] 
                        #" -v"
      )
      # print(command)
      if(!file.exists(output_masks[j])) {
        system("clear")
        system(command)
      }
    }
    stopCluster(cl)
  }
}

# BIANCA measures

bianca_performance <- function(lesionmask, threshold, manualmask, saveoutput = 0, output_name){
  cl <- initialize_parallel(2)
  foreach (i = 1:length(lesionmask)) %dopar% {
    print(i)
    
    if(file.exists(output_name[i]) == 0) {
      command <- paste0("/bin/bash bianca_overlap_measures ",
                        lesionmask[i], " ",
                        threshold[i], " ",
                        manualmask[i], " ",
                        saveoutput, " > ", output_name[i])
      print(command)
      system(command)
    }
  }
  stopCluster(cl)
}

bianca_cluster_info <- function(lesionmask, threshold, min_cluster_size = 0){
  cl <- initialize_parallel(2)
  output_name <- str_replace(lesionmask, ".nii.gz", paste0("_", threshold, ".txt"))
  foreach (i = 1:length(lesionmask)) %dopar% {
    print(i) 
    
    if(file.exists(output_name[i]) == 0) {
      command <- paste0("bianca_cluster_stats ",
                        lesionmask[i], " ",
                        threshold, " ",
                        min_cluster_size, " > ", output_name[i])
      print(command)
      system(command)
      system("clear")
    }
  }
  stopCluster(cl)
}

volume_extractor <- function(input_file, type){
  if(type == "wmh_number"){
    volume <- readLines(input_file)[1] %>% str_extract("(?<= is )[:digit:]*(\\.[:digit:]*$|$)")
  }
  else if(type == "total_wmh_volume"){
    volume <- readLines(input_file)[2] %>% str_extract("(?<= is )[:digit:]*(\\.[:digit:]*$|$)")    
  }
  return(volume)
}
