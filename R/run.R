library(forum.tools)
 
uri <- 'http://money.stackexchange.com/'
# uri <- 'http://www.savingadvice.com/forums/'
res <- get_forum(uri, forum.type='stackexchange') 
df <- do.call(cbind, res)
write.table(df, file='data/stackexchange.csv')

