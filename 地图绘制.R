#通常有两种方法

#增加一个分支的消息online

# 主分支在这里增加一个信息

#运用sf包完成
sf <- read_sf("2017maps/省2017.shp")
#sf <- st_read("2017maps/省2017.shp",quiet = T)#与上句同
ggplot(data = sf) +
  geom_sf() +geom_sf_label(aes(label = ProvinceNa),size =2) + 
  geom_sf(data = sf %>% filter(ProvinceNa %in% c('辽宁省','吉林省','黑龙江省')),aes(fill = ProvinceNa)) 

#运用rgdal包完成
##------省级作图
pacman::p_load('tidyverse','rgdal')
read_map <- readOGR("2017maps/省2017.shp",encoding = 'uft-8') #读取.shp文件，输出"SpatialPolygonsDataFrame"类
prov_data <- read_map@data
prov_data <- rownames_to_column(read_map@data,var = 'id') #把行名转换为id列，为多表连接做准备
extract_data <- read_map %>% broom::tidy() #抽取经纬度信息
plot_data <- prov_data %>% full_join(extract_data,by = 'id') #合并多表

### 1.基本图绘制
ggplot(data = plot_data) + 
  geom_polygon(aes(x = long,y = lat,group = group),color = 'black',fill = 'cornsilk') + 
  theme_void()

### 2.加入南海九段线
read_map_1 <-rgdal::readOGR("2017maps/九段线.shp",encoding = 'utf-8') 
nine_dash <- read_map_1 %>% broom::tidy()

ggplot(data = plot_data,aes(x = long,y = lat,group = group)) + 
  geom_polygon(color = 'black',fill = 'cornsilk') + 
  geom_path(data = nine_dash,size = 0.8,color = 'grey20') + 
  theme_void()

### 3.标识若干省份
some_prov <- plot_data %>% filter(ProvinceNa %in% c('辽宁省','黑龙江省','吉林省'))

ggplot(data = plot_data,aes(x = long,y = lat,group = group)) + #全国各省地图
  geom_polygon(color = 'grey20',fill = 'cornsilk',alpha = 0.3) + #加入若干省份
  geom_polygon(data = some_prov,aes(fill = ProvinceNa)) + #调整图例及省份的英文名称，并选择一个调色板
  scale_fill_brewer(name = 'Province',palette = 'Set1',labels = c('Heilongjiang','Jilin','Liaoning')) + 
  geom_path(data = nine_dash,size = 0.8,color = 'grey20') + #加入南海九段线
  theme_void()


##------地区作图（县级类同）
pacman::p_load('tidyverse','rgdal','RColorBrewer')
read_map_2 <- readOGR("2017maps/地级市2017.shp",encoding = 'uft-8') 
pref_data <- read_map_2@data
pref_data <- rownames_to_column(read_map_2@data,var = 'id') #把行名转换为id列，为多表连接做准备
extract_data_1 <- read_map_2 %>% broom::tidy() #抽取经纬度信息
plot_data_1 <- pref_data %>% full_join(extract_data_1,by = 'id') #合并多表

### 1.基本图绘制
ggplot(data = plot_data_1,aes(x = long,y = lat,group = group)) + 
  geom_polygon(color = 'black',fill = 'cornsilk') + 
  theme_void()

### 2.标识若干地区(以辽宁为例)

some_pref <- plot_data_1 %>% filter(Prefecture %in% c('鞍山市','铁岭市','本溪市','阜新市','沈阳市','锦州市','葫芦岛市','大连市','抚顺市','营口市','朝阳市','辽阳市','丹东市'))

#####2.1 放在总图中
ggplot(data = plot_data_1,aes(x = long,y = lat,group = group)) + #全国各地级市地图
  geom_polygon(color = 'grey20',fill = 'cornsilk',alpha = 0.3) + #加入若干地区
  geom_polygon(data = some_pref,aes(fill = Prefecture)) + #调整图例英文名称，选择调色板并泛化颜色
  scale_fill_manual(name = 'Prefecture',values = colorRampPalette(brewer.pal(12,'Set3'))(length(unique(some_pref$Prefecture)))) + 
  geom_path(data = nine_dash,size = 0.8,color = 'grey20') + #加入南海九段线
  theme_void()

#####2.2 单独绘制
ggplot(data = some_pref,aes(x = long,y = lat,group = group)) +
  geom_polygon(aes(fill = Prefecture),color = 'grey20',alpha = 0.3) + 
  scale_fill_manual(name = 'Prefecture',values = colorRampPalette(brewer.pal(9,'Set1'))(length(unique(some_pref$Prefecture)))) + 
  theme_void()

