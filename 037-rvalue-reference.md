# rvalueリファレンス

## 概要

いままで使っているリファレンスは、正式には`lvalue`リファレンスという名前がついている。これは`lvalue`へのリファレンスという意味だ。`lvalue`へのリファレンスがあるからには、`lvalue`ではないリファレンスがあるということだ。C++には`rvalue`へのリファレンスがある。これを`rvalue`リファレンスという。

この章で説明する内容はとても難しい。完全に理解するためには、何度も読み直す必要があるだろう。

## rvalueリファレンスの宣言

`T`型への`lvalue`型リファレンス型は`T &`と書く。

~~~cpp
T & lvalue_reference = ... ;
~~~

`T`型への`rvalue`リファレンス型は`T &&`と書く。

~~~cpp
T && rvalue_reference = ... ;
~~~

`lvalue`リファレンスは`lvalue`で初期化する。`rvalue`リファレンスは`rvalue`で初期化する。

`lvalue`とは名前付きのオブジェクトや戻り値の型としての`lvalue`リファレンスのことだ。

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

ここで、式`object`や式`f()`を評価した結果は`lvalue`だ。

`rvalue`とは、名前なしのオブジェクトや計算結果の一時オブジェクト、戻り値の型としての`rvalue`リファレンスのことだ。

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

ここで、式`0`、式`1 + 1`、式`g()`を評価した結果は`rvalue`だ。


`rvalue`リファレンスを`lvalue`で初期化することはできない。

~~~cpp
int object { } ;
int & f() { return object ; }

int main()
{
    // すべてエラー
    int && a = object ;
    int && b = f() ;
}
~~~

`lvalue`リファレンスを`rvalue`で初期化することはできない。

~~~cpp
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

リファレンスを初期化することを、リファレンスはリファレンス先を束縛するという。`lvalue`リファレンスは`lvalue`を束縛する。`rvalue`リファレンスは`rvalue`を束縛する。

ただし、`const`な`lvalue`リファレンスは`rvalue`を束縛することができる。

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

`rvalue`リファレンス自体は`lvalue`だ。なぜならば`rvalue`リファレンスはオブジェクトに名前を付けて束縛するからだ。

~~~cpp
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

`lvalue`と`rvalue`とは何か。もともと`lvalue`とは左辺値(left-hand value)、`rvalue`とは右辺値(right-hand value)という語源を持っている。これはまだC言語すらなかったはるか昔から存在する用語で、代入式の左辺に書くことができる値を`lvalue`、右辺に書くことができる値を`rvalue`と読んでいたことに由来する。

~~~cpp
lvalue = rvalue ;
~~~

例えば、`int`型の変数`x`は代入式の左辺に書くことができるから`lvalue`、整数リテラル`0`は右辺に書くことができるから`rvalue`といった具合だ。

~~~cpp
int x ;
x = 0 ;
~~~

C++では`lvalue`と`rvalue`をこのような意味では使っていない。

`lvalue`と`rvalue`を理解するには、値カテゴリーを理解しなければならない。

1. 式(expression)とは`glvalue`か`rvalue`である。
2. `glvalue`とは`lvalue`か`xvalue`である。
3. `rvalue`とは`prvalue`か`xvalue`である。

この関係を図示すると以下のようになる。

~~~
TODO: 図示

        expression
        /         \
    glvalue     rvalue
    /     \     /   \
lvalue     xvalue   prvalue
~~~
fig/fig37-01.png


### lvalue

`lvalue`はすでに説明したとおり名前付きのオブジェクトのことだ。

~~~cpp
// lvalue
int object ;
int & ref = object ;
~~~

通常使うほとんどのオブジェクトは`lvalue`になる。

### prvalue

`prvalue`は純粋な`rvalue`(pure rvalue)のことだ。つまり、名前なしのオブジェクトや計算結果の一時オブジェクトのことだ。

~~~cpp
int f() { return 0 ; }

// prvalue
0 ;
1 + 1 ;
f() ;
~~~

ほとんどの`prvalue`は式を評価するときに自動的に生成され、自動的に破棄されるので、あまり意識することはない。

関数の戻り値の型がリファレンスではない場合、一時オブジェクトが生成される。

~~~cpp
struct X { } ;
X f() ;
~~~

演算子も関数の一種なので、

~~~cpp
auto result = x + y + z ;
~~~

のような式がある場合、まず`x + y`が評価され、その結果が一時オブジェクトとして返される。その一時オブジェクトを仮に`temp`とすると、`temp + z`が評価され、また一時オブジェクトが生成され、変数`result`に代入される。

式文全体を評価し終わったあとに、一時オブジェクトは自動的に破棄される。

一時オブジェクトは自動的に生成され、自動的に破棄される。ここがとても重要な点だ。これは次の章で説明するムーブセマンティクスに関わってくる。

### xvalue

`xvalue`とは寿命が尽きかけている`lvalue`(eXpiring lvalue)のことだ。`xvalue`は`lvalue`や`prvalue`から変換することで発生する。

`xvalue`となる値は以下のような場合だ。

+ 戻り値の型がオブジェクトの型への`rvalue`リファレンスである関数の呼び出しの結果

~~~cpp
int && f() { return 0 ; }

int main()
{
    // xvalue
    int && r = f() ;
}
~~~

+ オブジェクトの型への`rvalue`リファレンスへのキャスト

~~~cpp
int main()
{
    int object{} ;
    // xvalue
    int && r = static_cast<int &&>(object) ;
}
~~~

+ `xvalue`配列への添字操作

~~~cpp
int main()
{
    int a[3] = {1,2,3} ;
    int && r = static_cast<int (&&)[3]>(a)[0] ;
}
~~~

`xvalue`配列というのは配列のオブジェクトを配列への`rvalue`リファレンス型にキャストすると得られる。`xvalue`配列への添字操作の結果は`xvalue`だ。

+ `xvalue`なクラスのオブジェクトへのリファレンスではない非`static`データメンバーへのアクセス

~~~cpp
struct X { int data_member ; } ;

int main()
{
    X x{} ;
    int && r = static_cast<X &&>(x).data_member ;
}
~~~

+ 式`.*`で最初のオペランドが`xvalue`で次のオペランドがデータメンバーへのポインターの場合

~~~cpp
struct X { int data_member ; } ;

int main()
{
    X x{} ;
    int && r = static_cast<X &&>(x).*&X::data_member ;
}
~~~

これも配列と似ていて、`xvalue`のクラスオブジェクトに対するメンバーへのポインター経由でのメンバーの参照結果は`xvalue`になるということだ。

重要なのは最初の2つだ。残りは覚える必要はない。重要なのは、`xvalue`とは、`lvalue`か`prvalue`から変換した結果発生するものだ。

### rvalue

`prvalue`と`xvalue`を合わせて、`rvalue`という。`rvalue`リファレンスというのは、`rvalue`でしか初期化できない。`rvalue`というのは`prvalue`か`xvalue`のどちらかだ。

`lvalue`は`xvalue`に変換できるので、結果として`rvalue`に変換できることになる。

~~~cpp
int main()
{
    // lvalueなオブジェクト
    int lvalue { } ;

    // OK、lvalueリファレンスはlvalueで初期化できる
    int & l_ref = lvalue ;

    // OK、rvalueリファレンスはrvalueで初期化できる
    // rvalueリファレンスにキャストした結果はrvalue
    int && r_ref = static_cast<int &&>(lvalue) ;
}
~~~

`lvalue`はそのままでは`rvalue`ではないが、`xvalue`に変換すれば`rvalue`になる。

`prvalue`はもともと`rvalue`である。

この性質は次の章で説明するムーブセマンティクスで利用する。

### glvalue

`glvalue`は一般的な`lvalue`(generalized lvalue)という意味だ。`glvalue`とは、`lvalue`か`xvalue`のことだ。

`lvalue`から変換した`xvalue`はもともと`lvalue`だったのだから、`glvalue`となるのも自然だ。`xvalue`に変換した`prvalue`は`glvalue`になれる。

この性質はムーブセマンティクスで利用する。


## rvalueリファレンスのライブラリ

### std::move

`std::move(e)`は値`e`を`xvalue`にするための標準ライブラリだ。`std::move(e)`は値`e`の型`T`への`rvalue`リファレンス型にキャストしてくれるので、`xvalue`になる。そして`xvalue`は`rvalue`だ。

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

この実装は`lvalue`を`xvalue`に変換することはできるが、`rvalue`(`prvalue`と`xvalue`)を`xvalue`に変換することはできない。

~~~cpp
int main()
{
    // エラー、prvalueを変換できない
    int && r1 = move(0) ;

    int lvalue { } ;
    // エラー、xvalueをxvalueに変換できない
    int && r2 = move(move(lvalue)) ;
}
~~~

`rvalue`は`rvalue`リファレンスで受け取れるので、`lvalue`リファレンスを関数の引数として受け取る`move`のほかに、`rvalue`リファレンスを関数の引数として受け取る`move`を書くとよい。

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

C++のテンプレートはコードの重複を省くためにある。そのため、C++ではテンプレートパラメーターへの`rvalue`リファレンスを関数の仮引数として取る場合を、フォワーディングリファレンス(forwarding reference)として、特別に`lvalue`でも`rvalue`でも受け取れるようにしている。

~~~cpp
// T &&はフォワーディングリファレンス
template < typename T >
void f( T && t ) ;
~~~

このような関数テンプレートの仮引数`t`に実引数として`rvalue`を渡すと、`T`は`rvalue`の型となり、結果として`t`の型は`T &&`になる。

~~~cpp
// Tはint
f(0) ;
~~~

もし実引数として型`U`の`lvalue`を渡すと、テンプレートパラメーター`T`が`U &`となる。そして、テンプレートパラメーター`T`に対するリファレンス宣言子(`&`, `&&`)は単に無視される。

~~~cpp
int lvalue{} ;
// Tはint &
// T &&はint &
f(lvalue) ;
~~~

ここで、関数テンプレート`f`のテンプレートパラメーター`T`は`int &`となる。この`T`にリファレンス宣言子を`T &`や`T &&`のように使っても、単に無視されて、`T &`となる。

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

`f(0)`は`prvalue`を渡している。この場合、`T`の型は`int`となる。`A`は`int &`、`B`は`int &&`となる。

`f(lvalue)`は`lvalue`を渡している。この場合、`T`の型は`int &`となる。この場合の`T`に`&`や`&&`を付けても無視される。なので、`A`, `B`の型はどちらも`int &`になる。

したがって、以下のように書くと`move`は`lvalue`も`rvalue`も受け取ることができる。

~~~cpp
// lvalueもrvalueも受け取ることができるmove
template < typename T >
T && move( T && t ) noexcept
{
    return static_cast<T &&>(t) ;
}
~~~

ただし、この実装にはまだ問題がある。この`move`に`lvalue`を渡した場合、`lvalue`の型を`U`とすると、テンプレートパラメーター`T`は`U &`になる。

~~~cpp
U lvalue{} ;
// TはU &
move( lvalue ) ;
~~~

テンプレートパラメーター名`T`がリファレンスのとき、`T`にリファレンス宣言子`&&`を付けても単に無視されることを考えると、上の`move`に`int &`型の`lvalue`が実引数として渡されたときは、以下のように書いたものと等しくなる。

~~~cpp
int & move( int & t ) noexcept
{
    return static_cast<int &>(t) ;
}
~~~

`move(e)`は`e`が`lvalue`であれ`rvalue`であれ、`xvalue`にする関数だ。そのためには、`rvalue`リファレンスにキャストしなければならない。テンプレートではフォーワーディングリファレンスという例外的な仕組みによって`lvalue`も`rvalue`も`T &&`で受け取れるが、`lvalue`を受け取ったときには`T &&`が`lvalue`リファレンスになってしまうのでは、`xvalue`にキャストできない。

この問題は別のライブラリによって解決できる。


### std::remove_reference_t<T>

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

ということは、これとリファレンス宣言子を組み合わせると、どのような型がテンプレート実引数に渡されても`rvalue`リファレンスにできる。

~~~cpp
template < typename T >
void f()
{
    using RT = std::remove_reference_t<T> && ;
}
~~~

`add_pointer_t/remove_pointer_t`があるように、`remove_reference_t`にも対となるリファレンスを追加するライブラリが存在する。ただしリファレンスには`lvalue`リファレンスと`rvalue`リファレンスがあるので、それぞれ`std::add_lvalue_reference_t<T>`、`std::add_rvalue_reference_t<T>`となっている。

~~~cpp
int main()
{
    // int &
    using A = std::add_lvalue_reference_t<int> ;
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

テンプレートパラメーターに`rvalue`リファレンス宣言子を使うと`lvalue`も`rvalue`も受け取れる。

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

このとき、関数`f`に渡されたものが`lvalue`でも`rvalue`でも、関数`g`に渡される値は`lvalue`になってしまう。

なぜならば、名前付きの`rvalue`リファレンスに束縛されたオブジェクトは`lvalue`だからだ。

~~~cpp
int main()
{
    // 名前付きのrvalueリファレンス
    int && rvalue_ref = 0 ;
    // これはlvalue
    int & lvalue_ref = rvalue_ref ;
}
~~~

なので、`g(t)`の`t`は`lvalue`となる。

ここで`rvalue`を渡すのは簡単だ。`std::move`を使えばいい。

~~~cpp
template < typename T >
void f( T && t )
{
    g( std::move(t) ) ;
}
~~~

ただし、これは`t`が`lvalue`のときも問答無用で`xvalue`にしてしまう。

`t`が`lvalue`ならば`lvalue`として、`rvalue`ならば`xvalue`として、渡された値カテゴリーのまま別の関数に渡したい場合、`std::forward<T>(t)`が使える。

~~~cpp
template < typename T >
void f( T && t )
{
    g( std::forward<T>(t) ) ;
}
~~~

`std::forward<T>(t)`の`T`にはテンプレートパラメーター名を書く。こうすると、`t`が`lvalue`ならば`lvalue`リファレンス、`rvalue`ならば`rvalue`リファレンスが戻り値として返される。


`std::forward`の実装は以下のとおりだ。

~~~cpp
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

もし`std::forward<T>(t)`に`lvalue`が渡された場合、上の`forward`が呼ばれる。その場合、`T`は`lvalue`リファレンスになっているはずなので`rvalue`リファレンス宣言子は無視され、`lvalue`リファレンスが戻り値の型になる。

`rvalue`が渡された場合、`rvalue`リファレンスが戻り値の型になる。
