
#' Creates folders from list of filenames
#'
#' @param list_of_files 
#'
#' @return Side-effect: creates folders on system, if they do not exists.
#' @examples path_to_folder(list_of files = list(c("folder_A", "folder_B", "folder_C")))
path_to_folder <- function(list_of_files) {
  paths_folder <- sub("[/][^/]+$", "", list_of_files)
  paths_folder <- unique(paths_folder)
  paths_folder <- paths_folder[!dir.exists(paths_folder)]
  lapply(paths_folder,
         dir.create,
         recursive = TRUE,
         showWarnings = FALSE)
}

file_copy <- function(input, output){
  for (i in seq_along(input)) {
    cat("\014")
    log_debug(paste(i, "of", length(input), " processed."))
    file.copy(input[i], output[i], overwrite = FALSE)
  }
}

file_gunzip <- function(input, output){
  output <- str_remove(output, ".gz$")
  for (i in seq_along(input)) {
    cat("\014")
    log_debug(paste(i, "of", length(input), " processed."))
    gunzip(input[i], output[i], 
           skip = TRUE, overwrite = FALSE, remove = FALSE)
  }
}


