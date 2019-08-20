# デバッグ：printfデバッグ

ループと多数の要素の集合を扱えるようになったので、読者はもう相当複雑な処理をするプログラムでも書けるようになった。処理が複雑になってくると増えるのがバグだ。

この章では、伝統ある`printfデバッグ`を紹介する。

`printfデバッグ`とは、プログラムの実行中に知りたい情報を出力することだ。`printf`とはC言語の伝統ある出力用のライブラリに由来する名前だが、本書では`iostream`を使う。

## 実践例

例えば前章で実装したように`vector`の要素を選択ソートでソートしたいとする。

選択ソートとは、要素の集合の中から0番目に来るべき要素の場所を探し、0番目の要素と交換し、1番目に来るべき要素の場所を探し、1番目の要素と交換し・・・を要素の数だけ繰り返すことによって要素全体をソートする方法だ。

以下のように書いたとする。

~~~cpp
int main()
{
    std::vector<int> v = { 3,8,2,5,6,9,4,1,7 } ;
    auto size = v.size() ;

    for ( std::size_t head = 0 ; head != size ; ++head )
    {
        auto min = head ;
        for ( std::size_t index = head+1 ; index != size ; ++index )
        {
            if ( v.at(index) < v.at(min) )
                min = index ;
        }
        
        auto temp = v.at(head) ;
        v.at(head) = v.at(min) ;
        v.at(min) = v.at(head) ;
    }

    for ( std::size_t i = 0 ; i != size ; ++i )
    {
        std::cout << v.at(i) << " "s ;
    }
}
~~~

さっそく実行してみよう。

~~~
$ make run
1 1 1 1 1 1 1 1 7
~~~

コンパイルはできるが、なぜかうまく動かない。コードのどこかが間違っているのはわかる。しかしどこが間違っているのかはわからない。さっそく`printfデバッグ`により問題のある箇所を特定してみよう。

`printfデバッグ`を行うには、まずコード中の間違っていそうな箇所にアタリをつける必要がある。

問題がどこにあるかわからないが、ループのどこかで間違っていそうだ。一番外側のループにアタリをつけよう。ループが実行されるごとに変数`v`の中身を表示してみる。

~~~cpp
for ( std::size_t head = 0 ; head != size ; ++head )
{
    // printfデバッグ
        std::cout << "debug: head = "s << head << ", v = { "s;
        for ( std::size_t i = 0 ; i != v.size() ; ++i )
        {
            std::cout << v.at(i) << " "s ;
        }
        std::cout << "}\n"s ;
    // printfデバッグ
~~~

そして実行した結果が以下だ。

~~~
$ make run
debug: v = { 3, 8, 2, 5, 6, 9, 4, 1, 7, }
debug: v = { 1, 8, 2, 5, 6, 9, 4, 1, 7, }
debug: v = { 1, 1, 2, 5, 6, 9, 4, 1, 7, }
debug: v = { 1, 1, 1, 5, 6, 9, 4, 1, 7, }
debug: v = { 1, 1, 1, 1, 6, 9, 4, 1, 7, }
debug: v = { 1, 1, 1, 1, 1, 9, 4, 1, 7, }
debug: v = { 1, 1, 1, 1, 1, 1, 4, 1, 7, }
debug: v = { 1, 1, 1, 1, 1, 1, 1, 1, 7, }
debug: v = { 1, 1, 1, 1, 1, 1, 1, 1, 7, }
1 1 1 1 1 1 1 1 7 
~~~

なぜか`1`が増えている。明らかにおかしい。しかしまだ問題の特定にまでは至らない。

内側のループにも`printfデバッグ`を追加してみよう。

~~~cpp
auto min = head ;
for ( std::size_t index = head+1 ; index != size ; ++index )
{
    // printfデバッグ
        std::cout << v.at(index) << ", "s ;
    // printfデバッグ

    if ( v.at(index) < v.at(min) )
        min = index ;
}
// printfデバッグ
    std::cout << "\n"s ;
// printfデバッグ
~~~

そして実行する。

~~~
debug: v = { 3, 8, 2, 5, 6, 9, 4, 1, 7, }
8, 2, 5, 6, 9, 4, 1, 7, 
debug: v = { 1, 8, 2, 5, 6, 9, 4, 1, 7, }
2, 5, 6, 9, 4, 1, 7, 
debug: v = { 1, 1, 2, 5, 6, 9, 4, 1, 7, }
5, 6, 9, 4, 1, 7, 
debug: v = { 1, 1, 1, 5, 6, 9, 4, 1, 7, }
6, 9, 4, 1, 7, 
debug: v = { 1, 1, 1, 1, 6, 9, 4, 1, 7, }
9, 4, 1, 7, 
debug: v = { 1, 1, 1, 1, 1, 9, 4, 1, 7, }
4, 1, 7, 
debug: v = { 1, 1, 1, 1, 1, 1, 4, 1, 7, }
1, 7, 
debug: v = { 1, 1, 1, 1, 1, 1, 1, 1, 7, }
7, 
debug: v = { 1, 1, 1, 1, 1, 1, 1, 1, 7, }

1 1 1 1 1 1 1 1 7 
~~~

あまりいい情報は得られないようだ。問題はここではないらしい。

ひょっとしたら大小比較が間違っているのかもしれない。確かめてみよう。

~~~cpp
for ( std::size_t index = head+1 ; index != size ; ++index )
{

    if ( v.at(index) < v.at(min) )
    {
        std::cout << v.at(index) << " < "s << v.at(min) << "\n"s ;
        min = index ;
    }
    else
    {
        std::cout << v.at(index) << " >= "s << v.at(min) << "\n"s ;
    }
}
~~~

実行結果は長いので一部だけ記載しておく。

~~~
debug: v = { 3, 8, 2, 5, 6, 9, 4, 1, 7, }
8 >= 3
2 < 3
5 >= 2
6 >= 2
9 >= 2
4 >= 2
1 < 2
7 >= 1

debug: v = { 1, 8, 2, 5, 6, 9, 4, 1, 7, }
2 < 8
5 >= 2
6 >= 2
9 >= 2
4 >= 2
1 < 2
7 >= 1
~~~

大小比較も問題ないようだ。では最終的に見つけた最も小さい値は、本当に最も小さい値だろうか。

~~~cpp
// 最小値を探すループ
for ( std::size_t index = head+1 ; index != size ; ++index )
{
    // より小さい値があればそれを現在の最小値とする
    if ( v.at(index) < v.at(min) )
        min = index ;
}

// printfデバッグ
    std::cout << v.at(min) << "\n"s ;
// printfデバッグ 
~~~

~~~
debug: v = { 3, 8, 2, 5, 6, 9, 4, 1, 7, }
1
debug: v = { 1, 8, 2, 5, 6, 9, 4, 1, 7, }
1
debug: v = { 1, 1, 2, 5, 6, 9, 4, 1, 7, }
1
debug: v = { 1, 1, 1, 5, 6, 9, 4, 1, 7, }
1
debug: v = { 1, 1, 1, 1, 6, 9, 4, 1, 7, }
1
debug: v = { 1, 1, 1, 1, 1, 9, 4, 1, 7, }
1
debug: v = { 1, 1, 1, 1, 1, 1, 4, 1, 7, }
1
debug: v = { 1, 1, 1, 1, 1, 1, 1, 1, 7, }
1
debug: v = { 1, 1, 1, 1, 1, 1, 1, 1, 7, }
7
1 1 1 1 1 1 1 1 7 
~~~

見つけた値は最も小さいようだ。しかし毎回`1`になる。`1`が残っているのだから当然だが、なぜ残っているのだろう。

ひょっとしたら要素の交換が間違っているのかもしれない。`printfデバッグ`してみよう。

~~~cpp
// printfデバッグ 
    std::cout << "debug before: "s <<  v.at(head) << ",  " << v.at(min) << "\n"s ;
// printfデバッグ

v.at(head) = v.at(min) ;
v.at(min) = v.at(head) ;

// printfデバッグ
    std::cout << "debug after : "s << v.at(head) << ", " << v.at(min) << "\n"s ;
// printfデバッグ
~~~

`"debug before:"`は交換前、`"debug after:"`は交換後の2つの要素の値だ。

以下は実行結果の一部だ。

~~~
debug: v = { 3, 8, 2, 5, 6, 9, 4, 1, 7, }
debug before: 3,  1
debug after : 1, 1
debug: v = { 1, 8, 2, 5, 6, 9, 4, 1, 7, }
debug before: 8,  1
debug after : 1, 1
debug: v = { 1, 1, 2, 5, 6, 9, 4, 1, 7, }
debug before: 2,  1
debug after : 1, 1
debug: v = { 1, 1, 1, 5, 6, 9, 4, 1, 7, }
~~~

これを見ると、要素の値の交換が正しく行われていないことがわかる。

問題の場所がわかったので、さっそくコードを見てみよう。

~~~cpp
v.at(head) = v.at(min) ;
v.at(min) = v.at(head) ;
~~~

これは要するに以下のコードと同じだ。

~~~cpp
int a = 0 ;
int b = 1 ;

a = b ; // a = 1
b = a ; // b = 1
~~~

変数`a`, `b`の値を交換したい場合、変数`a`に変数`b`を代入したあとに、変数`b`に変数`a`を代入する処理は誤りだ。なぜならば、変数`b`の代入のときには、変数`a`の値は変数`b`の値になってしまっているからだ。

前章で学んだように、こういう場合、別の変数に値を代入して退避させておく。

~~~cpp
int a = 0 ;
int b = 1 ;

int temp = a ;
a = b ;
b = temp ;
~~~

こうして`printfデバッグ`によって問題が解決した。

## `std::cerr`

`printfデバッグ`として標準出力である`std::cout`に出力すると、プログラムの通常の標準出力と混ざって見づらくなる。例えば以下のプログラムを見てみよう。

~~~cpp
// 1 * 2 * 3 * ... * nを計算するプログラム
int main()
{
    int n{} ;
    std::cin >> n ;
    if ( n < 1 )
        return -1 ;

    int sum = 1 ;  
    for ( int i = 2 ; i <= n ; ++i )
    {
        sum *= i ;

        // printfデバッグ
            std::cout << "debug: "s << i << ", " << sum << "\n"s ;
        // printfデバッグ
    }

    std::cout << sum ;
}
~~~

この場合、標準エラー出力を使うとプログラムの通常の出力と`printfデバッグ`用の出力を分けることができる。

標準エラー出力を使うには、`std::cout`の代わりに`std::cerr`を使う。

~~~cpp
int main()
{
    // 標準出力
    std::cout << "standard output\n"s ;

    // 標準エラー出力
    std::cerr << "standard error output\n"s ;
}
~~~

このプログラムを実行すると一見すべて同じように出力されているように見える。

~~~
$ make run
standard output
standard error output
~~~

違いはリダイレクトやパイプを使うとわかる。

~~~
$ ./program > /dev/null
standard error output
$ ./program | grep error
standard error output 
~~~

標準出力には`"standard output\n"`しか出力されていない。通常のリダイレクトやパイプで扱われるのも標準出力だけだ。そのため、`/dev/null`にリダイレクトすると標準エラー出力しか見えないし、`grep`にパイプしても標準出力しか受け取らない。

標準出力と標準エラー出力を別々にリダイレクトする方法もある。

~~~
$ ./program > cout.txt 2> cerr.txt
~~~

これを実行すると、ファイル`cout.txt`には`"standard output\n"`が、ファイル`cerr.txt`には`"standard error output\n"`が出力されている。

これを使って先ほどのプログラムを書き直すと以下のようになる。

~~~cpp
// 1 * 2 * 3 * ... * nを計算するプログラム
int main()
{
    int n{} ;
    std::cin >> n ;
    if ( n < 1 )
        return -1 ;

    int sum = 1 ;  
    for ( int i = 2 ; i <= n ; ++i )
    {
        sum *= i ;

        // printfデバッグ
            // 標準エラー出力
            std::cerr << "debug: "s << i << ", " << sum << "\n"s ;
        // printfデバッグ
    }
    // 標準出力
    std::cout << sum ;
}
~~~

## まとめ

`printfデバッグ`はコード中のどこに問題があるかを絞り込むための方法だ。プログラムに問題が存在し、問題の発生の有無はプログラムの状態を調べることで判断できるが、コード中のどこに問題が存在するかわからないとき、`printfデバッグ`で問題の箇所を絞り込むことができる。

`printfデバッグ`のやり方は以下のとおり。

1. コード中の間違っていそうな箇所にアタリをつける
2. プログラムの状態を出力する
3. 出力結果が期待どおりかどうかを調べる

`printfデバッグ`は原始的だが効果的なデバッグ方法だ。あとの章ではデバッガーというより高級でプログラマーらしいデバッグ方法も紹介するが、そのような高級なデバッグ方法が使えない環境でも、`printfデバッグ`ならば使えることは多い。
