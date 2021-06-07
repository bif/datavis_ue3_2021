# install libraries
#install.packages(c("OpenStreetMap", "DT", "RColorBrewer", "mapproj", "sf", "RgoogleMaps", 
#                   "scales", "rworldmap", "maps", "tidyverse", "rnaturalearth", 
#                   "rnaturalearthdata", "rgeos", "ggspatial", "maptools", "leaflet", "sf", 
#                   "tmap", "here", "rgdal", "scales", "sf", "geojsonlint", "plotly"))
# install package from github
#devtools::install_github("dkahle/ggmap", ref = "tidyup")

# load library
library(OpenStreetMap)
library(shiny)
library(ggplot2)
library(dplyr)
library(leaflet)
library(sf)
library(geojsonlint)
library(plotly)

# load autrian COVID data from: https://www.data.gv.at/katalog/dataset/4b71eb3d-7d55-4967-b80d-91a3f220b60c
data = read.csv("https://covid19-dashboard.ages.at/data/CovidFaelle_Timeline_GKZ.csv")
#head(data)
#class(data)

# load map of austrian districts from: https://github.com/ginseng666/GeoJSON-TopoJSON-Austria
map = geojson_read("https://github.com/ginseng666/GeoJSON-TopoJSON-Austria/blob/master/2021/simplified-99.9/bezirke_999_geo.json")
districts <- rgdal::readOGR(map)

pal <- colorNumeric("viridis", NULL)

server <- function(input, output, session) {
  output$map <- leaflet::renderLeaflet({
    leaflet(districts) %>%
      addTiles() %>%
      addPolygons(stroke = TRUE, smoothFactor = 0.3, fillOpacity = 0.5) %>%
      #      ,
      #    fillColor = ~pal(log10(pop)),
      #    label = ~paste0(name, ": ", formatC(pop, big.mark = ","))) %>%
      #    addLegend(pal = pal, values = ~log10(pop), opacity = 1.0,
      #              labFormat = labelFormat(transform = function(x) round(10^x))) %>%
      setView( lng = 13.4
               , lat = 47.7
               , zoom = 7) %>%
      addTiles()
  })
}


ui <- fluidPage(
  titlePanel("Explore Covid19 cases in Austria from 26th of Feb 2020 to 6th of Jun 2021"),
  #theme = shinythemes::shinytheme("darkly"),
  sidebarLayout(
    sidebarPanel(
      selectInput("selectdistrict", "select district", unique(data$Bezirk)),
      sliderInput("slidedate", 
                  "Select date", 
                   min = as.Date("2020-02-26","%Y-%m-%d"),
                   max = as.Date("2021-06-06","%Y-%m-%d"),
                   value = as.Date("2020-02-26"),
                   timeFormat="%Y-%m-%d")
    ),
    mainPanel(
      leaflet::leafletOutput('map'),
    )
  )
)
 

shinyApp(ui, server)
