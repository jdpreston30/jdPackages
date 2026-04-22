# GitHub Copilot Instructions

> **Note:** These are general coding style and structural preferences that apply broadly across projects. They represent defaults and conventions — not rigid requirements. Specific details such as subfolder naming conventions, pipeline numbering schemes, or output directory layouts may not apply at that level of resolution in every repo. Use these as guiding principles and adapt as the project warrants.

**R Code Style & Project Structure Preferences:**

## Comments & Spacing
- **Hierarchical comment structure**: `#*` (major section), `#+` (subsection), `#-` (detail/sub-subsection), `#_` (individual item), `#!` (important note)
- **Numbering format**: 
  - Major sections: `#* 9: Validation Plots Adjustment`
  - Subsections: `#+ 9.2: Plots that failed after review`
  - Details: `#- 9.2.1: Methylparaben (CP2252)`
  - Items can use colon format: `#_ Compound Name (ID)`
- **Inline comments**: Regular explanatory comments within code blocks just use `#` without special symbols
- **Comments are brief and descriptive**: Typically compound names, short phrases, or action descriptions
- **Compact code style**: NO extra blank lines between sections or subsections - code should be dense
- **No blank lines after section headers**: Code immediately follows comment headers
- **Example structure**:
  ```r
  #* 9: Major Section
  if (!isTRUE(config$skip_something)) {
  #+ 9.2: Subsection
  #- 9.2.1: Compound Name (ID)
  variable <- function_call(args)
  # Regular inline comment explaining something specific
  another_variable <- function_call(args)
  #- 9.2.2: Next Compound (ID)
  more_code <- function_call(args)
  }
  ```

## Project Architecture
- Use YAML configuration files for dynamic, computer-specific paths (`All_Run/config_dynamic.yaml`)
- Store utility functions in organized subdirectories: `R/Utilities/Helpers/`, `R/Utilities/Visualization/`, `R/Utilities/Analysis/`, etc.
- Use renv for package management with automatic restore on first run
- Pipeline structure: Main run script (`All_Run/run.R`) sources numbered scripts sequentially inside `{ }`
- Load all utility functions at setup with: `purrr::walk(list.files("R/Utilities", recursive = TRUE, full.names = TRUE, pattern = "\\.R$"), source)`
- Store configuration in `.GlobalEnv$config` for global access throughout pipeline
- Use `load_dynamic_config()` pattern for automatic computer detection and path resolution
- Declare all package dependencies in `DESCRIPTION` under `Imports:` only — no `Remotes:` field needed
- Non-CRAN packages (e.g. TernTables) are available via r-universe, which is configured in `.Rprofile` — treat them exactly like CRAN packages

## Functions
- **NEVER write functions or helpers directly inside `R/Scripts/` files.** Scripts are exclusively for pipeline steps (data flow, calling functions, orchestration). Every reusable function — no matter how small — must be modularized into its own dedicated file inside `R/Utilities/` (e.g., `R/Utilities/Helpers/`, `R/Utilities/Visualization/`, `R/Utilities/Analysis/`). One logical unit per file.
- Use roxygen2-style documentation for all utility functions
- Prefer tidyverse functions when appropriate
- Functions should respect YAML configuration flags (e.g., skip logic based on `config$` parameters)
- Separate concerns: e.g., plot generation vs PDF compilation in separate functions

## File Organization
- Scripts: Numbered for pipeline order (`00a`, `00b`, `01`, `02`, etc.) inside `R/Scripts/`
- Outputs: Organized in `Outputs/Figures/` and `Outputs/Tables/`
- Use OneDrive for final output storage, local `Outputs/` for run-specific I/O
- `All_Run/run.R` is the single entry point — sourcing it runs the complete pipeline

## TernTables
- `TernTables` is a standard dependency declared in `DESCRIPTION` under `Imports:` only (no `Remotes:` field needed)
- It is served via the jdpreston30 R-universe (<https://jdpreston30.r-universe.dev/TernTables>), which is a CRAN-compatible binary repository
- The `.Rprofile` sets `options(repos = c(jdpreston30 = "https://jdpreston30.r-universe.dev", CRAN = "https://cloud.r-project.org"))` so `install.packages("TernTables")` works directly — **no `remotes` or `devtools` required**
- renv snapshots it from r-universe automatically; `renv::restore()` reinstalls it without any special handling
- Do **not** use `remotes::install_github()` for TernTables — that bypasses the CRAN-compatible binary and is slower
- Do **not** add a `Remotes:` field to `DESCRIPTION` for TernTables
