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

### 入力イテレーター

入力イテレーターはイテレーターの比較、イテレーターの参照、イテレーターのインクリメントができる。


~~~cpp
template < typename InputIterator >
void f( InputIterator i, InputIterator j )
{
    // 比較
    bool b1 = (i == j) ;
    bool b2 = (i != j) ;

    // 参照
    *i ;
    // (*i).m と同じ
    i->m ;

    // インクリメント
    ++i ;
    i++ ;
}
~~~

入力イテレーターの参照は、読み込みことしか保証されていない。

~~~c++
template < typename InputIterator >
void f( InputIterator i )
{
    // OK
    auto value = *i ;
    // エラー
    *i = value ;
}
~~~

書き込みは出力イテレーターの仕事だ。

### 出力イテレーター

出力イテレーターはイテレーターのインクリメントと、イテレーターの参照への代入ができる。

~~~cpp
template < typename OutputIterator >
void f( OutputIterator i, typename OutputIterator::value_type v )
{
    // 参照への代入
    *i = v ;

    // インクリメント
    ++i ;
    i++ ;
}
~~~


出力イテレーターを参照した結果は定められていない。`void`かもしれない。したがって出力イテレーターの値を読むのは意味がない。

~~~cpp
template < typename OutputIterator >
void f( OutputIterator i )
{
    // 意味がない。
    auto value = *i ;
}
~~~

## iterator_traits

イテレーターカテゴリーやイテレーターの参照する値を見分けるためのライブラリとして、`iterator_traits<T>`がある。これは以下のようになっている。

~~~c++
namespace std {
template < typename T >
struct iterator
{
    using difference_type = ... ;
    using value_type = ... ;
    using pointer = ... ;
    using reference = ... ;
    using iterator_category = ... ;

} ;

}
~~~

`difference_type`はイテレーター同士の距離を指す数値だ。

~~~cpp
template < typename Iterator >
void f( Iterator i, Iterator j )
{
    // イテレーター同士の距離
    typename std::iterator_traits<Iterator>::difference_type diff = j - i ;
}
~~~

`value_type`はイテレーターの参照する値の型、`pointer`はそのポインター型、`reference`はそのリファレンス型だ。

~~~cpp
template < typename Iterator >
void f( Iterator i )
{
    // 値型
    typename std::iterator_traits<Iterator>::value_type v = *i ;
    // ポインター型 
    typename std::iterator_traits<Iterator>::pointer p = &v ;
    // リファレンス型
    typename std::iterator_traits<Iterator>::reference r = v ;
}
~~~

`iterator_category`はイテレーターカテゴリーを示す型で、以下のようになっている。

~~~c++
namespace std {
struct input_iterator_tag { };
struct output_iterator_tag { };
struct forward_iterator_tag: public input_iterator_tag { };
struct bidirectional_iterator_tag: public forward_iterator_tag { };
struct random_access_iterator_tag: public bidirectional_iterator_tag { };
}
~~~

`forward_iterator_tag`以降のコロン文字の後に続くコードについては、今は気にしなくてもよい。これは派生というまだ説明していないクラスの機能だ。

あるイテレーターがあるイテレーターカテゴリーを満たすかどうかを調べるには以下のようにする。

~~~cpp
template < typename tag, typename Iterator >
constexpr bool is_category_of( )
{
    using iter_tag = typename std::iterator_traits<Iterator>::iterator_category ;
    return std::is_base_of_v< tag, iter_tag> ;
}


int main()
{
    using iterator = std::vector<int>::iterator ;
    bool b = is_category_of< std::forward_iterator_tag, iterator >() ;
    // vecotrのイテレーターはランダムアクセスイテレーターなので前方イテレーターでもある
    std::cout << b ;
}
~~~

このコードはまだ学んでいないC++の機能をふんだんに使っているので、現時点で理解するのは難しい。


## イテレーターカテゴリーの実例

イテレーターカテゴリーについて学んだので、イテレーターカテゴリーの実例について見ていこう。

### 出力イテレーター

前方イテレーター以上のイテレーターカテゴリーを満たすイテレーターはすべて、出力イテレーターとして使える。例えばstd::arrayの内容をstd::vectorにコピーしたければ以下のように書ける。

~~~cpp
int main()
{
    std::array<int, 5> a = {1,2,3,4,5} ;
    std::vector<int> v(5) ;

    std::copy( std::begin(a) std::end(a), std::begin(v) ) ;
}
~~~

std::vectorのイテレーターは出力イテレーターとして振る舞う。

出力イテレーターの要件しか満たさないイテレーターは、例えば以下のようなものだ。



~~~cpp
struct cout_iterator
{
// --- ボイラープレートコード
    // 出力イテレーターでは使わないのでvoidでいい
    using difference_type = void ;
    using value_type = void ;
    using reference = void ;
    using pointer = void ;
    // イテレーターカテゴリーは出力イテレーター
    using iterator_category = std::output_iterator_tag ;
    // 何もしない
    // 自分自身を返すだけ
    cout_iterator & operator *() { return *this ; }
    cout_iterator & operator ++() { return *this ; }
    cout_iterator & operator ++(int) { return *this ; }
// --- ボイラープレートコード

    // ここが肝心
    template < typename T >
    cout_iterator & operator =( T const & x )
    {
        std::cout << x ;
        return *this ;
    }
} ;


int main()
{
    std::vector<int> v = {1,2,3,4,5} ;
    cout_iterator out ;

    std::copy( std::begin(v), std::end(v), out ) ;
}
~~~

`cout_iterator`は`*i = x;`と書いたときに、値xを`std::cout`で出力する。

cout_iteratorは出力イテレーターの要件を満たすので`std::copy`に渡せる。`std::copy`はイテレーターを順番に`*out = *i ;`のように実行するので、結果として値が全て`std::cout`で出力される。

`cout_iterator`はとても便利なので、標準ライブラリには`std::ostream_iterator<T>`がある。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;
    std::ostream_iterator<int> out(std::cout) ;
    std::copy( std::begin(v), std::end(v), out ) ;
}
~~~

`ostream_iterator`は出力ストリーム(ostream)に対するイテレーターだ。コンストラクターに出力先の出力ストリームを渡すことで値を出力先に出力してくれる。今回は`std::cout`だ。


上のような出力イテレーターが`operator =`で以下のようなことをしていたらどうだろう。

~~~c++
template < typename Container >
struct back_inserter ;
{
    back_inserter( Container & c )
        : c(c) { }

    // その他のボイラープレートコード

    
    back_inserter & operator =( const typename Container::value_type & value )
    {
        c.push_back(value) ;
    }

    Container & c ;
} ;

template < typename Container >
void f( Container const & c )
{
    // cの全要素をコピーしたい
    std:vector< typename Container::value_type > temp ;
    auto out = back_inserter(temp) ;
    std::copy( std::begin(c), std::end(c), out ) ;
}
~~~

このコードが何をするかわかるだろうか。コンテナー`c`の全要素を出力イテレーターで出力する。出力イテレーターは渡された値valueを`temp.push_back(value) ;`する。その結果、`temp`は`c`のすべての要素を保持していることになる。

C++の標準ライブラリには`std::back_inserter`がある。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;
    std::vector<int> temp ;
    auto out = std::back_inserter(temp) ;

    std::copy( std::begin(v), std::end(v), out ) ;
}
~~~

`std::back_inserter(c)`はコンテナー`c`に出力イテレーターとして渡された値を`puch_back`する。

ただし、`std::back_inserter`は古いライブラリなので、ここで示した方法とは少し違う実装がされている。

~~~c++
// 出力イテレーター
template < typename Container >
struct back_insert_iterator
{
    back_insert_iterator( Container & c )
        : c(&c) { }
    Container * c ;

    // その他のコード
} ;

// 出力イテレーターを返す関数
template < typename Container >
back_insert_iterator<Container> back_inserter( Container & c )
{
    return back_insert_iterator<Container>(c) ;
}
~~~

この理由は、C++17以前のC++ではクラスのコンストラクターからテンプレート実引数の推定ができなかったためだ。

~~~cpp
template < typename T >
void f( T ) { }

template < typename T >
struct S
{
    S( T ) { }
} ;

int main()
{
    // f<int>と推定
    f(0) ;

    // S<int>と推定
    S s(0) ;
}
~~~

C++17以前のC++では関数の実引数からテンプレート仮引数`T`の型を推定することはできたが、クラスのコンストラクターから推定することはできなかった。C++17以降は可能だ。

`std::cout`に出力したり、コンテナーに`push_back`する実装のイテレーターは、マルチパス保証を満たさない。実装を見ればわかるように、イテレーターをコピーして別々にインクリメントした結果のイテレーターのオブジェクトに対する操作は同一ではないからだ。

### 入力イテレーター

入力イテレーターの実例はどうか。

`std::cin`からT型を読み込む入力イテレーターの実装は以下のようになる。

~~~cpp
template < typename T >
struct cin_iterator
{
// --- ボイラープレートコード
    using difference_type = std::ptrdiff_t ;
    using value_type = T ;
    using reference = T & ;
    using pointer = T * ;
    // イテレーターカテゴリーは入力イテレーター
    using iterator_category = std::input_iterator_tag ;
// --- ボイラープレートコード

    // コンストラクター
    cin_iterator( bool fail = false )
        : fail(fail)
    { ++*this ; }    

    // キャッシュした値を返す
    const reference operator *() const
    { return value ; }

　  // 新しい値をキャッシュする
    cin_iterator & operator ++()
    {
        if ( !fail )
        {
            std::cin >> value ;
            fail = std::cin.fail() ;
        }
        return *this ;
    }

    // 後置インクリメント
    cin_iterator operator ++(int)
    {
        auto old = *this ;
        ++*this ;
        return old ;
    }

    // イテレーターの等価比較の状態
    bool fail ;
    // 値のキャッシュ
    value_type value ;
} ;

// 比較演算子
template < typename T >
bool operator ==( cin_iterator<T> const & l, cin_iterator<T> const & r )
{ return l.fail == r.fail ; }

template < typename T >
bool operator !=( cin_iterator<T> const & l, cin_iterator<T> const & r )
{ return !(l == r) ; }
~~~

以下のように使える。

~~~cpp
int main()
{
    cin_iterator<int> input, fail(true) ;
    std::vector<int> buffer ;

    std::copy( input, fail, std::back_inserter(buffer) ) ;
}
~~~

実装としては、まずボイラープレートコード

~~~c++
using difference_type = std::ptrdiff_t ;
using value_type = T ;
using reference = T & ;
using pointer = T * ;
// イテレーターカテゴリーは入力イテレーター
using iterator_category = std::input_iterator_tag ;
~~~

`difference_type`はイテレーターの距離を表現する型で、通常は`std::ptrdiff_t`という型が使われる。これはポインターの距離を表現する型だ。

`value_type`は参照している要素の型、`reference`と`pointer`は要素に対するリファレンスとポインターだ。

`iterator_category`は今回は入力イテレーターなので`std::input_iterator_tag`になる。

データメンバーが2つ。

~~~c++
bool fail ;
value_type value ;
~~~

`fail`は`std::cin`が失敗状態のときに`true`になる。通常は`false`だ。`std::cin`が失敗状態かどうかは、メンバー関数`fail`で確かめることができる。

~~~cpp
int main()
{
    bool b = std::cin.fail() ;
}
~~~

`std:cin`が失敗状態になる理由はいくつかあるが、EOFが入力された場合や、指定した型の値を読み込めなかった場合、例えばint型を読み込むのに入力が"abcd"のような文字列だった場合に`true`になる。

`value`は`std::cin`から読み込んだ値だ。

イテレーターから値を読み込むのは`operator *`の仕事だ。これは単にvalueを返す。

~~~c++
const reference operator *() const
{ return value ; }
~~~

入力イテレーターでは値の読み込みのみをサポートしている。書き込みはサポートしない。イテレーターiに対して`*i`は書けるが、`*i = x`とは書けない。

実際に`std::cin`から値を読み込むのは`operator ++`で行われる。

~~~c++
cin_iterator & operator ++()
{
    // 失敗状態でなければ
    if ( !fail )
    {
        // 値を読み込む
        std::cin >> value ;
        // 失敗状態かどうかも調べる
        fail = std::cin.fail() ;
    }
    return *this ;
}
~~~

まず`std::cin`が失敗状態でないかどうかを確認する。失敗状態となった`std::cin`からは読み込めないからだ。失敗状態でなければ値を読み込み、失敗状態かどうかを確認する。結果の値は`value`に、失敗状態かどうかは`fail`に保持される。

後置インクリメントは前置インクリメントを呼び出すだけの汎用的な実装だ。

~~~c++
cin_iterator operator ++(int)
{
    // 元の値をコピーし
    auto old = *this ;
    // 次の値を読み込み
    ++*this ;
    // 元の値を返す
    return old ;
}
~~~

コンストラクターにtrueを渡すと、イテレーターを最初から失敗状態にしておく

~~~c++
cin_iterator( bool fail = false )
    : fail(fail)
{ ++*this ; }    
~~~

コンストラクターは最初の値を読み込むために自分自身にインクリメントを呼び出す。

入力イテレーターは同値比較ができる。

~~~c++
template < typename T >
bool operator ==( cin_iterator<T> const & l, cin_iterator<T> const & r )
{ return l.fail == r.fail ; }

template < typename T >
bool operator !=( cin_iterator<T> const & l, cin_iterator<T> const & r )
{ return !(l == r) ; }
~~~

イテレーターが同値比較できると、イテレーターが終了条件に達したかどうかの判定ができる。

~~~cpp
template < typename InputIterator >
void print( InputIterator iter, InputIterator end_iter )
{
    // 終了条件に達するまで
    while ( iter != end_iter )
    {   // 値を標準出力する
        std::cout << *iter ;
        ++iter ;
    }
}
~~~

このような関数printに、vectorのbegin/endを渡すと、vectorの要素をすべて標準出力する。

~~~c++
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;
    print( std::begin(v), std::end(v) ) ;
}
~~~

`cin_iterator`を渡した場合、失敗状態になるまで標準出力する。

~~~c++
int main()
{
    cin_iterator iter, fail(true) ;
    print( iter, fail )
}
~~~

`cin_iterator`が比較するのは`std::cin`の失敗状態の有無だ。この比較によって、cin_iteratorで標準入力から失敗するまで値を読み込み続けることができる。

このようなイテレーターは標準に`std::istream_iterator<T>`として存在する。

~~~cpp
int main()
{
    std::istream_iterator<int> iter( std::cin ), end_iter ;
    std::vector<int> v ;

    std::copy( iter, end_iter, std::back_inserter(v) ) ;
}
~~~

標準ライブラリは読み込むストリームをコンストラクターで取る。何も指定しない場合は失敗状態になる。

### 前方イテレーター

前方イテレーター以上のイテレーターの例として、`iota_iterator<T>`を実装してみよう。
