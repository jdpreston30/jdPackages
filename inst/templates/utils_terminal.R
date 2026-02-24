#* Terminal Utilities
# Interactive helpers for development use. Sourced automatically via 00b_setup.R.
# These are NOT part of the reproducible pipeline — convenience only.

#' Solve Math Expressions in Render Files
#'
#' Crawls through render_figures.R (or specified file) and evaluates all
#' math expressions in x=, y=, width=, height= parameters, replacing them
#' with their exact decimal values.
#'
#' @param file Path to file to process. If NULL, automatically finds any file
#'   with "render_figure" in its name in R/Scripts/
#' @examples
#' m()  # Auto-find and process render_figures.R
#' m("R/Scripts/14_render_supplementary_figures.R")  # Process specific file
m <- function(file = NULL) {
  if (is.null(file)) {
    render_files <- list.files("R/Scripts", pattern = "render_figure.*\\.R$",
                               full.names = TRUE, ignore.case = TRUE)
    if (length(render_files) == 0) {
      stop("No render_figure*.R files found in R/Scripts/")
    } else if (length(render_files) > 1) {
      cat("Multiple render_figure files found:\n")
      for (i in seq_along(render_files)) cat(sprintf("  [%d] %s\n", i, render_files[i]))
      stop("Please specify which file to process")
    }
    file <- render_files[1]
    cat("Processing:", file, "\n")
  }
  if (!file.exists(file)) stop("File not found: ", file)
  lines <- readLines(file, warn = FALSE)
  pattern1 <- "(width|height|x|y)(\\s*=\\s*)([0-9.]+\\s*[+*/\\-]\\s*[0-9.]+(?:\\s*[+*/\\-]\\s*[0-9.]+)*)(\\s*[,)])"
  pattern2 <- "c\\(([0-9.]+),\\s*([0-9.+*/()\\-\\s]+)\\)"
  pattern3 <- "c\\(([0-9.+*/()\\-\\s]+),\\s*([0-9.]+)\\)"
  debug_lines <- grep("/", lines)
  if (length(debug_lines) > 0) cat("Lines with division found:", debug_lines, "\n")
  modified <- FALSE
  for (i in seq_along(lines)) {
    repeat {
      line_changed <- FALSE
      if (grepl(pattern1, lines[i])) {
        temp_line <- lines[i]
        match_found <- FALSE
        while (grepl(pattern1, temp_line)) {
          match <- regmatches(temp_line, regexec(pattern1, temp_line))[[1]]
          if (length(match) >= 5) {
            param <- match[2]; equals <- match[3]; expr <- match[4]; comma <- match[5]
            if (grepl("[+*/\\-]", expr)) {
              tryCatch({
                result <- eval(parse(text = expr))
                if (is.numeric(result)) {
                  result_str <- gsub("\\s+", "", format(result, digits = 10, nsmall = 0))
                  replacement <- paste0(param, equals, result_str, comma)
                  lines[i] <- sub(paste0(param, equals, expr, comma), replacement, lines[i], fixed = TRUE)
                  cat(sprintf("Line %d: %s = %s -> %s\n", i, param, expr, result_str))
                  modified <- TRUE; line_changed <- TRUE; match_found <- TRUE
                  break
                }
              }, error = function(e) {})
            }
          }
          temp_line <- sub(pattern1, "", temp_line)
        }
        if (match_found) next
      }
      if (!line_changed && grepl(pattern2, lines[i])) {
        match <- regmatches(lines[i], regexec(pattern2, lines[i]))[[1]]
        if (length(match) >= 3) {
          first_val <- match[2]; expr <- match[3]
          if (grepl("[0-9]\\s*[+*/\\-]\\s*[0-9]", expr)) {
            tryCatch({
              result <- eval(parse(text = expr))
              if (is.numeric(result)) {
                result_str <- gsub("\\s+", "", format(result, digits = 10, nsmall = 0))
                if (result_str != gsub("\\s+", "", expr)) {
                  lines[i] <- sub(paste0("c(", first_val, ", ", expr, ")"),
                                  paste0("c(", first_val, ", ", result_str, ")"), lines[i], fixed = TRUE)
                  cat(sprintf("Line %d: c(..., %s) -> c(..., %s)\n", i, expr, result_str))
                  modified <- TRUE; line_changed <- TRUE
                }
              }
            }, error = function(e) {})
          }
        }
      }
      if (!line_changed && grepl(pattern3, lines[i])) {
        match <- regmatches(lines[i], regexec(pattern3, lines[i]))[[1]]
        if (length(match) >= 3) {
          expr <- match[2]; second_val <- match[3]
          if (grepl("[0-9]\\s*[+*/\\-]\\s*[0-9]", expr)) {
            tryCatch({
              result <- eval(parse(text = expr))
              if (is.numeric(result)) {
                result_str <- gsub("\\s+", "", format(result, digits = 10, nsmall = 0))
                if (result_str != gsub("\\s+", "", expr)) {
                  lines[i] <- sub(paste0("c(", expr, ", ", second_val, ")"),
                                  paste0("c(", result_str, ", ", second_val, ")"), lines[i], fixed = TRUE)
                  cat(sprintf("Line %d: c(%s, ...) -> c(%s, ...)\n", i, expr, result_str))
                  modified <- TRUE; line_changed <- TRUE
                }
              }
            }, error = function(e) {})
          }
        }
      }
      if (!line_changed) break
    }
  }
  if (modified) {
    writeLines(lines, file)
    cat(sprintf("\nUpdated %s\n", file))
  } else {
    cat("No math expressions found to evaluate.\n")
  }
  invisible(modified)
}

#' Reload All Utility Functions and Config
#'
#' Quick helper to re-source all utility functions from R/Utilities/ and reload
#' config. Excludes Setup/ directory (one-time setup scripts, not utilities).
#' Useful during development when making changes to utility functions or config.
#'
#' If a number is provided, runs the corresponding numbered script after updating.
#'
#' @param n Optional script number to run after updating (e.g., 1 for 01_*.R)
#' @examples
#' u()   # Update utilities and config only
#' u(3)  # Update utilities/config, then run script 03_*.R
u <- function(n = NULL) {
  source("R/Utilities/Helpers/load_dynamic_config.R")
  config <<- load_dynamic_config(computer = "auto", config_path = "All_Run/config_dynamic.yaml")
  all_files     <- list.files("R/Utilities/", pattern = "\\.[rR]$", full.names = TRUE, recursive = TRUE)
  utility_files <- all_files[!grepl("Setup/", all_files)]
  purrr::walk(utility_files, source)
  cat("Config and utilities reloaded\n")
  if (!is.null(n)) {
    script_num     <- sprintf("%02d", n)
    matching_files <- list.files("R/Scripts/", pattern = paste0("^", script_num, ".*\\.R$"),
                                 full.names = TRUE, ignore.case = TRUE)
    if (length(matching_files) == 0) { cat("No script found matching number:", n, "\n"); return(invisible(NULL)) }
    if (length(matching_files) > 1)  { cat("Multiple scripts found matching number:", n, "\n"); return(invisible(NULL)) }
    cat("Running:", basename(matching_files[1]), "\n")
    source(matching_files[1])
    cat("Script completed\n")
  }
  invisible(NULL)
}

#' @rdname u
U <- u

#' Update, Run Script, and Render Figures
#'
#' Convenience wrapper: updates utilities/config, runs a numbered script,
#' then renders figures.
#'
#' @param n Script number to run (e.g., 1 for 01_*.R)
#' @examples
#' uf(1)  # Update, run 01_*.R, then render figures
uf <- function(n) { u(n); f(); invisible(NULL) }

#' Run Render Figures Script
#'
#' Quick helper to run assign_plots.R and render_figures.R scripts.
#' Dynamically finds these scripts regardless of their prefix numbers.
#'
#' @examples
#' f()
f <- function() {
  .run_named_script <- function(pattern, label) {
    files <- list.files("R/Scripts/", pattern = pattern, full.names = TRUE, ignore.case = TRUE)
    if (length(files) == 0) { cat("Script not found:", label, "\n"); return(FALSE) }
    if (length(files) > 1)  { cat("Multiple scripts found for:", label, "\n"); return(FALSE) }
    cat("Running:", basename(files[1]), "\n")
    source(files[1])
    TRUE
  }
  .run_named_script("assign_plots\\.R$",   "assign_plots.R")
  .run_named_script("render_figures\\.R$", "render_figures.R")
  cat("Figures rendered\n")
  invisible(NULL)
}

#' Run Numbered Script
#'
#' Quick helper to run any numbered script by its number.
#' Automatically pads single-digit numbers with a leading zero.
#'
#' @param n Script number (e.g., 1 for 01_*.R, 5 for 05_*.R)
#' @examples
#' r(1)  # Runs 01_*.R
#' r(5)  # Runs 05_*.R
r <- function(n) {
  script_num     <- sprintf("%02d", n)
  matching_files <- list.files("R/Scripts/", pattern = paste0("^", script_num, ".*\\.R$"),
                               full.names = TRUE, ignore.case = TRUE)
  if (length(matching_files) == 0) { cat("No script found matching number:", n, "\n"); return(invisible(NULL)) }
  if (length(matching_files) > 1)  { cat("Multiple scripts found matching number:", n, "\n"); return(invisible(NULL)) }
  cat("Running:", basename(matching_files[1]), "\n")
  source(matching_files[1])
  cat("Script completed\n")
  invisible(NULL)
}

#' Create Comment Report
#'
#' Crawls through all R/Scripts/ files in order and creates a comment_report.R
#' containing all section headings (lines starting with #*, #+, or #-).
#'
#' @examples
#' cr()  # Creates comment_report.R with all section headings
cr <- function() {
  all_files    <- sort(list.files("R/Scripts/", pattern = "\\.[rR]$", full.names = TRUE))
  output_lines <- c()
  for (file_path in all_files) {
    output_lines <- c(output_lines, paste0("#! ", basename(file_path)))
    contents     <- readLines(file_path, warn = FALSE)
    output_lines <- c(output_lines, contents[grepl("^#[*+-]", contents)], "")
  }
  writeLines(output_lines, "comment_report.R")
  cat("Comment report created: comment_report.R\n")
  cat("  Files processed:", length(all_files), "\n")
  cat("  Comment lines extracted:", sum(grepl("^#[*+-]", output_lines)), "\n")
  invisible(NULL)
}
