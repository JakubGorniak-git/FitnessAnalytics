library(dplyr)
library(readr)

raw_data <- read.csv("gym_dashboard/gym.csv", sep=",", stringsAsFactors = FALSE)

if("X" %in% names(raw_data)) {
  raw_data <- raw_data %>% select(-X)
}

str(raw_data)
required_cols <- c("Title", "Desc", "Type", "BodyPart", "Equipment", "Level", "Rating")
missing_cols <- setdiff(required_cols, names(raw_data))

if(length(missing_cols) > 0) {
  stop("Missing columns: ", paste(missing_cols, collapse = ", "))
}

duplicate_titles <- raw_data %>%
  count(Title) %>%
  filter(n > 1) %>%
  arrange(desc(n))

cat("Duplicats of titles:", nrow(duplicate_titles), "\n")
if(nrow(duplicate_titles) > 0) {
  cat("Top 5:\n")
  print(head(duplicate_titles, 5))
}

title_prefixes <- raw_data %>%
  mutate(
    prefix = gsub("^([A-Za-z ]+?)([A-Z][a-z]|$).*", "\\1", Title),
    prefix = trimws(prefix)
  ) %>%
  count(prefix, sort = TRUE) %>%
  filter(n > 10)

cat("\Top prefix in titles:\n")
print(head(title_prefixes, 10))

# missing values
cat("\nMissing values:\n")
sapply(raw_data, function(x) sum(is.na(x) | x == "" | x == 0)) %>%
  sort(decreasing = TRUE) %>%
  print()

cat("\nUnique:\n")
cat("Type:", length(unique(raw_data$Type)), "->", paste(unique(raw_data$Type), collapse = ", "), "\n")
cat("BodyPart:", length(unique(raw_data$BodyPart)), "->", paste(unique(raw_data$BodyPart), collapse = ", "), "\n")
cat("Equipment:", length(unique(raw_data$Equipment)), "->", paste(unique(raw_data$Equipment), collapse = ", "), "\n")
cat("Level:", length(unique(raw_data$Level)), "->", paste(unique(raw_data$Level), collapse = ", "), "\n")

clean_data <- raw_data %>%
  mutate(
    Title_Original = Title,
    Title = gsub("^(Dumbbell Fix |Barbell |Cable |Machine |Band[ed]* |Kettlebell |Medicine Ball )", "", Title),
    Title = gsub("^(FYR |BFR |Power |Partner )", "", Title),
    Title = trimws(Title),
    BodyPart_Original = BodyPart,
    BodyPart = case_when(
      BodyPart %in% c("Lats", "Middle Back", "Lower Back") ~ "Back",
      BodyPart %in% c("Biceps", "Triceps", "Forearms") ~ "Arms", 
      BodyPart %in% c("Hamstrings", "Quadriceps", "Calves", "Glutes") ~ "Legs",
      BodyPart %in% c("Traps", "Neck") ~ "Shoulders",
      BodyPart == "Adductors" ~ "Legs",
      BodyPart == "Abductors" ~ "Legs",
      TRUE ~ BodyPart
    ),
    
    Equipment_Original = Equipment,
    Equipment = case_when(
      Equipment %in% c("Bands", "E-Z Curl Bar") ~ "Other",
      Equipment == "Body Only" ~ "Bodyweight",
      Equipment == "Medicine Ball" ~ "Other",
      Equipment == "Exercise Ball" ~ "Other",
      Equipment == "Foam Roll" ~ "Other",
      Equipment == "None" ~ "Bodyweight",
      TRUE ~ Equipment
    ),
    
    Rating = ifelse(Rating == 0, NA, Rating),
    
    HasRating = !is.na(Rating),
    RatingCategory = case_when(
      is.na(Rating) ~ "Nie oceniono",
      Rating >= 9.0 ~ "Doskonałe (9.0+)",
      Rating >= 8.0 ~ "Bardzo dobre (8.0-8.9)",
      Rating >= 7.0 ~ "Dobre (7.0-7.9)",
      Rating >= 6.0 ~ "Średnie (6.0-6.9)",
      TRUE ~ "Słabe (<6.0)"
    ),
    
    ComplexityScore = case_when(
      Level == "Beginner" ~ 1,
      Level == "Intermediate" ~ 2,
      Level == "Expert" ~ 3
    ) + case_when(
      Equipment == "Bodyweight" ~ 0,
      Equipment %in% c("Dumbbell", "Barbell") ~ 1,
      Equipment %in% c("Cable", "Machine") ~ 0.5,
      TRUE ~ 1
    ),
    
    DescLength = nchar(Desc),
  
    ShortDesc = ifelse(DescLength > 120, 
                       paste0(substr(Desc, 1, 120), "..."), 
                       Desc)
  ) %>%
  distinct(Title, BodyPart, .keep_all = TRUE) %>%
  filter(DescLength > 10 | is.na(Desc))

cat("Data after cleaning:", nrow(clean_data), "ćwiczeń\n")
cat("Deleted:", nrow(raw_data) - nrow(clean_data), "wierszy\n")
cat("Rated:", sum(clean_data$HasRating, na.rm = TRUE), "\n")
cat("Avg rating:", round(mean(clean_data$Rating, na.rm = TRUE), 2), "\n")
write.csv(clean_data, "gym_cleaned.csv", row.names = FALSE)
