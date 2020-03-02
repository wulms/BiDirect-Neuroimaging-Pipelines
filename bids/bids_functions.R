copy_BIDS <- function(BIDS_sourcedata_dir, BIDS_tag, seq_n, BIDS_derivatives_temp_dir, gunzip = FALSE){
  
  BIDS_df <- tibble(input = list.files(path = BIDS_sourcedata_dir,
                                       pattern = BIDS_tag,
                                       full.names = TRUE, recursive = TRUE),
                    sub = str_extract(input, "sub-[:alnum:]*(?=_)"),
                    ses = str_extract(input, "ses-[:alnum:]*(?=_)"),
                    seq = str_extract(input, "_[:alnum:]*(?=\\.)")
  ) 
  
  BIDS_df_filtered <- BIDS_df %>% 
    group_by(sub, ses) %>% 
    count() %>% 
    ungroup() %>%
    filter(n == seq_n) %>%
    left_join(BIDS_df) %>%
    mutate(output_files = str_replace(input, BIDS_sourcedata_dir, BIDS_derivatives_temp_dir)) %>%
    filter(file.exists(output_files) == 0)
  
  path_to_folder(BIDS_df_filtered$output_files)
  if(gunzip == FALSE){
    file_copy(BIDS_df_filtered$input, BIDS_df_filtered$output_files)
  } else {
    file_gunzip(BIDS_df_filtered$input, BIDS_df_filtered$output_files)
  }
}

