# 条件分岐の果てのレストラン

さてC++の勉強に戻ろう。この章では条件分岐について学ぶ。

## 複合文

条件分岐とループについて学ぶ前に、まず`複合文`(compound statement)や`ブロック`(block)と呼ばれている、複数の文をひとまとめにする文について学ばなければならない。

C++では`文`(statement)が実行される。`文`については詳しく説明すると長くなるが、`';'`で区切られたものが`文`だ。

~~~cpp
int main()
{
    // 文
    auto x = 1 + 1 ;
    // 文
    std::cout << x ;

    // 空文
    // 実は空っぽの文も書ける。
    ;
}
~~~

複数の`文`を`{}`で囲むことで、1つの文として扱うことができる。これを`複合文`という。

~~~cpp
int main()
{
    // 複合文開始
    {
        std::cout << "hello\n"s ;
        std::cout << "hello\n"s ;
    } // 複合文終了

    // 別の複合文
    { std::cout << "world\n"s ; }

    // 空の複合文
    { }
}
~~~

`複合文`には`';'`はいらない。

~~~cpp
int main()
{
    // ;はいらない
    { }

    // これは空の複合文に続いて
    // 空文があるだけのコード
    { } ;
}
~~~

`複合文`の中に`複合文`を書くこともできる。

~~~cpp
int main()
{
    {{{}}} ;
}
~~~

`関数の本体`としての一番外側`'{}'`はこの`複合文`とは別のものだが、読者はまだ気にする必要はない。

`複合文`は複数の`文`をひとまとめにして、1つの`文`として扱えるようにするぐらいの意味しか持っていない。ただし、変数の見え方に影響する。変数は宣言された最も内側の複合文の中でしか使えない。


~~~cpp
int main()
{
    auto a = 0 ;

    {
        auto b = 0 ;
        {
            auto c = 0 ;
            // cはここまで使える
        }
        // bはここまで使える
    }
    // aはここまで使える
}
~~~

これを専門用語では`変数`の`寿命`とか`ブロックスコープ`(block-scope)という。

内側のブロックスコープの変数が、外側のブロックスコープの変数と同じ名前を持っていた場合はエラーではない。外側の変数が内側の変数で隠される。

~~~cpp
int main()
{
    auto x = 0 ;
    {
        auto x = 1 ;
        {
            auto x = 2 ;
            // 2
            std::cout << x ;
        }
        // 1
        std::cout << x ;
        x = 42 ;
        // 42
        std::cout << x ;
    }
    // 0
    std::cout << x ;
}
~~~

慣れないうちは驚くかもしれないが、多くのプログラミング言語はこのような挙動になっているものだ。


## 条件分岐

すでに読者はさまざまな数値計算を学んだ。読者は`12345 + 6789`の答えや、`8073 * 132 / 5`の答えを計算できる上、この2つの答えをさらに掛け合わせた結果だって計算できる。

~~~cpp
int main()
{
    auto a = 12345 + 6789 ;
    auto b = 8073 * 132 / 5 ;
    auto sum = a + b ;

    std::cout
        << "a=12345 + 6789=" << a << "\n"s
        << "b=8073 * 132 / 5=" << b << "\n"s
        << "a+b=" << sum << "\n"s ;
}
~~~

なるほど、答えがわかった。ところで変数`a`と変数`b`はどちらが大きいのだろうか。大きい変数だけ出力したい。この場合は条件分岐を使う。

C++では条件分岐に`if文`を使う。

~~~cpp
int main()
{
    auto a = 12345 + 6789 ;
    auto b = 8073 * 132 / 5 ;


    if ( a < b )
    {
        // bが大きい
        std::cout << b ;
    }
    else
    {
        // aが大きい
        std::cout << a ;
    }
}
~~~

`if文`は以下のように書く。

~~~c++
if ( 条件 )
文1
else
文2
~~~

`条件`が真(`true`)のときは`文1`が実行され、偽(`false`)のときは`文2`が実行される。

`else`の部分は書かなくてもよい。

~~~c++
if ( 条件 )
文1
文2
~~~

その場合、`条件`が真のときだけ`文1`が実行される。条件の真偽にかかわらず`文2`は実行される。

~~~cpp
int main()
{
    if ( 2 < 1 )
        std::cout << "sentence 1.\n" ; // 文1
    std::cout << "sentence 2.\n" ; // 文2
}
~~~

この例では、`2`が`1`より小さい場合は`文1`が実行される。`文2`は必ず実行される。

条件次第で複数の文を実行したい場合、`複合文`を使う。

~~~cpp
int main()
{
    if ( 1 < 2 )
    {
        std::cout << "yes!\n" ;
        std::cout << "yes!\n" ;
    }
}
~~~

`条件`とか`真偽`についてはとてもとても深い話があるのだが、その解説はあとの章に回すとして、まずは以下の比較演算子を覚えよう。

演算子             意味
--------          ---------
`a == b`          `a`は`b`と等しい
`a != b`          `a`は`b`と等しくない
`a <  b`          `a`は`b`より小さい
`a <= b`          `a`は`b`より小さい、もしくは等しい
`a >  b`          `a`は`b`より大きい
`a >= b`          `a`は`b`より大きい、もしくは等しい

真(`true`)というのは、意味が真であるときだ。正しい、成り立つ、正解などと言い換えてもよい。それ以外の場合はすべて偽(`false`)だ。正しくない、成り立たない、不正解などと言い換えてもいい。

整数や浮動小数点数の場合、話は簡単だ。

~~~cpp
int main()
{
    // 1は2より小さいか？
    if ( 1 < 2 )
    {   // 真、お使いのコンピューターは正常です
        std::cout << "Your computer works just fine.\n"s ;
    }
    else
    {
        // 偽、お使いのコンピューターには深刻な問題があります
        std::cout << "Your computer has serious issues.\n"s ;
    }
}
~~~

文字列の場合、内容が同じであれば等しい。違うのであれば等しくない。

~~~cpp
int main()
{
    auto a = "dog"s ;
    auto b = "dog"s ;
    auto c = "cat"s ;

    if ( a == b )
    {
        std::cout << "a == b\n"s ;
    }
    else
    {
        std::cout << "a != b\n" ;
    }

    if ( a == c )
    {
        std::cout << "a == c\n" ;
    }
    else
    {
        std::cout << "a != c\n" ;
    }
}
~~~

では文字列に大小はあるのだろうか。文字列に大小はある。

~~~cpp
int main()
{
    auto cat = "cat"s ;
    auto dog = "dog"s ;

    if ( cat < dog )
    {   // 猫は小さい
        std::cout << "cat is smaller.\n"s ;
    }
    else
    {   // 犬は小さい
        std::cout << "dog is smaller.\n"s ;
    }

    auto longcat = "longcat"s ;

    if ( longcat > cat )
    {   // longcatは長い
        std::cout << "Longcat is Looong.\n"s ;
    }
    else
    {
        std::cout << "Longcat isn't that long. Sigh.\n"s ;
    }
}
~~~

実行して確かめてみよう。ほとんどの読者の実行環境では以下のようになるはずだ。ほとんどの、というのは、そうではない環境も存在するからだ。読者がそのような稀有な環境を使っている可能性はまずないだろうが。

~~~
cat is smaller.
Longcat is Looong.
~~~

なるほど。`"cat"s`は`"dog"s`よりも小さく(？)、`"longcat"s`は`"cat"s`よりも長い(大きい？)ようだ。なんだかよくわからない結果になった。

これはどういうことなのか。もっと簡単な文字列で試してみよう。

~~~cpp
int main()
{
    auto x = ""s ;

    // aとbはどちらが小さいのだろうか？
    if ( "a"s < "b"s )
    {   x = "a"s ; }
    else
    {   x = "b"s ; }
 
    // 小さい方の文字が出力される
    std::cout << x ;
}
~~~

これを実行すると`a`と出力される。すると`"a"s`は`"b"s`より小さいようだ。

もっと試してみよう。

~~~cpp
int main()
{
    auto x = ""s ;
    if ( "aa"s < "ab"s )
    { x = "aa"s ; }
    else
    { x = "ab"s ; }

    // 小さい文字列が出力される
    std::cout << x ;
}
~~~

これを実行すると、`aa`と出力される。すると`"aa"s`は`"ab"s`より小さいことになる。

文字列の大小比較は文字単位で行われる。まず最初の文字が大小比較される。もし等しい場合は、次の文字が大小比較される。等しくない最初の文字の結果が、文字列の大小比較の結果となる。

## 条件式

### 条件とは何だろう

`if文`の中で書く`条件`(condition)は、`条件式`(conditional expression)とも呼ばれている`式`(expression)の一種だ。`式`というのは例えば`"1+1"`のようなものだ。`式`は`文`の中に書くことができ、これを`式文`(expression statement)という。

~~~cpp
int main()
{
    1 + 1 ; // 式文
}
~~~

`"a==b"`や`"a\<b"`のような`条件`も`式`なので、`文`として書くことができる。

~~~cpp
int main()
{
    1 == 1 ;
    1 < 2 ;
}
~~~

C++では多くの式には型がある。たとえば`"123"`は`int`型で、`"123+4"`も`int`型だ。

~~~cpp
int main()
{
    auto a = 123 ; // int
    auto b = a + 4 ; // int
    auto c = 1.0 ; // double
    auto d = "hello"s ; // std::string
}
~~~

とすると、`"1==2"`や`"3!=3"`のような条件式にも型があるのではないか。型があるのであれば変数に入れられるはずだ。試してみよう。

~~~cpp
int main()
{
    if (  1 == 1 )
    { std::cout << "1 == 1 is true.\n"s ; }
    else
    { std::cout << "1 == 1 is false.\n"s ; }

    auto x = 1 == 1 ;
    if ( x )
    { std::cout << "1 == 1 is true.\n"s ; }
    else
    { std::cout << "1 == 1 is false.\n"s ; }
}
~~~

`"if(x)"`は`"if(1==1)"`と書いた場合と同じように動く。

変数に入れられるのであれば出力もできるのではないだろうか。試してみよう。

~~~cpp
int main()
{
    auto a = 1 == 1 ; // 正しい
    auto b = 1 != 1 ; // 間違い
    std::cout << a << "\n"s << b ;
}
~~~

~~~
1
0
~~~

なるほど、条件が正しい場合`"1"`になり、条件が間違っている場合`"0"`になるようだ。

では`if文`の中に`1`や`0`を入れたらどうなるのだろうか。

~~~cpp
// 条件が正しい値だけ出力される。
int main()
{
    if ( 1 ) std::cout << "1\n"s ;
    if ( 0 ) std::cout << "0\n"s ;
    if ( 123 ) std::cout << "123\n"s ;
    if ( -1 ) std::cout << "-1\n"s ;
}
~~~

実行結果は以下のようになる。

~~~
1
123
-1
~~~

この結果を見ると、条件として`1`, `123`, `-1`は正しく、`0`は間違っているということになる。ますます訳がわからなくなってきた。

## bool型

そろそろ種明かしをしよう。条件式の結果は、`bool型`という特別な型を持っている。

~~~cpp
int main()
{
    auto a = 1 == 1 ; // bool型
    bool A = 1 == 1 ; // 型を書いてもよい
}
~~~

`int`型の変数には整数の値が入る。`double`型の変数には浮動小数点数の値が入る。`std::string`型の変数には文字列の値が入る。

すると、`bool`型の変数には`bool`型の値が入る。

`bool`型には2つの値がある。条件が正しいことを意味する`true`と、条件が間違っていることを意味する`false`だ。

~~~cpp
int main()
{
    bool correct = true ;
    bool wrong = false ;
}
~~~

`bool`型にこれ以外の値は存在しない。


`bool`型の値を正しく出力するには、`std::boolalpha`を出力する。

~~~cpp
int main()
{
    std::cout << std::boolalpha ;
    std::cout << true << "\n"s << false ;
}
~~~

~~~
true
false
~~~

`std::boolalpha`自体は何も出力をしない。一度`std::boolalpha`を出力すると、それ以降の`bool`値が`true`/`false`で出力されるようになる。

元に戻すには`std::noboolalpha`を使う。

~~~cpp
int main()
{
    std::cout << std::boolalpha ;
    std::cout << true << false ;
    std::cout << std::noboolalpha ;
    std::cout << true << false ;
}
~~~

以下のように出力される。

~~~
truefalse10
~~~

すでに学んだ比較演算子は、正しい場合に`bool`型の値`true`を、間違っている場合に`bool`型の値`false`を返す。

~~~cpp
int main()
{
    // true
    bool a = 1 == 1 ;
    // false
    bool b = 1 != 1 ;

    // true
    bool c = 1 < 2 ;
    // false
    bool d = 1 > 2 ;
}
~~~

先に説明した`if文`の`条件`が「正しい」というのは`true`のことで、「間違っている」というのは`false`のことだ。

~~~cpp
int main()
{
    // 出力される
    if ( true )
        std::cout << "true\n"s ;

    // 出力されない。
    if ( false )
        std::cout << "false\n"s ; 
}
~~~


## bool型の演算

`bool`型にはいくつかの演算が用意されている。



### 論理否定: operator !

`"!a"`は`a`が`true`の場合`false`に、`false`の場合`true`になる。

~~~cpp
int main()
{
    std::cout << std::boolalpha ;

    // false
    std::cout << !true << "\n"s ;

    // true
    std::cout << !false << "\n"s ;
}
~~~

論理否定演算子を使うと、`false`のときのみ実行されてほしい条件分岐が書きやすくなる。

~~~cpp
// ロケットが発射可能かどうかを返す関数
bool is_rocket_ready_to_launch()
{
    // まだだよ
    return false ;
}

int main()
{

    // ロケットが発射可能ではないときに実行される
    if ( !is_rocket_ready_to_launch() )
    {   // もうしばらくそのままでお待ちください
        std::cout << "Standby...\n" ;
    }
}
~~~

この例では、ロケットが発射可能でない場合のみ、待つようにアナウンスする。

同じように、`true`のときに実行されてほしくない条件分岐も書ける。

~~~cpp
// ロケットが発射可能かどうかを返す関数
bool is_rocket_ready_to_launch()
{
    // もういいよ
    return true ;
}

int main()
{
    // ロケットが発射可能なときに実行される
    if ( !is_rocket_ready_to_launch() )
    {   // カウントダウン
        std::cout << "3...2...1...Hallelujah!\n"s ;
    }

}
~~~

この2つの例では、ロケットの状態が実行すべき条件ではないので、正しく何も出力されない。

### 同値比較: operator ==, !=

`bool`型の値の同値比較はわかりやすい。`true`は`true`と等しく、`false`は`false`と等しく、`true`と`false`は等しくない。

~~~cpp
int main()
{
    std::cout << std::boolalpha ;
    auto print = [](auto b)
    { std::cout << b << "\n"s ; } ;

    print( true  == true  ) ; // true
    print( true  == false ) ; // false
    print( false == true  ) ; // false
    print( false == false ) ; // true

    print( true  != true  ) ; // false
    print( true  != false ) ; // true
    print( false != true  ) ; // true
    print( false != false ) ; // false
}
~~~

比較演算子の結果は`bool`値になるということを覚えているだろうか。`"1 \< 2"`は`true`になり、`"1 \> 2"`は`false`になる。

`bool`値同士も同値比較ができるということは、`"(1 \< 2) == true"`のように書くことも可能だということだ。

~~~cpp
int main()
{
    bool b = (1 < 2) == true ;
}
~~~

`"(1\<2)"`は`true`なので、`"(1\<2)==true"`は`"true==true"`と同じ意味になる。この結果はもちろん`"true"`だ。

### 論理積: operator &&

`"a && b"`は`a`と`b`がともに`true`のときに`true`となる。それ以外の場合は`false`となる。これを論理積という。


表にまとめると以下のようになる。

式                    結果
----------------      -------
`false && false`      `false`
`false && true`       `false`
`true  && false`      `false`
`true  && true`       `true`

さっそく確かめてみよう。

~~~cpp
int main()
{
    std::cout << std::boolalpha ;
    auto print = []( auto b )
    { std::cout << b << "\n"s ; } ;

    print( false && false ) ; // false
    print( false && true  ) ; // false
    print( true  && false ) ; // false
    print( true  && true  ) ; // true
}
~~~

論理積は、「AかつB」を表現するのに使える。

例えば、人間の体温が平熱かどうかを判断するプログラムを書くとする。36.1℃以上、37.2℃以下を平熱とすると、`if`文を使って以下のように書くことができる。

~~~cpp
int main()
{
    // 体温
    double temperature = 36.6 ;

    // 36.1度以上
    if ( temperature >= 36.1 )
        if ( temperature <= 37.2 )
        { std::cout << "Good.\n"s ; }
        else
        { std::cout << "Bad.\n"s ; }
    else
    { std::cout << "Bad.\n"s ; }
}
~~~

このコードは、`operator &&`を使えば簡潔に書ける。

~~~cpp
int main()
{
    double temperature = 36.6 ;

    if ( ( temperature >= 36.1 ) && ( temperature <= 37.2 ) )
    { std::cout << "Good.\n"s ; }
    else
    { std::cout << "Bad.\n"s ; }
}
~~~

### 論理和: operator ||

`"a || b"`は`a`と`b`がともに`false`のときに`false`となる。それ以外の場合は`true`となる。これを論理和という。

表にまとめると以下のようになる。

式                    結果
----------------      -------
`false || false`      `false`
`false || true`       `true`
`true  || false`      `true`
`true  || true`       `true`

さっそく確かめてみよう。

~~~cpp
int main()
{
    std::cout << std::boolalpha ;
    auto print = []( auto b )
    { std::cout << b << "\n"s ; } ;

    print( false || false ) ; // false
    print( false || true  ) ; // true
    print( true  || false ) ; // true
    print( true  || true  ) ; // true
}
~~~

論理和は、「AもしくはB」を表現するのに使える。

例えば、ある遊園地の乗り物には安全上の理由で身長が1.1m未満、あるいは1.9mを超える人は乗れないものとする。この場合、乗り物に乗れる身長かどうかを確かめるコードは、`if文`を使うと以下のようになる。

~~~cpp
int main()
{
    double height = 1.3 ;

    if ( height < 1.1 )
    { std::cout << "No."s ; }
    else if ( height > 1.9 )
    { std::cout << "No."s ; }
    else
    { std::cout << "Yes."s ; }
}
~~~

論理和を使うと以下のように簡潔に書ける。

~~~cpp
int main()
{
    double height = 1.3 ;

    if ( ( height < 1.1 ) || ( height > 1.9 ) )
    { std::cout << "No."s ; }
    else
    { std::cout << "Yes."s ; }
}
~~~

### 短絡評価

論理積と論理和は短絡評価と呼ばれる特殊な評価が行われる。これは、左から右に最小限の評価をするという意味だ。

論理積では、"`a` && `b`"とある場合、`a`と`b`がともに`true`である場合のみ、結果は`true`になる。もし、`a`が`false`であった場合、`b`の結果如何にかかわらず結果は`false`となるので、`b`は評価されない。

~~~cpp
int main()
{
    auto a = []()
    {
        std::cout << "a\n"s ;
        return false ;
    } ;
    auto b = []()
    {
        std::cout << "b\n"s ;
        return true ;
    } ;

    bool c = a() && b() ;
    std::cout << std::boolalpha << c ; 
}
~~~

これを実行すると以下のようになる。

~~~
a
false
~~~

関数呼び出し`"a()"`の結果は`false`なので、`"b()"`は評価されない。評価されないということは関数呼び出しが行われず、当然標準出力も行われない。

同様に、論理和では、`"a || b"`とある場合、`a`と`b`のどちらか片方でも`true`であれば、結果は`true`となる。もし、`a`が`true`であった場合、`b`の結果如何にかかわらず結果は`true`となるので、`b`は評価されない。

~~~cpp
int main()
{
    auto a = []()
    {
        std::cout << "a\n"s ;
        return true ;
    } ;
    auto b = []()
    {
        std::cout << "b\n"s ;
        return false ;
    } ;

    bool c = a() || b() ;
    std::cout << std::boolalpha << c ; 
}
~~~

結果、

~~~
a
true
~~~

`"b()"`が評価されていないことがわかる。


## boolの変換

`bool`型の値と演算はこれで全部だ。値は`true`/`false`の2つのみ。演算は`==`, `!=`, `!`と`&&`と`||`の5つだけだ。

読者の中には納得のいかないものもいるだろう。ちょっと待ってもらいたい。`bool`の大小比較できないのだろうか。`bool`の四則演算はできないのか。`"if(123)"`などと書けてしまうのは何なのか。

好奇心旺盛な読者は本書の解説を待たずしてすでに自分でいろいろとコードを書いて試してしまっていることだろう。

`bool`の大小比較はどうなるのだろうか。

~~~cpp
int main()
{
    std::cout << std::boolalpha ;

    bool b = true < false ;
    std::cout << b ;
}
~~~

このコードを実行すると、出力は`"false"`だ。`"true \< false"`の結果が`"false"`だということは、`true`は`false`より大きいということになる。

四則演算はどうか？

~~~cpp
int main()
{
    auto print = [](auto x)
    { std::cout << x << "\n"s ; } ;

    print( true  + true  ) ;
    print( true  + false ) ;
    print( false + true  ) ;
    print( false + false ) ;
}
~~~

結果、

~~~
2
1
1
0
~~~

不思議な結果だ。`"true+true"`は`"2"`、`"true+false"`は`"1"`、`"false+false"`は`"0"`。これは`true`が`1`で`false`が`0`ならば納得のいく結果だ。大小比較の結果としても矛盾していない。

すでに見たように、`std::boolalpha`を出力していない状態で`bool`を出力すると`true`が`1`、`false`が`0`となる。

~~~cpp
int main()
{
    std::cout << true << false ;
}
~~~

結果、

~~~
10
~~~

これは`bool型`と`整数型`が変換されているのだ。

異なる型の値が変換されるというのは、すでに例がある。`整数型`と`浮動小数点数型`だ。

~~~cpp
int main()
{
    // 3
    int i = 3.14 ;
    std::cout << i << "\n"s ;

    // 123.0
    double d = 123 ;
    std::cout << d << "\n"s ;
}
~~~

`浮動小数点数型`は`整数型`に変換できる。その際に小数部は切り捨てられる。`整数型`は`浮動小数点数型`に変換できる。小数部はない。

これと同じように、`bool型`も`整数型`と変換ができる。

`bool`型の`true`を`整数型`に変換すると`1`になる。`false`は`0`になる。

~~~cpp
int main()
{
    // 1
    int True = true ;
    // 0
    int False = false ;
}
~~~

同様に、`整数型`のゼロを`bool型`に変換すると`false`になる。非ゼロは`true`になる。

~~~cpp
int main()
{
    // false
    bool Zero = 0 ;

    // すべてtrue
    bool One = 1 ;
    bool minus_one = -1 ;
    bool OneTwoThree = 123 ;  
}
~~~

したがって、`"if (0)"`は`"if (false)"`と等しく、`"if (1)"`や`"if(-1)"`など非ゼロな値は`"if (true)"`と等しい。

~~~cpp
int main()
{
    // 出力されない
    if ( 0 )
        std::cout << "No output.\n"s ;

    // 出力される
    if ( 1 )
        std::cout << "Output.\n"s ;
}
~~~

大小比較は単に`bool`を整数に変換した結果を比較しているだけだ。`"true \< false"`は`"1 \< 0"`と書くのと同じだ。

~~~cpp
int main()
{
    std::cout << std::boolalpha ;

    // 1 < 0
    std::cout << (true < false) ;
}
~~~

同様に四則演算も`bool`型を整数型に変換した上で計算をしているだけだ。`"true + true"`は`"1 + 1"`と書くのと同じだ。

~~~cpp
int main()
{
    // 1 + 1
    std::cout << (true + true) ;
}
~~~

C++では、`bool型`と`整数型`の変換は暗黙に行われてしまうので注意が必要だ。
