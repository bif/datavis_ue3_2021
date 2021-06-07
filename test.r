


# load library
library(OpenStreetMap)
library(shiny)
library(ggplot2)
library(dplyr)
library(leaflet)

# From https://data.opendataportal.at/dataset/geojson-daten-osterreich
atcounties <- rgdal::readOGR("C:/Users/Stefan/Documents/Studium/TU_Wien_DataScience/SS2021/data_vis_ue/Exercise_03/data_base/maps/AustriaGeoJSON/2021/simplified-99.9/bezirke_999_geo.json")


pal <- colorNumeric("viridis", NULL)




server <- function(input, output, session) {
  output$map <- leaflet::renderLeaflet({
    leaflet(atcounties) %>%
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





