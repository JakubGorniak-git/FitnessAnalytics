# ui.R

library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(shinycssloaders)
library(shinyWidgets)
library(fresh)

ui <- dashboardPage(
  skin = "blue",
  dashboardHeader(
    title = div(
      style = "display: flex; align-items: center;",
      icon("dumbbell", style = "margin-right: 10px; color: #3b82f6;"),
      span("Fitness Analytics", style = "font-weight: bold; color: #white;")
    ),
    titleWidth = 280
  ),
  dashboardSidebar(
    width = 280,
    sidebarMenu(
      id = "sidebar",
      div(
        style = "text-align: center; padding: 15px 10px; margin-bottom: 15px; border-bottom: 1px solid rgba(255,255,255,0.1);",
        icon("chart-line", style = "font-size: 24px; color: #60a5fa;"),
        h4("Fitness Analytics", style = "margin-top: 10px; color: #f8fafc; font-weight: 600;")
      ),
      menuItem(" Dashboard", tabName = "overview", icon = icon("chart-line")),
      menuItem(" Body Parts", tabName = "bodyparts", icon = icon("user")),
      menuItem(" Equipment", tabName = "equipment", icon = icon("tools")),
      menuItem(" Top Exercises", tabName = "top_exercises", icon = icon("trophy")),
      menuItem(" Exploration", tabName = "exploration", icon = icon("search")),
      menuItem(" About", tabName = "about", icon = icon("info-circle"))
    ),
    div(style = "padding: 20px; color: #f1f5f9;",
        h4("Filters", style = "margin-bottom: 15px; font-weight: 600;"),
        pickerInput("filter_level", "Difficulty Level:", choices = c("All" = "all", "Beginner" = "Beginner", "Intermediate" = "Intermediate", "Expert" = "Expert"), selected = "all",
             width = "100%"),
        sliderInput("filter_rating", "Minimum Rating:", min = 0, max = 10, value = 0, step = 0.1, width = "100%"),
        prettyCheckbox("filter_rated_only", "Rated Exercises Only", FALSE, status = "primary", animation = "pulse", icon = icon("check"), shape="round", outline=TRUE,bigger=TRUE)
    )
  ),
  dashboardBody(
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")),
    tabItems(
      tabItem(tabName = "overview",
              fluidRow(
                column(12,
                       div(class = "hero-section", style = "text-align: center; padding: 40px 20px; background: linear-gradient(135deg, #4F46E5 0%, #7C3AED 100%); color: white; border-radius: 16px; margin-bottom: 30px; box-shadow: 0 10px 25px rgba(124, 58, 237, 0.2);",
                           div(style = "max-width: 800px; margin: 0 auto;",
                               h1("Fitness Analytics", style = "font-size: 3.5rem; margin-bottom: 15px; font-weight: 700; color: white; text-shadow: 0 2px 4px rgba(0,0,0,0.1);"),
                               h3("Discover the best exercises for your training", style = "font-size: 1.5rem; margin-bottom: 25px; font-weight: 500; color: rgba(255,255,255,0.9);"),
                               p("Analyze over 2900 exercises to discover new features in your training.",
                                 style = "font-size: 1.1rem; margin-bottom: 25px; font-weight: 400; color: rgba(255,255,255,0.8);"),
                           )
                       )
                )
              ),
              fluidRow(
                column(3,
                       div(class = "info-box", style = "border-radius: 12px; background: linear-gradient(135deg, #3B82F6 0%, #2563EB 100%); color: white; height: 120px; display: flex; align-items: center; padding: 20px;",
                           div(class = "info-box-icon", style = "font-size: 36px; margin-right: 15px; background: none", icon("dumbbell")),
                           div(class = "info-box-content", style = "margin-left: 5px;",
                               div(class = "info-box-text", style = "font-size: 14px; opacity: 0.9;", "Total Exercises"),
                               div(class = "info-box-number", style = "font-size: 24px; font-weight: 600;", textOutput("total_exercises_text"))
                           )
                       )
                ),
                column(3,
                       div(class = "info-box", style = "border-radius: 12px; background: linear-gradient(135deg, #F59E0B 0%, #D97706 100%); color: white; height: 120px; display: flex; align-items: center; padding: 20px;",
                           div(class = "info-box-icon", style = "font-size: 36px; margin-right: 15px;background: none", icon("star")),
                           div(class = "info-box-content", style = "margin-left: 5px;",
                               div(class = "info-box-text", style = "font-size: 14px; opacity: 0.9;", "Average Rating"),
                               div(class = "info-box-number", style = "font-size: 24px; font-weight: 600;", textOutput("avg_rating_text"))
                           )
                       )
                ),
                column(3,
                       div(class = "info-box", style = "border-radius: 12px; background: linear-gradient(135deg, #10B981 0%, #059669 100%); color: white; height: 120px; display: flex; align-items: center; padding: 20px;",
                           div(class = "info-box-icon", style = "font-size: 36px; margin-right: 15px;background: none", icon("user")),
                           div(class = "info-box-content", style = "margin-left: 1px;",
                               div(class = "info-box-text", style = "font-size: 14px; opacity: 0.9;", "Body Parts"),
                               div(class = "info-box-number", style = "font-size: 24px; font-weight: 600;", textOutput("body_parts_count_text"))
                           )
                       )
                ),
                column(3,
                       div(class = "info-box", style = "border-radius: 12px; background: linear-gradient(135deg, #EF4444 0%, #DC2626 100%); color: white; height: 120px; display: flex; align-items: center; padding: 20px;",
                           div(class = "info-box-icon", style = "font-size: 36px; margin-right: 15px;background: none", icon("tools")),
                           div(class = "info-box-content", style = "margin-left: 5px;",
                               div(class = "info-box-text", style = "font-size: 14px; opacity: 0.9;", "Equipment Types"),
                               div(class = "info-box-number", style = "font-size: 24px; font-weight: 600;", textOutput("equipment_count_text"))
                           )
                       )
                )
              ),
              fluidRow(
                box(title = "Most Popular Body Parts", status = "primary", style="text-align:center;", solidHeader = TRUE, width = 4, height = 450,
                    withSpinner(plotlyOutput("bodypart_bar", height = "360px"))
                ),
                box(title = "Difficulty Level Distribution", status = "primary", solidHeader = TRUE, width = 4, height = 450,
                    withSpinner(plotlyOutput("level_pie", height = "360px"))
                ),
                box(title = "Equipment Usage", status = "primary", solidHeader = TRUE, width = 4, height = 450,
                    withSpinner(plotlyOutput("equipment_usage", height = "360px"))
                )
              )
      ),
      tabItem(tabName = "bodyparts",
              fluidRow(
                column(12,
                       div(style = "background-color: #e9f5ff; padding: 30px; border-radius: 15px; margin-bottom: 30px; text-align: center; box-shadow: 0 6px 20px rgba(0,0,0,0.08);",
                           h2("Body Part Analysis", style = "margin-bottom: 10px; color: #004085; font-weight: 700; font-size: 2.5rem;"),
                           p("Explore exercises and their characteristics for each muscle group.", style = "color: #4a6c8b; font-size: 1.2rem; line-height: 1.6;")
                       )
                )
              ),
              fluidRow(
                column(4,
                       div(class = "custom-card",
                           h3("Select Body Part", style = "color: #333; margin-bottom: 15px; font-size: 2.4rem; text-align:center;"),
                           selectInput("selected_bodypart", NULL, choices = NULL, width = "100%"),
                           hr(style = "border-top: 1px solid #eee; margin: 20px 0;"),
                           div(id = "bodypart_info", style = "min-height: 0px; color: #555;")
                       )
                ),
                column(8,
                       div(class = "custom-card",
                           h3("Analysis Results", style = "color: #333; margin-bottom: 20px; font-size: 2.4rem; text-align:center;"),
                           tabsetPanel(
                             id = "bodypart_tabs",
                             tabPanel("Difficulty Breakdown",
                                      withSpinner(plotlyOutput("bodypart_stats", height = "500px"))),
                             tabPanel("Exercise List",
                                      withSpinner(DT::dataTableOutput("bodypart_exercises", height = "500px"))),
                             tabPanel("Equipment Usage",
                                      withSpinner(plotlyOutput("bodypart_equipment", height = "500px")))
                           )
                       )
                )
              )
      ),
      tabItem(tabName = "equipment",
              fluidRow(
                column(12,
                       div(style = "background-color: #e9f5ff; padding: 30px; border-radius: 15px; margin-bottom: 30px; text-align: center; box-shadow: 0 6px 20px rgba(0,0,0,0.08);",
                           h2("Equipment Analysis", style = "margin-bottom: 10px; color: #004085; font-weight: 700; font-size: 2.5rem;"),
                           p("Detailed information about exercises and their ratings for different types of equipment.", style = "color: #4a6c8b; font-size: 1.2rem; line-height: 1.6;")
                       )
                )
              ),
              fluidRow(
                column(8,
                       div(class = "custom-card",
                           h3("Heatmap: Body Parts vs. Equipment", style = "color: #333; margin-bottom: 20px; margin-top:-5px; font-size: 2.4rem; text-align:center;"),
                           withSpinner(plotlyOutput("equipment_heatmap", height = "500px"))
                       )
                ),
                column(4,
                       div(class = "custom-card",
                           h3("Equipment Rating Analysis", style = "color: #333; margin-bottom: 20px; margin-top:-5px; font-size: 2.4rem; text-align:center;"),
                           selectInput("selected_equipment", "Select equipment:", choices = NULL, width = "100%"),
                           hr(style = "border-top: 1px solid #eee; margin: 0px 0;"),
                           div(id = "equipment_stats_display", style = "min-height: 25px; color: #555; text-align: center;"),
                           withSpinner(plotlyOutput("equipment_rating_dist", height = "400px"))
                       )
                )
              )
      ),
      tabItem(tabName = "top_exercises",
              fluidRow(
                column(12,
                       div(style = "background-color: #e9f5ff; padding: 30px; border-radius: 15px; margin-bottom: 30px; text-align: center; box-shadow: 0 6px 20px rgba(0,0,0,0.08);",
                           h2("Top Rated Exercises Analysis", style = "margin-bottom: 10px; color: #004085; font-weight: 700; font-size: 2.5rem;"),
                           p("Discover the highest-rated exercises and analyze rating patterns.", style = "color: #4a6c8b; font-size: 1.2rem; line-height: 1.6;")
                       )
                )
              ),
              fluidRow(
                column(6,
                       div(class = "custom-card",
                           h3("Rating Distribution", style = "color: #333; margin-bottom: 20px; margin-top:-5px; font-size: 2.4rem; text-align:center"),
                           withSpinner(plotlyOutput("rating_distribution", height = "350px"))
                       )
                ),
                column(6,
                       div(class = "custom-card",
                           h3("Ratings by Difficulty Level", style = "color: #333; margin-bottom: 20px; margin-top:-5px;font-size: 2.4rem; text-align:center"),
                           withSpinner(plotlyOutput("rating_by_level", height = "350px"))
                       )
                )
              ),
              fluidRow(
                column(12,
                       div(class = "custom-card",
                           h3("Top 20 Highest Rated Exercises", style = "color: #333; margin-bottom: 20px; margin-top:-5px;font-size: 2.4rem; text-align:center"),
                           withSpinner(DT::dataTableOutput("top_exercises_table"))
                       )
                )
              )
      ),
      tabItem(tabName = "exploration",
              fluidRow(
                column(12,
                       div(style = "background-color: #e9f5ff; padding: 30px; border-radius: 15px; margin-bottom: 30px; text-align: center; box-shadow: 0 6px 20px rgba(0,0,0,0.08);",
                           h2("Exercise Exploration", style = "margin-bottom: 10px; color: #004085; font-weight: 700; font-size: 2.5rem;"),
                           p("Interactive exploration of all exercises with filters and visualizations.", style = "color: #4a6c8b; font-size: 1.2rem; line-height: 1.6;")
                       )
                )
              ),
              fluidRow(
                column(3,
                       div(class = "custom-card",
                           h3("Exploration Filters", style = "color: #333; margin-bottom: 20px; font-size: 2.4rem; text-align:center"),
                           selectInput("explore_bodypart", "Body Part:",
                                       choices = c("All" = "all"), selected = "all", width = "100%"),
                           selectInput("explore_equipment", "Equipment:",
                                       choices = c("All" = "all"), selected = "all", width = "100%"),
                           selectInput("explore_type", "Exercise Type:",
                                       choices = c("All" = "all"), selected = "all", width = "100%"),
                           hr(style = "border-top: 1px solid #eee; margin: 20px 0;"),
                           actionButton("reset_filters", "Reset Filters",
                                        class = "btn-primary custom-button", width = "100%")
                       )
                ),
                column(9,
                       div(class = "custom-card",
                           h3("Results and Visualizations", style = "color: #333; margin-bottom: 20px; font-size: 2.4rem; text-align: center"),
                           tabsetPanel(
                             id = "exploration_tabs",
                             tabPanel("Visualization",
                                      withSpinner(plotlyOutput("exploration_scatter", height = "480px"))),
                             tabPanel("Results",
                                      withSpinner(DT::dataTableOutput("exploration_table")))
                           )
                       )
                )
              )
      ),
      tabItem(tabName = "about",
              fluidRow(
                column(12,
                       div(style = "background-color: #e9f5ff; padding: 30px; border-radius: 15px; margin-bottom: 30px; text-align: center; box-shadow: 0 6px 20px rgba(0,0,0,0.08);",
                           h2("About Fitness Analytics", style = "margin-bottom: 10px; color: #004085; font-weight: 700; font-size: 2.5rem;"),
                           p("Interactive analytics panel for training data.", style = "color: #4a6c8b; font-size: 1.2rem; line-height: 1.6;")
                       )
                )
              ),
              fluidRow(
                column(12,
                       div(class = "custom-card",
                           h3("Analytics training panel", style = "color: #333; margin-bottom: 20px; font-size: 1.6rem;"),
                           p("This interactive panel has been created to analyse a comprehensive database of training exercises.", style = "color: #555; font-size: 1.1rem; line-height: 1.6;"),
                           
                           h4("Functionalities:", style = "color: #004085; font-weight: 600; margin-top: 25px; margin-bottom: 10px;"),
                           tags$ul(style = "list-style: none; padding-left: 20px;",
                                   tags$li(style = "margin-bottom: 8px; color: #555;", icon("check-circle"), "Analysis of more than 2,900 exercises in various categories "),
                                   tags$li(style = "margin-bottom: 8px; color: #555;", icon("chart-line"), "Interactive visualisations with filter options"),
                                   tags$li(style = "margin-bottom: 8px; color: #555;", icon("dumbbell"), "Comparison of exercises by body part and equipment"),
                                   tags$li(style = "margin-bottom: 8px; color: #555;", icon("star"), "Recommendations of the top-rated exercises")
                           ),
                           
                           h4("Data review:", style = "color: #004085; font-weight: 600; margin-top: 25px; margin-bottom: 10px;"),
                           tags$ul(style = "list-style: none; padding-left: 20px;",
                                   tags$li(style = "margin-bottom: 8px; color: #555;", icon("chart-pie"), textOutput("about_total_exercises_text", inline = TRUE)),
                                   tags$li(style = "margin-bottom: 8px; color: #555;", icon("biking"), textOutput("about_body_parts_text", inline = TRUE)),
                                   tags$li(style = "margin-bottom: 8px; color: #555;", icon("tools"), textOutput("about_equipment_text", inline = TRUE)),
                                   tags$li(style = "margin-bottom: 8px; color: #555;", icon("clipboard-check"), textOutput("about_ratings_text", inline = TRUE))
                           ),
                           
                           h4("Technologies:", style = "color: #004085; font-weight: 600; margin-top: 25px; margin-bottom: 10px;"),
                           p("Panel was build in R with: ", strong("plotly"), ", ", strong("DT"), ", ", strong("shinydashboard"), ", ", strong("fresh"), " and ", strong("shinyWidgets"), ".", style = "color: #555; font-size: 1.1rem; line-height: 1.6;"),
                           
                           hr(style = "border-top: 1px solid #eee; margin: 30px 0;"),
                           div(style = "text-align: center; color: #64748b; font-size: 0.9rem;",
                               p("© 2025 Fitness Analytics Dashboard | Version 1.0")
                           )
                       )
                )
              )
      )
    )
  )
)