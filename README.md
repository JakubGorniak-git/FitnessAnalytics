# 🏋️ Fitness Analytics Dashboard

An interactive R Shiny dashboard for analyzing gym exercise data. Ideal for fitness enthusiasts, trainers, and researchers interested in exploring patterns, equipment usage, and top-rated exercises.

## 🎯 Key Features

- **Interactive Visualizations**  
  Analyze muscle groups, exercise difficulty, equipment usage, and rating distributions

- **Smart Filtering System**  
  Filter by difficulty, ratings, equipment, exercise type, and more

- **Sortable Data Tables**  
  Searchable tables with color-coded ratings and export functionality

- **Modern UI Design**  
  Responsive layout with clean visuals, CSS styling, and loading animations

## 📊 Dashboard Sections

1. **Overview** – Key stats, muscle popularity, difficulty and equipment summary  
2. **Body Part Analysis** – Muscle-focused stats, recommended equipment  
3. **Equipment Analysis** – Heatmaps of body part vs. equipment usage  
4. **Top Exercises** – Highest-rated exercises and performance comparisons  
5. **Interactive Exploration** – Custom filters and scatter plots  
6. **About** – Dataset and tech stack info

## 📁 Dataset

The dashboard uses a CSV file named `gym_cleaned.csv` with the following columns:

| Column     | Description                         |
|------------|-------------------------------------|
| Title      | Name of the exercise                |
| BodyPart   | Targeted muscle group               |
| Equipment  | Required equipment                  |
| Type       | Exercise category                   |
| Level      | Difficulty level (Beginner, etc.)   |
| Rating     | Exercise rating (0–10 scale)        |


## 📌 Data Source: https://www.kaggle.com/datasets/niharika41298/gym-exercise-data

## 🛠️ Built With
- **R (4.0+)**
- **Shiny, shinydashboard**
- **plotly, ggplot2**
- **dplyr, tidyr, forcats**
- **DT (DataTables)**
- **shinyWidgets, shinycssloaders**

## 🚀 How to Run This Project

To run the Fitness Analytics Dashboard locally on your machine, follow these steps:

### 1. 📦 Install Required R Packages

Open R or RStudio and run:

```r
install.packages(c("shiny", "shinydashboard", "DT", "plotly", 
                   "dplyr", "ggplot2", "tidyr", "forcats", 
                   "viridis", "ggbeeswarm", "shinycssloaders", 
                   "shinyWidgets", "fresh"))
```

### 2. 🧬 Clone the Repository

Use Git to download the project files:

```bash
git clone [https://github.com/JakubGorniak-git/FitnessAnalytics.git](https://github.com/JakubGorniak-git/FitnessAnalytics.git)
cd FitnessAnalytics
```

### 3. 📁 Prepare the Dataset
Make sure the file gym_cleaned.csv is in the main project directory.

### 4. 🧪 Run the Application
In your R console, run:
```r
shiny::runApp()
```
The dashboard should open automatically in your web browser (e.g., http://127.0.0.1:xxxx).

## 🌐 Live Demo
🔗 Live Demo on [shinyapps.io](https://jakubgorniak.shinyapps.io/gym_dashboard/)

## 📝 License
MIT License.
Icons provided by Font Awesome.
Built with the amazing R Shiny ecosystem.

<div align="center"> ⭐ If you find this project helpful, please consider giving it a star! ⭐ </div>
