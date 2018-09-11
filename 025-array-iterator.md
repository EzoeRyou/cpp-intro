# arrayのイテレーター

## イテレーターの中身

自作の`array`をイテレーターに対応させる前に、まず'std::array'のイテレーターについて一通り調べよう。

イテレーターは`std::begin/std::end`で取得する

~~~cpp
int main()
{
    std::array<int, 5> a = {1,2,3,4,5} ;

    auto first = std::begin(a) ;
    auto last = std::end(a) ;
}
~~~

`std::begin/std::end`は何をしているのか見てみよう。

~~~c++
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
    auto begin( C const & c )
    { return c.end() ;}
}
~~~

なんと、単に引数に対してメンバー関数`begin/end`を呼び出してその結果を返しているだけだ。

早速確かめてみよう。

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

~~~c++
// イテレーターを表現するクラス
struct array_iterator { }

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

イテレーターに対応するには、おおむねこのような実装になるとみていいだろう。おそらく細かい部分で微調整が必要になるが、今はこれでよしとしよう。ではイテレーターが具体的に何をするかを見ていこう。

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

これまでに作った自作の`array`で最初の要素にアクセスする方法を考えてみよう

~~~c++
array<int, 5> a = {1,2,3,4,5} ;
int x = a[0] ; // 1
a[0] = 0 ;
~~~

このことから考えると、先頭要素を指すイテレーターは`operator *`をオーバーロードして先頭要素をリファレンスで返せば良い。

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

`array_iterator`を様々な`array`を扱うにはどうすればいいのか。テンプレートを使う。

~~~c++
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

しかしなぜかエラーだとコンパイラーに怒られる。この理由を説明するのはとても難しい。気になる読者は近所のC++グルに教えを乞おう。ここでは答えだけを教える。

`T::Y`において、`T`がテンプレート引数に依存する名前で、`Y`がネストされた型名の場合、`typename`キーワードをつけなければならない。

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

さしあたって必要なのは`Array::reference`の前に`typename`キーワードをつけることだ。

~~~c++
typename Array::reference
operator * ()
{
    return a[0] ;
}
~~~

どうやら最初の要素を読み書きするイテレーターはできたようだ。`array`側も実装して試してみよう。

array側の実装にはまだ現時点では完全に理解できない黒魔術`*this`が必要だ。

~~~cp
template < typename T, std::size_t N >
struct array
{
    T storage[N] ;
    using iterator = array_iterator_begin<array_int_10> ;
    iterator begin()
    { return *this ; }
}
~~~

`*this`はメンバー関数を読んだクラスのオブジェクトへのリファレンスだ。

~~~cpp
struct S
{
    int data {} ;
    S & THIS() { return *this ; } 
} ;

int main()
{
    S s ;
    
    s.THIS().data = 123 ;
}
~~~

`*this`を理解するためには、これまたポインターの理解が必要になるが、それは次の章で学ぶ。

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

自作の`array_iterator`で書いてみよう。


~~~c++
template < typename Array >
struct array_iterator
{
    Array & a ;

    array_iterator_begin( Array & a )
        : a( a ) { }

    // 次の要素を指す
    array_iterator & operator ++() ;
    // 前の要素を指す
    array_iterator & operator --() ;
    
    //いま参照している要素へのリファレンスを返す
    Array::reference operator *() ;
} ;
~~~

イテレーターの実装で先頭の要素を参照するのは`a[0]`だった。その次の要素を参照するには`a[1]`だ。その次の要素は`a[2]`となり、その前の要素は`a[1]`だ。

~~~c++
array<int, 5> a = {1,2,3,4,5} ;

auto iter = a.begin() ; // 最初の要素
*iter ; // 1
++iter ; // 次の要素
*iter ; // 2
--iter ; // 前の要素、つまり最初の要素
*iter ; // 1
~~~

では最初の要素の前の要素や、最後の要素の次の要素を参照しようとするとどうなるのか。

~~~c++
auto first = a.begin() ;
--first ;
*first ; // 最初の前の要素？
auto last = a.end() ;
++last ; //
*last ; // 最後の次の要素？
~~~

これはエラーになる。このようなエラーを起こさないように務めるのはユーザーの責任で、イテレーター実装者の責任ではない。しかし、必要であればイテレーターの実装者はこのようなエラーを防ぐような実装もできる。それは後の章で学ぶ。ここでは、こういう場合が起こることは考えなくてもよいとしよう。

これを考えていくと、イテレーターの実装をどうすればいいのかがわかってくる。

array_iteratorの`operator *`は`a[i]`を返す。

~~~c++
typename Array::reference array_iterator::operator *()
{
    return a[i] ;
}
~~~

`i`は`std::size_t`型のデータメンバーで、イテレーターが現在参照している`i`番目の要素を記録している。




