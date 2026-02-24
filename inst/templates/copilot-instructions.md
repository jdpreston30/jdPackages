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
- Declare all package dependencies in `DESCRIPTION` under `Imports:` (and `Remotes:` for GitHub packages)
- GitHub-only packages (e.g. TernTablesR) go in both `Imports:` and `Remotes:` in DESCRIPTION

## Functions
- Use roxygen2-style documentation for all utility functions
- Prefer tidyverse functions when appropriate
- Functions should respect YAML configuration flags (e.g., skip logic based on `config$` parameters)
- Separate concerns: e.g., plot generation vs PDF compilation in separate functions

## File Organization
- Scripts: Numbered for pipeline order (`00a`, `00b`, `01`, `02`, etc.) inside `R/Scripts/`
- Outputs: Organized in `Outputs/Figures/Final/`, `Outputs/Figures/PDF/`, `Outputs/Figures/PNG/`, `Outputs/Tables/`, `Outputs/Validation/`
- Use OneDrive for final output storage, local `Outputs/` for run-specific I/O
- `All_Run/run.R` is the single entry point — sourcing it runs the complete pipeline

## TernTablesR
- `TernTablesR` (from GitHub: `jdpreston30/TernTablesR`) is a standard dependency
- It is declared in `DESCRIPTION` under both `Imports:` and `Remotes:`
- Install via: `remotes::install_github("jdpreston30/TernTablesR")`
- It is **not** on CRAN — do not use `install.packages()` for it
