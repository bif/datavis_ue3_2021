# set options
options(stringsAsFactors = F)         # no automatic data transformation
options("scipen" = 100, "digits" = 4) # suppress math annotation
op <- options(gvis.plot.tag='chart')  # set gViz options
# install libraries
#install.packages(c("OpenStreetMap", "DT", "RColorBrewer", "mapproj", "sf", "RgoogleMaps", 
#                   "scales", "rworldmap", "maps", "tidyverse", "rnaturalearth", 
#                   "rnaturalearthdata", "rgeos", "ggspatial", "maptools", "leaflet", "sf", 
#                   "tmap", "here", "rgdal", "scales"))
# install package from github
#devtools::install_github("dkahle/ggmap", ref = "tidyup")

# load library
library(OpenStreetMap)
# extract map
AustrianMap <- openmap(c(49,9), 
                       c(46,18))
# plot map
plot(AustrianMap)

#library(maps)
#library(ggplot2)
#world_data <- ggplot2::map_data('world')
#world_data <- fortify(world_data)


