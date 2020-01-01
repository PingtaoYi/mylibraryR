# 针对两个常用的配色包

# 取wesanderson包中的所有配色
###1.map完成循环取色,walk依次输出
mycolor <- map(seq_along(wes_palettes),function(x) wes_palettes[[x]])
  # map(seq_along(wes_palettes),~ wes_palettes[[.]]) #与上同
walk(.x = mycolor,.f = scales::show_col)

###2.'Rushmore','Darjeeling1','FantasticFox1'三种配色较好
scales::show_col(wes_palette('FantasticFox1'))#再确认

###3.离散化wesanderson的配色并显示,当超过色板已有颜色时，type需要设置为continuous
scales::show_col(wes_palette(name = 'FantasticFox1',
                             n = 22,
                             type = 'continuous'
                            ))

# 实现Rcolorbrewer包中的色板输出
###1.分步骤实现
name <- row.names(brewer.pal.info)
n <- brewer.pal.info$maxcolors
mycolor <- map2(n,name,.f =  brewer.pal) 
  #map2(name,n,.f =  brewer.pal)运行不了，name及n的顺序要匹配函数中参数的顺序
walk(mycolor,show_col)

###2.可以用下面的一句实现
walk(map2(brewer.pal.info$maxcolors,
     row.names(brewer.pal.info),
     .f =  brewer.pal),scales::show_col)
