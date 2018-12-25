# ムーブ

ムーブ(move)とはコピー(copy)と対になる概念だ。ムーブはちょっと特殊なコピーと考えることもできる。

コピーの仕方を振り返ってみよう。


~~~cpp
T source ;
// コピー構築
T a = soruce ;
T b( source ) ;
T c{ soruce ) ;

// 
~~~
