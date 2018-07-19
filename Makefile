
all : book

clean :
	rm -f index.html
	rm -f bin/sample-code-checker

test : cpptest texttest

texttest : *.md
	textlint -f unix *.md

cpptest : test-tool
	bin/sample-code-checker *.md

retest : test-tool
	bin/sample-code-checker retest /tmp/sample-code-checker/*.cpp

test-tool : bin/sample-code-checker

bin/sample-code-checker : bin/sample-code-checker.cpp
	g++ -D _ISOC11_SOURCE -std=c++17 --pedantic-errors -Wall -pthread -O2 -o bin/sample-code-checker  bin/sample-code-checker.cpp

book : docs/index.html


docs/index.html : *.md style.css
	pandoc -s --toc --toc-depth=6 --mathjax -o $@ -H style.css  pandoc_title_block *-*.md

filter.json : *.md style.css
	pandoc -t json -s --toc --toc-depth=6 --mathjax -o $@ -H style.css  pandoc_title_block *-*.md

index.md : *.md
	pandoc -s --toc --toc-depth=6 --mathjax -o index.md -H style.css  pandoc_title_block *-*.md

.PHONY : all book clean test test-tool texttest cpptest retest
