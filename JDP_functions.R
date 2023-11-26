JDP_ref <- function(arg) {
  if (missing(arg)) {
    print("Please provide an argument.")
  }
  else if (deparse(substitute(arg)) == "best_practice") {
    cat("\n")
    cat("\033[1m\033[4mBest Practice Guidelines:\033[0m\n")
    cat("\033[1m\033[38;5;208m Sectioning, Headings, Subheadings, Comments:\033[0m\n")
    cat("  • A single asterisk will make a section title (light green, bold, underlined, all caps)\n")
    cat("  • Three plus symbols will make a heading (blue, bold, underlined)\n")
    cat("  • Five minus signs will make a subheading (orange, underlined)\n")
    cat("  • An exclamation point is used to make long comments (red, italic)\n")
    cat("  • A single forward slash will strikethrough text (charcoal)\n")
    cat("  • A single hash is ONLY used to comment out codes that toggle\n")
    cat("  • A single underscore is used for normal, short comments or descriptors (white), which always are on line above}\n")
    cat("\n")
    cat("\033[1m\033[38;5;208m Spacing:\033[0m\n")
    cat("  • Three lines separate entire sections of code\n")
    cat("  • Two lines separate entire headings of code\n")
    cat("  • One line separates entire subheadings of code (orange)\n")
    cat("  • Always indent the code inside curly braces\n")
    cat("  • Always put a space after a comma in a parenthetical statement\n")
    cat("  • Bracketed statements are ALWAYS [row:row, col:col]\n")
  } else if (deparse(substitute(arg)) == "shortcuts") {
    cat("\n")
    cat("\033[1m\033[4mKeyboard Shortcuts:\033[0m\n")
    cat("\033[1m\033[38;5;208m General:\033[0m\n")
    cat("  • cmd + / = comment out entire line\n")
    cat("  • cmd + <- OR -> = move cursor to beginning or end of line\n")
    cat("  • cmd + ^ = move cursor to beginning\n")
    cat("  • cmd  + K (in terminal) = clear terminal\n")
    cat("  • cmd + shift + <- OR -> = select line\n")
    cat("  • cmd + shift + ^ = select all code above\n")
    cat("  • cmd + K then cmd + 0 = collapse all sections\n")
    cat("  • cmd + K then cmd + J = unfold all sections\n")
    cat("  • cmd + shift + f = manual fold from section\n")
    cat("  • cmd + shift + d = remove manual fold from selection\n")
  } else if (deparse(substitute(arg)) == "cheatsheet") {
    cat("\n")
    cat("\033[1m\033[4mCheatsheet:\033[0m\n")
    cat("\033[1m\033[38;5;208m General:\033[0m\n")
    cat("  • print() = print df in terminal\n")
    cat("  • ncol() or nrow () = number of columns or rows in df\n")
    cat("  • tibble() = write df as tibble\n")
    cat("  • data <- read_csv('file_name.csv') = import CSV into dataframe\n")
    cat("  • cbind(df1, df2) = combine two dataframes\n")
    cat("  • log(insert base)() = log transform dataframe\n")
    cat("  • write_csv(df, 'file_name.csv') = saves df as CSV\n")
  }
  else {
    cat("\n")
    cat("\033[1m\033[4m\033[31mInvalid input. Please specify one of the following:\n\033[0m")
    cat("\033[31m  • best_practice\n")
    cat("  • shortcuts\n")
    cat("  • cheatsheet\033[0m\n")
  }
}

JDP_setup <- function() {
  cat("\n")
  cat("#~ Part 1\n")
  cat("#* SETUP\n")
  cat("#++ Housekeeping\n")
  cat('options(repos = c(CRAN = "https://cloud.r-project.org/")) #_CRAN Mirror\n')
  cat('setwd("/Users/JoshsMacbook2015/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Euthanized Emory SLAM Metabolomics Summer 2023 (Sync to M drive)/UNTARGETED Analysis/Data Preprocess") #_Set working directory\n')
  cat('Sys.setenv("VROOM_CONNECTION_SIZE" = 524288) #_Increase VROOM\n')
  cat('options(tibble.print_max = 150) #_Increase tibble printing lines\n\n')
  cat("#++ Packages\n")
  cat("#--- Loading packages using pacman and librarian\n")
  cat("library(pacman)\n")
  cat("library(librarian)\n")
  cat("lib_startup()\n")
  cat("#--- Detecting package conflicts with 'amigoingmad'\n")
  cat("#_This will ensure dplyr is always \"on top\" for functions like select()\n")
  cat("amigoingmad() ###\n")
}



