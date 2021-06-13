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

#functions
range01 <- function(x){(x-min(x))/(max(x)-min(x))}

# load autrian COVID data from: https://www.data.gv.at/katalog/dataset/4b71eb3d-7d55-4967-b80d-91a3f220b60c
data = read.csv("https://covid19-dashboard.ages.at/data/CovidFaelle_Timeline_GKZ.csv", sep = ";", fileEncoding = "UTF-8")
#head(data)

date = format(as.POSIXct(strptime(data$Time,"%d.%m.%Y %H:%M:%S",tz="")) ,format = "%Y-%m-%d")
#time <- format(as.POSIXct(strptime(data$Time,"%d.%m.%Y %H:%M:%S",tz="")) ,format = "%H:%M:%S")
data$Time = NULL
data$SiebenTageInzidenzFaelle = gsub(",", ".", data$SiebenTageInzidenzFaelle)
data=mutate(data, SiebenTageInzidenzFaelle = as.double(SiebenTageInzidenzFaelle))
data = data.frame(date, data, range01(data$SiebenTageInzidenzFaelle))
#str(data)

# load map of austrian districts from: https://github.com/ginseng666/GeoJSON-TopoJSON-Austria
#map = geojson_read("https://github.com/ginseng666/GeoJSON-TopoJSON-Austria/raw/master/2021/simplified-99.9/bezirke_999_geo.json")
#dstricts = rgdal::readOGR(map)

# directly read geojson trows an error - workaround with temporarry download
download.file("https://github.com/ginseng666/GeoJSON-TopoJSON-Austria/raw/master/2021/simplified-99.9/bezirke_999_geo.json", destfile="bezirke_999_geo.json")
path_file = paste(getwd(),"/bezirke_999_geo.json", sep = "")
districts = rgdal::readOGR(path_file)
file.remove("./bezirke_999_geo.json")  #delete the tmpfile


server = function(input, output, session) {
  
  # dataInput = reactive({
  #   if(input$seldistrict == "all") 
  #   {
  #     x = data %>%
  #       filter(date == input$seldate)
      
  #     y = data.frame(x$SiebenTageInzidenzFaelle)
  #     #print(y)
  #     rownames(y) = x$Bezirk
  #     print(y[input$seldistrict])
  #     y
  #   }
  #   else
  #   {
  #     x = data %>%
  #       filter(Bezirk == input$seldistrict, date == input$seldate)
      
  #     print(paste("Bezirk: ", x$SiebenTageInzidenzFaelle))
  #     x$SiebenTageInzidenzFaelle
  #   }
  # })
  
  
  colorInput = reactive({
    x = data %>%
      filter(date == input$seldate)

    retval = x$range01.data.SiebenTageInzidenzFaelle
    
  })
  
  fill_O = reactive({
    x = data %>%
      filter(date == input$seldate)
    len = length(x$SiebenTageInzidenzFaelle)
    if(input$seldistrict != "all") {
      retval = rep(0, times=len)
      for(i in 1:len) {
        if(x$Bezirk[i] == input$seldistrict) {
          retval[i] = 1
        }
      }
    } else {
      retval = rep(1, times=len)
    }
    retval
  })
  
 
  
 
 #qpal <- colorNumeric(palette = "Reds", domain = data$SiebenTageInzidenzFaelle )
 
  output$map = leaflet::renderLeaflet({
    leaflet(districts) %>%
      #addTiles() %>%
      addPolygons(stroke = TRUE, color = "black", weight = 1.5, opacity = 1, smoothFactor = 0.3, fillOpacity = ~colorInput()) %>%
#      addPolygons(stroke = TRUE, color = "black", weight = 1.5, opacity = 1, smoothFactor = 0.3, fillOpacity = 1,#~fill_O(),
#        fillColor = ~qpal(seq(1,94,by=1))) #%>%
        #  label = ~paste0(name, ": ", formatC(pop, big.mark = ","))) %>%
        #addLegend(pal = pal, values = ~log10(pop), opacity = 1.0,
        #            labFormat = labelFormat(transform = function(x) round(10^x))) %>%
      #setView( lng = 13.4
      #         , lat = 47.7
      #         , zoom = 8) %>%
      addTiles()
  })
  
  output$testtext = colorInput
  
}

ui = bootstrapPage(
  theme = shinythemes::shinytheme('simplex'),
  leaflet::leafletOutput('map', height = '100%', width = '100%'),
  absolutePanel(top = 10, left = 50, id = 'controls',
                selectInput("seldistrict", "select District (or search by typewrite)", append("all", sort(unique(data$Bezirk)))),
                sliderInput("seldate", 
                            "select Date", 
                            min = as.Date("2020-02-26","%Y-%m-%d"),
                            max = as.Date("2021-06-06","%Y-%m-%d"),
                            value = as.Date("2020-02-26"),
                            animate = animationOptions(interval = 1000, loop = TRUE),
                            step = 7
                )#,
                #textOutput("testtext")
  ),
  tags$style(type = "text/css", "
    html, body {width:100%;height:100%}     
    #controls{background-color:white;padding:20px;}
  "))


shinyApp(ui, server)

