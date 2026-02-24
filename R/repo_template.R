#' Scaffold a new reproducible R analysis project
#'
#' Creates a complete project directory with a standard structure matching
#' the personal analysis style: numbered pipeline scripts, organized utilities,
#' dynamic YAML configuration, renv setup, and GitHub Copilot instructions.
#'
#' @param project_name Character. Name of the new project / directory to create.
#' @param path Character. Parent directory where the project folder will be created.
#'   Defaults to current working directory.
#' @param github_user Character. Your GitHub username, used in DESCRIPTION and
#'   README placeholders. Defaults to \code{"jdpreston30"}.
#'
#' @return Invisibly returns the full path to the created project directory.
#' @export
#'
#' @examples
#' \dontrun{
#' repo_template("my-new-analysis", path = "~/Desktop/Repos")
#' }
repo_template <- function(project_name,
                           path        = getwd(),
                           github_user = "jdpreston30") {

  #* 1: Validate inputs
  if (missing(project_name) || !nzchar(project_name)) {
    cli::cli_abort("project_name must be a non-empty string.")
  }
  project_dir <- fs::path_abs(fs::path(path, project_name))
  if (fs::dir_exists(project_dir)) {
    cli::cli_abort("Directory already exists: {project_dir}")
  }

  cli::cli_h1("Scaffolding project: {project_name}")
  cli::cli_alert_info("Target directory: {project_dir}")

  #* 2: Create directory tree
  dirs <- c(
    ".github",
    ".vscode",
    "All_Run",
    "Outputs/Figures/Final",
    "Outputs/Figures/PDF",
    "Outputs/Figures/PNG",
    "Outputs/Tables",
    "Outputs/Validation",
    "R/Scripts",
    "R/Utilities/Analysis",
    "R/Utilities/Helpers",
    "R/Utilities/Preprocessing",
    "R/Utilities/Tabulation",
    "R/Utilities/Terminal",
    "R/Utilities/Visualization"
  )
  purrr::walk(dirs, function(d) {
    fs::dir_create(fs::path(project_dir, d))
  })
  cli::cli_alert_success("Directory structure created")

  #* 3: Define substitution values
  subs <- list(
    PROJECT_NAME = project_name,
    GITHUB_USER  = github_user,
    DATE         = format(Sys.Date(), "%Y-%m-%d"),
    YEAR         = format(Sys.Date(), "%Y")
  )

  #+ 3.1: Write template files
  write_tmpl(project_dir, "DESCRIPTION",                    "DESCRIPTION",                subs)
  write_tmpl(project_dir, "README.md",                      "README.md",                  subs)
  write_tmpl(project_dir, ".gitignore",                     "gitignore",                  subs)
  write_tmpl(project_dir, ".Rprofile",                      "Rprofile",                   subs)
  write_tmpl(project_dir, ".renvignore",                    "renvignore",                 subs)
  write_tmpl(project_dir, "QUICKSTART.txt",                 "QUICKSTART.txt",             subs)
  write_tmpl(project_dir, ".github/copilot-instructions.md","copilot-instructions.md",    subs)
  write_tmpl(project_dir, ".vscode/settings.json",          "vscode_settings.json",       subs)
  write_tmpl(project_dir, "All_Run/config_dynamic.yaml",    "config_dynamic.yaml",        subs)
  write_tmpl(project_dir, "All_Run/run.R",                  "run.R",                      subs)
  write_tmpl(project_dir, "R/Scripts/00a_environment_setup.R", "00a_environment_setup.R", subs)
  write_tmpl(project_dir, "R/Scripts/00b_setup.R",          "00b_setup.R",                subs)
  write_tmpl(project_dir, "R/Scripts/01_step1.R",           "01_step1.R",                 subs)
  write_tmpl(project_dir, "R/Scripts/02_step2.R",           "02_step2.R",                 subs)
  write_tmpl(project_dir, "R/Utilities/Helpers/load_dynamic_config.R",
                                                             "load_dynamic_config.R",      subs)
  write_tmpl(project_dir, "R/Utilities/Helpers/helper_template.R",
                                                             "helper_template.R",          subs)
  write_tmpl(project_dir, "R/Utilities/Visualization/visualization_template.R",
                                                             "visualization_template.R",   subs)
  write_tmpl(project_dir, "R/Utilities/Terminal/utils_terminal.R",
                                                             "utils_terminal.R",           subs)
  cli::cli_alert_success("All template files written")

  #* 4: Interactive prompt — renv initialization
  cli::cli_h2("renv Setup")
  cli::cli_alert_info(paste0(
    "renv provides reproducible package management by locking exact package versions.\n",
    "  This will: initialize renv, install TernTablesR from GitHub, and snapshot the lockfile."
  ))
  init_renv <- .prompt_yn("Initialize renv now? (recommended)", default = TRUE)

  if (init_renv) {
    #+ 4.1: Init renv inside the new project
    cli::cli_alert_info("Initializing renv (this may take a moment)...")
    old_wd <- getwd()
    on.exit(setwd(old_wd), add = TRUE)
    setwd(project_dir)

    tryCatch({
      renv::init(project = project_dir, restart = FALSE)
      cli::cli_alert_success("renv initialized")
    }, error = function(e) {
      cli::cli_alert_warning("renv::init() encountered an issue: {e$message}")
      cli::cli_alert_info("You can run renv::init() manually inside the project.")
    })

    #+ 4.2: Install TernTablesR from GitHub
    cli::cli_alert_info("Installing TernTablesR from {github_user}/TernTablesR...")
    tryCatch({
      if (!requireNamespace("remotes", quietly = TRUE)) {
        renv::install("remotes")
      }
      remotes::install_github(
        paste0(github_user, "/TernTablesR"),
        upgrade = "never"
      )
      cli::cli_alert_success("TernTablesR installed")
    }, error = function(e) {
      cli::cli_alert_warning("Could not install TernTablesR: {e$message}")
      cli::cli_alert_info("Run: remotes::install_github(\"{github_user}/TernTablesR\") manually.")
    })

    #+ 4.3: Snapshot lockfile
    tryCatch({
      renv::snapshot(project = project_dir, prompt = FALSE)
      cli::cli_alert_success("renv.lock snapshot created")
    }, error = function(e) {
      cli::cli_alert_warning("renv::snapshot() failed: {e$message}")
    })

    setwd(old_wd)
  } else {
    cli::cli_alert_info("Skipped. Run renv::init() inside the project when ready.")
  }

  #* 5: Interactive prompt — Docker setup
  cli::cli_h2("Docker Setup")
  cli::cli_alert_info(paste0(
    "Docker provides maximum reproducibility by containerising the full R environment.\n",
    "  This is typically configured later in the project lifecycle, not at the start.\n",
    "  See QUICKSTART.txt for deployment instructions."
  ))
  create_docker <- .prompt_yn("Create Docker scaffold now? (optional, can do later)", default = FALSE)

  if (create_docker) {
    write_tmpl(project_dir, "Dockerfile",           "Dockerfile",           subs)
    write_tmpl(project_dir, "docker-compose.yml",   "docker-compose.yml",   subs)
    cli::cli_alert_success("Dockerfile and docker-compose.yml written")
  } else {
    cli::cli_alert_info("Skipped. Run repo_template_add_docker(\"{project_dir}\") to add later.")
  }

  #* 6: Final summary
  cli::cli_h1("Project ready: {project_name}")
  cli::cli_bullets(c(
    "v" = "Project directory: {project_dir}",
    "v" = "Open the project: .Rproj or setwd(\"{project_dir}\")",
    "v" = "Run the pipeline: source(\"All_Run/run.R\")",
    "i" = "Edit All_Run/config_dynamic.yaml with your computer-specific paths",
    "i" = "See QUICKSTART.txt for full onboarding steps"
  ))

  invisible(project_dir)
}


#' Add Docker scaffold to an existing project
#'
#' Writes a Dockerfile and docker-compose.yml into an existing project directory.
#' Safe to call if you answered N to the Docker prompt during repo_template().
#'
#' @param project_dir Character. Full path to an existing project directory.
#' @export
repo_template_add_docker <- function(project_dir = getwd()) {
  project_dir  <- fs::path_abs(project_dir)
  project_name <- fs::path_file(project_dir)
  if (!fs::dir_exists(project_dir)) {
    cli::cli_abort("Directory not found: {project_dir}")
  }
  subs <- list(
    PROJECT_NAME = project_name,
    GITHUB_USER  = "jdpreston30",
    DATE         = format(Sys.Date(), "%Y-%m-%d"),
    YEAR         = format(Sys.Date(), "%Y")
  )
  write_tmpl(project_dir, "Dockerfile",         "Dockerfile",         subs)
  write_tmpl(project_dir, "docker-compose.yml", "docker-compose.yml", subs)
  cli::cli_alert_success("Docker files written to {project_dir}")
  invisible(project_dir)
}


# ── Internal helpers ──────────────────────────────────────────────────────────

#' @keywords internal
write_tmpl <- function(project_dir, dest_relpath, template_name, subs) {
  tmpl_path <- system.file("templates", template_name, package = "jdPackages")
  if (!nzchar(tmpl_path) || !file.exists(tmpl_path)) {
    cli::cli_alert_warning("Template not found: {template_name} — skipping.")
    return(invisible(NULL))
  }
  content <- paste(readLines(tmpl_path, warn = FALSE), collapse = "\n")
  # Substitute all {{KEY}} placeholders
  for (nm in names(subs)) {
    content <- gsub(paste0("\\{\\{", nm, "\\}\\}"), subs[[nm]], content, fixed = FALSE)
  }
  dest_path <- fs::path(project_dir, dest_relpath)
  fs::dir_create(fs::path_dir(dest_path))
  writeLines(content, dest_path)
}


#' @keywords internal
.prompt_yn <- function(msg, default = TRUE) {
  default_str <- if (default) "[Y/n]" else "[y/N]"
  raw <- readline(prompt = paste0("  ? ", msg, " ", default_str, ": "))
  raw <- trimws(tolower(raw))
  if (!nzchar(raw)) return(default)
  raw %in% c("y", "yes")
}
