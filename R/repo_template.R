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
#' @param in_place Logical. If \code{TRUE}, scaffolds into the current working
#'   directory instead of creating a new subdirectory. Use this when your R
#'   terminal is already inside the project folder (e.g. a freshly cloned repo).
#'   Defaults to \code{TRUE} — so \code{repo_template()} with no arguments works
#'   out of the box.
#'
#' @return Invisibly returns the full path to the created project directory.
#' @export
#'
#' @examples
#' \dontrun{
#' # Scaffold into the current directory (default — terminal already inside the project)
#' repo_template()
#'
#' # Create a new named subdirectory elsewhere
#' repo_template("my-new-analysis", path = "~/Desktop/Repos", in_place = FALSE)
#' }
repo_template <- function(project_name = NULL,
                           path        = getwd(),
                           github_user = "jdpreston30",
                           in_place    = TRUE) {

  #* 1: Validate inputs and resolve project directory
  if (in_place) {
    project_dir  <- fs::path_abs(getwd())
    project_name <- fs::path_file(project_dir)
    cli::cli_alert_info("Scaffolding in place into: {project_dir}")
  } else {
    if (is.null(project_name) || !nzchar(project_name)) {
      cli::cli_abort("project_name must be a non-empty string when in_place = FALSE.")
    }
    project_dir <- fs::path_abs(fs::path(path, project_name))
    if (fs::dir_exists(project_dir)) {
      cli::cli_abort(c(
        "Directory already exists: {project_dir}",
        "i" = "If your terminal is already inside the project folder, use: repo_template(in_place = TRUE)"
      ))
    }
  }

  cli::cli_h1("Scaffolding project: {project_name}")
  cli::cli_alert_info("Target directory: {project_dir}")

  #* 2: Create directory tree
  dirs <- c(
    ".github",
    ".vscode",
    "All_Run",
    "Outputs/Figures",
    "Outputs/Tables",
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
  write_tmpl(project_dir, ".github/copilot-instructions.md",         "copilot-instructions.md",         subs)
  write_tmpl(project_dir, ".github/figure-style.instructions.md",    "figure-style.instructions.md",    subs)
  write_tmpl(project_dir, ".vscode/settings.json",                   "vscode_settings.json",            subs)
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
    "  This will: initialize renv, install TernTables from GitHub, and snapshot the lockfile."
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

    #+ 4.2: Install TernTables from GitHub
    cli::cli_alert_info("Installing TernTables from {github_user}/TernTables...")
    tryCatch({
      if (!requireNamespace("remotes", quietly = TRUE)) {
        renv::install("remotes")
      }
      remotes::install_github(
        paste0(github_user, "/TernTables"),
        upgrade = "never"
      )
      cli::cli_alert_success("TernTables installed")
    }, error = function(e) {
      cli::cli_alert_warning("Could not install TernTables: {e$message}")
      cli::cli_alert_info("Run: remotes::install_github(\"{github_user}/TernTables\") manually.")
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

  #* 6: Interactive prompt — GitHub repository linking
  cli::cli_h2("GitHub Repository Setup")
  cli::cli_alert_info(paste0(
    "Linking to GitHub lets you back up your work, collaborate, and version-control\n",
    "  your analysis. This step will push the initial scaffold to a new remote repo."
  ))
  link_github <- .prompt_yn("Link this project to a GitHub repository?", default = FALSE)

  if (link_github) {
    #+ 6.1: Check for GitHub CLI — use it if available, otherwise fall back to browser+paste
    gh_available <- nzchar(Sys.which("gh"))
    gh_authed    <- FALSE
    if (gh_available) {
      auth_check <- system2("gh", c("auth", "status"), stdout = TRUE, stderr = TRUE)
      gh_authed  <- !isTRUE(attr(auth_check, "status") != 0)
    }

    if (gh_available && gh_authed) {
      #+ 6.1a: Fully automatic path via GitHub CLI
      cli::cli_text("")
      cli::cli_rule(left = "GitHub CLI detected \u2014 creating repository automatically")
      cli::cli_text("")

      visibility_ans <- ""
      repeat {
        cli::cli_text("  ? Visibility \u2014 select one:")
        cli::cli_text("    1: public")
        cli::cli_text("    2: private")
        vis_choice <- trimws(readline(prompt = "  Selection: "))
        if (vis_choice == "1") { visibility_ans <- "public";  break }
        if (vis_choice == "2") { visibility_ans <- "private"; break }
        cli::cli_alert_warning("Please enter 1 (public) or 2 (private).")
      }

      cli::cli_alert_info("Creating {visibility_ans} repository '{project_name}' on GitHub...")
      gh_out <- system2(
        "gh",
        c("repo", "create", paste0(github_user, "/", project_name),
          paste0("--", visibility_ans)),
        stdout = TRUE, stderr = TRUE
      )
      gh_status <- attr(gh_out, "status")

      if (isTRUE(gh_status != 0)) {
        cli::cli_alert_warning("gh repo create failed: {paste(gh_out, collapse = ' ')}")
        cli::cli_alert_info("Falling back to manual URL entry...")
        gh_authed <- FALSE  # trigger fallback below
      } else {
        # gh prints the repo URL to stdout
        remote_url <- trimws(gh_out[nzchar(trimws(gh_out))][1])
        if (!grepl("github\\.com", remote_url)) {
          remote_url <- paste0("https://github.com/", github_user, "/", project_name, ".git")
        }
        cli::cli_alert_success("Repository created: {.url {remote_url}}")
      }
    }

    if (!gh_available || !gh_authed) {
      #+ 6.1b: Manual path — open browser, user pastes URL
      cli::cli_text("")
      if (!gh_available) {
        cli::cli_alert_info(
          "GitHub CLI (gh) not found. Opening GitHub in your browser instead."
        )
        cli::cli_alert_info(
          "Tip: install gh for a fully automatic experience \u2014 {.url https://cli.github.com}"
        )
      } else {
        cli::cli_alert_info("GitHub CLI is not authenticated. Opening GitHub in your browser.")
        cli::cli_alert_info("Tip: run {.code gh auth login} once to enable full automation.")
      }
      cli::cli_text("")
      cli::cli_rule(left = "STEP 1 \u2014 Create a new repository on GitHub")
      cli::cli_text("")
      cli::cli_alert_info("Opening https://github.com/new in your browser...")
      utils::browseURL("https://github.com/new")
      cli::cli_text("")
      cli::cli_bullets(c(
        "1" = "A browser tab just opened to: {.url https://github.com/new}",
        "2" = "Set the repository name to: {.strong {project_name}}",
        "3" = "{.emph Leave it EMPTY} \u2014 do NOT add a README, .gitignore, or license",
        "  " = "(the template already provides all of these)",
        "4" = "Set visibility to Public or Private as desired",
        "5" = "Click {.strong \"Create repository\"}",
        "6" = "On the next page, copy the HTTPS URL shown under \"Quick setup\"",
        "  " = "It will look like: https://github.com/{github_user}/{project_name}.git"
      ))
      cli::cli_text("")
      cli::cli_rule(left = "STEP 2 \u2014 Paste the URL below")
      cli::cli_text("")

      remote_url <- ""
      repeat {
        remote_url <- trimws(readline(prompt = "  > Paste GitHub repository URL: "))
        if (grepl("^https://github\\.com/.+/.+\\.git$", remote_url) ||
            grepl("^git@github\\.com:.+/.+\\.git$", remote_url) ||
            grepl("^https://github\\.com/.+/.+$", remote_url)) {
          break
        }
        if (nzchar(remote_url)) {
          cli::cli_alert_warning("That doesn't look like a valid GitHub URL. Please try again.")
          cli::cli_alert_info("Expected format: https://github.com/{github_user}/{project_name}.git")
        } else {
          cli::cli_alert_warning("URL cannot be blank. Please paste the URL from GitHub.")
        }
      }
    }

    #+ 6.3: Initialize git and link remote
    old_wd2 <- getwd()
    on.exit(setwd(old_wd2), add = TRUE)
    setwd(project_dir)

    git_ok <- TRUE

    # Initialise git repo if not already done
    if (!fs::dir_exists(fs::path(project_dir, ".git"))) {
      cli::cli_alert_info("Initializing git repository...")
      result <- system2("git", c("init", "-b", "main"), stdout = TRUE, stderr = TRUE)
      if (!identical(attr(result, "status"), 0L) && !is.null(attr(result, "status"))) {
        # Older git versions don't support -b; try plain init + branch rename
        system2("git", "init", stdout = FALSE, stderr = FALSE)
        system2("git", c("checkout", "-b", "main"), stdout = FALSE, stderr = FALSE)
      }
      cli::cli_alert_success("Git repository initialized")
    }

    # Set remote origin
    cli::cli_alert_info("Setting remote origin to: {remote_url}")
    ret <- system2("git", c("remote", "add", "origin", remote_url),
                   stdout = TRUE, stderr = TRUE)
    if (isTRUE(attr(ret, "status") != 0)) {
      # Remote may already exist — update it instead
      system2("git", c("remote", "set-url", "origin", remote_url),
              stdout = FALSE, stderr = FALSE)
      cli::cli_alert_info("Remote origin updated")
    } else {
      cli::cli_alert_success("Remote origin set")
    }

    # Stage all files
    cli::cli_alert_info("Staging all project files...")
    ret <- system2("git", c("add", "-A"), stdout = TRUE, stderr = TRUE)
    if (isTRUE(attr(ret, "status") != 0)) {
      cli::cli_alert_warning("git add failed. You may need to commit manually.")
      git_ok <- FALSE
    }

    # Initial commit
    if (git_ok) {
      cli::cli_alert_info("Creating initial commit...")
      ret <- system2(
        "git",
        c("commit", "-m", shQuote("Initial scaffold via JDP.repo::repo_template()")),
        stdout = TRUE, stderr = TRUE
      )
      if (isTRUE(attr(ret, "status") != 0)) {
        cli::cli_alert_warning("git commit failed. Check git config user.name / user.email.")
        git_ok <- FALSE
      } else {
        cli::cli_alert_success("Initial commit created")
      }
    }

    # Push to GitHub
    if (git_ok) {
      cli::cli_alert_info("Pushing to GitHub (this may prompt for credentials)...")
      ret <- system2("git", c("push", "-u", "origin", "main"),
                     stdout = TRUE, stderr = TRUE)
      if (isTRUE(attr(ret, "status") != 0)) {
        cli::cli_alert_warning("Push failed. Common fixes:")
        cli::cli_bullets(c(
          "x" = "Make sure the GitHub repo exists and the URL is correct",
          "x" = "Authenticate via: gh auth login  (GitHub CLI) or configure a PAT",
          "i" = "Then manually run: git push -u origin main"
        ))
      } else {
        cli::cli_alert_success("Project pushed to GitHub!")
        cli::cli_alert_info("View your repo at: {.url {sub(\"\\\\.git$\", \"\", remote_url)}}")
      }
    }

    setwd(old_wd2)
  } else {
    cli::cli_alert_info("Skipped. To link later, run: git remote add origin <url> && git push -u origin main")
  }

  #* 7: Final summary
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
  tmpl_path <- system.file("templates", template_name, package = "JDP.repo")
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
