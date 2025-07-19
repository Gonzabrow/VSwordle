# generate_word_set.py
import requests

# ソース：5文字の英単語（例：https://www-cs-faculty.stanford.edu/~knuth/sgb-words.txt など）
url = 'https://raw.githubusercontent.com/dwyl/english-words/master/words_alpha.txt'

res = requests.get(url)
words = res.text.splitlines()

five_letter_words = sorted(set(w.lower() for w in words if len(w) == 5 and w.isalpha()))

with open('word_set.dart', 'w', encoding='utf-8') as f:
    f.write('const Set<String> wordSet = {\n')
    for word in five_letter_words:
        f.write(f"  '{word}',\n")
    f.write('};\n')

print(f'{len(five_letter_words)} words exported to word_set.dart')