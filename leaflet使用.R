leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng=c(174.768,150), lat=c(-36.852,-35), label =c("The birth","place of R"))

df = data.frame(Lat = 1:10, Long = rnorm(10))
leaflet(df) %>% addCircles()


library(sp)
Sr1 = Polygon(cbind(c(2, 4, 4, 1, 2), c(2, 3, 5, 4, 2)))
Sr2 = Polygon(cbind(c(5, 4, 2, 5), c(2, 3, 2, 2)))
Sr3 = Polygon(cbind(c(4, 4, 5, 10, 4), c(5, 3, 2, 5, 5)))
Sr4 = Polygon(cbind(c(5, 6, 6, 5, 5), c(4, 4, 3, 3, 4)), hole = TRUE)
Srs1 = Polygons(list(Sr1), "s1")
Srs2 = Polygons(list(Sr2), "s2")
Srs3 = Polygons(list(Sr4, Sr3), "s3/4")
SpP = SpatialPolygons(list(Srs1, Srs2, Srs3), 1:3)
leaflet(height = "300px") %>% addPolygons(data = SpP)

library(maps)
mapStates = map("state", fill = TRUE, plot = FALSE)
leaflet(data = mapStates) %>% addTiles() %>%
  addPolygons(fillColor = topo.colors(10, alpha = NULL), stroke = FALSE)


content <- paste(sep = "<br/>", "<b><a href='http://www.samurainoodle.com'>Samurai Noodle</a></b>","606 5th Ave. S","Seattle, WA 98138")

sf <- read_sf("../R语言地理绘图代码/2017maps/省2017.shp")
leaflet(sf) %>% addTiles() %>%
  addPopups(123.45, 41.85, content,
            options = popupOptions(closeButton = FALSE)
  )

m <- leaflet() %>% setView(lng = -71.0589, lat = 42.3601, zoom = 12)
m %>% addTiles()

m <- leaflet() %>% setView(lng = 123.431354, lat = 41.659258, zoom = 12)
m %>% addTiles()
# 沈阳123.443212,41.825469
# 东北大学 123.431354,41.659258
# 用百度坐标拾取


m %>% addProviderTiles(providers$Stamen.Toner)
m %>% addProviderTiles(providers$CartoDB.Positron) 


m %>% addProviderTiles(providers$Stamen.Toner) %>%  addMarkers(lng=123.431354, lat=41.659258, popup= "northeastern universtiy")

leaflet() %>% addTiles() %>% setView(-93.65, 42.0285, zoom = 4) %>%
  addWMSTiles(
    "http://mesonet.agron.iastate.edu/cgi-bin/wms/nexrad/n0r.cgi",
    layers = "nexrad-n0r-900913",
    options = WMSTileOptions(format = "image/png", transparent = TRUE),
    attribution = "Weather data © 2012 IEM Nexrad"
  )

m %>% addProviderTiles(providers$MtbMap) %>%
  addProviderTiles(providers$Stamen.TonerLines,
                   options = providerTileOptions(opacity = 0.35)) %>%
  addProviderTiles(providers$Stamen.TonerLabels)


leaflet() %>% 
  setView(lng = 110, lat = 30, zoom = 2) %>%
  addTiles() %>% 
  addProviderTiles("NASAGIBS.ModisTerraTrueColorCR",
                   options = providerTileOptions(
                     time = "2015-05-15", opacity = 1))

leaflet()%>%setView(lng=116.38,lat=39.9,zoom=1)%>%
  addTiles()%>%addProviderTiles("NASAGIBS.ViirsEarthAtNight2012")
