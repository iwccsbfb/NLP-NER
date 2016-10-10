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

# input: equity_tickers
load_tickers <- function(equity_tickers) {
  equity_tickers <- as.list(equity_tickers)
  equity_tickers$sep <- ','
  equity_tickers_str <- do.call(paste, equity_tickers)
  url <- sprintf('http://finance.yahoo.com/d/quotes.csv?s=%s&f=sn', equity_tickers_str)
  download.file(url, destfile = 'tmp.csv')
  data <- read.table(file='tmp.csv', header=FALSE, sep=',', stringsAsFactors=FALSE)
  if(file.exists('tmp.csv')) file.remove('tmp.csv')
  colnames(data) <- c('equity_ticker', 'comp_name')
  data
}

# get company names and ticker
# assume: bond ticker could be equity ticker + 2letters-country code, like ABXCN, EOANGR, NGCTT
# some bond ticker may not have equity ticker; 
#TODO: save bond tickers, save tickers that cannot find names 
get_company_names <- function() {
  bond_tickers <- unique(get_secmaster()$bonds$ticker)
  
#  tickers <- tickers[1:100]
  result <- data.frame(bond_ticker='a', equity_ticker='a', comp_name='a',stringsAsFactors=FALSE)
  len <- 200
  for(idx in seq(1, length(tickers), len)) {
    idx_end <- idx + len - 1
    if(idx_end > length(tickers)) idx_end <- length(tickers)
    bond_tickers.sub <- bond_tickers[idx:idx_end]
    success <- FALSE
    while(!success) {
      tryCatch({
        # assume bond ticker is equity ticker first
        data <- load_tickers(bond_tickers.sub)
        data <- cbind(bond_ticker=bond_tickers.sub, data, stringsAsFactors=FALSE)
        result <- rbind(result, data[data$comp_name != 'N/A',])
        bond_tickers.NA <- data$bond_ticker[data$comp_name == 'N/A']
        
        equity_tickers <- sapply(bond_tickers.NA, function(bond_ticker) {
          if(nchar(bond_ticker) <= 2) {
            result <<- rbind(result, c(bond_ticker,'NA','NA'))
        #print(sprintf('%s has <= 2 chars.', bond_ticker))
            return ('')
          } 
          equity_ticker <- substr(bond_ticker, 1, nchar(bond_ticker)-2)
          if(bond_ticker %in% bond_tickers) {
        #print(sprintf("Truncated ticker %s is in tickers set, removing it.", equity_ticker))
            result <<- rbind(result, c(bond_ticker,equity_ticker,'NA'))
            return ('')
          } 
          return (equity_ticker)
        })
        idx <- equity_tickers != ''
        if(any(idx)) {
          #never reach here
          print('ahhahah')
          data <- load_tickers(equity_tickers[idx])
          data <- cbind(bond_tickers.NA[idx], data)
          result <- rbind(result, data)
        }
        # append bond tickers that are 
#        print(sprintf('%d tickers cannot find data', sum(data$comp_name == 'N/A')))
        success <- TRUE
      }, error = function(err) {
        print(err)
        print('Network busy, sleeping for a while and retry...')
        Sys.sleep(5)
      })
    }
  }
  file = 'data/comp_names.csv'
  result <- result[2:nrow(result),]
  write.table(result, file=file, row.names=FALSE, col.names=TRUE, append=FALSE, quote=FALSE, sep=',')
  invisible()
}


