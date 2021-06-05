


# load library
library(OpenStreetMap)
library(shiny)
library(ggplot2)
library(dplyr)
library(leaflet)
# extract map
#AustrianMap <- openmap(c(49.1,9.4), c(46.3,17.3))
# plot map
#plot(AustrianMap)

geolandbasemap<-"http://{s}.wien.gv.at/basemap/geolandbasemap/normal/google3857/{z}/{y}/{x}.png"
bmapgrau<-"http://{s}.wien.gv.at/basemap/bmapgrau/normal/google3857/{z}/{y}/{x}.png"
bmapoverlay<-"http://{s}.wien.gv.at/basemap/bmapoverlay/normal/google3857/{z}/{y}/{x}.png"
bmaphidpi<-"http://{s}.wien.gv.at/basemap/bmaphidpi/normal/google3857/{z}/{y}/{x}.jpeg"
bmaportho<-"http://{s}.wien.gv.at/basemap/bmaporthofoto30cm/normal/google3857/{z}/{y}/{x}.jpeg"

# standard
basemap_1<-leaflet() %>% addTiles(geolandbasemap,
                                options=tileOptions(minZoom=0, subdomains=c("maps","maps1", "maps2", "maps3", "maps4")), 
                                attribution = "www.basemap.at") 

print(basemap_1)
#basemap %>% setView(14.62036, 48.32018, zoom = 12) # zoom to the mean location of my cats

# gray
basemap_2<-leaflet() %>% addTiles(bmapgrau,
                                options=tileOptions(minZoom=0, subdomains=c("maps","maps1", "maps2", "maps3", "maps4")), 
                                attribution = "www.basemap.at")

print(basemap_2

# high dpi
basemap_3<-leaflet() %>% addTiles(bmaphidpi,
                                options=tileOptions(minZoom=0, subdomains=c("maps","maps1", "maps2", "maps3", "maps4")), 
                                attribution = "www.basemap.at")

print(basemap_3)

# ortho+overlay
basemap_4<-leaflet() %>% addTiles(bmaportho,
                                options=tileOptions(minZoom=0, subdomains=c("maps","maps1", "maps2", "maps3", "maps4")), 
                                attribution = "www.basemap.at") %>% 
  addTiles(bmapoverlay,
           options=tileOptions(minZoom=0, subdomains=c("maps","maps1", "maps2", "maps3", "maps4")), 
           attribution = "www.basemap.at")

print(basemap_4)


server <- function(input, output, session) {
  output$map <- leaflet::renderLeaflet({
    basemap_4 %>%
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





