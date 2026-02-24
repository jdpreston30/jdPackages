# {{PROJECT_NAME}}

## Overview

[ENTER BRIEF PROJECT DESCRIPTION HERE]

**Status:** [In Progress / Under Review / Published]
**Manuscript:** [Journal name, year — link when available]
**Data repository:** [e.g. MetaboLights ID, if applicable]

---

## Requirements

- R ≥ 4.5.0
- [renv](https://rstudio.github.io/renv/) for reproducible package management
- TinyTeX for PDF/supplementary rendering (`tinytex::install_tinytex()`)
- [Optional] Docker for fully containerised reproducibility

---

## Quick Start

```r
# 1. Open the project (.Rproj or setwd())
# 2. Restore renv packages (first run only — may take 10–20 min)
renv::restore()

# 3. Edit computer-specific paths
#    Open: All_Run/config_dynamic.yaml

# 4. Run the full pipeline
source("All_Run/run.R")
```

See `QUICKSTART.txt` for complete onboarding instructions.

---

## Project Structure

```
{{PROJECT_NAME}}/
├── All_Run/
│   ├── config_dynamic.yaml   # Computer-specific path configuration
│   └── run.R                 # Master pipeline runner
├── R/
│   ├── Scripts/              # Numbered pipeline scripts (00a, 00b, 01, 02, ...)
│   └── Utilities/            # Reusable functions (Analysis, Helpers, Visualization, ...)
├── Outputs/
│   ├── Figures/              # Generated figures
│   └── Tables/               # Generated tables
├── DESCRIPTION               # Package-style dependency declaration
├── QUICKSTART.txt            # Full onboarding guide
└── renv.lock                 # Exact package versions
```

---

## Data Availability

[DESCRIBE DATA ACCESS — raw data location, OneDrive path, MassIVE/MetaboLights accession, etc.]

---

## Citation

[ENTER CITATION WHEN AVAILABLE]

---

## Contact

Joshua Preston · joshua.preston@emory.edu · [{{GITHUB_USER}}](https://github.com/{{GITHUB_USER}})
