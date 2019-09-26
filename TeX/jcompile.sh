
# Clear out junk
rm -f *.aux
rm -f *.toc

uplatex -kanji=utf8 cpp-intro

mendex -U -s indexstyle.ist -o cpp-intro.ind cpp-intro.idx
uplatex -kanji=utf8 cpp-intro

uplatex -kanji=utf8 cpp-intro
dvipdfmx cpp-intro
