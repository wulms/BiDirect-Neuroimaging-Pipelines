path_to_folder <- function(path){
  paths_folder <- sub("[/][^/]+$", "", path)
  
  paths_folder <- unique(paths_folder)
  print(head(paths_folder))
  
  
  
  lapply(paths_folder, dir.create, recursive = TRUE, showWarnings = FALSE)
}
