# install libraries
#install.packages(c("OpenStreetMap", "DT", "RColorBrewer", "mapproj", "sf", "RgoogleMaps", 
#                   "scales", "rworldmap", "maps", "tidyverse", "rnaturalearth", 
#                   "rnaturalearthdata", "rgeos", "ggspatial", "maptools", "leaflet", "sf", 
#                   "tmap", "here", "rgdal", "scales", "sf", "geojsonlint", "plotly", "geojsonR"))
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


# globals
selectableFeatures = c("Sieben Tage Inzidenz F\344lle","Summe Anzahl Tote","Summe Anzahl Geheilt")

# functions
range01 = function(x){
  (x-min(x))/(max(x)-min(x))
}

# source

# load autrian COVID data from: https://www.data.gv.at/katalog/dataset/4b71eb3d-7d55-4967-b80d-91a3f220b60c
#data = read.csv("https://covid19-dashboard.ages.at/data/CovidFaelle_Timeline_GKZ.csv", sep = ";", fileEncoding = "UTF-8")
#data = read.csv(paste(getwd(),"/data_base/modified", "/mod_CovidFaelle_Timeline_GKZ-1.csv", sep = ""), sep = ";", fileEncoding = "UTF-8")
data = read.csv("https://github.com/bif/datavis_ue3_2021/raw/sync_GeJSON_CofidData/data_base/modified/mod_CovidFaelle_Timeline_GKZ-1.csv", sep = ";", fileEncoding = "UTF-8")
#head(data)

#date = format(as.POSIXct(strptime(data$Time,"%d.%m.%Y %H:%M:%S",tz="")) ,format = "%Y-%m-%d")
#data$Time = NULL
data$SiebenTageInzidenzFaelle = gsub(",", ".", data$SiebenTageInzidenzFaelle)
data=mutate(data, SiebenTageInzidenzFaelle = as.double(SiebenTageInzidenzFaelle))
#data = data.frame(date, data, range01(data$SiebenTageInzidenzFaelle))

#str(data)

# directly read geojson trows an error - workaround with temporarry download
#download.file("https://github.com/ginseng666/GeoJSON-TopoJSON-Austria/raw/master/2021/simplified-99.9/bezirke_999_geo.json", destfile="bezirke_999_geo.json")
#path_file = paste(getwd(),"/bezirke_999_geo.json", sep = "")
download.file("https://github.com/bif/datavis_ue3_2021/raw/sync_GeJSON_CofidData/data_base/modified/mod_bezirke_999_geo.json", destfile="mod_bezirke_999_geo.json")
path_file = paste(getwd(),"/mod_bezirke_999_geo.json", sep = "")
#path_file = paste("data_base/modified", "/mod_bezirke_999_geo.json", sep = "")

districts = geojsonio::geojson_read(path_file, what = "sp")
class(districts)
#file.remove("./bezirke_999_geo.json")  #delete the tmpfile
file.remove("./mod_bezirke_999_geo.json")  #delete the tmpfile

names(districts)
  
server = function(input, output, session) {
  
  selInput = reactive({
    x = data %>%
      filter(date == input$seldate)
    
     retval = switch(  
       input$selfeature,  
       "Sieben Tage Inzidenz F\344lle" = x$SiebenTageInzidenzFaelle,
       "Summe Anzahl Tote" = x$AnzahlTotSum,
       "Summe Anzahl Geheilt" = x$AnzahlGeheiltSum
     )
     
    #  retval = switch(  
    #    input$selfeature,  
    #    selectableFeatures[1] = x$SiebenTageInzidenzFaelle,
    #    selectableFeatures[2] = x$AnzahlTotSum,
    #    selectableFeatures[3] = x$AnzahlGeheiltSum
    #  )
  })
  
  getSelFeature = reactive({
    retval = input$selfeature
  })
  
  getLabel = function(name, selF, val) {
    retval = paste0(selF, " Bezirk ", name, ": ", formatC(val, big.mark = ","))
  }
  
  #pal = colorNumeric(palette = "Reds", domain = data$SiebenTageInzidenzFaelle)
  pal = colorBin(palette = "Reds", domain = data$SiebenTageInzidenzFaelle, bins=20)

  output$map = leaflet::renderLeaflet({
    leaflet(districts) %>%
      addPolygons(
        stroke = TRUE, color = "black", weight = 1.5, opacity = 1, dashArray = "3", fillOpacity = 1, fillColor = ~pal(selInput()),
        highlight = highlightOptions(
          weight = 4,color = "#666", dashArray = "", fillOpacity = 1, bringToFront = TRUE),
        #label = ~paste0("Sieben Tage Inzidenz, Bezirk ", name, ": ", formatC(selInput(), big.mark = ","))) %>%
        #label = ~sprintf(
        #  "<strong>Sieben Tage Inzidenz, Bezirk %s</strong><br/>%c per 100000 people</sup>",
        #  districts$name, formatC(selInput(), big.mark = ",")) %>% 
        #lapply(htmltools::HTML)) %>%
        label = ~getLabel(name, getSelFeature(), selInput())) %>%
      addLegend(pal = pal, values = selInput(), opacity = 1.0, title = input$selfeature) %>%
      addTiles()
  })
  
  #output$testtext = selInput
  
}


ui <- fluidPage(
  #theme = shinythemes::shinytheme('simplex'),
  #leaflet::leafletOutput('map', height = '100%', width = '100%'),

  titlePanel('For testing R Shiny Code'),
  sidebarLayout(
    sidebarPanel(
      sliderInput("seldate", 
                  "select Date", 
                  min = as.Date("2020-02-26","%Y-%m-%d"),
                  max = as.Date("2021-06-06","%Y-%m-%d"),
                  value = as.Date("2020-02-26"),
                  animate = animationOptions(interval = 1000, loop = TRUE),
                  step = 1
      )
      #textOutput("testtext")
    ),
    mainPanel(bootstrapPage(
      div(class = "outer", tags$style(type = "text/css", ".outer {position: fixed; top: 120px; left: 0; right: 0; bottom: 0; overflow: hidden; padding: 0}"),
          leaflet::leafletOutput("map",height="100vh")
      )
    ))
  )
)

shinyApp(ui, server)