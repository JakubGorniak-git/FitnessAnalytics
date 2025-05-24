# server.R
library(shiny)
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(plotly)
library(DT)
library(tidyr)
library(forcats)
library(viridis)
library(ggbeeswarm)

server <- function(input, output, session){
  raw_data <- reactive({
    data <- read.csv("gym_cleaned.csv", sep=",", stringsAsFactors = FALSE)
    return(data)
  })
  
  filtered_data <- reactive({
    data <- raw_data()
        if(input$filter_level != "all") {
      data <- data[data$Level == input$filter_level, ]
    }
    
    if(input$filter_rated_only) {
      data <- data[!is.na(data$Rating), ]
    }
    data <- data[is.na(data$Rating) | data$Rating >= input$filter_rating, ]
    
    return(data)
  })
  
  observe({
    data <- raw_data()
    updateSelectInput(session, "filter_level",
                      choices = c("All" = "all", unique(data$Level)))
    updateSelectInput(session, "selected_bodypart",
                      choices = unique(data$BodyPart))
    updateSelectInput(session, "selected_equipment",
                      choices = unique(data$Equipment))
    updateSelectInput(session, "explore_bodypart",
                      choices = c("All" = "all", unique(data$BodyPart)))
    updateSelectInput(session, "explore_equipment",
                      choices = c("All" = "all", unique(data$Equipment)))
    updateSelectInput(session, "explore_type",
                      choices = c("All" = "all", unique(data$Type)))
  })
  
  # OVERVIEW TAB
  
  output$total_exercises_text <- renderText({
    nrow(filtered_data())
  })
  
  output$avg_rating_text <- renderText({
    avg_rating <- round(mean(filtered_data()$Rating, na.rm = TRUE), 2)
    ifelse(is.nan(avg_rating), "N/A", avg_rating)
  })
  
  output$body_parts_count_text <- renderText({
    length(unique(filtered_data()$BodyPart))
  })
  
  output$equipment_count_text <- renderText({
    length(unique(filtered_data()$Equipment))
  })
  
  # Most Popular Body Parts
  
  output$bodypart_bar <- renderPlotly({
    data <- filtered_data() %>%
      count(BodyPart) %>%
      arrange(desc(n))
    
    p <- ggplot(data, aes(x = reorder(BodyPart, n), y = n, fill = n,
                          text = paste0("Body Part: ", BodyPart, "<br>Exercises: ", n))) +
      geom_col(show.legend = FALSE, width = 0.5) +
      scale_fill_gradient(low = "#0ae2ff", high = "#0affc6") +
      coord_flip() +
      labs(
        x = NULL,
        y = NULL,
      ) +
      theme_minimal(base_family = "Inter") +
      theme(
        axis.text = element_text(size = 8, color = "#475569"),
        panel.grid.major.y = element_blank(),
        panel.grid.minor = element_blank()
      )
    
    ggplotly(p, tooltip = "text") %>% 
      layout(
        hoverlabel = list(
          bgcolor = "#1e293b",
          font = list(family = "Inter", color = "white")
        )
      )
  })
  
  # Difficulty Level Distribution
  
  output$level_pie <- renderPlotly({
    req(filtered_data())
    level_counts <- filtered_data() %>%
      count(Level) %>%
      mutate(Level = factor(Level, levels = c("Beginner", "Intermediate", "Expert")))
    fig <- plot_ly(
      level_counts,
      labels = ~Level,
      values = ~n,
      type = 'pie',
      textinfo = 'label+percent',
      insidetextfont = list(color = '#FFFFFF', size = 14, family = 'Inter, sans-serif'),
      marker = list(
        colors = c("#326da8", "#69a832", "#a8327b"),
        line = list(color = '#1e293b', width = 1),
        pad = list(r = 4)
      ),
      hoverinfo = 'label+value+percent',
      sort = FALSE,
      hole = 0.3
    ) %>%
      layout(
        showlegend = FALSE, 
        margin = list(t = 30, b = 50, l = 20, r = 20) 
      ) %>%
      config(displayModeBar = FALSE)
    fig
  })
  
  #Equipment usage
  
  output$equipment_usage <- renderPlotly({
    data <- filtered_data() %>%
      count(Equipment) %>%
      arrange(desc(n))
    
    p <- ggplot(data, aes(x = reorder(Equipment, n), y = n, fill = n)) +
      geom_col(
        show.legend = FALSE,
        width = 0.5,
        aes(text = paste0("Equipment: ", Equipment, "<br>Exercises: ", n))
      ) +
      scale_fill_gradient(low = "#ff5c0a", high = "#fffb0a") +
      coord_flip() +
      labs(
        x = NULL,
        y = NULL,
      ) +
      theme_minimal(base_family = "Inter") +
      theme(
        axis.text = element_text(size = 8, color = "#475569"),
        panel.grid.major.y = element_blank(),
        panel.grid.minor = element_blank()
      )
    
    ggplotly(p, tooltip = "text") %>%
      layout(
        hoverlabel = list(
          bgcolor = "#1e293b",
          font = list(family = "Inter", color = "white")
        )
      )
  })
  
  
  # BODY PARTS
  
  output$bodypart_stats <- renderPlotly({
    req(input$selected_bodypart)
    
    data <- filtered_data() %>%
      filter(BodyPart == input$selected_bodypart, !is.na(Level), !is.na(Equipment)) %>%
      count(Equipment, Level, name = "Count")
  
    p <- plot_ly(
      data = data,
      x = ~Equipment,
      y = ~Count,
      color = ~Level,
      type = "bar",
      hoverinfo = "text"
    ) %>%
      layout(
        yaxis = list(title = "Numbers of exercises"),
        barmode = "group",
        legend = list(title = list(text = "Difficulty level"))
      )
    
    
    return(p)
  })
  
  
  # Body part  table
  
  output$bodypart_exercises <- DT::renderDataTable({
    req(input$selected_bodypart)
    
    data <- filtered_data() %>%
      filter(BodyPart == input$selected_bodypart) %>%
      select(Title, Type, Equipment, Level, Rating) %>%
      mutate(Rating = round(Rating, 2))
    
    datatable(data, 
              options = list(pageLength = 10, scrollX = TRUE),
              rownames = FALSE) %>%
      formatStyle("Rating", 
                  backgroundColor = styleInterval(c(7, 8.5), 
                                                  c("#f8d7da", "#d4edda", "#d1ecf1")))
  })
  
  
  #Equipment
  
  output$bodypart_equipment <- renderPlotly({
    req(input$selected_bodypart)
    
    data <- filtered_data() %>%
      filter(BodyPart == input$selected_bodypart) %>%
      count(Equipment) %>%
      arrange(desc(n))
    
    p <- ggplot(data, aes(x = reorder(Equipment, n), y = n, fill = n, text = paste0("Equipment: ", Equipment, "<br>Exercises: ", n))) +
      geom_col(width = 0.6) + 
      scale_fill_gradient(low = "#32a85e", high = "#328ba8") +
      coord_flip() +
      labs(
        x = NULL,
        y = "Number of Exercises",
        title = paste("Equipment for", input$selected_bodypart)
      ) +
      theme_minimal(base_family = "Inter") +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", size = 14, color = "#065f46"),
        axis.title.y = element_blank(),
        axis.title.x = element_text(size = 12, face = "bold", color = "#065f46"),
        axis.text = element_text(size = 10, color = "#065f46"),
        panel.grid.major.y = element_blank(),
        panel.grid.minor = element_blank()
      )
    
    ggplotly(p, tooltip = "text") %>%
      layout(
        hoverlabel = list(
          bgcolor = "#065f46",
          font = list(family = "Inter", color = "white", size = 12)
        )
      )
  })
  
  
  # EQUIPMENT TAB OUTPUTS
  
  output$equipment_heatmap <- renderPlotly({
    data <- filtered_data() %>%
      count(BodyPart, Equipment) %>%
      complete(BodyPart, Equipment, fill = list(n = 0)) %>%
      mutate(BodyPart = fct_reorder(BodyPart, n, .fun = sum, .desc = FALSE)) %>%
      mutate(Equipment = fct_reorder(Equipment, n, .fun = sum, .desc = TRUE))
    
    p <- ggplot(data, aes(x = Equipment, y = BodyPart, fill = n)) +
      geom_tile(color = "white", linewidth = 0.5) +
      scale_fill_gradient(
        low = "#E0F2F7",  
        high = "#007bff",
        name = "Number of\nExercises"
      ) +
      geom_text(aes(label = ifelse(n > 0, n, "")), color = "black", size = 3) +
      labs(
        x = NULL,
        y = NULL
      ) +
      theme_minimal() +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
        axis.text.y = element_text(size = 10),
        plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
        legend.position = "right",
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 9),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        plot.background = element_rect(fill = "transparent", colour = NA),
        panel.background = element_rect(fill = "transparent", colour = NA)
      )
    
    ggplotly(p, tooltip = "text")
  })
  
  # Equipment rating distribution
  
  output$equipment_rating_dist <- renderPlotly({
    req(input$selected_equipment)
    
    data <- filtered_data() %>%
      filter(Equipment == input$selected_equipment, !is.na(Rating))
    
    if(nrow(data) == 0) {
      p <- ggplot() + 
        annotate("text", x = 1, y = 1, label = "No ratings available") +
        theme_void()
    } else {
      p <- ggplot(data, aes(x = Rating)) +
        geom_histogram(bins = 20, fill = "#17a2b8", alpha = 0.7, color = "white") +
        labs(x = "Rating", y = "Number of Exercises",
             title = paste("Rating Distribution for", input$selected_equipment)) +
        theme_minimal() +
        theme(
          plot.title = element_text(hjust = 0.5, size = 10)
          )
    }
    
    ggplotly(p)
  })
  
  # TOP EXERCISES
  
  # Rating distribution
  
  output$rating_distribution <- renderPlotly({
    data <- filtered_data() %>%
      filter(!is.na(Rating))
    
    p <- ggplot(data, aes(x = Rating)) +
      geom_histogram(aes(y = ..density..), bins = 30, fill = "#ffc107", alpha = 0.6, color = "white") +
      geom_density(color = "#dc3545", size = 1) +
      labs(x = "Rating", y = "Density",
           title = NULL) +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5))
    
    ggplotly(p)
  })
  
  # Rating by level
  
  output$rating_by_level <- renderPlotly({
    data <- filtered_data() %>%
      filter(!is.na(Rating)) %>%
      mutate(Level = factor(Level, levels = c("Beginner", "Intermediate", "Expert")))
    
    p <- ggplot(data, aes(x = Level, y = Rating, color = Level)) +
      geom_quasirandom(alpha = 0.6, size = 2, width = 0.3) +
      scale_color_manual(values = c("Beginner" = "#28a745", 
                                    "Intermediate" = "#ffc107", 
                                    "Expert" = "#dc3545")) +
      labs(x = "Difficulty Level", y = "Rating",
           title = NULL) +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5), legend.position = "none")
    
    ggplotly(p)
  })
  
  # Top exercises table
  
  output$top_exercises_table <- DT::renderDataTable({
    data <- filtered_data() %>%
      filter(!is.na(Rating)) %>%
      arrange(desc(Rating)) %>%
      head(20) %>%
      select(Title, BodyPart, Equipment, Level, Rating) %>%
      mutate(Rating = round(Rating, 2))
    
    datatable(data,
              options = list(pageLength = 10, scrollX = TRUE),
              rownames = FALSE) %>%
      formatStyle("Rating",
                  backgroundColor = styleInterval(c(8, 9), 
                                                  c("#fff3cd", "#d4edda", "#d1ecf1")))
  })
  
  # EXPLORATION
  
  # Reset filters
  observeEvent(input$reset_filters, {
    updateSelectInput(session, "explore_bodypart", selected = "all")
    updateSelectInput(session, "explore_equipment", selected = "all")
    updateSelectInput(session, "explore_type", selected = "all")
  })
  
  output$exploration_scatter <- renderPlotly({
    data <- filtered_data() %>%
      filter(!is.na(Rating))
    if(input$explore_bodypart != "all") {
      data <- data[data$BodyPart == input$explore_bodypart, ]
    }
    if(input$explore_equipment != "all") {
      data <- data[data$Equipment == input$explore_equipment, ]
    }
    if(input$explore_type != "all") {
      data <- data[data$Type == input$explore_type, ]
    }
    data$Level <- factor(data$Level, levels = c("Beginner", "Intermediate", "Expert"))
    data$x_jitter <- as.numeric(data$Level) + runif(nrow(data), -0.2, 0.2)
    
    if(nrow(data) == 0) {
      p <- ggplot() + 
        annotate("text", x = 2, y = 5, label = "No data matching current filters") +
        xlim(0.5, 3.5) + ylim(0, 10) +
        theme_void()
    } else {
      p <- ggplot(data, aes(x = x_jitter, y = Rating, color = BodyPart, 
                            text = paste("Exercise:", Title, 
                                         "<br>Body Part:", BodyPart,
                                         "<br>Equipment:", Equipment,
                                         "<br>Level:", Level,
                                         "<br>Rating:", Rating))) +
        geom_point(alpha = 0.7, size = 3) +
        scale_x_continuous(breaks = 1:3, labels = c("Beginner", "Intermediate", "Expert")) +
        labs(x = "Difficulty Level", y = "Rating",
             title = NULL,
             color = "Body Part") +
        theme_minimal() +
        theme(plot.title = element_text(hjust = 0.5))
    }
    
    ggplotly(p, tooltip = "text")
  })
  
  # Exploration table
  output$exploration_table <- DT::renderDataTable({
    data <- filtered_data()
    
    # Apply exploration filters
    if(input$explore_bodypart != "all") {
      data <- data[data$BodyPart == input$explore_bodypart, ]
    }
    if(input$explore_equipment != "all") {
      data <- data[data$Equipment == input$explore_equipment, ]
    }
    if(input$explore_type != "all") {
      data <- data[data$Type == input$explore_type, ]
    }
    
    data <- data %>%
      select(Title, BodyPart, Equipment, Type, Level, Rating) %>%
      mutate(Rating = round(Rating, 2))
    
    datatable(data,
              options = list(pageLength = 15, scrollX = TRUE),
              rownames = FALSE,
              filter = 'top') %>%
      formatStyle("Rating",
                  backgroundColor = styleInterval(c(7, 8.5), 
                                                  c("#f8d7da", "#fff3cd", "#d1ecf1")))
  })
  
  # ABOUT TAB OUTPUTS
  
  output$about_total_exercises_text <- renderText({
    paste("Total:", nrow(raw_data()), "exercises in database")
  })
  
  output$about_body_parts_text <- renderText({
    paste("Body Parts:", length(unique(raw_data()$BodyPart)))
  })
  
  output$about_equipment_text <- renderText({
    paste("Equipment Types:", length(unique(raw_data()$Equipment)))
  })
  
  output$about_ratings_text <- renderText({
    rated_count <- sum(!is.na(raw_data()$Rating))
    total_count <- nrow(raw_data())
    paste("Rated Exercises:", rated_count, "out of", total_count, 
          paste0("(", round(rated_count/total_count*100, 1), "%)"))
  })
  
}