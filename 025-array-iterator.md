# arrayのイテレーター

## イテレーターの中身

自作の`array`をイテレーターに対応させる前に、まず`'std::array'`のイテレーターについてひと通り調べよう。

イテレーターは`std::begin/std::end`で取得する。

~~~cpp
int main()
{
    std::array<int, 5> a = {1,2,3,4,5} ;

    auto first = std::begin(a) ;
    auto last = std::end(a) ;
}
~~~

`std::begin/std::end`は何をしているのか見てみよう。

~~~cpp
namespace std
{
    template < typename C >
    auto begin( C & c )
    { return c.begin() ; }

    template < typename C >
    auto begin( C const & c )
    { return c.begin() ; }

    template < typename C >
    auto end( C & c )
    { return c.end() ;}

    template < typename C >
    auto end( C const & c )
    { return c.end() ;}
}
~~~

なんと、単に引数に対してメンバー関数`begin/end`を呼び出してその結果を返しているだけだ。

さっそく確かめてみよう。

~~~cpp
int main()
{
    std::array<int, 5> a = {1,2,3,4,5} ;

    auto iter = a.begin() ;
    std::cout << *iter ; // 1
    ++iter ;
    std::cout << *iter ; // 2
}
~~~

確かに動くようだ。

すると自作の`array`でイテレーターに対応する方法がわかってきた。

~~~cpp
// イテレーターを表現するクラス
struct array_iterator { } ;

template < typename T, std::size_t N >
struct array
{
    // イテレーター型
    using iterator = array_iterator ;

    // イテレーターを返すメンバー関数
    iterator begin() ;
    iterator end() ;

    // その他のメンバー
} ;
~~~

イテレーターに対応するには、おおむねこのような実装になるとみていいだろう。おそらく細かい部分で微調整が必要になるが、いまはこれでよしとしよう。ではイテレーターが具体的に何をするかを見ていこう。

すでに学んだように、イテレーターは`operator *`で参照する要素の値を取得できる。また書き込みもできる。

~~~cpp
int main()
{
    std::array<int, 5> a = {1,2,3,4,5} ;

    auto iter = a.begin() ;
    int x = *iter ; // 1
    *iter = 0 ;
    // aは{0,2,3,4,5}
}
~~~

問題を簡単にするために、これまでに作った自作の`array`で最初の要素にアクセスする方法を考えてみよう

~~~cpp
array<int, 5> a = {1,2,3,4,5} ;
int x = a[0] ; // 1
a[0] = 0 ;
~~~

このことから考えると、先頭要素を指すイテレーターは`operator *`をオーバーロードして先頭要素をリファレンスで返せばよい。

~~~cpp
struct array_iterator_int_5_begin
{
    array<int, 5> & a ;

    array<int, 5>::reference operator *()
    {
        return a[0] ;
    }
} ;
~~~

しかし、この実装では`array<int,5>`にしか対応できない。`array<int,7>`や`array<double, 10>`には対応できない。なぜなら、`array`に渡すテンプレート実引数が違うと、別の型になるからだ。

`array_iterator`でさまざまな`array`を扱うにはどうすればいいのか。テンプレートを使う。

~~~cpp
template < typename Array >
struct array_iterator_begin
{
    Array & a ;

    array_iterator_begin( Array & a )
        : a( a ) { }

    // エラー
    // Array::referenceは型ではない
    Array::reference operator *()
    {
        return a[0] ;
    }
} ;
~~~

しかしなぜかエラーだとコンパイラーに怒られる。この理由を説明するのはとても難しい。気になる読者は近所のC++グルに教えを請おう。ここでは答えだけを教える。

`T::Y`において、`T`がテンプレート引数に依存する名前で、`Y`がネストされた型名の場合、`typename`キーワードを付けなければならない。

~~~cpp
template < typename T >
void f()
{
    // typenameが必要
    typename T::Y x = 0 ;
}

struct S
{
    using Y = int ;
} ;

int main()
{
    // T = S
    // T::Y = int
    f<S>() ;
}
~~~

わかっただろうか。わからなくても無理はない。この問題を理解するにはテンプレートに対する深い理解が必要だ。理解した暁には読者はC++グルとして崇拝されているだろう。

さしあたって必要なのは`Array::reference`の前に`typename`キーワードを付けることだ。

~~~cpp
typename Array::reference
array_iterator_begin::operator * ()
{
    return a[0] ;
}
~~~

どうやら最初の要素を読み書きするイテレーターはできたようだ。`array`側も実装して試してみよう。

`array`側の実装にはまだ現時点では完全に理解できない黒魔術が必要だ。

~~~cpp
template < typename T, std::size_t N >
struct array
{
    T storage[N] ;
    // 黒魔術1: array
    using iterator = array_iterator_begin<array> ;
    iterator begin()
    // 黒魔術2: *this
    // 黒魔術3: iterator(*this)
    { return iterator(*this) ; }
} ;
~~~

黒魔術1は`array_iterator_begin<array>`の中にある。この`array`は`array<T,N>`と同じ意味になる。つまり全体としては、`array_iterator_begin<array<T,N>>`と書いたものと同じだ。クラステンプレートの中でクラス名を使うと、テンプレート実引数をそれぞれ指定したものと同じになる。

~~~cpp
template < typename A, typename B, typename C >
struct S
{
    void f()
    {
        // S<A,B,C>と同じ
        S s ;
    }
} ;
~~~

黒魔術2は`*this`だ。`*this`はメンバー関数を呼んだクラスのオブジェクトへのリファレンスだ。

~~~cpp
struct S
{
    int data {} ;
    // *thisはメンバー関数が呼ばれたSのオブジェクト
    S & THIS() { return *this ; } 
} ;

int main()
{
    S s1 ;
    
    s1.THIS().data = 123 ;
    // 123
    std::cout << s1.data ;

    S s2 ;
    s2.THIS().data = 456 ;
    // 456
    std::cout << s2.data ;
}
~~~

クラスのメンバー関数は対応するクラスのオブジェクトに対して呼ばれる。本来ならばクラスのオブジェクトをリファレンスで取るような形になる。

~~~cpp
struct S
{
    int data {} ;
    void set(int x)
    {
        data = x ;
    }
} ;

int main()
{
    S object ;
    object.set(42) ;
}
~~~

というコードは、ほぼ同じことを以下のようにも書ける。

~~~cpp
struct S
{
    int data {} ;
} ;

void set( S & object, int x )
{
    object.data = x ;
}

int main()
{
    S ojbect ;
    set( object, 42 ) ;
}
~~~

クラスの意義は変数と関数を結び付けることだ。このように変数と関数がバラバラではわかりにくいので、メンバー関数という形で`object.set(...)`のようにわかりやすく呼び出せるし、その際クラス`S`のオブジェクトは変数`object`であることが文法上わかるので、わざわざ関数の実引数の形で書くことは省略できるようにしている。

メンバー関数の中で、メンバー関数が呼ばれているクラスのオブジェクトを参照する方法が`*this`だ。

しかしなぜ`*this`なのか。もっとわかりやすいキーワードでもいいのではないか。なぜ`*`が付いているのか。この謎を理解するためには、これまたポインターの理解が必要になるが、それは次の章で学ぶ。

黒魔術3は`iterator(*this)`だ。クラス名に`()`や`{}`を続けると、コンストラクターを呼び出した結果のクラスの値を得ることができる。

~~~cpp
struct S
{
    S() { }
    S( int ) { }
    S( int, int ) { }
} ;

int main()
{
    S a = S() ;
    S b = S(0) ;
    S c = S(1,2) ;

    S d = S{} ;
    S e = S{0} ;
    S f = S{1,2} ;
}
~~~

黒魔術の解説が長くなった。本題に戻ろう。

`array_iterator_begin`は先頭の要素しか扱えない。イテレーターで先頭以外の別の要素を扱う方法を思い出してみよう。


イテレーターは`operator ++`で次の要素を参照する。`operator --`で前の要素を参照する。

~~~cpp
int main()
{
    std::array<int, 5> a = {1,2,3,4,5} ;

    auto iter = a.begin() ;
    *iter ; // 1
    ++iter ;
    *iter ; // 2
    --iter ;
    *iter ; // 1
}
~~~

この`operator ++`と`operator --`はイテレーターへのリファレンスを返す。なぜならば、以下のように書けるからだ。

~~~cpp
*++iter ;
*++++iter ;
~~~

以上を踏まえて、自作の`array_iterator`の宣言を書いてみよう。


~~~cpp
template < typename Array >
struct array_iterator
{
    Array & a ;

    array_iterator( Array & a )
        : a( a ) { }

    // 次の要素を指す
    array_iterator & operator ++() ;
    // 前の要素を指す
    array_iterator & operator --() ;
    
    // いま参照している要素へのリファレンスを返す
    Array::reference operator *() ;
} ;
~~~

イテレーターの実装で先頭の要素を参照するのは`a[0]`だった。その次の要素を参照するには`a[1]`だ。その次の要素は`a[2]`となり、その前の要素は`a[1]`だ。

~~~cpp
array<int, 5> a = {1,2,3,4,5} ;

auto iter = a.begin() ; // 最初の要素
*iter ; // 1
++iter ; // 次の要素
*iter ; // 2
--iter ; // 前の要素、つまり最初の要素
*iter ; // 1
~~~

では最初の要素の前の要素や、最後の要素の次の要素を参照しようとするとどうなるのか。

~~~cpp
auto first = a.begin() ;
--first ;
*first ; // 最初の前の要素？
auto last = a.end() ;
++last ; //
*last ; // 最後の次の要素？
~~~

これはエラーになる。このようなエラーを起こさないように務めるのはユーザーの責任で、イテレーター実装者の責任ではない。しかし、必要であればイテレーターの実装者はこのようなエラーを防ぐような実装もできる。それはあとの章で学ぶ。ここでは、こういう場合が起こることは考えなくてもよいとしよう。

これを考えていくと、イテレーターの実装をどうすればいいのかがわかってくる。

`array_iterator`の`operator *`は`a[i]`を返す。

~~~cpp
typename Array::reference array_iterator::operator *()
{
    return a[i] ;
}
~~~

`i`は`std::size_t`型のデータメンバーで、イテレーターが現在参照している`i`番目の要素を記録している。

ということは先ほどの`array_iterator`の宣言にはデータメンバー`i`を追加する修正が必要だ。

~~~cpp
template < typename Array >
struct array_iterator
{
    Array & a ;
    std::size_t i ;

    array_iterator( Array & a, std::size_t i )
        : a( a ), i(i) { }

    // いま参照している要素へのリファレンスを返す
    Array::reference operator *()
    {
        return a[i] ;
    }

    // その他のメンバー
} ;
~~~

そして、`array`側にも新しい`array_iterator`への対応が必要になる。

~~~cpp
template < typename T, std::size_t N >
struct array
{
    using iterator = array_iterator<array> ;

    // 先頭要素のイテレーター
    iterator begin()
    {
        return array_iterator( *this, 0 ) ;
    }

    // 最後の次の要素へのイテレーター
    iterator end()
    {
        return array_iterator( *this, N ) ;
    }
} ;
~~~

何度も書くように、インデックスは`0`から始まる。要素が$N$個ある場合、最初の要素は0番目で、最後の要素は$N-1$番目だ。

インクリメント演算子`operator ++`にも対応しよう。

~~~cpp
array_iterator & array_iterator::operator ++()
{
    ++i ;
    return *this ;
}
~~~

これで最低限のイテレーターは実装できた。さっそく試してみよう。

~~~cpp
int main()
{
    array<int,5> a = {1,2,3,4,5} ;

    auto iter = a.begin() ;

    std::cout << *iter ; // 1
    ++iter ;
    std::cout << *iter ; // 2
}
~~~

実は`operator ++`は2種類ある。前置演算子と後置演算子だ。

~~~cpp
int main()
{
    int i = 0 ;

    // 前置
    std::cout << ++i ;  // 1
    // 後置
    std::cout << i++ ;  // 1
    std::cout << i ;    // 2
}
~~~

`int`型では、前置`operator ++`はオペランドの値を1加算した値にする。後置`operator ++`はオペランドの値を1加算するが、式を評価した結果は前のオペランドの値になる。

~~~cpp
++i ; // i+1
i++ ; // i、ただしiの値はi+1
~~~

後置`operator ++`のオーバーロードは以下のように書く。

~~~cpp
struct IntLike
{
    int data {} ;

    // 前置
    IntLike & operator ++()
    {
        ++data ;
        return *this ;
    }
    // 後置
    IntLike operator ++(int)
    {
        IntLike copy = *this ;
        ++*this ;
        return copy ;
    }
} ;
~~~

このコードは慣れないとわかりにくいが、妥当な理由のあるコードだ。順番に説明しよう。

まず演算子オーバーロードの宣言だ。

~~~cpp
// 前置
IntLike & operator ++() ;
// 後置
IntLike operator ++(int) ;
~~~

前置はリファレンスを返す。前置演算子の適用結果はさらに変更できるようにするためだ。

~~~cpp
int main()
{
    int i { } ;

    ++++i ;
}
~~~

もちろん、リファレンスを返さない実装は可能だ。そもそも何も値を返さない`void`を使うことも可能だ。

~~~cpp
struct S
{
    void operator ++() { }
} ;
~~~

ただし、その場合`operator ++`に対して通常期待されるコードが書けなくなる。理由がない限り演算子の自然な挙動を目指すべきだ。

前置と後置は区別できる必要がある。C++はその区別の方法として、`int`型の仮引数を1つ取る`operator ++`を後置演算子だと認識する文法を採用した。この`int`型の実引数は前置と後置を区別するためだけのもので、値に意味はない。

~~~cpp
struct S
{
    void operator ++( int x )
    {
        // 値に意味はない。
        std::cout << x ;
    }
} ;

int main()
{
    S s ;
    // 演算子としての使用
    s++ ;
    // メンバー関数としての使用
    s.operator++(123) ;
}
~~~

値に意味はないが、演算子として使用した場合、値は`0`になるというどうでもいい仕様がある。メンバー関数として使用すると好きな値を渡せるというこれまたどうでもいい仕様がある。テストには出ないので覚える必要はない。

前置は自然な挙動のためにリファレンスを返すが、後置はリファレンスではなくコピーした値を返す。

~~~cpp
// 後置
IntLike IntLike::operator ++(int)
{
    // コピーを作る
    IntLike copy = *this ;
    // 演算子が呼ばれたオブジェクトをインクリメントする
    // 前置インクリメント演算子を呼んでいる
    ++*this ;
    // 値が変更されていないコピーを返す
    return copy ;
}
~~~

このように実装すると、後置として自然な挙動が実装できる。

`++*this`は後置インクリメント演算子が呼ばれたオブジェクトに対して前置インクリメント演算子を使用している。わかりにくければ前置インクリメントと同じ処理を書いてもいい。

~~~cpp
IntLike IntLike::operator ++(int)
{
    IntLike copy = *this ;
    // 同じ処理
    ++data ;
    return copy ;
}
~~~

`IntLike`のように簡単な処理であればこれでもいいが、もっと複雑な何行もある処理の場合は、すでに実装した前置インクリメントを呼び出した方が楽だ。コードの重複を省けるのでインクリメントの処理を変更するときに、2箇所に同じ変更をしなくても済む。

以上を踏まえて、`array_iterator`に後置インクリメント演算子を実装しよう。

~~~cpp
array_iterator array_iterator::operator ++(int)
{
    array_iterator copy = *this ;
    ++*this ;
    return copy ;
}
~~~

デクリメント演算子`operator --`の実装はインクリメント演算子`operator ++`と同じだ。ただ処理がインクリメントではなくデクリメントになっているだけだ。

~~~cpp
// 前置
array_iterator & array_iterator::operator --()
{
    -- i ;
    return *this ;
}
// 後置
array_iterator array_iterator::operator --(int)
{
    array_iterator copy = *this ;
    --*this ;
    return copy ;
}
~~~

ここまでくればイテレーターに必要な操作はあと1つ。比較だ。

イテレーターは同じ要素を指している場合に等しい。つまり、オペレーター`a`と`b`が同じ要素を指しているならば、`a == b`は`true`で`a != b`は`false`だ。違う要素を指しているならば`a == b`は`false`で`a != b`は`true`だ。

~~~cpp
int main()
{
    std::array<int, 5> a = {1,2,3,4,5} ;

    auto a = a.begin() ;
    auto b = a.begin() ;

    // true
    bool b1 = (a == b) ;
    // false
    bool b2 = (a != b) ;
    ++a ;
    // false
    bool b3 = (a == b) ;
    // true
    bool b4 = (a != b) ;
}
~~~

イテレーターは比較ができるので、イテレーターが終端に到達するまでループを回すことができる。

~~~cpp
int main()
{
    std::array<int,5> a = {1,2,3,4,5} ;

            // 変数宣言
    for (   auto iter = std::begin(a),
            last = std::end(a) ;
            // 終了条件
            iter != last ;
            // ループごとの処理
            ++iter )
    {
        std::cout << *iter ;
    }
}
~~~

イテレーターは比較ができるので、各種アルゴリズムに渡すことができる。

`array_iterator`の比較は、単にデータメンバー`i`の比較でよい。

~~~cpp
bool array_iterator::operator ==( array_iterator const & right )
{
    return i == right.i ;
}
bool array_iterator::operator !=( array_iterator const & right )
{
    return i != right.i ;
}
~~~

これで自作の`array`と`array_iterator`はアルゴリズムに渡せるようになった。

~~~cpp
int main()
{
    array<int, 5> a = {1,2,3,4,5} ;

    std::for_each( std::begin(a), std::end(a),
        [](auto x){ std::cout << x ; } ) ;
}
~~~

## 残りのイテレーターの実装

`std::array`や`std::vector`のイテレーターはとても柔軟にできている。

例えばイテレーター`i`の参照する要素を3つ進めたい場合を考えよう。

~~~cpp
++i ; // 1
++i ; // 2
++i ; // 3
~~~

これは非効率的だ。もっと効率的なイテレーターの進め方として、`operator +=`がある。

~~~cpp
i += 3 ;
~~~

`i += n`はイテレーター`i`を`n`回進める。

`operator +`もある。

~~~cpp
auto j = i + 3 ;
~~~

イテレーター`j`の値はイテレーター`i`を3つ進めた値になる。イテレーター`i`の値は変わらない。

実装は簡単だ。データメンバー`i`に対して同じ計算をする。

~~~cpp
template < typename Array >
struct array_iterator
{
    Array & a ;
    std::size_t i ;

    array_iterator & operator += ( std::size_t n )
    {
        i += n ;
        return *this ;
    }

    array_iterator operator + ( std::size_t n ) const
    {
        auto copy = *this ;
        copy += n ;
        return copy ;
    }
} ;
~~~

`operator +`はオペランドの値を変更しないので`const`にできる。

同様に、`operator -=`と`operator -`もある。上を参考に自分で実装してみよう。

`operator +`によって任意の`n`個先の要素を使うことができるようになったので、イテレーター`i`の`n`個先の要素を参照したければ、以下のように`*(i+n)`も書ける。

~~~cpp
int main()
{
    std::array<int, 5> a = {1,2,3,4,5} ;

    std::cout << a[3] ; // 4

    auto i = a.begin() ;

    std::cout << *(i + 3) ; // 4
}
~~~

カッコが必要なのは、演算子の評価順序の都合だ。`*i + 3`は`(*i) + 3`であり、`i`の指す要素に対して`+3`される。`*(i+3)`は`i`の指す要素の3つ先の要素の値を読む。

イテレーター`i`の`n`個先の要素を読み書きするのにいちいち`*(i+n)`と書くのは面倒なので、`std::array`や`std::vector`のイテレーターには`operator []`がある。これを使うと`i[n]`と書ける。

~~~cpp
int main()
{
    std::array<int, 5> a = {1,2,3,4,5} ;

    std::cout << a[3] ; // 4

    auto i = a.begin() ;

    std::cout << *(i + 3) ; // 4
}
~~~

`operator []`の実装は文字どおり`*(i+n)`と同じことをするだけでよい。

~~~cpp
template < typename Array >
struct array_iterator
{
    typename Array::reference
    operator [] ( std::size_t n ) const
    {
        return *( *this + n ) ;
    }

    // その他のメンバー
} ;
~~~

この`operator []`は、`array_iterator`のデータメンバーを変更しないので`const`修飾できる。

`*this`というのはこのイテレーターのオブジェクトなので、それに対してすでに実装済みの`operator +`を適用し、その結果に`operator *`を適用している。既存の実装を使わない場合、`return`文は以下のようになる。

~~~cpp
return a[i+n] ;
~~~

こちらの方が一見簡単なように見えるが、`operator +`や`operator *`の実装が複雑な場合、この方法では同じコードを複数の箇所に書かなければならず、コードを修正するときは同じ変更を複数の箇所に行わなければならない。すでに実装したメンバー関数は積極的に使って楽をしていこう。

イテレーターは大小比較ができる。

~~~cpp
a <  b ;
a <= b ;
a >  b ;
a >= b ;
~~~

イテレーターの大小はどういう意味を持つのか。`array`のようにイテレーターが線形に順序のある要素を参照している場合で、前の要素を参照しているイテレーターはあとの要素を参照しているイテレーターより小さい。

~~~cpp
int main()
{
    std::array<int, 5> a = {1,2,3,4,5} ;

    auto a = std::begin(a) ;
    auto b = a + 1 ;

    a <  b ; // true
    a <= b ; // true
    a >  b ; // false
    a >= b ; // false
}
~~~

自作の`array`の場合、単にデータメンバー`i`を比較する。

~~~cpp
template < typename Array >
struct array_iterator
{
    Array & a ;
    std::size_t i ;

    bool operator < ( array_iterator const & right ) const
    {
        return i < right.i ;
    }
}
~~~

残りの演算子も同様に実装できる。

## constなイテレーター: const_iterator

`std::array<T,N>`は通常のイテレーターである`std::array<T,N>::iterator`のほかに、`const`なイテレーターである`std::array<T,N>::const_iterator`を提供している。

~~~cpp
int main()
{
    std::array<int,5> a = {1,2,3,4,5} ;

    // iterator
    std::array<int,5>::iterator iter = a.begin() ;
    // const_iterator
    std::array<int,5>::const_iterator const_iter = a.cbegin() ;
}
~~~

`const_iterator`は`const iterator`ではない。`const_iterator`とはそれ自体が型名だ。`const`というのは型名を修飾する別の機能だ。

そのため、`const`の有無の2種類の状態と、`iterator`, `const_iterator`の2つの型を掛け合わせた、以下の型が存在する。

+ `iterator`
+ `const iterator`
+ `const_iterator`
+ `const const_iterator`

    

~~~cpp
int main()
{
    using Array = std::array<int,5> ;

    // iterator 
    Array::iterator i ;
    // const iterator
    const Array::iterator c_i ;
    // const_iterator
    Array::const_iterator ci ;
    // const const_iterator
    const Array::const_iterator c_ci ;
}
~~~

`const_iterator`は`iterator`とは別の型だ。自作の`array`に実装するならば以下のようになる。

~~~cpp
template < typename T, std::size_t N >
struct array
{
    using iterator          = array_iterator<array> ;
    using const_iterator   = array_const_iterator<array> ;
} ;
~~~

それぞれの型に対して、`const`キーワードを付けた型とそうでない型が存在する。

`const_iterator`を得る方法はいくつかある。

+ `const`な`array`の`begin`/`end`を呼び出す

~~~cpp
int main()
{
    // constなarray
    const std::array<int, 5> a = {1,2,3,4,5} ;

    // const_iterator
    auto i = a.begin() ;
}
~~~

+ `cbegin`/`cend`を呼び出す

~~~cpp
int main()
{
    std::array<int, 5> a = {1,2,3,4,5} ;

    // const_iterator
    auto i = a.cbegin() ;
}
~~~

+ `iterator`から`const_iterator`への変換

~~~cpp
int main()
{
    using Array = std::array<int,5> ;
    Array a = {1,2,3,4,5} ;

    // iterator
    Array::iterator i = a.begin() ;
    // iteratorからconst_iteratorへの変換
    Array::const_iterator j = i ;
}
~~~

`const`キーワードはすでに学んだように、オブジェクトの値を変更できないようにする機能だ。

なぜ`const_iterator`が存在するのか。`const iterator`ではだめなのか。その理由は、`const iterator`は値の変更ができないためだ。

~~~cpp
int main()
{
    using Array = std::array<int,5> ;
    Array a = {1,2,3,4,5} ;

    // const iterator
    const Array::iterator iter = a.begin() ;

    // エラー
    // constなオブジェクトは変更できない
    ++iter ;

    // Ok
    // iterは変更していない
    auto next_iter = iter + 1 ;
}
~~~

`const_iterator`ならばイテレーター自体の変更はできる。イテレーターが参照する要素の変更はできない。

~~~cpp
int main()
{
    using Array = std::array<int,5> ;
    Array a = {1,2,3,4,5} ;

    auto citer = a.cbegin() ;

    // OK
    // イテレーター自体の変更
    ++citer ;

    // OK
    // 要素を変更しない
    std::cout << *citer ;

    // エラー
    // 要素を変更している
    *citer = 0 ;
}
~~~

`const const_iterator`は`const_iterator`の`const`だ。`const const_iterator`は`const iterator`と同じく、イテレーター自体の変更ができない。


~~~cpp
int main()
{
    using Array = std::array<int,5> ;
    Array a = {1,2,3,4,5} ;

    // const const_iterator
    auto const iter = a.cbegin() ;

    // エラー
    // constなオブジェクトは変更できない
    ++iter ;

    // OK
    // iterは変更していない
    auto next_iter = iter + 1 ;
}
~~~

`auto const`もしくは`const auto`を使うと、変数の型を自動で推定してくれるが、`const`が付くようになる。

`const_iterator`はどう実装するのか。まず`array`にネストされた型名`const_iterator`を追加する。

~~~cpp
template < typename T, std::size_t N >
struct array
{
    using iterator = array_iterator<array> ;
    using const_iterator = array_const_iterator<array> ;
} ;
~~~

`array`に`const_iterator`を返す`cbegin/cend`と、`const array`のときに`const_iterator`を返す`begin`/`end`を追加する。

~~~cpp
template < typename T, std::size_t N >
struct array
{
    using iterator = array_iterator<array> ;
    using const_iterator = array_const_iterator<array> ;

    // const arrayのときにconst_iteratorを返す
    const_iterator begin() const
    { return const_iterator(*this, 0) ; }
    const_iterator end() const
    { return const_iterator(*this, N) ; }

    // 常にconst_iteratorを返す
    const_iterator cbegin() const
    { return const_iterator(*this, 0) ; }
    const_iterator cend() const
    { return const_iterator(*this, N) ; }

    // その他のメンバー
} ;
~~~

あとは`array_const_iterator<array>`を実装する。その実装は`array_iterator<array>`とほぼ同じだ。

~~~cpp
template < typename Array >
struct array_const_iterator
{
    Array const & a ;
    std::size_t i ;

    // コンストラクター
    array_const_iterator( Array const & a, std::size_t i )
        : a(a), i(i) { }
} ;
~~~

ただし、`const_iterator`は`iterator`から変換できるので、

~~~cpp
int main()
{
    using Array = std::array<int,5> ;
    Array a = {1,2,3,4,5} ;

    // iterator
    auto i = a.begin() ;

    // iteratorからconst_iteratorへの変換
    Array::const_iterator j = i ;
}
~~~

これに対応するために、`const_iterator`のコンストラクターは`iterator`から変換するためのコンストラクターも持つ。

~~~cpp
template < typename Array >
struct array_const_iterator
{
    Array const & a ;
    std::size_t i ;

    // array_iteratorからの変換コンストラクター
    array_const_iterator( typename array_iterator<Array>::iterator const & iter )
        : a( iter.a ), i( iter.i ) { }
} ;
~~~

残りのメンバー関数は`iterator`とほぼ同じだ。

例えば`operator ++`は完全に同じだ。

~~~cpp
// iterator版
array_iterator & array_iterator::operator++()
{
    ++i ;
    return *this ;
}
// const_iterator版
array_const_iterator & array_const_iterator::operator ++()
{
    ++i ;
    return *this ;
}
~~~

`operator *`や`operator []`は`const`なリファレンスを返す。

~~~cpp
typename Array::const_reference operator *() const
{
    return a[i] ;
}

typename Array::const_reference operator []( std::size_t i ) const
{
    return *(*this + i) ;
}
~~~

このために、`array`クラスにもネストされた型名`const_reference`を宣言しておく。

~~~cpp
template < typename T, std::size_t N >
struct array
{
    using const_reference = T const & ;
} ;
~~~

残りは`iterator`の実装を参考に読者が自分で実装してみよう。
