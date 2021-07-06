

extract_table_measures <- function(df){
  
  table_measure_column <- df$table_measure
  filename <- df$files
  type <- df$type
  subject <- df$subject
  session <- df$session
  hemisphere <- df$hemisphere
  
  for (i in 1:length(table_measure_column)) {
    
    output_filename <- str_replace(filename[i], ".stats$", ".stats_measure.csv")
    
    if (!file.exists(output_filename)) {
      
      cat("\014")
      print(paste(i, "of", length(table_measure_column)))
      print(paste(type[i], subject[i], session[i], hemisphere[i], output_filename))
      
      subject_table_long <- table_measure_column[[i]] %>%
        str_remove("# Measure |, mm^3") %>%
        data.frame(
          input = .,
          type = type[i],
          session = session[i],
          subject = subject[i],
          hemisphere = hemisphere[i]
        ) %>%
        separate(
          input,
          into = c("variable", "value"),
          sep = regex(", (?=[:digit:]{1})")
        ) %>%
        separate(value,
                 into = c("value_in_mm3", "unit"),
                 sep = ", ") %>%
        mutate(
          value_in_mm3 = as.numeric(value_in_mm3),
          variable = paste0(variable, " (", unit, ")")
        ) %>%
        select(subject, session, type, hemisphere, everything()) %>%
        select(-unit)
      
      subject_table_wide <- subject_table_long %>%
        pivot_wider(
          names_from = variable,
          values_from = value_in_mm3,
          names_prefix = paste0(type[i], "_")
        )
      readr::write_csv(subject_table_wide, path = output_filename, col_names = TRUE)
    }
  }
}


extract_table_roi <- function(df, extract_type){
  
  table_roi_column <- df$table_roi
  filename <- df$files
  type <- df$type
  subject <- df$subject
  session <- df$session
  hemisphere <- df$hemisphere
  
  for (i in 1:length(table_roi_column)) {
    
    output_filename <- str_replace(filename[i], ".stats$", ".stats_roi.csv")
    
    cat("\014")   
    print(paste(i, "of", length(table_roi_column)))
    print(paste(type[i], subject[i], session[i], hemisphere[i], output_filename))

    
    table_df <- table_roi_column[[i]] %>%
      str_remove("# ColHeaders ") %>% as.character()
    # Extract column names
    header_id <- str_squish(table_df[[1]]) %>% str_split(pattern = " ") %>% unlist()
    
    if (!file.exists(output_filename)) {
      
      if (extract_type == "global") {
        
        subject_table_long <- table_df %>%
          data.frame(input = str_squish(.),
                     type = type[i], 
                     subject = subject[i],
                     session = session[i],
                     hemisphere = hemisphere[i]) %>%
          mutate(input = as.character(input)) %>%
          separate(input, into = header_id, sep = " ") %>%
          filter(str_detect(., "Index", negate = TRUE)) %>%
          select(-.) %>%
          select(subject, session, type, hemisphere, everything())
        
        subject_table_wide <- subject_table_long %>%
          pivot_wider(names_from = StructName,
                      values_from = c(Index, SegId, NVoxels, Volume_mm3, normMean, normStdDev, normMin, normMax, normRange), 
                      names_glue = paste0(type[i],"_{StructName}_{.value}"))
        
      } else if (extract_type == "thickness") {
        
        subject_table_long <- table_df %>%
          data.frame(input = str_squish(.),
                     type = type[i], 
                     subject = subject[i],
                     session = session[i],
                     hemisphere = hemisphere[i]) %>%
          mutate(input = as.character(input)) %>%
          separate(input, into = header_id, sep = " ") %>%
          filter(str_detect(., "StructName", negate = TRUE)) %>%
          select(-.) %>%
          select(subject, session, type, hemisphere, everything())
        
        subject_table_wide <- subject_table_long %>%
          pivot_wider(names_from = StructName,
                      values_from = c(NumVert, SurfArea, GrayVol, ThickAvg, ThickStd, MeanCurv, GausCurv, FoldInd, CurvInd), 
                      names_glue = paste0(type[i],"_{StructName}_{.value}"))
      }
    
    readr::write_csv(subject_table_wide, path = output_filename, col_names = TRUE)
     }
  }
  
}





merge_table_information <- function(df){
  
  unique_tables <- unique(df$table)
  
  dir.create(output_data)
  
  file.remove(list.files(path = output_data, pattern = ".csv", recursive = FALSE, full.names = TRUE))
  
  for(i in 1:length(unique_tables)){
    cat("\014")
    print(paste(i, unique_tables[i]))
    
    output_name = paste0(output_data, unique_tables[i])
    
    csv_selection <- df %>%
      filter(table == unique_tables[i]) %>%
      pull(csv_name)
    
    for(j in 1:length(csv_selection)) {
      cat("\014")
      print(paste(j, "of", length(csv_selection), ": ", csv_selection[j]))
      
      csv_info <- readr::read_csv(csv_selection[j])
      
      if(file.exists(output_name)) {
        readr::write_csv(csv_info, output_name, append = TRUE)
      } else {
        readr::write_csv(csv_info, output_name, append = FALSE)
      }
    }
  }
}


merge_csv_files <- function(csv_files_to_merge){
  
  remove(df_merged)
  remove(df_cleaned)
  
  for(i in 1:length(csv_files_to_merge)){
    df <- readr::read_csv(csv_files_to_merge[i])
    
    df_cleaned <- df %>%
      select_if(function(col) n_distinct(col) > 1)
    
    if(exists("df_merged")) {
      df_merged <- full_join(df_merged, df_cleaned)
    } else {
      df_merged <- df_cleaned
    }
    
  }
  return(df_merged)
}
