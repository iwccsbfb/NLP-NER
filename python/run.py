from news_corpus_generator import NewsCorpusGenerator
import os, sys
dir_path = os.path.dirname(os.path.realpath(__file__))
#print(dir_path)




if(__name__ == '__main__'): 
  corpus_dir = dir_path + '/../data/'
  # Save results to sqlite or  files per article 
  ex = NewsCorpusGenerator(corpus_dir,'file')
  # Retrieve 50 links related to the search term dogs and assign a category of Pet to the retrieved links
  links = ex.google_news_search('aapl','tech',50)

  # Generate and save corpus
  ex.generate_corpus(links)


