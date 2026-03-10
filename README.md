# Spotifind — Shiny for R

A Shiny for R re-implementation of the [Spotifind](https://019c9734-80f7-7726-68c1-3f657d071b93.share.connect.posit.cloud/) group project dashboard.

Spotifind lets users explore Spotify songs by filtering on audio features like energy, danceability, valence (mood), and popularity. Useful for DJs, sound technicians, and music enthusiasts interested in the technical side of music.

**Deployed app:** [app](https://019cda18-cfc5-a463-763e-3618b866ec64.share.connect.posit.cloud)

---

## Dataset

[TidyTuesday Spotify Songs](https://github.com/rfordatascience/tidytuesday/blob/main/data/2020/2020-01-21/readme.md) (MIT License).

The app loads the dataset directly from GitHub — no manual download needed.

---

## Getting Started

Clone the repository and open it in RStudio:

```bash
git clone https://github.com/rahiqraees/spotifind-r.git
cd spotifind-r
```


---

## Installation

This project uses [`renv`](https://rstudio.github.io/renv/) to manage package dependencies. Run the following in the **R Console**:

```r
install.packages("renv")
renv::restore()
```

If R restarts automatically, run `renv::restore()` once more to finish installing all packages.

---

## Running the App Locally

In the **R Console**, run:

```r
shiny::runApp("app.R")
```

---

## App Features

- **Inputs:** sliders for Energy, Danceability, Valence, and Popularity; dropdown for Genre; Reset button
- **Reactive calc:** a single `filtered_df()` reactive that filters the dataset based on all inputs
- **Outputs:**
  - 3 KPI value boxes (song count, avg energy, avg danceability)
  - Mood Map scatter plot (Valence vs Energy, coloured by Danceability)
  - Results table with popularity highlighting
  - Top Genres bar chart

---

## Author

Rahiq Raees
