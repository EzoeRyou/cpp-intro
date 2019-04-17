# 浮動小数点数

浮動小数点数の型には`float`, `double`, `long double`がある。`float`が最も精度が低く、`double`は`float`と同等以上の精度を持ち、`long double`は`double`と同等以上の精度を持つ。

~~~cpp
float f = 1.0 ;
double d = 1.0 ;
long double ld = 1.0 ;
~~~


以下は浮動小数点数型の変数のサイズを調べるコードだ。

~~~cpp
int main()
{
    auto print = [](std::size_t s )
    { std::cout << s << "\n"s ; } ;

    print( sizeof(float) ) ;
    print( sizeof(double) ) ;
    print( sizeof(long double) ) ;
}
~~~

筆者の環境では以下のように出力される。

~~~
4
8
16
~~~

浮動小数点数は一見整数と同じように扱える上、小数点以下の値も扱える。

~~~cpp
double a = 1.23 ;
double b = 0.00001 ;
~~~

浮動小数点数が表現できる最大値は実装依存だが、通常はかなり大きな値を表現できる。

しかし、浮動小数点数は値を正確に表現しているわけではない。例えば以下のコードを実行してみよう。

~~~cpp
int main()
{
    // １万
    float a = 10000.0 ;
    // １万分の1
    float b = 0.0001 ;

    // １万足す１万分の1
    float c = a + b ;

    std::cout << a << "\n"s << b << "\n"s << c ;
}
~~~

変数`a`の値は１万、変数bの値は１万分の1だ。変数`c`の値は`a+b`で`10000.0001`となるはずだが結果はどうだろう。

~~~
10000
0.0001
10000
~~~

変数`c`の値は`10000.0001`ではない。この謎は浮動小数点数を学べば明らかになる。

## 浮動小数点数リテラル

## 10進浮動小数点数リテラル

浮動小数点数リテラルの最も簡単な書き方は10進数で整数部を書き、小数点`'.'`を書き、続けて小数部を書く。末尾が`f`/`F`なら`float`型、末尾がなければ`double`型、末尾が`l`/`L`なら`long double`型だ。

~~~cpp
// float
auto a = 123.456f ;
auto b = 123.456F ;

// double
auto c = 123.456 ;

// long double
auto d = 123.456l ;
auto e = 123.456L ;
~~~

### 10進数の仮数と指数による表記

`123.456`という値について考えてみよう。この値は以下のように表現することができる。

$$1.23456 \times 10^{2}$$

あるいは以下のように表現することもできる。

$$123456 \times 10^{-3}$$

あるいは以下のようにも表現できる。

$$123.456 \times 10^{0}$$

一般に、値は以下のように表現できるということだ。

$$a \times 10^{b}$$

浮動小数点数リテラルのもう一つの文法として、この`a`と`b`を指定するものがある。

~~~cpp
// 値はすべて123.456
auto a = 1.23456e2 ;
auto b = 123456e-3 ;
auto c = 123.456e0 ;
auto d = 123.456E0 ;
~~~

この文法は、`a`と`b`にe/Eを挟むことによって浮動小数点数の値を指定する。

この`a`を仮数部(fractional part)、`b`を指数部(exponent part)と言う。仮数のことは他にも、coefficient, significand, mantissaなどと呼ばれたりもする。

そして、指数は底が10になる。

浮動小数点数は、値を正確に表現しているのではなく、仮数と指数の組み合わせで表現している。浮動小数点数が浮動と呼ばれる理由は、指数の存在によって小数点数が浮いているかのように動くからだ。

例えば、仮数と指数がともに符号付き1バイトの整数で表現された2バイトの浮動小数点数があるとする。指数、仮数ともに、-128から127までの範囲の整数を表現できる。この浮動小数点数は10000(1万)も100000000(1億)も1000000000000(1兆)も表現できる。それぞれ、`1e4`, `1e8`, `1e12`だ。

しかし、この浮動小数点数では1000100010000(1兆1億1万)を表現できない。なぜならば、この値を正確に表現するには、`100010001e4`を表現できる必要があるが、仮数は100010001を表現できないからだ。

浮動小数点数は値を必ずしも正確に表現できない。その代わり、とても大きな値や、とても小さな値を表現できる。


浮動小数点数の型を表す末尾の`f`/`F`/`l`/`L`は同じように使える。

~~~cpp
// float
auto a = 1.0e0f ;
// double
auto b = 1.0e0 ;
// long double
auto c = 1.0e0l ;
~~~


### 16進数の仮数と指数による表記

浮動小数点数の仮数部と指数部によるリテラルは、16進数で記述することもできる。


文法は、`0x`からはじめ、16進数の仮数部を書き、`e`/`E`の代わりに`p`/`P`を使い、指数部を10進数で指定する。このときの指数部の底は2になる。

値は

$$仮数 \times 2^{指数}$$

になる。

~~~cpp
// 5496
double a = 0xabc.0p0 ;
// 7134
double b = 0xde.fp5 ;
~~~

## 浮動小数点数の表現と特性

浮動小数点数は指数と仮数で表現される。浮動小数点数の表現は様々だが、多くのアーキテクチャーでは国際標準規格のISO/IEC/IEEE 60559:2011が使われている。これは米国電気電子学会の規格IEEE 754-2008と同じ内容になっている。その大本はIntelが立案した規格、IEEE 754-1985だ。一般にはIEEE 754(アイトリプルイー 754)という名称で知られている。


IEEE 754では、浮動小数点数は符号ビット、仮数部、指数部からなる。本書ではIEEE 754のを前提として、浮動小数点数で気をつけるべき特性を説明する。

### +0.0と-0.0

IEEE 754では符号ビットがあるので、ゼロには2種類ある。正のゼロと負のゼロだ。

~~~cpp
int main()
{
    std::cout << 0.0 << "\n"s << -0.0 ;
}
~~~

+0.0と-0.0の違いを浮動小数点数で表現することはできるが、値を比較すると同じものだとみなされる。

~~~cpp
int main()
{
    // a, bは異なるビットパターンを持つ
    double a = +0.0 ;
    double b = -0.0 ;

    // true
    bool c = a == b ;
}
~~~

### +∞と-∞(無限大)

IEEE 754の浮動小数点数は正の無限と負の無限を表現できる。

浮動小数点数の値としての無限は、計算の結果として現れるほか、`numeric_limits<T>::infinity()`を使って取得できる。

~~~cpp
int main()
{
    double a = std::numeric_limits<double>::infinity() ;
    double b = -std::numeric_limits<double>::infinity() ;

    std::cout << a << "\n"s << b ;
}
~~~

### NaN(Not a Number)

NaN(Not a Number)は計算結果が未定義の場合を表現する浮動小数点数の特別な値だ。

計算結果が未定義な場合とは、例えばゼロで除算する場合だ。

値としてのNaNは`numeric_limits<T>::quiet_NaN()`で取得できる。

~~~cpp
int main()
{
    double NaN = std::numeric_limits<double>::quiet_NaN() ;
    std::cout << NaN ;
}
~~~

NaNとの比較結果はすべて`false`となる。

~~~cpp
int main()
{
    double NaN = std::numeric_limits<double>::quiet_NaN() ;

    // すべてfalse
    bool a = NaN == 0.0 ;
    bool b = NaN != 0.0 ;
    bool c = NaN == NaN ;
    bool d = NaN != NaN ;
    bool e = NaN < 0.0 ;
}
~~~

整数であれば、`'a == b'`が`false`であるならば、`'a != b'`なのだと仮定してもよいが、こと浮動小数点数の場合、NaNの存在があるために必ずしもそうとは限らない。上の例でわかるように、NaNとの比較はすべて`false`になる。

### 有効桁数

浮動小数点数は正確な値のすべての桁数を表現できない。表現できるのは仮数部が何桁を正確に表現できるかに依存している。この有効桁数は、`numeric_limits<T>::digits10`で取得できる。

~~~cpp
int main()
{
    std::cout
        << "float: "s << std::numeric_limits<float>::digits10 << "\n"s
        << "double: "s << std::numeric_limits<double>::digits10 << "\n"s
        << "long double: "s << std::numeric_limits<long double>::digits10 << "\n"s ;
}
~~~

浮動小数点数型Tの`numeric_limits<T>`にはもう一つ、`max_digits10`がある。これは浮動小数点数を10進数表記にして、その10進数表記を浮動小数点数に戻したときに、浮動小数点数としての値を精度が落ちることなく再現できる桁数のことだ。

もうひとつ興味深い値としては、`numeric_limits<T>::epsilon()`がある。これは浮動小数点数の1と比較可能な最小の値との差だ。

~~~cpp
int main()
{
    std::cout
        << "float: "s << std::numeric_limits<float>::epsilon() << "\n"s
        << "double: "s << std::numeric_limits<double>::epsilon() << "\n"s
        << "long double: "s << std::numeric_limits<long double>::epsilon() << "\n"s ;
}
~~~

## 浮動小数点数同士の変換

浮動小数点数型は相互に変換できる。変換先の浮動小数点数型が変換元の値を完全に表現できるならばその値に、できないのであれば近い値に変換される。

~~~cpp
int main()
{
    double a = 1.23456789 ;

    // 変換
    float b = a ;
    // 変換
    long double c = a ;
}
~~~

異なる浮動小数点数同士を演算すると、`float<double<long double`の順で大きい浮動小数点数型に合わせて変換される。

~~~cpp
int main()
{
    // float
    auto a = 1.0f + 1.0f ;
    // double
    auto b = 1.0f + 1.0 ;
    // long double
    auto c = 1.0f + 1.0l ;
}
~~~

## 浮動小数点数と整数の変換

浮動小数点数型を整数型に変換すると、小数部が切り捨てられる。

~~~cpp
int main()
{
    double a = 1.9999 ;
    // 1
    int x = a ;
}
~~~

変換元の浮動小数点数から小数部を切り捨てた値が変換先の整数型で表現できなかった場合は、何が起こるかわからない。

整数型を浮動小数点数型に変換すると、変換元の整数の値が変換先の浮動小数点数型で正確に表現できる場合はその値に、そうでない場合は表現できる最も近い値になる。

~~~cpp
int main()
{
    int a = 1 ;
    // 1.0
    double b = a ;
}
~~~

浮動小数点数と整数を演算した場合、浮動小数点数型になる。

~~~cpp
int main()
{
    // double
    auto a = 1.0 + 1 ;
    auto b = 1 + 1.0 ;

    // float
    auto c = 1.0f + 1 ;
}
~~~
