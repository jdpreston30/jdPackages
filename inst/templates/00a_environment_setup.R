#* 0a: Environment Setup
#+ 0a.1: Verify renv is active
cat("Package environment managed by renv\n")
if (!("renv" %in% loadedNamespaces())) {
  warning("renv is not active. Attempting to activate...")
  source("renv/activate.R")
}
#+ 0a.2: Ensure jdPackages is excluded from renv (it is a global tool, not a project dependency)
tryCatch({
  current_ignored <- renv::settings$ignored.packages()
  if (!"jdPackages" %in% current_ignored) {
    renv::settings$ignored.packages(c(current_ignored, "jdPackages"))
  }
}, error = function(e) NULL)
#+ 0a.3: Read package lists from DESCRIPTION
desc <- read.dcf(here::here("DESCRIPTION"))
#- 0a.3.1: CRAN / Bioconductor packages (Imports field)
raw_imports  <- trimws(strsplit(desc[, "Imports"], ",\\s*|\n\\s*")[[1]])
cran_pkgs    <- raw_imports[nzchar(raw_imports)]
#- 0a.3.2: GitHub-only packages (Remotes field) — these need remotes::install_github()
github_pkgs <- character(0)
if ("Remotes" %in% colnames(desc)) {
  raw_remotes  <- trimws(strsplit(desc[, "Remotes"], ",\\s*|\n\\s*")[[1]])
  github_pkgs  <- raw_remotes[nzchar(raw_remotes)]
}
# Package names only (strip version pins like " (>= 1.0)")
pkg_names <- gsub("\\s*\\(.*\\)", "", cran_pkgs)
# For GitHub remotes the install name is the repo (user/pkg) but the namespace name is just pkg
github_pkg_names <- basename(github_pkgs)
#+ 0a.4: Check and install missing packages
#- 0a.4.1: CRAN/Bioconductor packages via renv::restore()
non_github_names <- setdiff(pkg_names, github_pkg_names)
missing_cran     <- non_github_names[!sapply(non_github_names, requireNamespace, quietly = TRUE)]
if (length(missing_cran) > 0) {
  cat("Core packages missing:", paste(missing_cran, collapse = ", "), "\n")
  cat("Running renv::restore() to install packages (may take 10-20 min on first run)...\n\n")
  tryCatch({
    renv::restore(prompt = FALSE)
    cat("\nPackage installation complete!\n")
  }, error = function(e) {
    stop("Failed to restore packages: ", e$message,
         "\nPlease run renv::restore() manually and check for errors.")
  })
  still_missing <- non_github_names[!sapply(non_github_names, requireNamespace, quietly = TRUE)]
  if (length(still_missing) > 0) {
    stop("Packages still missing after restore: ", paste(still_missing, collapse = ", "),
         "\nPlease check renv::status() for details.")
  }
} else {
  cat("renv environment verified. All CRAN/Bioconductor packages available.\n")
}
#- 0a.4.2: GitHub-only packages (e.g. TernTablesR) via remotes::install_github()
missing_github <- github_pkg_names[!sapply(github_pkg_names, requireNamespace, quietly = TRUE)]
if (length(missing_github) > 0) {
  cat("GitHub-only packages missing:", paste(missing_github, collapse = ", "), "\n")
  if (!requireNamespace("remotes", quietly = TRUE)) renv::install("remotes")
  for (repo in github_pkgs) {
    pkg_nm <- basename(repo)
    if (!requireNamespace(pkg_nm, quietly = TRUE)) {
      cat("Installing", pkg_nm, "from GitHub:", repo, "\n")
      tryCatch(
        remotes::install_github(repo, upgrade = "never"),
        error = function(e) warning("Could not install ", repo, ": ", e$message)
      )
    }
  }
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
