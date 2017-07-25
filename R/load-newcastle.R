library(sp)
library(sf)
library(dplyr)
# Aim: download and analyse OD data for walking
u = "https://github.com/npct/pct-bigdata/releases/download/1.6-beta/l_nat.Rds"
download.file(u, "l.Rds")
l = readRDS("l.Rds")
l = st_as_sf(l)
# find all people walking to work in newcastle
download.file(url = "https://github.com/npct/pct-bigdata/blob/master/england_lad_2011.Rds?raw=true", "england_lad_2011.Rds")
lads = readRDS("england_lad_2011.Rds")
lads$namechar = as.character(lads$name)
lads = st_as_sf(lads)
lads = st_transform(lad, 4326)
lad = lads[grepl(pattern = "Newcastle up", x = lads$name), ]
plot(lad)
write_sf(lad, "../data/newcastle.geojson")

# analyse walking to work
l = select(l, dist, msoa1, msoa2, all, foot, bicycle, car_driver)
l = l %>% filter(dist < 2)
l = l[lad,]
plot(l$geometry)
plot(lad, add = T)

write_sf(l, "../data/od-lines.geojson")

g_poly = st_transform(g_poly, 4326)
g_point = st_transform(g_point, 4326)
g_poly_lad = g_poly[lad,]
g_point_lad = g_point[lad,]
plot(g_poly_lad, add = T, col = "green")
plot(g_point_lad, add = T, col = "red")
write_sf(g_poly_lad, "../data/parks.geojson")
write_sf(g_point_lad, "../data/park-points.geojson")

g_walk = aggregate(l["foot"], g_poly_lad, sum, drop = FALSE)
row.names(g_walk)
g_walk$gml_id = g_poly_lad$gml_id
plot(g_walk, add = T)
g_df = st_set_geometry(g_poly_lad, NULL)
g_df = left_join(g_df, g_walk)