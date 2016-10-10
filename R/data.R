library(forum.tools)

get_forum_data <- function() { 
  uri <- 'http://money.stackexchange.com/'
  # uri <- 'http://www.savingadvice.com/forums/'
  res <- get_forum(uri, forum.type='stackexchange') 
  df <- do.call(cbind, res)
  write.table(df, file='data/stackexchange.csv')
}


library(saucer)
# map ticker to cusip, isin and figi
get_bond_data <- function() {
  bonds <- get_secmaster()$bonds
  cols <- c('ticker', 'cusip', 'isin', 'bb_global_id')
  data <- bonds[, cols]
  colnames(data) <- c('ticker', 'cusip', 'isin', 'figi')
  data <- data[order(data$ticker),]
  write.csv(data, file = 'data/bond_data.csv', row.names=FALSE)
  invisible()
}

load_tickers <- function(tickers, file = 'data/comp_names.csv') {
  tickers <- as.list(tickers)
  tickers$sep <- ','
  tickers_str <- do.call(paste, tickers)
  url <- sprintf('http://finance.yahoo.com/d/quotes.csv?s=%s&f=sn', tickers_str)
  #download.file(url, destfile = 'data/comp_names.csv', mode='a')
  download.file(url, destfile = 'tmp.csv')
  data <- read.table(file='tmp.csv', header=FALSE, sep=',', stringsAsFactors=FALSE)
  data.nonNA <- data[data[2] != 'N/A',]
  write.table(data.nonNA, file=file, row.names=FALSE, col.names=FALSE, append=TRUE, quote=FALSE, sep=',')
  data
}

# get company names and ticker
# assume: bond ticker could be equity ticker + 2letters-country code, like ABXCN, EOANGR, NGCTT
# some bond ticker may not have equity ticker; 
#TODO: save bond tickers, save tickers that cannot find names 
get_company_names <- function() {
  tickers <- unique(get_secmaster()$bonds$ticker)
  
#  tickers <- tickers[1:100]
  len <- 200
  for(idx in seq(1, length(tickers), len)) {
    idx_end <- idx + len - 1
    if(idx_end > length(tickers)) idx_end <- length(tickers)
    tickers.sub <- tickers[idx:idx_end]
    success <- FALSE
    while(!success) {
      tryCatch({        
        data <- load_tickers(tickers.sub)
        tickers.NA <- data[data[2] == 'N/A',1]
        tickers.new <- sapply(tickers.NA, function(ticker) {
          if(nchar(ticker) <= 2) {
            print(sprintf('%s has <= 2 chars.', ticker))
            return (NULL)
          } 
          ticker <- substr(ticker, 1, nchar(ticker)-2)
          if(ticker %in% tickers) {
            print(sprintf("Truncated ticker %s is in tickers set, removing it.", ticker))
            return (NULL)
          } 
          return (ticker)
        })
        tickers.new <- tickers.new[!is.null(tickers.new)]
        data <- load_tickers(tickers.new)
        print(sprintf('%d tickers cannot find data', sum(data[2] == 'N/A')))
        success <- TRUE
      }, error = function(err) {
        print(err)
        print('Network busy, sleeping for a while and retry...')
        Sys.sleep(5)
      })
    }
  }
  invisible()
}


