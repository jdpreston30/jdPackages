#* 0a: Environment Setup
#+ 0a.1: Verify renv is active
cat("Package environment managed by renv\n")
if (!("renv" %in% loadedNamespaces())) {
  warning("renv is not active. Attempting to activate...")
  source("renv/activate.R")
}
#+ 0a.2: Ensure JDP.repo is excluded from renv (it is a global tool, not a project dependency)
tryCatch({
  current_ignored <- renv::settings$ignored.packages()
  if (!"JDP.repo" %in% current_ignored) {
    renv::settings$ignored.packages(c(current_ignored, "JDP.repo"))
  }
}, error = function(e) NULL)
#+ 0a.3: Read package list from DESCRIPTION (Imports field)
# All packages — including TernTables — are CRAN-compatible via r-universe.
# No Remotes field or remotes/devtools required.
desc <- read.dcf(here::here("DESCRIPTION"))
raw_imports <- trimws(strsplit(desc[, "Imports"], ",\\s*|\n\\s*")[[1]])
cran_pkgs   <- raw_imports[nzchar(raw_imports)]
# Strip version pins like " (>= 1.0)"
pkg_names <- gsub("\\s*\\(.*\\)", "", cran_pkgs)
#+ 0a.4: Check and install missing packages via renv::restore()
# renv uses repos set in .Rprofile (including r-universe) so TernTables is handled automatically.
missing_pkgs <- pkg_names[!sapply(pkg_names, requireNamespace, quietly = TRUE)]
if (length(missing_pkgs) > 0) {
  cat("Packages missing:", paste(missing_pkgs, collapse = ", "), "\n")
  cat("Running renv::restore() to install packages (may take 10-20 min on first run)...\n\n")
  tryCatch({
    renv::restore(prompt = FALSE)
    cat("\nPackage installation complete!\n")
  }, error = function(e) {
    stop("Failed to restore packages: ", e$message,
         "\nPlease run renv::restore() manually and check for errors.")
  })
  still_missing <- pkg_names[!sapply(pkg_names, requireNamespace, quietly = TRUE)]
  if (length(still_missing) > 0) {
    stop("Packages still missing after restore: ", paste(still_missing, collapse = ", "),
         "\nPlease check renv::status() for details.")
  }
} else {
  cat("renv environment verified. All packages available.\n")
}
#+ 0a.5: Load all packages from DESCRIPTION
cat("Loading packages...\n")
invisible(lapply(pkg_names, function(pkg) {
  tryCatch({
    library(pkg, character.only = TRUE)
    cat("  v", pkg, "\n")
  }, error = function(e) {
    warning("Could not load package: ", pkg, " — ", e$message)
  })
}))
cat("All packages loaded.\n")
#+ 0a.6: Check TinyTeX for PDF/supplementary rendering
if (!requireNamespace("tinytex", quietly = TRUE)) {
  cat("tinytex package not found — skipping TinyTeX check.\n")
} else if (!tinytex::is_tinytex()) {
  cat("TinyTeX not found. Installing (needed for PDF rendering)...\n")
  tinytex::install_tinytex()
  cat("TinyTeX installed.\n")
} else {
  cat("TinyTeX OK.\n")
}
