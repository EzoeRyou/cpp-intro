# 名前

プログラミング言語C++にはさまざまな名前が出てくる。変数、関数、型など、さまざまなものに名前が付いている。この章では名前について学ぶ。

## キーワード

一部の名前はキーワードとして予約され、特別な意味を持つ。キーワードは名前として使うことができない。

キーワードの一覧は以下のとおり。


~~~c++
alignas         alignof     asm         auto        bool            break
case            catch       char        char16_t    char32_t        class
concept         const       constexpr   const_cast  continue        decltype
default         delete      do          double      dynamic_cast    else
enum            explicit    export      extern      false           float
for             friend      goto        if          inline          int
long            mutable     namespace   new         noexcept        nullptr
operator        private     protected   public      register        reinterpret_cast
requires        return      short       signed      sizeof          static
static_assert   static_cast struct      switch      template        this
thread_local    throw       true        try         typedef         typeid
typename        union       unsigned    using       virtual         void
volatile        wchar_t     while
~~~

## 名前に使える文字

名前というのは根本的には識別子と呼ばれる文字列で成り立っている。

C++では識別子にラテンアルファベット小文字、大文字、アラビア数字、アンダースコア、を使うことができる。以下がその文字の一覧だ。

~~~c++
a b c d e f g h i j k l m
n o p q r s t u v w x y z
A B C D E F G H I J K L M
N O P Q R S T U V W X Y Z
0 1 2 3 4 5 6 7 8 9
_
~~~

小文字と大文字は区別される。名前`a`と名前`A`は別の名前だ。

ただし、名前はアラビア数字で始まってはならない。

~~~cpp
int 123abc = 0 ; // エラー
~~~

名前にダブルアンダースコア(`__`)が含まれているものは予約されているので使ってはならない。ダブルアンダースコアとはアンダースコア文字が2つ連続したものをいう。

~~~cpp
// 使ってはならない
// すべてダブルアンダースコアを含む
int __ = 0 ;
int a__ = 0 ;
int __a = 0 ;
~~~

アンダースコアに大文字から始まる名前も予約されているので使ってはならない。

~~~cpp
// 使ってはならない
// アンダースコアに大文字から始まる
int _A = 0 ;
~~~

アンダースコアに小文字から始まる名前もグローバル名前空間で予約されているので使ってはならない。グローバル名前空間についてはこのあと説明する。

~~~cpp
// 使ってはならない
// アンダースコアに小文字から始まる
int _a = 0 ;
~~~

予約されているというのは、C++コンパイラーがその名前をC++の実装のために使うかもしれないということだ。例えばC++コンパイラーは`_A`という名前を特別な意味を持つものとして使うかもしれないし、その名前の変数や関数をプログラムに追加するかもしれない。



##  宣言と定義

C++では、名前は使う前に宣言しなければならない。

~~~cpp
int main()
{
    int x = 0 ; // 宣言
    x = 1 ; // 使用
}
~~~

宣言する前に使うことはできない。

~~~cpp
int main()
{
    // エラー、名前xは宣言されていない。
    x = 1 ; 

    int x = 0 ;
}
~~~

C++では多くの名前は宣言と定義に分かれている。宣言と定義の分離は関数が一番わかりやすい。

~~~cpp
// 関数の宣言
int plus_one( int x ) ;

// 関数の定義
int plus_one( int x ) // 宣言部分
// 定義部分
// 関数の本体
{
    return x + 1 ;
}
~~~

関数の定義は宣言を兼ねる。

宣言は何度でも書くことができる。


~~~cpp
int plus_one( int x ) ; // 初出
int plus_one( int x ) ; // OK
int plus_one( int x ) ; // OK
~~~

定義はプログラム中に一度しか書くことができない。

~~~cpp
// 定義
int odr() { }

// エラー、定義の重複
int odr() { }
~~~

名前を使うのに事前に必要なのは宣言だ。定義は名前を使ったあとに書いてもよい。

~~~cpp
// 宣言
int plus_one( int x ) ;

int main()
{
    plus_one( 1 ) ;
}

// 定義
int plus_one( int x )
{
    return x + 1 ;
}
~~~

ほとんどの変数は宣言と定義が同時に行われる。変数でも宣言と定義を分割して行う方法もあるのだが、解説は分割コンパイルの章で行う。

## 名前空間

本書をここまで読んだ読者は、一部の型名の記述が少し変なことに気が付いているだろう。

~~~cpp
std::string a ;
std::vector<int> b ;
~~~

コロンやアングルブラケットは名前に使える文字ではない。信じられない読者は試してみるとよい。

~~~cpp
// エラー
int :: = 0 ;
int <int> = 0 ;
~~~

莫大なエラーが表示されるだろうが、すでに学んだようにとてもいいことだ。コンパイラーが間違いを見つけてくれたのだから。わからないことがあったらどんどんコンパイルエラーを出すとよい。

実は`std`というのは名前空間(namespace)の名前だ。ダブルコロン(`::`)は名前空間を指定する文法だ。

名前空間の文法は以下のとおり。

~~~c++
namespace ns {
// コード
}
~~~

名前空間の中の名前を参照するには`::`を使う。

~~~cpp
ns::name ;
~~~

名前空間の中には変数も書ける。この変数は関数の内部に限定されたローカル変数とは違い、どの関数からでも参照できる。

~~~cpp
namespace ns {
    int name{} ;
}

int f()
{
    return ns::name ;
}

int main()
{
    ns::name = 1 ;
}
~~~

名前空間の中で宣言された名前は、名前空間を指定しなければ使えなくなる。

~~~cpp
namespace ns {
    int f() { return 0 ; }
}

int main()
{
    ns::f() ;

    f() ; // エラー
}
~~~

異なる名前空間名の下の名前は別の名前になる。

~~~cpp
namespace a {
    int f() { return 0 ; }
}


namespace b {
    int f() { return 1 ; }
}

int main()
{
    a::f() ; // 0
    b::f() ; // 1
}
~~~

これだけを見ると、名前空間というのはわざわざ名前空間名を指定しなければ使えない面倒な機能に見えるだろう。名前空間の価値は複数人で同じプログラムのソースファイルを編集するときに出てくる。

例えば、アリスとボブがプログラムを共同で開発しているとする。あるプログラムのソースファイル`f`という名前の関数を書いたとする。ここで、同じプログラムを共同開発している他人も`f`という名前の関数を書いたらどうなるか。

~~~cpp
// アリスの書いた関数f
int f() { return 0 ; }

// ボブの書いた関数f
int f() { return 1 ; }
~~~

すでに宣言と定義で学んだように、このコードはエラーになる。なぜならば、同じ名前に対して定義が2つあるからだ。

名前空間なしでこの問題を解決するためはに、アリスとボブが事前に申し合わせて、名前が衝突しないように調整する必要がある。

しかし名前空間があるC++では、そのような面倒な調整は必要がない。アリスとボブが別の名前空間を使えばいいのだ。


~~~cpp
// アリスの名前空間
namespace alice {
    // アリスの書いた関数f
    int f() { return 0 ; }
}

// ボブの名前空間
namespace bob {
    // ボブの書いた関数f
    int f() { return 1 ; }
}
~~~


`alice::f`と`bob::f`は別の名前なので定義の衝突は起こらない。

### グローバル名前空間

名前空間に包まれていないソースファイルのトップレベルの場所は、実はグローバル名前空間(global name space)という名前のない名前空間で包まれているという扱いになっている。

~~~cpp
// グローバル名前空間
int f() { return 0 ; }

namespace ns {
    int f() { return 1 ; }
}

int main()
{
    f() ; // 0
    ns::f() ; // 1
}
~~~

グローバル名前空間は名前の指定のない単なる`::`で指定することもできる。

~~~cpp
int x { } ;

int main()
{
    x ; // ::xと同じ
    ::x ;
}
~~~

すでに名前空間の中では変数を宣言できることは学んだ。グローバル名前空間は名前空間なので同じように変数を宣言できる。

`main`関数はグローバル名前空間に存在しなければならない。

~~~cpp
// グローバル名前空間
int main() { }
~~~

### 名前空間のネスト

名前空間の中に名前空間を書くことができる。

~~~cpp
namespace A { namespace B { namespace C {
    int name {} ;
} } }

int main()
{
    A::B::C::name = 0 ;
}
~~~

名前空間のネストは省略して書くこともできる。

~~~cpp
namespace A::B::C {
    int name { } ;
}

int main()
{
    A::B::C::name = 0 ;
}
~~~

### 名前空間名の別名を宣言する名前空間エイリアス

名前空間名には別名を付けることができる。これを名前空間エイリアスと呼ぶ。

たとえば名前空間名が重複することを恐れるあまり、とても長い名前空間名を付けたライブラリがあるとする。

~~~cpp
namespace very_long_name {
    int f() { return 0 ; }
}

int main()
{
    very_long_name::f() ;
}
~~~

この関数`f`を使うために毎回`very_long_name::f`と書くのは面倒だ。こういうときには名前空間エイリアスを使うとよい。名前空間エイリアスは名前空間名の別名を宣言できる。

~~~c++
namespace 別名 = 名前空間名 ;
~~~

使い方。

~~~cpp
namespace very_long_name {
    int f() { return 0 ; }
}

int main()
{
    // 名前空間エイリアス
    namespace vln = very_long_name ;
    // vlnはvery_long_nameのエイリアス
    vln::f() ;
}
~~~

名前空間エイリアスは元の名前空間名と同じように使える。意味も同じだ。

名前空間エイリアスはネストされた名前空間にも使える。

~~~cpp
namespace A::B::C {
    int f() { return 0 ; }
}

int main()
{
    namespace D = A::B::C ;
    // DはA::B::Cのエイリアス
    D::f() ;
}
~~~

名前空間エイリアスを関数の中で宣言すると、その関数の中でだけ有効になる。

~~~cpp
namespace A { int x { } ; }

int f()
{
    // Bの宣言
    namespace B = A ;
    // OK、Bは宣言されている
    return B::x ;
}

int g()
{
    // エラー、Bは宣言されていない
    return B::x ;
}
~~~

名前空間エイリアスを名前空間の中で宣言すると、宣言以降の名前空間内で有効になる。

~~~cpp
namespace ns {
    namespace A { int x { } ; }
    namespace B = A ;

    // OK
    int f(){ return B::x ; }
    // OK
    int g(){ return B::x ; }

} // end namespace ns

// エラー、Bは宣言されていない
int h(){ return B::x ; }
~~~

グローバル名前空間は名前空間なので、名前空間エイリアスを宣言できる。

~~~cpp
namespace long_name_is_loooong { }
namespace cat = long_name_is_loooong ;
~~~

### 名前空間名の指定を省略するusingディレクティブ

名前空間は名前の衝突を防ぐ機能だが、名前空間名をわざわざ指定するのは面倒だ。

~~~cpp
int main()
{
    // std名前空間のstring
    std::string s ;
    // std名前空間のvector<int>
    std::vector<int> v ;

    // std名前空間のcout
    std::cout << 123 ;
}
~~~

もし自分のソースファイルが`string`, `vector<int>`, `cout`、その他`std`名前空間で使われる名前をいっさい使っていない場合、名前の衝突は発生しないことになる。その場合でも名前空間名を指定しなければならないのは面倒だ。

C++では指定した名前空間を省略できる機能が存在する。`using`ディレクティブだ。


~~~c++
using namespace 名前空間名 ;
~~~

これを使えば、先ほどのコードは以下のように書ける。

~~~cpp
int main()
{
    using namespace std ;
    // std名前空間のstring
    string s ;
    // std名前空間のvector<int>
    vector<int> v ;

    // std名前空間のcout
    cout << 123 ;
}
~~~

では名前が衝突した場合はどうなるのか。


~~~cpp
namespace abc {
    int f() { return 0 ; }
}

int f() { return 1 ; }

int main()
{
    using namespace abc ;

    // エラー、名前が曖昧
    f() ;
}
~~~

名前`f`に対してどの名前を使用するのか曖昧になってエラーになる。このエラーを回避するためには、名前空間を直接指定する。


~~~cpp
namespace abc {
    int f() { return 0 ; }
}

int f() { return 1 ; }

int main()
{
    using namespace abc ;

    // OK、名前空間abcのf
    abc::f() ;

    // OK、グローバル名前空間のf
    ::f() ;
}
~~~

`using`ディレクティブは関数の中だけではなく、名前空間の中にも書ける。

~~~cpp
namespace A {
    int f(){ return 0 ; }
}

namespace B {
    using namespace A ;
    int g()
    {
        // OK、A::f
        f() ;
    }
}
~~~

名前空間の中に`using`ディレクティブを書くと、その名前空間の中では指定した名前空間を省略できる。

グローバル名前空間は名前空間なので`using`ディレクティブが書ける。

~~~cpp
using namespace std ;
~~~

ただし、グローバル名前空間の中に`using`ディレクティブを書くと、それ以降すべての箇所で指定した名前空間の省略ができてしまうので注意が必要だ。

### 名前空間を指定しなくてもよいinline名前空間

`inline名前空間`は`inline namespace`で定義する。

~~~c++
inline namespace name { }
~~~

`inline`名前空間内の名前は名前空間名を指定して使うこともできるし、名前空間を指定せずとも使うことができる。

~~~cpp
inline namespace A {
    int a { } ;
}

namespace B {
    int b { } ;
}

int main()
{
    a = 0 ;     // A::a
    A::a = 0 ;  // A::a

    b = 0 ;     // エラー、名前bは宣言されていない
    B::b = 0 ;  // B::b
}
~~~

読者が`inline`名前空間を使うことはほとんどないだろうが、ライブラリのソースファイルを読むときには出てくるだろう。


## 型名

型名とは型を表す名前だ。

型名は`int`や`double`のように言語組み込みのキーワードを使うこともあれば、独自に作った型名を使うこともある。この独自に作った型名を専門用語ではユーザー定義された型(user-defined type)という。ユーザー定義された型を作る方法はさまざまだ。具体的に説明するのは本書のだいぶあとの方になるだろう。例としては、`std::string`や`std::vector<T>`がある。標準ライブラリによってユーザー定義された型だ。

~~~cpp
// 組み込みの型名
int i = 0 ;
double d = 0.0 ;

// ユーザー定義された型名
std::string s ;
std::vector<int> v ;
~~~


### 型名の別名を宣言するエイリアス宣言

長い名前空間名を書くのが煩わしいように、長い型名を書くのも煩わしい。名前空間名の別名を宣言できるように、型名も別名を宣言できる。

型名の別名を宣言するにはエイリアス宣言を使う。

~~~c++
using 別名 = 型名 ;
~~~

使い方。

~~~cpp
int main()
{
    // エイリアス宣言
    using Number = int ;

    // Numberはintの別名
    Number x = 0 ;
}
~~~

型名の別名は型名と同じように使える。意味も同じだ。

歴史的な経緯により、エイリアス宣言による型名の別名のことを、`typedef名`(typedef name)という。これは`typedef`名を宣言する文法が、かつては`typedef`キーワードを使ったものだったからだ。`typedef`キーワードを使った`typedef`名の宣言方法は、昔のコードによく出てくるので現代でも覚えておく必要はある。

~~~c++
typedef 型名 typedef名 ;
~~~

使い方。

~~~cpp
int main()
{
    // typedef名による型名の宣言
    typedef int Number ;

    Number x = 0 ;
}
~~~

これは変数の宣言と同じ文法だ。変数の宣言が以下のような文法で、

~~~c++
型名 変数名 ;
~~~

これに`typedef`キーワードを使えば`typedef`名の宣言になる。

しかし`typedef`キーワードによる`typedef`名の宣言はわなが多い。例えば熟練のC++プログラマーでも、以下のコードが合法だということに驚くだろう。

~~~cpp
int main()
{
    int typedef Number ;
    Number x = 0 ;
}
~~~

しかし本書ではまだ教えていない複雑な型名について、このようなコードを書こうとするとコンパイルエラーになることに熟練のC++プログラマーは気が付くはずだ。その理由はとても難しい。

エイリアス宣言にはこのようなわなはない。

## スコープ

スコープ(scope)というのはやや説明が難しい概念だ。名前空間や関数はスコープを持っている。とてもおおざっぱに説明するとカーリブラケット`{}`で囲まれた範囲がスコープだ。

~~~cpp
namespace ns
{ // 名前空間スコープの始まり
} // 名前空間スコープの終わり

void f()
{ // 関数スコープの始まり

} // 関数スコープの終わり
~~~

これとは別にブロック文のスコープもある。ブロックとは関数の中で複数の文を束ねて1つの文として扱う機能だ。覚えているだろうか。

~~~cpp
void f()
{ // 関数スコープ

    { // 外側のブロックスコープ
        { // 内側のブロックスコープ
        }
    }
}
~~~

スコープは`{`に始まり`}`に終わる。

なぜスコープという概念について説明したかというと、宣言された名前が有効な範囲は、宣言された最も内側のスコープの範囲だからだ。


~~~cpp
namespace ns
{// aの所属するスコープ
    int a {} ;

    void f()
    { // bの所属するスコープ
        int b {} ;

        { // cの所属するスコープ
            int c {} ;
        }// cの範囲終わり

        
    }// bの範囲終わり

} // aの範囲終わり
~~~

名前が有効な範囲は、宣言された最も内側のスコープだ。

外側のスコープで宣言された名前は内側のスコープで使える。

~~~cpp
void f()
{
    int a {} ;
    {// 新たなスコープ
        a = 0 ;
    }
}
~~~

その逆はできない。

~~~cpp
void f()
{
    { int a {} ; }
    // エラー
    a = 0 ;
}
~~~

名前空間も同じだ。

~~~cpp
// グローバル名前空間スコープ

namespace ns {
    int a {} ;
    void f()
    {
        a = 0 ; // OK
    }
} // 名前空間nsのスコープの終了

int main()
{
    // エラー
    a = 0 ;
    // OK 
    ns::a ;
}
~~~

名前空間スコープと関数スコープには違う点もあるが、名前の有効な範囲としては同じスコープだ。

外側のスコープで宣言された名前と同じ名前を内側で宣言すると、内側の名前が外側の名前を隠す。

~~~cpp
// グローバル名前空間のf
auto f =  []()
{ std::cout << 1 ; } ;

int main()
{
    f() ; // 1

    // 関数mainのf
    auto f = []()
    { std::cout << 2 ; } ;

    f() ; // 2

    {
        f() ; // 2

        // ブロックのf
        auto f = []()
        { std::cout << 3 ; } ;
        f() ; // 3
    }

    f() ; // 2
}
~~~

宣言されている場所に注意が必要だ。名前`f`は3つある。最初の関数呼び出しの時点ではグローバル名前空間の`f`が呼ばれる。まだ名前`f`は関数`main`の中で宣言されていないからだ。そして関数`main`のスコープの中で名前`f`が宣言される。このときグローバル名前空間の`f`は隠される。そのため、次の関数`f`の呼び出しでは関数`main`の`f`が呼ばれる。次にブロックの中に入る。ここで関数`f`が呼ばれるが、まだこの`f`は関数`main`の`f`だ。そのあとにブロックの中で名前`f`が宣言される。すると次の関数`f`の呼び出しはブロックの`f`だ。ブロックから抜けたあとの関数`f`の呼び出しは関数`main`の`f`だ。

この章では名前について解説した。名前は難しい。難しいが、プログラミングにおいては名前と向き合わなければならない。
