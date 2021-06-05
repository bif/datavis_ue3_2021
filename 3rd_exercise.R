# install libraries
#install.packages(c("OpenStreetMap", "DT", "RColorBrewer", "mapproj", "sf", "RgoogleMaps", 
#                   "scales", "rworldmap", "maps", "tidyverse", "rnaturalearth", 
#                   "rnaturalearthdata", "rgeos", "ggspatial", "maptools", "leaflet", "sf", 
#                   "tmap", "here", "rgdal", "scales", "sf"))
# install package from github
#devtools::install_github("dkahle/ggmap", ref = "tidyup")

# load library
library(OpenStreetMap)
library(shiny)
library(ggplot2)
library(dplyr)
library(leaflet)
library(sf)
# extract map
#AustrianMap <- openmap(c(49.1,9.4), c(46.3,17.3))
# plot map
#plot(AustrianMap)

districts = readsf("./data_base/maps/Austria_shape/Austria_shapefile/at_100km.shp")#read_sf("streets.shp")

server <- function(input, output, session) {
  output$map <- leaflet::renderLeaflet({
    leaflet() %>% 
      addProviderTiles("OpenStreetMap") %>%
      setView( lng = 13.4
               , lat = 47.7
               , zoom = 7) #%>%
      # add austrian districts
     # addPolylines(
      # data = districts,
       # opacity = 0.5,
        #weight = 1,
        #color = "red"
     # )
  })
}


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

shinyApp(ui, server)





