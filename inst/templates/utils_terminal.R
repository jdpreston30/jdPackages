#* Terminal Shortcuts
# Quick utility functions for interactive use in the R terminal.
# Not part of the reproducible pipeline — convenience only.
# Source this file manually when working interactively.

#' Quick memory usage overview
m <- function() {
  cat(format(sum(sapply(ls(envir = .GlobalEnv),
                        function(x) object.size(get(x, envir = .GlobalEnv)))),
             big.mark = ","), "bytes in .GlobalEnv\n")
}

#' List objects in the global environment with sizes
u <- function() {
  objs <- ls(envir = .GlobalEnv)
  if (length(objs) == 0) { cat("Global environment is empty.\n"); return(invisible(NULL)) }
  sizes <- sapply(objs, function(x) object.size(get(x, envir = .GlobalEnv)))
  df <- data.frame(Object = objs, Size = format(sizes, big.mark = ","),
                   stringsAsFactors = FALSE)
  print(df[order(-sizes), ], row.names = FALSE)
}

#' Quick git status
g <- function() system("git status --short")

#' List files in current directory
l <- function(path = ".") {
  files <- list.files(path, full.names = FALSE)
  cat(paste(files, collapse = "\n"), "\n")
}
