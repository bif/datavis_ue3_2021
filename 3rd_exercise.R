# install libraries
#install.packages(c("OpenStreetMap", "DT", "RColorBrewer", "mapproj", "sf", "RgoogleMaps", 
 #                 "scales", "rworldmap", "maps", "tidyverse", "rnaturalearth", 
  #                "rnaturalearthdata", "rgeos", "ggspatial", "maptools", "leaflet", "sf", 
   #              "tmap", "here", "rgdal", "scales", "sf", "geojsonlint", "plotly", "geojsonR"))
# install package from github
#devtools::install_github("dkahle/ggmap", ref = "tidyup")

# load library
library(OpenStreetMap)
library(shiny)
library(ggplot2)
library(dplyr)
library(leaflet)
library(sf)
library(geojsonio)
library(plotly)
library(RJSONIO)
library(geojsonR)
library(htmltools)
#todos: 
#  serverside - function to create tooltip with respect to selectinput
#  UI side - how to use UI input in an other ui - checkbox for step
#functions
range01 = function(x){
  (x-min(x))/(max(x)-min(x))
}

# load autrian COVID data from: https://www.data.gv.at/katalog/dataset/4b71eb3d-7d55-4967-b80d-91a3f220b60c
data = read.csv("https://covid19-dashboard.ages.at/data/CovidFaelle_Timeline_GKZ.csv", sep = ";", fileEncoding = "UTF-8")
#head(data)

date = format(as.POSIXct(strptime(data$Time,"%d.%m.%Y %H:%M:%S",tz="")) ,format = "%Y-%m-%d")
data$Time = NULL
data$SiebenTageInzidenzFaelle = gsub(",", ".", data$SiebenTageInzidenzFaelle)
data=mutate(data, SiebenTageInzidenzFaelle = as.double(SiebenTageInzidenzFaelle))
data = data.frame(date, data, range01(data$SiebenTageInzidenzFaelle))
#str(data)

# directly read geojson trows an error - workaround with temporarry download
download.file("https://github.com/ginseng666/GeoJSON-TopoJSON-Austria/raw/master/2021/simplified-99.9/bezirke_999_geo.json", destfile="bezirke_999_geo.json")
path_file = paste(getwd(),"/bezirke_999_geo.json", sep = "")
districts = geojsonio::geojson_read(path_file, what = "sp")
class(districts)
file.remove("./bezirke_999_geo.json")  #delete the tmpfile

names(districts)
  
server = function(input, output, session) {
  colorInput = reactive({
    x = data %>%
      filter(date == input$seldate)
    retval = x$SiebenTageInzidenzFaelle
  })
  
  pal = colorNumeric(palette = "Reds", domain = data$SiebenTageInzidenzFaelle )
 
  output$map = leaflet::renderLeaflet({
    leaflet(districts) %>%
      addPolygons(
        stroke = TRUE, color = "black", weight = 1.5, opacity = 1, dashArray = "3", fillOpacity = 1, fillColor = ~pal(colorInput()),
        highlight = highlightOptions(
          weight = 5,color = "#666", dashArray = "", fillOpacity = 1, bringToFront = TRUE),
#      ) %>%
    label = ~paste0("Sieben Tage Inzidenz, Bezirk ", name, ": ", formatC(colorInput(), big.mark = ","))) %>%
#        label = sprintf(
#          "<strong>Sieben Tage Inzidenz, Bezirk %s</strong><br/>%d per 100000 people</sup>",
#          districts$name, ~colorInput()) %>% 
#        lapply(htmltools::HTML)) %>%
      addLegend(pal = pal, values = colorInput(), opacity = 1.0, title = input$selfeature) %>%
      addTiles()
  })
  
  #output$testtext = colorInput
  
}

ui = bootstrapPage(
  theme = shinythemes::shinytheme('simplex'),
  leaflet::leafletOutput('map', height = '100%', width = '100%'),
  absolutePanel(top = 10, left = 50, id = 'controls',
                #selectInput("seldistrict", "select District (or search by typewrite)", append("all", sort(unique(data$Bezirk)))),
                selectInput("selfeature", "select Feature", c("Sieben Tage Inzidenz F\344lle","Summe Anzahl Tote","Summe Anzahl Geheilt")),
                sliderInput("seldate", 
                            "select Date", 
                            min = as.Date("2020-02-26","%Y-%m-%d"),
                            max = as.Date("2021-06-06","%Y-%m-%d"),
                            value = as.Date("2020-02-26"),
                            animate = animationOptions(interval = 1000, loop = TRUE),
                            step = 1
                )#,
                #textOutput("testtext")
  ),
  tags$style(type = "text/css", "
    html, body {width:100%;height:100%}     
    #controls{background-color:white;padding:20px;}
  ")
)

shinyApp(ui, server)

