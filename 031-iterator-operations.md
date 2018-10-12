# イテレーター操作

## イテレーターとポインターの関係

arrayのイテレーターの実装を振り返ろう。前回実装したイテレーターは、リファレンスとインデックスを使うものだった。

~~~c++
template < Array >
struct array_iterator
{
    using reference = typename Array::reference ;

    Array & a ;
    std::size_t i ;

    array_iterator( Array * a, std::size_t i )
        a(a), i(i) { }

    reference operator *() const
    { return a[i] ; }

    array_iterator & operator ++()
    {
        ++i ;
        return *this ;
    }

    reference operator [] ( std::size_t n )
    { return a[i + n] ; }
} ;
~~~

このコードは単にポインターをクラスで実装しているだけではないだろうか。ならば、ポインターでイテレーターを実装することもできるのではないか。

~~~cpp
struct array_iterator
{
    using pointer = typename Array::pointer ;
    using reference = typename Array::reference ;
    pointer p ;

    array_iterator( pointer p )
        : p(p) { }

    reference operator *()
    { return *p ; }

    array_iterator & operator ++()
    {
        ++p ;
        return *this ;
    }

    reference operator[] ( std::size_t n )
    { return p[n] ; }
} ;
~~~

このコードは本当にポインターをクラスで実装しているだけだ。ならばイテレータークラスの代わりにポインターでもいいのではないだろうか。

~~~cpp
template < typename T, std::size_t N >
struct array
{

    T storage[N] ;

    // ポインター
    using iterator = T * ;

    iterator begin()
    { return &storage[0] ;  }

    iterator end()
    { return egin() + N ; }
} ;
~~~

これは動く。そして実際の`std::array`の実装もこうなっている。

実はイテレーターはポインターを参考にして作られた。インクリメントで次の要素を参照、`operator *`で参照先の要素にアクセスといった操作は、すべてポインターの操作をより抽象化したものだ。

ポインターの操作をすべてサポートしたイテレーターは、ランダムアクセスイテレーターと呼ばれる。

## イテレーターカテゴリー

イテレーターにはサポートしている操作に応じて以下のような種類が存在する。

+ 入力イテレーター(Input Iterator)
+ 出力イテレーター(Output Iterator)
+ 前方イテレーター(Forward Iterator)
+ 双方向イテレーター(Bidirectional Iterator)
+ ランダムアクセスイテレーター(Random Access Iterator)

イテレーターの関係は以下のようになっている。


~~~
TODO: 図示
ランダムアクセスイテレーター → 双方向イテレーター → 前方イテレーター → 入力イテレーター
                                                                     → 出力イテレーター
~~~

矢印`A → B`はAがBであることを意味している。

ランダムアクセスイテレーターは双方向イテレーターのすべての操作をサポートする。故にランダムアクセスイテレーターは双方向イテレーターである。

同様に、双方向イテレーターは前方イテレーターである。前方イテレーターは入力イテレーター/出力イテレーターである。

AはBであることに加えて、追加の操作をサポートしている。

### ランダムアクセスイテレーター

ランダムアクセスイテレーターは名前の通りランダムアクセスができる。イテレーターがn番目の要素を指すとき、n+m番目の要素を指すことができる。mは負数でもよい。

~~~cpp
template < typename RandomAccessIterator >
void f( RandomAccessIterator i, int n  )
{
    i + n ;
    i - n ;

    // i = i + n ; と同じ
    i += n ;
    // i = i - n ; と同じ
    i -= n ;
}
~~~

と書ける。nの型が符号付き整数型でよい。`i + (-5)`は`i-5`と同じ意味だ。


イテレーターiのn個先の要素を参照したい場合は、

~~~cpp
template < typename RandomAccessIterator >
void f( RandomAccessIterator i, std::size_t n )
{
    // *(i + n) ; と同じ
    i[n] ;
}
~~~

と書ける。この操作は双方向イテレーターにはできない。


### 双方向イテレーター

双方向イテレーターは名前の通り双方向のイテレーターの移動ができる。双方向というのはイテレーターが参照しているn番目の要素のn-1番目の要素とn+1番目の要素だ。

~~~c++
template < typename BidirectionalIterator >
void f( BidirectionalIterator i )
{
    ++i ; // i+1
    --i ; // i-1

    // r1, r2は変更する前のiの値
    auto r1 = i++ ;
    auto r2 = i-- ;
}
~~~

と書ける。この操作は前方イテレーターにはできない。


1個づつ移動できるのであれば、イテレーターをn個進めることもできそうなものだ。実際、双方向イテレーターを以下のようにしてn個進めることができる。

~~~cpp
template < typename BidirectionalIterator >
BidirectionalIterator
nth_next( BidirectionalIterator iter, std::size_t n )
{
    for ( std::size_t i = 0 ; i != n ; ++i )
        ++iter ;
    return iter ;
}
~~~

たしかにこれはできる。できるが、効率的ではない。双方向イテレーターが提供される場合というのは、ランダムアクセスが技術的に可能ではあるが非効率的な場合だ。具体的なデータ構造を出すと、例えばリンクリストがある。リンクリストに対するランダムアクセスは技術的に可能であるが非効率的だ。

### 前方イテレーター

前方イテレーターは前方にしか移動できない。イテレーターが0番目の要素を指しているならば1番目、1番目の要素を指しているならば2番めに移動できる。

~~~cpp
template < ForwardIterator >
void f( ForwardIterator i )
{
    ++i ;
}
~~~

前方イテレーターにはマルチパス保証がある。イテレーターの指す要素を動かす前のイテレーターの値を保持しておき、保持した値を動かしたとき、ふたつのイテレーターは同一になるという保証だ。

~~~cpp
template < typename ForwardIterator >
void f( ForwardIterator i )
{
    // 動かす前の値を保持
    auto prev = i ;
    // 次の要素を指す
    ++i ;
    // 動かす前の値も次の要素を指すようにする
    ++prev ;

    // true
    bool b = ( i == prev )

    // r1, r2は同じ要素を指す
    auto & r1 = *i ;
    auto & r2 = *prev ;
}
~~~

入力イテレーター、出力イテレーターにはこの保証がない。


