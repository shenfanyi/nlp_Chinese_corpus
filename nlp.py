# !/usr/bin/env python
# coding=utf-8



import chardet
import jieba
import jieba.analyse
import jieba.posseg
import os
from operator import itemgetter
import pandas as pd



# ----recursive files----
files = []
for fpathe, dirs, fs in os.walk('corpora/Sogou'):
    for f in fs:
        files.append(os.path.join(fpathe, f))
        # break
print('the total number of files: ', len(files))  # len(files) = 17,910



# ----read data and transfer coding way: GB2312 to UTF-8----
# with open(files[0], 'rb') as f:
#     print chardet.detect(f.readline())["encoding"]

text = ''
# n_files = 10
# for file in files[:n_files]:
for file in files:
    with open(file, 'rb') as f:
        for i in f.readlines():
            text = text + i
# text = text.decode('GB2312').encode('UTF-8')



# ----cut text: jieba cut----
seg_list = jieba.cut(text, cut_all=False)



# ----keyword: extract, index, weight----
# --- way1: tf-idf
allwords_sorted = []
for x, w in jieba.analyse.extract_tags(text, topK=10000000, withWeight=True, withFlag=True, allowPOS=('n', 'ns', 'nr', 'v', 'a', 'ad')):
    # print '%s %s' % (x, w)
    allwords_sorted.append([x.encode('UTF-8').split('/')[0], x.encode('UTF-8').split('/')[1], w])

# --save to .csv
allwords_sorted_df = pd.DataFrame(allwords_sorted, columns=['keyword', 'pos', 'weight'])
noun_sorted_df = allwords_sorted_df[allwords_sorted_df.pos.isin(['n', 'ns', 'nr'])]
verb_sorted_df = allwords_sorted_df[allwords_sorted_df.pos == 'v']
adj_sorted_df = allwords_sorted_df[allwords_sorted_df.pos == 'a']
adv_sorted_df = allwords_sorted_df[allwords_sorted_df.pos == 'ad']

print('allwords number: ', len(allwords_sorted_df))  # 162,105
print('noun number: ', len(noun_sorted_df))  # 124,353
print('verb number: ', len(verb_sorted_df))  # 33,217
print('adj number: ', len(adj_sorted_df))  # 4,420
print('adv number: ', len(adv_sorted_df))  # 115

allwords_sorted_df.to_csv('output/allwords_sorted.csv')
noun_sorted_df.to_csv('output/noun_sorted.csv')
verb_sorted_df.to_csv('output/verb_sorted.csv')
adj_sorted_df.to_csv('output/adj_sorted.csv')
adv_sorted_df.to_csv('output/adv_sorted.csv')

# --check csv
# keywords_weighted_df = pd.read_csv('output/keyword_weight_1.csv')
# print(keywords_weighted_df.size)  # 364,755


# --- way2: TextRank
# n2 = 0
# for x, w in jieba.analyse.textrank(text, topK=1000000, withWeight=True):
#     print '%s %s' % (x, w)
#     n2 += 1
# print n2


# --- way3: according times only, from cutted text
# dict = {}
# stop_word_list = [U'', U' ', U'  ', U'   ', U'、', U'，', U'。', U'的']
# for word in seg_list:
#     if word in stop_word_list:
#         continue
#     else:
#         if word in dict.keys():
#             dict[word] += 1
#             word = ''
#         else:
#             dict[word] = 1
#             word = ''
# dict_sorted = sorted(dict.items(), key=itemgetter(1))
# # dict_sorted = sorted(dict.items(), key=itemgetter(1), reverse=True)
# for key, value in dict_sorted:
#     print("{} : {}".format(key.encode('UTF-8'), value))
# print(len(dict))




