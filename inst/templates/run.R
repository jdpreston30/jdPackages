#* ALL RUN — {{PROJECT_NAME}}
# Master pipeline runner. Source this file to execute the full analysis.
# Each script is sourced in order; 00x scripts handle environment, packages,
# and utility loading before numbered analysis scripts begin.
# Edit config_dynamic.yaml before running on a new machine.
{
source("R/Utilities/Helpers/load_dynamic_config.R")
config <- load_dynamic_config(computer = "auto", config_path = "All_Run/config_dynamic.yaml")
source("R/Scripts/00a_environment_setup.R")
source("R/Scripts/00b_setup.R")
#+ Analysis scripts — add or rename as the project grows
source("R/Scripts/01_step1.R")
source("R/Scripts/02_step2.R")
}
