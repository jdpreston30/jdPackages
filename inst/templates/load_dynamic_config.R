#' Load dynamic configuration based on the current computer
#'
#' Reads config_dynamic.yaml and substitutes computer-specific path templates
#' into the paths section. Detects the current machine automatically by
#' matching the home directory against entries in the "computers:" block.
#'
#' @param computer Character. Either \code{"auto"} (default, detects machine
#'   from home directory) or a specific key from the \code{computers:} block
#'   (e.g. \code{"laptop"}, \code{"desktop"}).
#' @param config_path Character. Path to the YAML config file, relative to the
#'   project root. Defaults to \code{"All_Run/config_dynamic.yaml"}.
#'
#' @return A named list of configuration values with paths fully resolved.
#'   The result is also assigned to \code{.GlobalEnv$config}.
#' @export
load_dynamic_config <- function(computer    = "auto",
                                config_path = "All_Run/config_dynamic.yaml") {
  #+ 1: Read YAML
  if (!file.exists(config_path)) {
    stop("Config file not found: ", config_path,
         "\n  Make sure you are running from the project root directory.")
  }
  cfg <- yaml::read_yaml(config_path)
  #+ 2: Detect computer
  if (computer == "auto") {
    user_home    <- normalizePath("~", winslash = "/")
    computer_key <- NULL
    for (nm in names(cfg$computers)) {
      if (grepl(cfg$computers[[nm]]$user_home, user_home, fixed = TRUE)) {
        computer_key <- nm
        break
      }
    }
    if (is.null(computer_key)) {
      warning(
        "Could not auto-detect computer from home directory: ", user_home,
        "\n  Add an entry to the 'computers:' block in ", config_path,
        "\n  Falling back to first entry: ", names(cfg$computers)[1]
      )
      computer_key <- names(cfg$computers)[1]
    }
  } else {
    computer_key <- computer
    if (!computer_key %in% names(cfg$computers)) {
      stop("Computer '", computer_key, "' not found in config. ",
           "Available: ", paste(names(cfg$computers), collapse = ", "))
    }
  }
  cat("Computer detected:", computer_key, "\n")
  #+ 3: Build substitution values
  comp         <- cfg$computers[[computer_key]]
  subs         <- list(
    user_home    = comp$user_home,
    onedrive_path = comp$onedrive_path,
    figures_path = comp$figures_path
  )
  #+ 4: Substitute {variable} placeholders in all path values
  resolve <- function(val, env) {
    for (nm in names(env)) {
      # Allow {nm} references; also resolve {base_data_path} after it is set
      val <- gsub(paste0("\\{", nm, "\\}"), env[[nm]], val)
    }
    val
  }
  # First pass — resolve computer-level vars in all paths
  paths_resolved <- lapply(cfg$paths, function(v) resolve(as.character(v), subs))
  # Second pass — resolve {base_data_path} (which itself was just resolved)
  subs_with_base <- c(subs, list(base_data_path = paths_resolved$base_data_path))
  paths_resolved <- lapply(cfg$paths, function(v) resolve(as.character(v), subs_with_base))
  cfg$paths      <- paths_resolved
  cfg$computer   <- computer_key
  #+ 5: Assign to global env and return
  assign("config", cfg, envir = .GlobalEnv)
  invisible(cfg)
}
