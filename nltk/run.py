import nltk, pdb
from nltk.corpus import treebank
import spacy

def unicode2ascii(text):
  return "".join([str(ch) if ord(ch) < 128 else ' ' for ch in text])

def run2():
  f = open('wsj_0027.txt')
  text = ''.join(f.readlines())
  en_doc = en_nlp(text)

class doc_words:
  def __init__(self, sent, names):
    self.sent = sent
    self.names = names
  
def get_names(f_name):
  import csv
  f = open(f_name)
  f.readline()
  reader = csv.reader(f, delimiter=',', quotechar='"')
  names = []
  for line in reader:
    name = line[1]
    names.append(name)
  return names 

def is_name_generator():
  names = get_names('../data/NYSE.csv')
  names.extend(get_names('../data/NASDAQ.csv'))
  name_set = set(names)
  def fun(name):
    return name in name_set
  return fun
is_comp_name = is_name_generator()
    

if __name__ == '__main__':
  en_nlp = spacy.load('en')
  
  for f in treebank.fileids():
    count = 0
    for sent in treebank.sents(f):
      count += 1
      sent = ' '.join(sent)
  #    pdb.set_trace()

      doc = en_nlp(sent)
      name, names, flag = [], [], False
      for i in range(len(doc)):
        token = doc[i]  
  #      if count == 12:
  #        print token.text, token.pos
  #        pdb.set_trace()
        if(not flag and len(name) != 0): 
          names.append(' '.join(name))
          name = []
        if(token.pos == spacy.parts_of_speech.PROPN):
          name.append(token.text)
          flag = True
        else: flag = False
      if(len(names) != 0): print names
      for i in names:
        if(is_comp_name(i)): print '%s is in comp_name set' % (i)
          
          
  #  sentence = u''
  #  for word in f_data:
  #    sentence += word + ' '
  #  print(sentence) 
    



