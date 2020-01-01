pacman::p_load(DALEX,caret,tidyverse,ingredients)


#--------------------------一个模块，连续变量，caret
apartments %>% as_tibble

#使用caret包迅速建模
set.seed(123)
regr_rf <- train(m2.price~., data = apartments, method="rf", ntree = 100)

regr_gbm <- train(m2.price~. , data = apartments, method="gbm")

regr_nn <- train(m2.price~., data = apartments,
                 method = "nnet",
                 linout = TRUE,
                 preProcess = c('center', 'scale'),
                 maxit = 500,
                 tuneGrid = expand.grid(size = 2, decay = 0),
                 trControl = trainControl(method = "none", seeds = 1))

#模型解释
data(apartmentsTest)

explainer_regr_rf <- DALEX::explain(regr_rf, label="rf", 
                                    data = apartmentsTest, y = apartmentsTest$m2.price)

explainer_regr_gbm <- DALEX::explain(regr_gbm, label = "gbm", 
                                     data = apartmentsTest, y = apartmentsTest$m2.price)

explainer_regr_nn <- DALEX::explain(regr_nn, label = "nn", 
                                    data = apartmentsTest, y = apartmentsTest$m2.price)

# 模型表现
mp_regr_rf <- model_performance(explainer_regr_rf)
mp_regr_gbm <- model_performance(explainer_regr_gbm)
mp_regr_nn <- model_performance(explainer_regr_nn)

View(mp_regr_rf)
View(mp_regr_gbm)

plot(mp_regr_rf, mp_regr_nn, mp_regr_gbm)
plot(mp_regr_rf, mp_regr_nn, mp_regr_gbm, geom = "boxplot")

# 变量重要性分析
vi_regr_rf <- ingredients::feature_importance(explainer_regr_rf, loss_function = loss_root_mean_square)
vi_regr_gbm <- ingredients::feature_importance(explainer_regr_gbm, loss_function = loss_root_mean_square)
vi_regr_nn <- ingredients::feature_importance(explainer_regr_nn, loss_function = loss_root_mean_square)

plot(vi_regr_rf, vi_regr_gbm, vi_regr_nn)

# 变量解析
#1.PDF方法
#对于连续型变量，默认variable_type = "numerical"
pdp_regr_rf  <- ingredients::partial_dependency(explainer_regr_rf, variables =  c("surface",'floor',"construction.year"), variable_type = "numerical")
pdp_regr_gbm  <- ingredients::partial_dependency(explainer_regr_gbm, variables = c("surface",'floor',"construction.year"))
pdp_regr_nn  <- ingredients::partial_dependency(explainer_regr_nn, variables =  c("surface",'floor',"construction.year"))

#对于离散型的变量，需要设置variable_type = "categorical"
pdp_regr_rf  <- ingredients::partial_dependency(explainer_regr_rf, variables =  'district', variable_type = "categorical")
pdp_regr_gbm  <- ingredients::partial_dependency(explainer_regr_gbm, variables = 'district', variable_type = "categorical")
pdp_regr_nn  <- ingredients::partial_dependency(explainer_regr_nn, variables =  'district', variable_type = "categorical")

plot(pdp_regr_rf, pdp_regr_gbm, pdp_regr_nn)

d1 <- rbind(pdp_regr_rf, pdp_regr_gbm, pdp_regr_nn)
names(d1) <- c('vname','label','x','yhat','ids')

d1 %>% 
  ggplot() + geom_bar(aes(x =label,y = yhat,fill = x),stat = 'identity',position = 'dodge') + scale_fill_viridis_d() + coord_cartesian(ylim  = c(3000,6000))

names()  
#2.ALE方法
ale_regr_rf  <- ingredients::accumulated_dependency(explainer_regr_rf, variables =  c("surface",'floor',"construction.year"))
ale_regr_gbm  <- ingredients::accumulated_dependency(explainer_regr_gbm, variables = c("surface",'floor',"construction.year"))
ale_regr_nn  <- ingredients::accumulated_dependency(explainer_regr_nn, variables =  c("surface",'floor',"construction.year"))
plot(ale_regr_rf, ale_regr_gbm, ale_regr_nn)


#--------------------------一个模块，离散变量，用caret
pacman::p_load(DALEX,caret,tidyverse,breakDown)
data("wine")
head(wine)
wine %>% as_tibble

wine$quality <- factor(ifelse(wine$quality>5,1,0))
View(wine)

trainIndex <- createDataPartition(wine$quality,p = 0.6,list = F,times = 1)
wineTrain <- wine[trainIndex,]
wineTest <- wine[-trainIndex,]

classif_rf <- train(quality~.,data = wineTrain,method = 'rf',ntree = 100, tuneLength = 1)

p_fun <- function(object, newdata){predict(object, newdata=newdata, type="prob")[,2]} 

yTest <- as.numeric(as.character(wineTest$quality))

explainer_classif_rf <- DALEX::explain(classif_rf, label = "rf",
                                       data = wineTest, y = yTest,
                                       predict_function = p_fun)

mp_classif_rf <- model_performance(explainer_classif_rf)
plot(mp_classif_rf)

plot(mp_classif_rf, geom = "boxplot")

prop.table(table(iris$Species))
