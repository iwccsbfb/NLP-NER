# only install dependencies for news-corpus-builder by firstly install it and then remove it
# Use local version of news-corpus-builder, that's why uninstall it
pip install news-corpus-builder
pip uninstall news-corpus-builder

# might have error in installing below packages, so install it again
pip install BeautifulSoup, cssselect
