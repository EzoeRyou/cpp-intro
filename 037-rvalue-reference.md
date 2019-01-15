# rvalueリファレンス

## 概要

今まで使っているリファレンスは、正式にはlvalueリファレンスという名前がついている。これはlvalueへのリファレンスという意味だ。lvalueへのリファレンスがあるからには、lvalueではないリファレンスがあるということだ。C++にはrvalueへのリファレンスがある。これをrvalueリファレンスという。

この章で説明する内容はとても難しい。完全に理解するためには、何度も読み直す必要があるだろう。

## rvalueリファレンスの宣言

T型へのlvalue型リファレンス型は`T &`と書く。

~~~c++
T & lvalue_reference = ... ;
~~~

T型へのrvalueリファレンス型は`T &&`と書く。

~~~c++
T && rvalue_reference = ... ;
~~~

lvalueリファレンスはlvalueで初期化する。rvalueリファレンスはrvalueで初期化する。

lvalueとは名前付きのオブジェクト、戻り値の型としてのlvalueリファレンスのことだ。

~~~cpp
int object { } ;
int & f() { return object ; }

int main()
{
    // lvalueリファレンス
    int & a = object ;
    int & b = f() ;
}
~~~

ここで、式`object`や式`f()`を評価した結果はlvalueだ。

rvalueとは、名前無しのオブジェクト、計算結果の一時オブジェクト、戻り値の型としてのrvalueリファレンスのことだ。

~~~cpp
int && g() { return 0 ; }
int h() { return 0 ; }

int main()
{
    // rvalueリファレンス
    int && a = 0 ;
    int && b = 1 + 1 ;
    int && c = g() ;
    int && d = h() ;
}
~~~

ここで、式`0`、式`1 + 1`、式`g()`を評価した結果はrvalueだ。


rvalueリファレンスをlvalueで初期化することはできない。

~~~c++
int object { } ;
int & f() { return object ; }

int main()
{
    // すべてエラー
    int && a = object ;
    int && b = f() ;
}
~~~

lvalueリファレンスをrvalueで初期化することはできない。

~~~c++
int && g() { return 0 ; }
int h() { return 0 ; }

int main()
{
    // すべてエラー
    int & a = 0 ;
    int & b = 1 + 1 ;
    int & c = g() ;
    int & d = h() ;
}
~~~

リファレンスを初期化することを、リファレンスはリファレンス先を束縛するという。lvalueリファレンスはlvalueを束縛する。rvalueリファレンスはrvalueを束縛する。

ただし、constなlvalueリファレンスはrvalueを束縛することができる。

~~~cpp
int && g() { return 0 ; }

int main()
{
    // OK、constなlvalueリファレンス
    const int & a = 0 ;
    const int & b = 1 + 1 ;
    const int & c = g() ;
}
~~~

rvalueリファレンス自体はlvalueだ。なぜならばrvalueリファレンスはオブジェクトに名前をつけて束縛するからだ。

~~~c++
int main()
{
    // rvalueリファレンス
    int && a = 0 ;
    // OK、rvalueリファレンスaはlvalue
    int & b = a ;
    // エラー、rvalueリファレンスaはrvalueではない
    int && b = a ;
}
~~~

## 値カテゴリー

lvalueとrvalueとは何か。元々lvalueとは左辺値(left-hand value)、rvalueとは右辺値(right-hand value)という語源を持っている。これはまだC言語すらなかったはるか昔から存在する用語で、代入式の左辺に書くことができる値をlvalue、右辺に書くことができる値をrvalueと読んでいたことに由来する。

~~~
lvalue = rvalue ;
~~~

例えば、`int`型の変数`x`は代入式の左辺に書くことができるからlvalue、整数リテラル`0`は右辺に書くことができるからrvalueといった具合だ。

~~~c++
int x ;
x = 0 ;
~~~

C++ではlvalueとrvalueをこのような意味では使っていない。

lvalueとrvalueを理解するには、値カテゴリーを理解しなければならない。

1. 式(expression)とはglvalueかrvalueである
2. glvalueとはlvalueかxvalueである
3. rvalueとはprvalueかxvalueである。

この関係を図示すると以下のようになる。



TODO: 図示

~~~
        expression
        /         \
    glvalue     rvalue
    /     \     /   \
lvalue     xvalue   prvalue
~~~

### lvalue

lvalueはすでに説明したとおり名前付きのオブジェクトのことだ。

~~c++
// lvalue
int object ;
int & ref = object ;
~~~

通常使う殆どのオブジェクトはlvalueになる。

### prvalue

pvalueは純粋なrvalue(pure rvalue)のことだ。名前無しのオブジェクト、計算結果の一時オブジェクトのことだ。

~~~c++
int f() { return 0 ; }

// prvalue
0 ;
1 + 1 ;
f() ;
~~~

ほとんどのprvalueは式を評価するときに自動的に生成され、自動的に破棄されるので、あまり意識することはない。

関数の戻り値の型がリファレンスではない場合、一時オブジェクトが生成される。

~~~c++
struct X { } ;
X f() ;
~~~

演算子も関数の一種なので、

~~~c++
auto result = x + y + z ;
~~~

のような式がある場合、まず`x + y`が評価され、その結果が一時オブジェクトとして返される。その一時オブジェクトを仮にtempとすると、`temp + z`が評価され、また一時オブジェクトが生成され、変数`result`に代入される。

式文全体を評価し終わった後に、一時オブジェクトは自動的に破棄される。

一時オブジェクトは自動的に生成され、自動的に破棄される。ここがとても重要な点だ。これは次の章で説明するムーブセマンティクスに関わってくる。

### xvalue

xvalueとは寿命が尽きかけているlvalue(eXpiring lvalue)のことだ。xvalueはlvalueやprvalueから変換することで発生する。

xvalueとなる値は以下のような場合だ。

+ 戻り値の型がオブジェクトの型へのrvalueリファレンスである関数の呼び出しの結果。

~~~cpp
int && f() { retgurn 0 ; }

int main()
{
    // xvalue
    int && r = f() ;
}
~~~

+ オブジェクトの型へのrvalueリファレンスへのキャスト

~~~cpp
int main()
{
    int object{} ;
    // xvalue
    int && r = static_cast<int &&>(object) ;
}
~~~

+ xvalue配列への添字操作

~~~c++
int main()
{
    int a[3] = {1,2,3} ;
    int && r = static_cast<int (&&)[3]>(a)[0] ;
}
~~~

xvalue配列というのは配列のオブジェクトを配列へのrvalueリファレンス型にキャストすると得られる。xvalue配列への添字操作の結果はxvalueだ。

+ xvalueなクラスのオブジェクトへのリファレンスではない非staticデータメンバーへのアクセス

~~~c++
struct X { int data_member ; } ;

int main()
{
    X x{} ;
    int && r = static_cast<X &&>(x).data_member ;
} ;
~~~

+ 式`.*`で最初のオペランドがxvalueで次のオペランドがデータメンバーへのポインターの場合

~~~c++
struct X { int data_member ; } ;

int main()
{
    X x{} ;
    int && r = static_cast<X &&>(x).*&X::data_member ;
}
~~~

これも配列と似ていて、xvalueのクラスオブジェクトに対するメンバーへのポインター経由でのメンバーの参照結果はxvalueになるということだ。

重要なのは最初の2つだ。残りは覚える必要はない。重要なのは、xvalueとは、lvalueかprvalueから変換した結果発生するものだ。

### rvalue

prvalueとxvalueを合わせて、rvalueという。rvalueリファレンスというのは、rvalueでしか初期化できない。rvalueというのはprvalueかxvalueのどちらかだ。

lvalueはxvalueに変換できるので、結果としてrvalueに変換できることになる。

~~~c++
int main()
{
    // lvalueなオブジェクト
    int lvalue { } ;

    // OK、lvalueリファレンスはlvalueで初期化できる。
    int & l_ref = lvalue ;

    // OK、rvalueリファレンスはrvalueで初期化できる
    // rvalueリファレンスにキャストした結果はrvalue
    int && r_ref = static_cast<int &&>(lvalue) ;
}
~~~

lvalueはそのままではrvalueではないが、xvalueに変換すればrvalueになる。

prvalueはもともとrvalueである。

この性質は次の章で説明するムーブセマンティクスで利用する。

### glvalue

glvalueは一般的なlvalue(generalizd lvalue)という意味だ。glvalueとは、lvalueかxvalueのことだ。

lvalueから変換したxvalueはもともとlvalueだったのだから、glvalueとなるのも自然だ。xvalueに変換したprvalueはglvalueになれる。

この性質はムーブセマンティクスで利用する。


## rvalueリファレンスのライブラリ

### std::move

`std::move(e)`は値`e`をxvalueにするための標準ライブラリだ。`std::move(e)`は値`e`の型`T`へのrvalueリファレンス型にキャストしてくれるので、xvalueになる。そしてxvalueはrvalueだ。

~~~cpp
int main()
{
    int lvalue { } ;
    int && r = std::move(lvalue) ;
}
~~~

これは以下のように書いたものと同じようになる。

~~~cpp
int main()
{
    int lvalue { } ;
    int && r = static_cast<int &&>(lvalue) ;
}
~~~

### std::moveの実装

`std:move(e)`の実装は少し難しい。根本的には、式`e`のリファレンスではない型`T`に対して、`static_cast<T &&>(e)`をしているだけだ。

すると以下のような実装だろうか。

~~~cpp
template < typename T >
T && move( T & t ) noexcept
{
    return static_cast<T &&>(t) ;
}
~~~

この実装はlvalueをxvalueに変換することはできるが、rvalue(prvalueとxvalue)をxvalueに変換することはできない。

~~~c++
int main()
{
    // エラー、prvalueを変換できない
    int && r1 = move(0) ;

    int lvalue { } ;
    // エラー、xvalueをxvalueに変換できない
    int && r2 = move(move(lvalue)) ;
}
~~~

rvalueはrvalueリファレンスで受け取れるので、lvalueリファレンスを関数の引数として受け取る`move`の他に、rvalueリファレンスを関数の引数として受け取る`move`を書くとよい。

すると以下のように書けるだろうか。

~~~cpp
// lvalueリファレンス
template < typename T >
T && move( T & t ) noexcept
{
    return static_cast<T &&>(t) ;
}

// rvalueリファレンス
template < typename T >
T && move( T && t ) noexcept
{
    return static_cast<T &&>(t) ;
}
~~~

しかしこれでは関数の本体の中身がまったく同じ関数が2つできてしまう。もっと複雑な関数を書くときにこのようなコードの重複があると、ソースコードの修正が難しくなる。せっかくテンプレートを使っているのにこれでは意味がない。

### フォワーディングリファレンス

C++のテンプレートはコードの重複を省くためにある。そのため、C++ではテンプレートパラメーターへのrvalueリファレンスを関数の仮引数として取る場合を、フォワーディングリファレンス(forwarding reference)として、特別にlvalueでもrvalueでも受け取れるようにしている。

~~~cpp
// T &&はフォワーディングリファレンス
template < typename T >
void f( T && t ) ;
~~~

このような関数テンプレートの仮引数`t`に実引数としてrvalueを渡すと、`T`はrvalueの型となり、結果として`t`の型は`T &&`になる。

~~~c++
// Tはint
f(0) ;
~~~

もし実引数として型`U`のlvalueを渡すと、テンプレートパラメーター`T`が`U &`となる。そして、テンプレートパラメーター`T`に対するリファレンス宣言子(`&`, `&&`)は単に無視される。

~~~c++
int lvalue{} ;
// Tはint &
// T &&はint &
f(lvalue) ;
~~~

ここで、関数テンプレート`f`のテンプレートパラメーターTは`int &`となる。この`T`にリファレンス宣言子を`T &`や`T &&`のように使っても、単に無視されて、`T &`となる。

~~~cpp
template < typename T >
void f( T && t )
{
    using A = T & ;
    using B = T && ; 
}

int main()
{
    // prvalue
    f(0) ;
    int lvalue{} ;
    // lvalue
    f(lvalue) ;
}
~~~

`f(0)`はprvalueを渡している。この場合、`T`の型は`int`となる。`A`は`int &`、`B`は`init &&`となる。

`f(lvalue)`はlvalueを渡している。この場合、`T`の型は`int &`となる。この場合の`T`に`&`や`&&`をつけても無視される。なので、`A`, 'B'の型はどちらも`int &`になる。

したがって、以下のように書くと`move`はlvalueもrvalueも受け取ることができる。

~~~c++
// lvalueもrvalueも受け取ることができるmove
template < typename T >
T && move( T && t ) noexcept
{
    return static_cast<T &&>(t) ;
}
~~~

ただし、この実装にはまだ問題がある。この`move`にlvalueを渡した場合、lvalueの型を`U`とすると、テンプレートパラメーター`T`は`U &`になる。

~~~c++
U lvalue{} ;
// TはU &
move( lvalue ) ;
~~~

テンプレートパラメーター名`T`がリファレンスのとき、`T`にリファレンス宣言子`&&`をつけても単に無視されることを考えると、上の`move`に`int &`型のlvalueが実引数として渡されたときは、以下のように書いたものと等しくなる。

~~~c++
int & move( int & t ) noexcept
{
    return static_cast<int &>(t) ;
}
~~~

`move(e)`は`e`がlvalueであれrvalueであれ、xvalueにする関数だ。そのためには、rvalueリファレンスにキャストしなければならない。テンプレートではフォーワーディングリファレンスという例外的な仕組みによってlvalueもrvalueも`T &&`で受け取れるが、lvalueを受け取ったときには`T &&`がlvalueリファレンスになってしまうのでは、xvalueにキャストできない。

この問題は別のライブラリによって解決できる。


### std::removereference_t<T>

`std::remove_reference_t<T>`は`T`型からリファレンス型を除去してくれるライブラリだ。

~~~cpp
int main()
{
    // int
    using A = std::remove_reference_t<int> ;
    // int
    using B = std::remove_reference_t<int &> ;
    // int
    using C = std::remove_reference_t<int &&> ;
}
~~~

ということは、これとリファレンス宣言子を組み合わせると、どのような型がテンプレート実引数に渡されてもrvalueリファレンスにできる。

~~~cpp
template < typename T >
void f()
{
    using RT = std::remove_reference_t<T> && ;
}
~~~

`add_pointer_t/remove_pointer_t`があるように、`remove_reference_t`にも対となるリファレンスを追加するライブラリが存在する。ただしリファレンスにはlvalueリファレンスとrvalueリファレンスがあるので、それぞれ`std::add_lvalue_refrence_t<T>`、`std::add_rvalue_reference_t<T>`となっている。

~~~cpp
int main()
{
    // int &
    using A = std::add_lvalue_refrence_t<int> ;
    // int &&
    using B = std::add_rvalue_reference_t<int> ;
}
~~~

### std::moveの正しい実装

`std::remove_reference_t<T>`を使うと、`move`は以下のように書ける。

~~~cpp
template < typename T >
std::remove_reference_t<T> && move( T && t ) noexcept
{
    return static_cast< std::remove_reference_t<T> && >(t) ;
}
~~~

### std::forward

テンプレートパラメーターにrvalueリファレンス宣言子を使うとlvalueもrvalueも受け取れる。

~~~cpp
template < typename T >
void f( T && t ) { }

int main()
{
    int lvalue{} ;
    f(lvalue) ;
    f(0) ;
}
~~~

この関数`f`から別の関数`g`に値を渡したい場合を考えよう。

~~~cpp
template < typename T >
void g( T && t ) { }

template < typename T >
void f( T && t )
{
    g(t) ;
}
~~~

このとき、関数`f`に渡されたものがlvalueでもrvalueでも、関数`g`に渡される値はlvalueになってしまう。

なぜならば、名前付きのrvalueリファレンスに束縛されたオブジェクトはlvalueだからだ。

~~~cpp
int main()
{
    // 名前付きのrvalueリファレンス
    int && rvalue_ref = 0 ;
    // これはlvalue
    int & lvalue_ref = rvalue_ref ;
}
~~~

なので、`g(t)`の`t`はlvalueとなる。

ここでrvalueを渡すのは簡単だ。`std::move`を使えばいい。

~~~c++
template < typename T >
void f( T && t )
{
    g( std::move(t) ) ;
}
~~~

ただし、これはtがlvalueのときも問答無用でxvalueにしてしまう。

`t`がlvalueならばlvalueとして、rvalueならばxvalueとして、渡された値カテゴリーのまま別の関数に渡したい場合、`std::forward<T>(t)`が使える。

~~~c++
template < typename T >
void f( T && t )
{
    g( std::forward<T>(t) ) ;
}
~~~

`std::forward<T>(t)`の`T`にはテンプレートパラメーター名を書く。こうすると、`t`がlvalueならばlvalueリファレンス、rvalueならばrvalueリファレンスが戻り値として返される。


`std::forward`の実装は以下の通りだ。

~~~c++
template<class T>
constexpr 
T &&
forward(remove_reference_t<T>& t) noexcept
{ return static_cast<T&&>(t) ; }

template<class T>
constexpr 
T &&
forward(remove_reference_t<T>&& t) noexcept
{ return static_cast<T&&>(t) ; }
~~~

もし`std::forward<T>(t)`にlvalueが渡された場合、上の`forward`が呼ばれる。その場合、`T`はlvalueリファレンスになっているはずなのでrvalueリファレンス宣言子は無視され、lvalueリファレンスが戻り値の型になる。

rvalueが渡された場合、rvalueリファレンスが戻り値の型になる。
