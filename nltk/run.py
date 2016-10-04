import nltk, pdb
from nltk.corpus import treebank

def unicode2ascii(text):
  return "".join([str(ch) if ord(ch) < 128 else ' ' for ch in text])


count = 0
for f in treebank.fileids():
  count += 1
  f_data = treebank.words(f)
#  sentence = u''
  if count == 27: pdb.set_trace()
#  for word in f_data:
#    sentence += word + ' '
#  print(sentence) 
  print ' '.join(f_data)





