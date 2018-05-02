# !/usr/bin/env python
# encoding=utf-8


import chardet
import thulac
import jieba
import jieba.analyse
import jieba.posseg
import os



# ----recursive files----
files = []
for fpathe, dirs, fs in os.walk('corpora/HIT_IRLab_LTP_Corpora_Sample/6哈工大信息检索研究室多文档自动文摘语料库'):
    for f in fs:
        files.append(os.path.join(fpathe, f))

# for i in files:
#     print(i)



# ----decode GB2312----
text = ''
for file in files:
    with open(file, 'rb') as f:
        # print chardet.detect(f.readline())["encoding"]
        for i in f.readlines():
            text = text + i.decode('GB2312')
            # print i.decode('GB2312').encode("UTF-8")
# print(text)



# ----cut text----
# jieba cut
seg_list = jieba.cut(text)
for i in seg_list:
    print i

# thulac cut
thu1 = thulac.thulac(seg_only=True)
for i in text:
	cutted_text = thu1.cut(i, text=True)
	print cutted_text
	break

# thulac cut file
thu1.cut_f(files[0], "corpora/cutted.txt")



# ----keyword: extract, index, weight----
# way1: tf-idf
n1 = 0
for x, w in jieba.analyse.extract_tags(text, topK=10000, withWeight=True):
    print '%s %s' % (x, w)
    n1 += 1
print n1

# way2: TextRank
n2 = 0
for x, w in jieba.analyse.textrank(text, topK=10000, withWeight=True):
    print '%s %s' % (x, w)
    n2 += 1
print n2

# way3: according times only, from cutted text
dict = {}
for word in seg_list:
    if word == '':
        continue
    else:
        if word in dict.keys():
            dict[word] += 1
            word = ''
        else:
            dict[word] = 1
            word = ''
for i in dict:
    print i
for i in dict.values():
    print i
print(len(dict))