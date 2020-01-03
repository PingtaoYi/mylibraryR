#先安装sparklyr然后加载
library(sparklyr)
#安装spark到本地
spark_install(version = "2.4.0") 

  #（同时要下载安装Java的jdk，并设置好JAVAHOME=C:\Program Files\Java\jdk1.8.0_131\，在Path中添加C:\Program Files\Java\jdk1.8.0_131\bin及C:\Program Files\Java\jdk1.8.0_131\jre）

#设置sparkhome(手动建立连接，用窗口New connection可能会出错)
spark_home_set('C:/Users/oobeing_Yi/AppData/Local/spark/spark-2.4.0-bin-hadoop2.7') 
  #换路径后切换版本;
  #如果在windows中设置了"SPARK_HOME=C:\Users\oobeing_Yi\AppData\Local\spark\spark-2.4.0-bin-hadoop2.7 ,Path中加入%SPARK_HOME%\bin"的信息，则不需要这个语句了，如要临时设置，可用这个函数
  #spark_home_set('C:/Program Files/spark-3.0.0-preview2-bin-hadoop3.2')#运行不了，不要安装太高的spark版本，sparklyr一般延后支持

#建立连接
sc <- spark_connect(master = "local")

#关闭连接
spark_disconnect(sc)

#导入
iris_tbl <- copy_to(sc, iris)
flights_tbl <- copy_to(sc, nycflights13::flights, "flights")
batting_tbl <- copy_to(sc, Lahman::Batting, "batting")
src_tbls(sc)

#基本操作
flights_tbl %>% filter(dep_delay == 2) %>% collect

library(ggplot2)
delay <- flights_tbl %>% 
  group_by(tailnum) %>%
  summarise(count = n(), dist = mean(distance), delay = mean(arr_delay)) %>%
  filter(count > 20, dist < 2000, !is.na(delay)) %>%
  collect
ggplot(delay, aes(dist, delay)) +
  geom_point(aes(size = count), alpha = 1/2) +
  geom_smooth() +
  scale_size_area(max_size = 2)

batting_tbl %>%
  select(playerID, yearID, teamID, G, AB:H) %>%
  arrange(playerID, yearID, teamID) %>%
  group_by(playerID) %>%
  filter(min_rank(desc(H)) <= 2 & H > 0)

library(DBI)
iris_preview <- dbGetQuery(sc, "SELECT * FROM iris LIMIT 10")
iris_preview

# copy mtcars into spark
mtcars_tbl <- copy_to(sc, mtcars)

# transform our data set, and then partition into 'training', 'test'
partitions <- mtcars_tbl %>%
  filter(hp >= 100) %>%
  mutate(cyl8 = cyl == 8) %>%
  sdf_random_split(training = 0.5, test = 0.5, seed = 1099)

# fit a linear model to the training dataset
fit <- partitions$training %>%
  ml_linear_regression(response = "mpg", features = c("wt", "cyl"))
fit
summary(fit)

#也可以用以下基础包中的lm来拟合，过程信息不完全相同
lm(mpg ~ wt+cyl,data = partitions$training) %>% summary()


# 安装livy本地环境
#用迅雷下载“http://archive.apache.org/dist/incubator/livy/0.5.0-incubating/livy-0.5.0-incubating-bin.zip”，并按提示（Installing to:  - "C:\Users\oobeing_Yi\AppData\Local\rstudio\livy\Cache/livy-0.5.0"）解压到相应位置，切换到spark2.2.0后，未成功启动livy
#livy_install()
livy_service_start()
sc <- spark_connect(master = "http://localhost:8998", method = "livy", version = "2.4.0")
copy_to(sc, iris)
spark_disconnect(sc)
livy_service_stop()
config <- livy_config(username="<username>", password="<password>")
sc <- spark_connect(master = "<address>", method = "livy", config = config)
spark_disconnect(sc)
#上述代码引自https://github.com/sparklyr/sparklyr
