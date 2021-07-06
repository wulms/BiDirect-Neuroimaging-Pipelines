initialize_parallel <- function(not_use = 2) {
  # Calculate the number of cores
  no_cores <- detectCores() - not_use
  
  # Initiate cluster
  cl <- makeCluster(no_cores, type = "FORK", outfile = "")
  
  registerDoParallel(cl)
  getDoParWorkers()
  return(cl)
}

bianca_r <- function(masterfile, output_name, cores_not_used = 2) {
  initialize_parallel(not_use = cores_not_used)
  path_to_folder(unique(output_name))

  
  foreach (i = 1:length(output_name)) %dopar% {
  
    if (file.exists(paste0(output_name[i], ".nii.gz")) == 0) {
      command <- paste0("bianca --singlefile=", masterfile, 
                        " --labelfeaturenum=4 --brainmaskfeaturenum=1 --querysubjectnum=", i,
                        " --trainingnums=all --featuresubset=1,2 --matfeaturenum=3 --trainingpts=2000 --nonlespts=10000 --selectpts=noborder -o '", output_name[i],
                         "'"#, " --saveclassifierdata ", output_name[i] 
                        #" -v"
                        )
      cat("\014")  
      print(command)
      system(command)
    }
  }
}


train_bianca <- function(train_list, output_name, output_classifier) {
  initialize_parallel()
  foreach (i = 1:length(output_classifier)) %dopar% {
    query_subject <- read_table(train_list[i], col_names = FALSE) %>% nrow()
    command <- paste0("bianca --singlefile=", train_list[i], 
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

test_bianca <- function(masterfile, output_name, input_classifiercores_not_used = 2) {
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

application_bianca_classifiers <- function(trained_models, test_sets){
  for (i in 1:length(trained_models)) {
    # Clear terminal
    cat("\014")
    
    # Creation of output folders
    output_folder <- str_replace(trained_models[i], "trained_classifier/", "trained_classifier_output")
    print(output_folder)
    # Reading in of file list for model application
    output_masks <- read.table(test_sets[i], sep = '\t', header = FALSE)[,1] %>% as.character() %>%
      str_replace("/mnt/458e8a35-865f-4f0e-ab7e-8b4ac8684363/WML121_BIDS/derivatives/FSL/5-FSL_FLIRT/anat_FLAIR_defaced_pydeface/", output_folder) %>% 
      str_replace(".nii.gz", "_BIANCA_mask")
    # print(length(output_masks))
    # print(head(output_masks))
    
    cl <- initialize_parallel(not_use = 1)
    
    
    #for (j in 1:length(output_masks)){
    
    
    foreach(j = 1:length(output_masks)) %dopar% {
      path_to_folder(output_masks[j])
      cat("\014")
      
      command <- paste0("bianca --singlefile=", test_sets[i], 
                        " --loadclassifierdata=", trained_models[i],
                        " --brainmaskfeaturenum=1 --querysubjectnum=", j,
                        " --featuresubset=1,2 --matfeaturenum=3 -o ", output_masks[j] 
                        #" -v"
      )
      # print(command)
      if(file.exists(paste0(output_masks[j], ".nii.gz")) == 0) {
        system("clear")
        system(command)
      }
    }
    stopCluster(cl)
  }
}



bianca_performance <- function(lesionmask, threshold, manualmask, saveoutput = 0, output_name){
  initialize_parallel(2)
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
}

bianca_cluster_info <- function(lesionmask, threshold, min_cluster_size = 0, output_name){
  initialize_parallel(2)
  foreach (i = 1:length(lesionmask)) %dopar% {
    print(i) 
    
    if(file.exists(output_name[i]) == 0) {
    command <- paste0("bianca_cluster_stats ",
                      lesionmask[i], " ",
                      threshold[i], " ",
                      min_cluster_size, " > ", output_name[i])
    print(command)
    system(command)
    system("clear")
    }
    #print(a)
    #WMH_number = str_extract(a[1], "(?<= is )([:digit:]+\\.[:digit:]+|[:digit:]+)")
    #esion_Volume = str_extract(a[2], "(?<= is )([:digit:]+\\.[:digit:]+|[:digit:]+)")
    #print(WMH_number)
    #print(Lesion_Volume)
    #return(paste0(WMH_number, ", ", Lesion_Volume))
  }
}