#* 0b: Project Setup
#+ 0b.1: Load all utility functions
# Sources every .R file in R/Utilities/ recursively in one call.
# Add utility scripts to any subdirectory and they will be picked up automatically.
cat("Loading utility functions...\n")
util_files <- list.files(
  path       = "R/Utilities",
  pattern    = "\\.R$",
  recursive  = TRUE,
  full.names = TRUE
)
purrr::walk(util_files, function(f) {
  tryCatch(source(f), error = function(e) {
    warning("Could not source utility: ", f, " — ", e$message)
  })
})
cat("  v", length(util_files), "utility file(s) loaded\n")
#+ 0b.2: Package options
options(
  tibble.print_max    = config$analysis$tibble_options$print_max,
  tibble.print_min    = config$analysis$tibble_options$print_min,
  tibble.sigfig       = config$analysis$tibble_options$sigfig,
  datatable.print.class = config$analysis$datatable_options$print_class,
  datatable.print.keys  = config$analysis$datatable_options$print_keys
)
#+ 0b.3: Package conflict resolution
# Explicitly namespace functions that conflict across packages.
# Uncomment and add to this section as needed.
# filter  <- dplyr::filter
# select  <- dplyr::select
# rename  <- dplyr::rename
# mutate  <- dplyr::mutate
# [ADD CONFLICT RESOLUTIONS HERE]
cat("Setup complete. Pipeline ready.\n")
