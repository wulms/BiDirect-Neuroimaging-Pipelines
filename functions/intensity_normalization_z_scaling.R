# intensity normalization volume value = value * value / mean

int_norm_z_scale <- function(input, output) {

command <- paste0("fslmaths ", input[i], " -inm 1 ", output[i], " -odt float")
}