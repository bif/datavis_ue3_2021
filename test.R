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

# load autrian COVID data from: https://www.data.gv.at/katalog/dataset/4b71eb3d-7d55-4967-b80d-91a3f220b60c
data = read.csv("https://covid19-dashboard.ages.at/data/CovidFaelle_Timeline_GKZ.csv", sep = ";", fileEncoding = "UTF-8")
#head(data)

date = format(as.POSIXct(strptime(data$Time,"%d.%m.%Y %H:%M:%S",tz="")) ,format = "%Y-%m-%d")
#time <- format(as.POSIXct(strptime(data$Time,"%d.%m.%Y %H:%M:%S",tz="")) ,format = "%H:%M:%S")
data$Time = NULL
data = data.frame(date, data)
head(data)


# load map of austrian districts from: https://github.com/ginseng666/GeoJSON-TopoJSON-Austria
#map = geojson_read("https://github.com/ginseng666/GeoJSON-TopoJSON-Austria/raw/master/2021/simplified-99.9/bezirke_999_geo.json")
#dstricts = rgdal::readOGR(map)

# directly read geojson trows an error - workaround with temporarry download
##download.file("https://github.com/ginseng666/GeoJSON-TopoJSON-Austria/raw/master/2021/simplified-99.9/bezirke_999_geo.json", destfile="bezirke_999_geo.json")
##path_file = paste(getwd(),"/bezirke_999_geo.json", sep = "")
##districts = rgdal::readOGR(path_file)
##file.remove("./bezirke_999_geo.json")  #delete the tmpfile



  
server = function(input, output, session) {
  
  dataInput = reactive({
    if(input$seldistrict == "all") 
    {
      x = data %>%
        filter(date == input$seldate)
      
      y = data.frame(x$SiebenTageInzidenzFaelle)
      #print(y)
      rownames(y) = x$Bezirk
      print(y[input$seldistrict])
      y
    }
    else
    {
      x = data %>%
        filter(Bezirk == input$seldistrict, date == input$seldate)
      
      print(paste("Bezirk: ", x$SiebenTageInzidenzFaelle))
      x$SiebenTageInzidenzFaelle
    }
  })
  
  output$testtext = dataInput
}


ui <- fluidPage(
  titlePanel('For testing R Shiny Code'),
  sidebarLayout(
    sidebarPanel(
      selectInput("seldistrict", "select District (or search by typewrite)", append("all", sort(unique(data$Bezirk)))),
      sliderInput("seldate", 
                  "select Date", 
                  min = as.Date("2020-02-26","%Y-%m-%d"),
                  max = as.Date("2021-06-06","%Y-%m-%d"),
                  value = as.Date("2020-02-26")
      ),
    ),
    mainPanel(
      #tabsetPanel(
        textOutput("testtext")
      #)
    )
  )
)

shinyApp(ui, server)

