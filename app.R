library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(DT)

df <- read.csv(
  "https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2020/2020-01-21/spotify_songs.csv",
  stringsAsFactors = FALSE
)
df <- df[!duplicated(df$track_id), ]
df$duration_s <- round(df$duration_ms / 1000, 1)

genres <- c("All", sort(unique(na.omit(df$playlist_genre))))

ui <- page_sidebar(
  title = "🎵 Spotifind — Spotify Song Explorer",
  theme = bs_theme(bootswatch = "flatly", primary = "#0d6efd"),
  
  sidebar = sidebar(
    width = 260,
    h5("Filter Controls"),
    hr(),
    sliderInput("energy", "Energy", 0, 1, value = c(0, 1), step = 0.01),
    sliderInput("danceability", "Danceability", 0, 1, value = c(0, 1), step = 0.01),
    sliderInput("valence", "Valence (Mood)", 0, 1, value = c(0, 1), step = 0.01),
    sliderInput("popularity", "Popularity (0–100)", 0, 100, value = c(0, 100), step = 1),
    selectInput("genre", "Genre", choices = genres, selected = "All"),
    hr(),
    actionButton("reset", "Reset Filters", class = "btn-outline-secondary btn-sm w-100")
  ),
  
  layout_columns(
    value_box(
      title = "Songs Found",
      value = textOutput("kpi_count"),
      showcase = icon("music"),
      theme = "primary"
    ),
    value_box(
      title = "Avg Energy",
      value = textOutput("kpi_energy"),
      showcase = icon("bolt"),
      theme = "success"
    ),
    value_box(
      title = "Avg Danceability",
      value = textOutput("kpi_dance"),
      showcase = icon("music"),
      theme = "info"
    ),
    col_widths = c(4, 4, 4)
  ),
  
  card(
    card_header("Mood Map — Valence vs Energy"),
    plotOutput("mood_map", height = "380px")
  ),
  
  layout_columns(
    card(
      card_header("Results Table"),
      DTOutput("tbl_results")
    ),
    card(
      card_header("Top Genres"),
      plotOutput("top_genre", height = "300px")
    ),
    col_widths = c(8, 4)
  ),
  
  p(
    HTML("Spotifind | Data: TidyTuesday Spotify Songs | Authors: Rahiq Raees, Nguyen Nguyen, Shuhang Li, Jose Davila | <a href='https://github.com/UBC-MDS/DSCI-532_2026_37_Spotifind' target='_blank'>GitHub Repo</a> | Individual Assignment R Version"),
    style = "color: grey; font-size: 0.8em; text-align: center; margin-top: 1rem;"
  )
)

server <- function(input, output, session) {
  
  filtered_df <- reactive({
    data <- df |>
      filter(
        energy    >= input$energy[1],    energy    <= input$energy[2],
        danceability >= input$danceability[1], danceability <= input$danceability[2],
        valence   >= input$valence[1],   valence   <= input$valence[2],
        track_popularity >= input$popularity[1], track_popularity <= input$popularity[2]
      )
    if (input$genre != "All") {
      data <- data |> filter(playlist_genre == input$genre)
    }
    data
  })
  
  observeEvent(input$reset, {
    updateSliderInput(session, "energy",       value = c(0, 1))
    updateSliderInput(session, "danceability", value = c(0, 1))
    updateSliderInput(session, "valence",      value = c(0, 1))
    updateSliderInput(session, "popularity",   value = c(0, 100))
    updateSelectInput(session, "genre",        selected = "All")
  })
  
  output$kpi_count <- renderText({
    paste0(format(nrow(filtered_df()), big.mark = ","), " songs")
  })
  
  output$kpi_energy <- renderText({
    data <- filtered_df()
    if (nrow(data) == 0) return("—")
    paste0(round(mean(data$energy), 2), " / 1.0")
  })
  
  output$kpi_dance <- renderText({
    data <- filtered_df()
    if (nrow(data) == 0) return("—")
    paste0(round(mean(data$danceability), 2), " / 1.0")
  })
  
  output$mood_map <- renderPlot({
    data <- filtered_df()
    if (nrow(data) == 0) {
      ggplot() +
        annotate("text", x = 0.5, y = 0.5, label = "No songs match filters", size = 6) +
        theme_void()
    } else {
      sample_data <- data |> slice_sample(n = min(500, nrow(data)))
      ggplot(sample_data, aes(x = valence, y = energy, color = danceability)) +
        annotate("rect", xmin = 0,   xmax = 0.5, ymin = 0.5, ymax = 1,   fill = "#c0d9f5", alpha = 0.3) +
        annotate("rect", xmin = 0.5, xmax = 1,   ymin = 0.5, ymax = 1,   fill = "#f5e6c0", alpha = 0.3) +
        annotate("rect", xmin = 0,   xmax = 0.5, ymin = 0,   ymax = 0.5, fill = "#d4c0f5", alpha = 0.3) +
        annotate("rect", xmin = 0.5, xmax = 1,   ymin = 0,   ymax = 0.5, fill = "#c0f5d0", alpha = 0.3) +
        geom_point(alpha = 0.5, size = 1.5) +
        scale_color_viridis_c(name = "Danceability") +
        geom_hline(yintercept = 0.5, linetype = "dashed", color = "#555555") +
        geom_vline(xintercept = 0.5, linetype = "dashed", color = "#555555") +
        annotate("text", x = 0.02, y = 0.98, label = "Sad & Intense",  hjust = 0, vjust = 1, color = "#2a5fa5", fontface = "bold", size = 3.5) +
        annotate("text", x = 0.52, y = 0.98, label = "Happy & Intense", hjust = 0, vjust = 1, color = "#a57a2a", fontface = "bold", size = 3.5) +
        annotate("text", x = 0.02, y = 0.02, label = "Sad & Calm",     hjust = 0, vjust = 0, color = "#6a2aa5", fontface = "bold", size = 3.5) +
        annotate("text", x = 0.52, y = 0.02, label = "Happy & Calm",   hjust = 0, vjust = 0, color = "#2aa55a", fontface = "bold", size = 3.5) +
        labs(
          title = paste0("Mood Map — ", format(nrow(data), big.mark = ","), " songs"),
          x = "Valence (Sadness → Happiness)",
          y = "Energy (Calm → Intense)"
        ) +
        coord_cartesian(xlim = c(0, 1), ylim = c(0, 1)) +
        theme_minimal(base_size = 13)
    }
  })
  
  output$tbl_results <- renderDT({
    data <- filtered_df() |>
      select(track_name, track_artist, track_album_name,
             track_album_release_date, playlist_genre, track_popularity) |>
      rename(
        Song = track_name, Artist = track_artist,
        Album = track_album_name, Released = track_album_release_date,
        Genre = playlist_genre, Popularity = track_popularity
      ) |>
      arrange(desc(Popularity))
    
    datatable(
      data,
      options = list(pageLength = 10, scrollX = TRUE),
      rownames = FALSE
    ) |>
      formatStyle(
        "Popularity",
        backgroundColor = styleInterval(69, c("white", "#d4edda"))
      )
  })
  
  output$top_genre <- renderPlot({
    data <- filtered_df()
    if (nrow(data) == 0) {
      ggplot() +
        annotate("text", x = 0.5, y = 0.5, label = "No songs match filters", size = 5) +
        theme_void()
    } else {
      top <- data |>
        count(playlist_genre, name = "Count") |>
        arrange(desc(Count)) |>
        slice_head(n = 6) |>
        arrange(Count)
      
      ggplot(top, aes(x = Count, y = reorder(playlist_genre, Count))) +
        geom_col(fill = "#1DB954") +
        geom_text(aes(label = format(Count, big.mark = ",")),
                  hjust = -0.1, size = 3.5) +
        scale_x_continuous(expand = expansion(mult = c(0, 0.15))) +
        labs(title = "Top Genres", x = "Number of Songs", y = NULL) +
        theme_minimal(base_size = 12) +
        theme(
          panel.grid.major.y = element_blank(),
          plot.title = element_text(face = "bold")
        )
    }
  })
}

shinyApp(ui, server)