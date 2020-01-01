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

