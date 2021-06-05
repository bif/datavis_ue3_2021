# install libraries
#install.packages(c("OpenStreetMap", "DT", "RColorBrewer", "mapproj", "sf", "RgoogleMaps", 
#                   "scales", "rworldmap", "maps", "tidyverse", "rnaturalearth", 
#                   "rnaturalearthdata", "rgeos", "ggspatial", "maptools", "leaflet", "sf", 
#                   "tmap", "here", "rgdal", "scales"))
# install package from github
#devtools::install_github("dkahle/ggmap", ref = "tidyup")

# load library
library(OpenStreetMap)
library(shiny)
library(ggplot2)
library(dplyr)
library(leaflet)
# extract map
AustrianMap <- openmap(c(49.1,9.4), 
                       c(46.3,17.3))
# plot map
#plot(AustrianMap)


myMap <- leaflet(options = leafletOptions(minZoom = 11)) %>%
  addProviderTiles("OpenStreetMap-Austria") %>%
  setView( lng = 47.6
           , lat = 13.5
           , zoom = 11 ) %>%
  setMaxBounds( lng1 = 49.1
                , lat1 = 9.4
                , lng2 = 46.3
                , lat2 = 17.3 )


ui <- bootstrapPage(
  theme = shinythemes::shinytheme('simplex'),
  leaflet::leafletOutput('map', height = '100%', width = '100%'),
  absolutePanel(top = 10, right = 10, id = 'controls',
                # CODE BELOW: Add slider input named nb_fatalities
                sliderInput("nb_fatalities", "Minimum Fatalities", value=10, min=1, max=40),
                # CODE BELOW: Add date range input named date_range
                dateRangeInput("date_range", "Select Date:",
                               start  = "2010-01-01",
                               end    = "2019-12-01",
                               format = "yyyy-mm-dd"
                )
  ),
  tags$style(type = "text/css", "
    html, body {width:100%;height:100%}     
    #controls{background-color:white;padding:20px;}
  "))

server <- function(input, output, session) {
  output$map <- leaflet::renderLeaflet({
    leaflet() %>% 
      addTiles() %>%
      setView( -98.58, 39.82, zoom = 5) %>% 
      addTiles()
  })
}

shinyApp(ui, server)





