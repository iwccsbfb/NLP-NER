import os, sys, json
import pdb

dir_path = os.path.dirname(os.path.realpath(__file__))



if __name__ == '__main__':
  news_directory = dir_path + '/../data/google_news'
  for file_name in os.listdir(news_directory): 
    file_name = news_directory + '/' + file_name
    with open(file_name, 'r') as f:
      data = json.load(f)
      pdb.set_trace()



