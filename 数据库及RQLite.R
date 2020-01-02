#----RSQLite
library(RSQLite)
#构建表格
db<- dbConnect(SQLite(), dbname = 'Test.sqlite')
dbSendQuery(conn = db,
            "drop table if exists MOBILE_PHONE")
dbSendQuery(conn = db,
            "CREATE TABLE MOBILE_PHONE
            (Product_ID INTEGER,
            product_Name TEXT,
            price REAL,
            Brand_name TEXT)")
dbSendQuery(conn = db,
            "INSERT INTO MOBILE_PHONE
            VALUES(1,'iPhone 6s',6000,'Apple')")
dbSendQuery(conn = db,
            "INSERT INTO MOBILE_PHONE
            VALUES(2,'华为P8',3000,'华为')")
dbSendQuery(conn = db,
            "INSERT INTO MOBILE_PHONE
            VALUES(3,'三星 Galaxy S6',5000,'三星')")
dbListTables(db)
dbListFields(db,"MOBILE_PHONE")
head(dbReadTable(db,"MOBILE_PHONE"))
dbDisconnect(db)

#导入变量数据
db.diamonds <- dbConnect(SQLite(),dbname = 'diamonds.sqlite')
dbWriteTable(conn = db.diamonds,name = 'diam',value = diamonds,overwrite = T,row.names = T)
tmp <- dbReadTable(db.diamonds,'diam')
head(tmp,100)
View(tmp)
dbGetQuery(db.diamonds,"select * from diam where Price >= 4000")[1:5,]
dbDisconnect(db.diamonds)

#导入csv数据
db.hotcities <- dbConnect(SQLite(),dbname = 'hotcities.sqlite')
dt <- fread('D:\\OneDrive\\Daily_document\\采集数据集\\热点城市招聘信息19_01_08-01_10.csv',encoding = 'UTF-8')
dbWriteTable(conn = db.hotcities,name = 'Hotcity',value = dt[1:10000,],overwrite = T,row.names = T)
tmd <- dbReadTable(db.hotcities,'Hotcity')
head(tmd)
dbDisconnect(db.hotcities)

#dbplyr与数据库
### 以下为内存中快速建立临时数据库
iris2 <- dbplyr::src_memdb() %>% copy_to(iris, overwrite = TRUE)
iris2 %>% class()

### 以下为用dbplyr操纵sqllite数据库
con <- dbConnect(RSQLite::SQLite(),dbname = 'db_yi')
dplyr::copy_to(con,nycflights13::flights,'flight')
dbReadTable(con,'flight')
flights_db <- tbl(con,'flight')
class(flights_db)
flights_db
flights_db %>% select(year:day,arr_time)
flights_db %>% filter(dep_delay > 240) %>% show_query()
flights_db %>% 
  group_by(dest) %>%
  summarise(delay = mean(dep_time)) %>% show_query()

tailnum_delay_db <- flights_db %>% 
  group_by(tailnum) %>%
  summarise(
    delay = mean(arr_delay),
    n = n()
  ) %>% 
  arrange(desc(delay)) %>%
  filter(n > 100)

class(tailnum_delay_db)
tailnum_delay_db %>% show_query()
tail(tailnum_delay_db) # 因为tailnum_delay_db是lazzy属性，tail不能配合使用

tailnum_delay <- tailnum_delay_db %>% collect() #实现向R中tibble的转换

tailnum_delay %>% tail()

dbDisconnect(con)

### 以下为用dbplyr操纵postgreSQL数据库
####1.写入数据，再操作
m <- RPostgreSQL::PostgreSQL() # m <- DBI::dbDriver('PostgreSQL') #效果相同
con <- dbConnect(m,user = 'postgres',password = '',dbname = 'postgres')
#与下句同作用
# con <- dbConnect(RPostgreSQL::PostgreSQL(),user = 'postgres',password = '',dbname = 'postgres')
dplyr::copy_to(con,nycflights13::flights,'flight',temporary = F,overwrite = T)
dbReadTable(con,'flight')
flights_db <- tbl(con,'flight')
class(flights_db)
flights_db
flights_db %>% select(year:day,arr_time)
flights_db %>% filter(dep_delay > 240) %>% show_query()
flights_db %>% 
  group_by(dest) %>%
  summarise(delay = mean(dep_time)) %>% show_query()

tailnum_delay_db <- flights_db %>% 
  group_by(tailnum) %>%
  summarise(
    delay = mean(arr_delay),
    n = n()
  ) %>% 
  arrange(desc(delay)) %>%
  filter(n > 100)

class(tailnum_delay_db)
tailnum_delay_db %>% show_query()
tail(tailnum_delay_db) # 因为tailnum_delay_db是lazzy属性，tail不能配合使用

tailnum_delay <- tailnum_delay_db %>% collect() #实现向R中tibble的转换

tailnum_delay %>% tail()

dbDisconnect(con)
####2.操作已存在的表
con <- dbConnect(m,user = 'postgres', password = '',dbname = 'Yi')
#dbReadTable(con,'Employment-Northeast(1)')
emp <- tbl(con,'Employment-Northeast(1)',encoding = 'UTF-8')

