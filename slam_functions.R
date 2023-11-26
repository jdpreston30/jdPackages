set_age_class <- function(tb) {
  tb %>%
    mutate(Age_Classification = case_when(
      Age >= 6 & Age <= 9 ~ "6 - 9 months (Young Adult)",
      Age >= 12 & Age <= 15 ~ "12 - 15 months (Middle Adult)",
      Age >= 18 & Age <= 24.5 ~ "18 - 24.5 months (Older Adult)",
      Age >= 27 & Age <= 34 ~ "27 to 34 months (Aged)",
      TRUE ~ "Unknown"
    )) %>%
    select(1:4, Age_Classification, 5:ncol(.)) %>%
    mutate(Age_Classification = factor(Age_Classification))
}

males <- function(tb) {
  tb %>%
    filter(Sex == "M")
}

females <- function(tb) {
  tb %>%
    filter(Sex == "F")
}

B6s <- function(tb) {
  tb %>%
    filter(Strain == "B6")
}

HET3s <- function(tb) {
  tb %>%
    filter(Strain == "HET3")
}


#++ PLS DAs
PLS_DA <- function(tb, filename_and_title, legend_title) {
  #_Convert the input tibble to a data frame
  tb_df <- as.data.frame(tb)
  #_Extract the response variable
  response <- tb_df[, 1]
  #_Exclude the response variable from the predictors
  predictors <- tb_df[, -1]
  #_Run the PLS-DA analysis
  plsda_model <- plsda(X = predictors, Y = response, ncomp = 3)
  #_Extract the scores
  scores <- plsda_model$variates$X[, 1:2]
  #_Combine the scores and response into one data frame
  plsda_results <- cbind(scores, response)
  #_Write the results to a CSV file named after the input tibble
  write.csv(plsda_results, file = paste0(filename_and_title, ".csv"), row.names = FALSE)
  #_Plot the results
  #_Define the background object as a data frame containing the predictor variables
  background = background.predict(plsda_model, comp.predicted=2, dist = "max.dist")
  plotIndiv(plsda_model, ind.names = FALSE, ellipse = TRUE, legend = TRUE, legend.title = legend_title, title = filename_and_title)
  # plotIndiv(plsda_model, ind.names = FALSE, legend = TRUE, legend.title = legend_title, title = filename_and_title, background = background)
}


#++ Set old baseline
#_Build an "old" (>=27 mo) population baseline for each metabolite intensity
#_Check what percent of rows will be used
# sum(tb$Age >= 27)
# nrow(tb))*100
set_old_baseline <- function(tb,output_name) {
  slam_log_old_baseline_i = tb %>%
    filter(Age >= 27) %>%
    summarize(across(where(is.numeric), mean, na.rm=TRUE))
  #_Manually change the age to 27
  slam_log_old_baseline <- slam_log_old_baseline_i %>%
    mutate(Age = 27)
  #_Remove >=27 month values from original table since these are the "ending point"
  slam_log_young <- tb %>%
    filter(Age < 27)
  slam_log_all_subjects <- tb [,1:4]
  slam_log_unique_subjects <- slam_log_all_subjects %>%
    distinct(Sub_ID, .keep_all = TRUE)
  #_Merge stand-in old values with unique ID's, giving them a stand-in "27mo"
  #_Replicate unique subject id count of rows
  full_old_baseline <- slam_log_old_baseline %>%
    slice(rep(1:n(), each = nrow(slam_log_unique_subjects)))
  slam_27 <- as_tibble(cbind(slam_log_unique_subjects[,1:3],full_old_baseline))
  slam_young_27 <- bind_rows(slam_27,slam_log_young)
  assign(output_name, slam_young_27, envir = .GlobalEnv)
}
