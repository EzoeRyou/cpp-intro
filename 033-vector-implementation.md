# vectorの実装 : 基礎

クラス、ポインター、メモリー確保を学んだので、とうとうコンテナーの中でも一番有名な`std::vector`を実装する用意ができた。しかしその前に、アロケーターについて学ぶ必要がある。

`std::vector`は`std::vector<T>`のように要素の型`T`を指定して使うので、以下のようになっていると思う読者もいるだろう。

~~~cpp
namespace std {
    template < typename T >
    struct vector ;
}
~~~

実際には以下のようになっている。

~~~cpp
namespace std {
    template < typename T, typename allocator = allocator<T> >
    struct vector ;
}
~~~

`std::allocator<T>`というのは標準ライブラリのアロケーターだ。アロケーターは生のメモリーの確保と解放をするライブラリだ。デフォルトで`std::allocator<T>`が渡されるので、普段ユーザーはアロケーターを意識することはない。

`std::vector`は`malloc`や`operator new`を直接使わずアロケーターを使ってメモリー確保を行う。

アロケーターはテンプレートパラメーターで指定できる。何らかの理由で独自のメモリー確保を行いたい場合、独自のアロケーターを実装してコンテナーに渡すことができる。

~~~cpp
// 独自のアロケーター
template < typename T >
struct custom_allocator
{
    // ...
} ;

template < typename T >
using custom_vector = std::vector< T, custom_allocator<T> > ;

int main()
{
    custom_vector<int> v ;
    // 独自のアロケーターを使ったメモリー確保
    v.push_back(0) ;
}
~~~

## `std::allocator<T>`の概要

`std::allocator<T>`は`T`型を構築できる生のメモリーを確保するために以下のようになっている。

~~~cpp
namespace std {
template<class T> class allocator {
    // ネストされた型名の宣言
    using value_type = T;
    using size_type = size_t;
    using difference_type = ptrdiff_t;
    using propagate_on_container_move_assignment = true_type;
    using is_always_equal = true_type;

    // コンストラクター
    // constexprはまだ学んでいない
    constexpr allocator() noexcept;
    constexpr allocator(const allocator&) noexcept;
    template<class U> constexpr allocator(const allocator<U>&) noexcept;
    ~ allocator();
    // コピー代入演算子
    allocator& operator=(const allocator&) = default;

    // ここが重要
    [[nodiscard]] T* allocate(size_t n);
    void deallocate(T* p, size_t n);
};
}
~~~

`constexpr`というキーワードがあるが、ここでは気にする必要はない。あとで学ぶ。

重要なのはメモリー確保をする`allocate`と、メモリー解放をする`deallocate`だ。

## `std::allocator<T>`の使い方

標準ライブラリのアロケーター、`std::allocator<T>`は、`T`型を構築できる生のメモリーの確保と解放をするライブラリだ。重要なメンバーは以下のとおり。

~~~cpp
// メモリー確保
[[nodiscard]] T* allocate(size_t n);
// メモリー解放
void deallocate(T* p, size_t n);
~~~

`allocate(n)`は`T`型の`n`個の配列を構築できるだけの生のメモリーを確保してその先頭へのポインターを返す。

`deallocate(p, n)`は`allocate(n)`で確保されたメモリーを解放する。

~~~cpp
int main()
{
    std::allocator<std::string> a ;
    // 生のメモリー確保
    // std::string [1]分のメモリーサイズ
    std::string * p = a.allocate(1) ;
    // メモリー解放
    a.deallocate( p, 1 ) ;
}
~~~

`allocate`には`[[nodiscard]]`という属性が付いている。これにより戻り値を無視すると警告が出る。

~~~cpp
int main()
{
    std::allocator<int> a ;
    // 警告、戻り値が無視されている
    a.allocate(1) ;

    // OK
    int * p = a.allocate(1) ;
}
~~~

確保されるのが生のメモリーだということに注意したい。実際に`T`型の値として使うには、`new`による構築が必要だ。

~~~cpp
int main()
{
    std::allocator<std::string> a ;
    // 生のメモリー確保
    // std::string [1]分のメモリーサイズ
    std::string * p = a.allocate(1) ;
    // 構築
    std::string * s = new(p) std::string("hello") ;
    // 明示的なデストラクター呼び出し
    s->~basic_string() ;
    // メモリー解放
    a.deallocate( p, 1 ) ;
}
~~~

このように書くのはとても面倒だ。特に`std::string`の明示的なデストラクター呼び出し`s->~basic_string`が面倒だ。なぜ`s->~string`ではだめなのか。

実は`std::string`は以下のようなクラステンプレートになっている。

~~~cpp
namespace std {
template <
    typename charT,
    typename traits     = char_traits<charT>,
    typename Allocator  = allocator<charT>>
class basic_string
{
    // デストラクター
    ~basic_string() ;
} ;

}
~~~

本当のクラス名は`basic_string`なのだ。

普段は使っている`std::string`というのは、以下のようなエイリアスだ。

~~~cpp
namespace std {
using string = basic_string<char> ;
}
~~~

明示的なデストラクター呼び出しにエイリアスは使えないので、本当のクラス名である`basic_string`を直接指定しなければならない。

この問題はテンプレートで解決できる。

~~~cpp
// 明示的なデストラクター呼び出しをする関数テンプレート
template < typename T >
void destroy_at( T * location )
{
    location->~T() ;
}
~~~

このようにテンプレートで書くことによって、クラス名を意識せずに破棄ができる。

~~~cpp
// 破棄
destroy_at( s ) ;
~~~

このようなコードを書くのは面倒なので、標準ライブラリには`std::destroy_at`がある。また、これらをひっくるめたアロケーターを使うためのライブラリである`allocator_traits`がある。

## `std::allocator_traits<Alloc>`

`std::allocator_traits<Alloc>`はアロケーター`Alloc`を簡単に使うためのライブラリだ。

`allocator_traits<Alloc>`はアロケーターの型`Alloc`を指定して使う。

~~~cpp
std::allocator<int> a ;
int * p = a.allocate(1) ;
~~~

と書く代わりに、

~~~cpp
std::allocator<int> a ;
int * p = std::allocator_traits< std::allocator<int> >::allocate( a, 1 ) ;
~~~

と書く。

これはとても使いづらいので、`allocator_traits`のエイリアスを書くとよい。

~~~cpp
std::allocator<int> a ;
// エイリアス
using traits = std::allocator_traits< std::allocator<int> > ;
int * p = traits::allocate( a, 1 ) ;
~~~

これもまだ書きにくいので、`decltype`を使う。`decltype(expr)`は式`expr`の型として使える機能だ。

~~~cpp
// int型
decltype(0) a ;
// double型
decltype(0.0) b ;
// int型
decltype( 1 + 1 ) c ;
// std::string型
decltype( "hello"s ) c ;
~~~

`decltype`を使うと以下のように書ける。

~~~cpp
std::allocator<int> a ;
// エイリアス
using traits = std::allocator_traits< decltype(a) > ;
int * p = traits::allocate( a, 1 ) ;
~~~

`allocator_traits`はアロケーターを使った生のメモリーの確保、解放と、そのメモリー上にオブジェクトを構築、破棄する機能を提供している。


~~~cpp
int main()
{
    std::allocator<std::string> a ;
    // allocator_traits型
    using traits = std::allocator_traits<decltype(a)> ;

    // 生のメモリー確保
    std::string * p = traits::allocate( a, 1 ) ;
    // 構築
    std::string * s = traits::construct( a, p, "hello") ;
    // 破棄
    traits::destroy( a, s ) ;
    // メモリー解放
    traits::deallocate( a, p, 1 ) ;
}
~~~

`T`型の`N`個の配列を構築するには、まず`N`個の生のメモリーを確保し、

~~~cpp
std::allocator<std::string> a ;
using traits = std::allocator_traits<decltype(a)> ;
std::string * p = traits::allocate( a, N ) ;
~~~

`N`回の構築を行う。

~~~cpp
for ( auto i = p, last = p + N ; i != last ; ++i )
{
    traits::construct( a, i, "hello" ) ;
}
~~~

破棄も`N`回行う。

~~~cpp
for ( auto i = p + N, first = p ; i != first ; --i )
{
    traits::destroy( a, i ) ;
}
~~~

生のメモリーを破棄する。

~~~cpp
traits::deallocate( a, p, N ) ;
~~~


## 簡易vectorの概要

準備はできた。簡易的な`vector`を実装していこう。以下が本書で実装する簡易`vector`だ。

~~~cpp
template < typename T, typename Allocator = std::allocator<T> >
class vector
{
private :
    // データメンバー
public :
    // value_typeなどネストされた型名
    using value_type = T ;
    // コンストラクター
    vector( std::size_t n = 0, Allocator a = Allocator() ) ;
    // デストラクター
    ~vector() ;
    // コピー
    vector( const vector & x ) ;
    vector & operator =( const vector & x ) ;

    // 要素アクセス
    void push_back( const T & x ) ;
    T & operator []( std::size_t i ) noexcept ;

    // イテレーターアクセス
    iterator begin() noexcept ;
    iterator end() noexcept ;
} ;
~~~

これだけの簡易`vector`でもかなり便利に使える。

例えば要素数を定めて配列のようにアクセスできる。

~~~cpp
vector v(100) ;
for ( auto i = 0 ; i != 100 ; ++i )
    v[i] = i ; 
~~~

イテレーターも使える。

~~~cpp
std::for_each( std::begin(v), std::end(v),
    []( auto x ) { std::cout << x ; } ) ;
~~~

要素を際限なく追加できる。

~~~cpp
std::copy(
    std::istream_iterator<int>(std::cin), std::istream_iterator<int>(), 
    std::back_inserter(v) ) ;
~~~

## classとアクセス指定

簡易`vector`の概要では、まだ学んでいない機能が使われていた。`class`と`public`と`private`だ。

C++のクラスにはアクセス指定がある。`public:`と`private:`だ。アクセス指定が書かれたあと、別のアクセス指定が現れるまでの間のメンバーは、アクセス指定の影響を受ける。

~~~cpp
struct C
{
public :
    // publicなメンバー
    int public_member1 ;
    int public_member2 ;
private :
    // privateなメンバー
    int private_member1 ;
    int private_member2 ;
public :
    // 再びpublicなメンバー
    int public_member3 ;    
} ;
~~~


`public`メンバーはクラスの外から使うことができる。

~~~cpp
struct C
{
public :
    int data_member ;
    void member_function() { }
} ;

int main()
{
    C c;
    // クラスの外から使う
    c.data_member = 0 ;
    c.member_function() ;
}
~~~

`private`メンバーはクラスの外から使うことができない。

~~~cpp
struct C
{
private :
    int data_member ;
    void member_function() ;
} ;

int main()
{
    C c ;
    // エラー
    c.data_member = 0 ;
    // エラー
    c.member_function() ;
}
~~~

コンストラクターもアクセス指定の対象になる。

~~~cpp
struct C
{
public :
    C(int) { }
private :
    C(double) { }
} ;

int main()
{
    // OK
    C pub(0) ;
    // エラー
    C pri(0.0) ;
}
~~~

この例では、`C::C(int)`は`public`メンバーなのでクラスの外から使えるが、`C::C(double)`は`private`メンバーなのでクラスの外からは使えない。

`private`メンバーはクラスの中から使うことができる。クラスの中であればどのアクセス指定のメンバーからでも使える。

~~~cpp
struct C
{
public :
    void f()
    {
        // ここはクラスの中
        data_member = 0 ;
        member_function() ;
    }

private :
    int data_member ;
    void member_function() { }
} ;
~~~

`private`メンバーの目的はクラスの外から使ってほしくないメンバーを守ることだ。例えば以下のようにコンストラクターで`new`してデストラクターで`delete`するようなクラスがあるとする。

~~~cpp
class dynamic_int
{
private :
    int * ptr ;
public :
    dynamic_int( int value = 0  )
        : ptr( new int(value) )
    { }
    ~dynamic_int()
    {
        delete ptr ;
    }
} ;
~~~

もし`dynamic_int::ptr`が`public`メンバーだった場合、以下のようなコードのコンパイルが通ってしまう。

~~~cpp
int main()
{
    dynamic_int i ;
    delete i.ptr ;
    int obj{} ;
    i.ptr = &obj ;
}
~~~

このプログラムが`dynamic_int`のデストラクターを呼ぶと、`main`関数のローカル変数のポインターに対して`delete`を呼び出してしまう。これは未定義の挙動となる。

外部から使われては困るメンバーを`private`メンバーにすることでこの問題はコンパイル時にエラーにでき、未然に回避できる。

クラスを定義するにはキーワードとして`struct`もしくは`class`を使う。

~~~cpp
struct  foo { } ;
class   bar { } ;
~~~

違いはデフォルトのアクセス指定だ。

`struct`はデフォルトで`public`となる。

~~~cpp
struct foo
{
    // publicメンバー
    int member ;
} ;
~~~

`class`はデフォルトで`private`となる。

~~~cpp
class bar
{
    // privateメンバー
    int member ;
} ;
~~~

`struct`と`class`の違いはデフォルトのアクセス指定だけだ。アクセス指定を明示的に書く場合、違いはなくなる。

## ネストされた型名

`std::vector`にはさまざまなネストされた型名がある。

~~~cpp
int main()
{
    using vec = std::vector<int> ;
    vec v = {1,2,3} ;

    vec::value_type val = v[0] ;
    vec::iterator i = v.begin() ;
}
~~~

自作の簡易`vector`で`std::vector`と同じようにネストされた型名を書いていこう。

要素型に関係するネストされた型名。

~~~cpp
template < typename T, typename Allocator = std::allocator<T> >
class vector
{
public :
    using value_type                = T ;
    using pointer                   = T *;
    using const_pointer             = const pointer;
    using reference                 = value_type & ;
    using const_reference           = const value_type & ;
} ;
~~~

本物の`std::vector`とは少し異なるが、ほぼ同じだ。要素型が`value_type`で、あとは要素型のポインター、`const`ポインター、リファレンス、`const`リファレンスがそれぞれエイリアス宣言される。

アロケーター型も`allocator_type`としてエイリアス宣言される。

~~~cpp
template < typename T, typename Allocator = std::allocator<T> >
class vector
{
public :
    using allocator_type = Allocator ;
} ;
~~~

`size_type`は要素数を表現する型だ。

~~~cpp
void f( std::vector<int> & v )
{
    std::vector<int>::size_type s = v.size() ;
}
~~~

通常`std::size_t`が使われる。

~~~cpp
size_type = std::size_t ;
~~~

`difference_type`はイテレーターの`difference_type`と同じだ。これはイテレーター間の距離を表現する型だ。

~~~cpp
void f( std::vector<int> & v )
{
    auto i = v.begin() ;
    auto j = i + 3 ;

    // iとjの距離
    std::vector<int>::difference_type d = j - i ;
}
~~~

通常`std::ptrdiff_t`が使われる。

~~~cpp
difference_type = std::ptrdiff_t ;
~~~

イテレーターのエイリアス。

~~~cpp
using iterator                  = pointer ;
using const_iterator            = const_pointer ;
using reverse_iterator          = std::reverse_iterator<iterator> ;
using const_reverse_iterator    = std::reverse_iterator<const_iterator> ;
~~~

今回実装する簡易`vector`では、ポインター型をイテレーター型として使う。`std::vector`の実装がこのようになっている保証はない。

`reverse_iterator`と`const_reverse_iterator`はリバースイテレーターだ。

## 簡易vectorのデータメンバー

簡易`vector`にはどのようなデータメンバーがあればいいのだろうか。以下の4つの情報を保持する必要がある。

1. 動的確保したストレージへのポインター
2. 現在有効な要素数
3. 動的確保したストレージのサイズ
4. アロケーター

これを素直に考えると、ポインター1つ、整数2つ、アロケーター1つの4つのデータメンバーになる。


~~~cpp
template < typename T, typename Allocator = std::allocator<T> >
class vector
{
private :
    // 動的確保したストレージへのポインター
    pointer first = nullptr ;
    // 現在有効な要素数
    size_type valid_size = nullptr ;
    // 動的確保したストレージのサイズ
    size_type allocated_size = nullptr ;
    // アロケーターの値
    allocator_type alloc ;
} ;
~~~

確かに`std::vector`はこのようなデータメンバーでも実装できる。しかし多くの実装では以下のようなポインター3つとアロケーター1つになっている。

~~~cpp
template < typename T, typename Allocator = std::allocator<T> >
class vector
{
private :
    // 先頭の要素へのポインター
    pointer first ;
    // 最後の要素の1つ前方のポインター
    pointer last ;
    // 確保したストレージの終端
    pointer reserved_last ;
    // アロケーターの値
    allocator_type alloc ;
} ;
~~~

このように実装すると、現在有効な要素数は`last - first`で得られる。確保したストレージのサイズは`reserved_last - first`だ。ポインターで持つことによってポインターが必要な場面でポインターと整数の演算を必要としない。

効率的な実装はC++が実行される環境によっても異なるので、すべての環境に最適な実装はない。

## 簡単なメンバー関数の実装

簡易`vector`の簡単なメンバー関数を実装していく。ここでのサンプルコードはすべて簡易`vector`のクラス定義の中に書いたかのように扱う。例えば

~~~cpp
void f() { }
~~~

とある場合、これは、

~~~cpp
template < typename T, typename Allocator = std::allocator<T> >
class vector
{
    // その他のメンバーすべて
public :
    void f() {}
} ;
~~~

のように書いたものとして考えよう。

### イテレーター

簡易`vector`は要素の集合を配列のように連続したストレージ上に構築された要素として保持する。したがってイテレーターは単にポインターを返すだけでよい。

まず通常のイテレーター

~~~cpp
iterator begin() noexcept
{ return first ; }
iterator end() noexcept
{ return last ; }
~~~

これは簡単だ。`iterator`型は実際には`T *`型へのエイリアスだ。このメンバー関数は例外を投げないので`noexcept`を指定する。

`vector`のオブジェクトが`const`の場合、`begin/end`は`const_iterator`が返る。

~~~cpp
int main()
{
    std::vector<int> v(1) ;
    // std::vector<int>::iterator
    auto i = v.begin() ;
    // OK、代入可能
    *i = 0 ;
    // constなvectorへのリファレンス
    auto const & cv = v ;
    // std::vector<int>::const_iterator
    auto ci = cv.begin() ;
    // エラー
    // const_iteratorを参照した先には代入できない
    *ci = 0 ;
}
~~~

これを実現するには、メンバー関数を`const`修飾する。

~~~cpp
struct Foo
{
    // 非const版
    void f() {}
    // const版
    void f() const { }
} ;

int main()
{
    // aは非constなオブジェクト
    Foo a ;
    // 非const版が呼ばれる
    a.f() ;
    // constなリファレンス
    const Foo & cref = a ;
    // const版が呼ばれる
    cref.f() ;
}
~~~

すでに学んだように`const`修飾は`this`ポインターを修飾する。オブジェクトの`const`性によって、適切な方のメンバー関数が呼ばれてくれる。

簡易`vector`での実装は単に`const`修飾するだけだ。

~~~cpp
iterator begin() const noexcept
{ return first ; }
iterator end() const noexcept
{ return last ; }
~~~

`const`ではない`vector`のオブジェクトから`const_iterator`がほしいときに、わざわざ`const`なリファレンスに変換するのは面倒なので、`const_reference`を返す`cbegin`/`cend`もある。

~~~cpp
int main()
{
    std::vector<int> v(1) ;
    // std::vector<int>::const_iterator
    auto i = v.cbegin() ;
}
~~~

この実装はメンバー関数名以外同じだ。

~~~cpp
const_iterator cbegin() const noexcept
{ return first ; }
const_iterator cend() const noexcept
{ return last ; }
~~~

`std::vector`にはリバースイテレーターを返すメンバー関数`rbegin`/`rend`と`crbegin`/`crend`がある。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;

    // イテレーター
    auto i = v.begin() ;
    *i ; // 1

    // リバースイテレーター
    auto r = v.rbegin() ;
    *r ; // 5
}
~~~

`begin`に対する`rbegin`/`rend`の実装は以下のようになる。`crbegin`/`crend`は自分で実装してみよう。

~~~cpp
reverse_iterator rbegin() noexcept
{ return reverse_iterator{ last } ; }
reverse_iterator rend() noexcept
{ return reverse_iterator{ first } ; }
~~~

`return`文で`T{e}`という形の明示的な型変換を使っている。これには理由がある。

C++では引数が1つしかないコンストラクターを`変換コンストラクター`として特別に扱う。

例えば以下は数値のように振る舞う`Number`クラスの例だ。

~~~cpp
class Number
{
    Number( int i ) ;
    Number( double d ) ;
    Number( std::string s ) ;
} ;
~~~

この`Number`は初期値をコンストラクターで取る。そのとき、`int`型、`double`型、はては文字列で数値を表現した`std::string`型まで取る。この3つのコンストラクターは引数が1つしかないため変換コンストラクターだ。

クラスは変換コンストラクターの引数の型から暗黙に型変換できる。

例えば`Number`クラスを引数に取る関数があると、

~~~cpp
void print_number( Number n ) ;
~~~

変換コンストラクターの型の値を渡せる。

~~~cpp
int main()
{
    // int型から変換
    print_number( 123 ) ;
    // double型から変換
    print_number( 3.14 ) ;
    // std::string型から変換
    print_number( "3.14"s ) ;
}
~~~

`int`や`double`や`std::string`は`Number`ではないが、変換コンストラクターによって暗黙に型変換される。

戻り値として返すときにも変換できる。

~~~cpp
// Number型のゼロを返す
Number zero()
{
    // int型から変換
    return 0 ;
}
~~~

しかし、場合によってはこのような暗黙の型変換を行いたくないこともある。そういう場合、コンストラクターに`explicit`キーワードを付けると、暗黙の型変換を禁止させることができる。

~~~cpp
class Number
{
    explicit Number( int i ) ;
    explicit Number( double d ) ;
    explicit Number( std::string s ) ;
} ;
~~~

実は`std::reverse_iterator<Iterator>`のコンストラクターにも`explicit`キーワードが付いている。

~~~cpp
namespace std {
template< typename  Iterator >
class reverse_iterator
{
    constexpr explicit reverse_iterator(Iterator x);
    // ...
} ;
}
~~~

`explicit`キーワード付きの変換コンストラクターを持つクラスは、暗黙の型変換ができないので、明示的に型変換しなければならない。


### 容量確認

`std::vector`には容量を確認するメンバー関数がある。

~~~cpp
int main()
{
    std::vector<int> v ;
    // true、要素数0
    bool a = v.empty() ;
    v.push_back(0) ;
    // false、要素数非ゼロ
    bool b = v.empty() ;
    // 1、現在の要素数
    auto s = v.size() ;
    // 実装依存、追加の動的メモリー確保をせずに格納できる要素の最大数
    auto c = v.capacity() ;
}
~~~

さっそく実装していこう。

`size`は要素数を返す。イテレーターの距離を求めればよい。

~~~cpp
size_type size() const noexcept
{
    return end() - begin() ;
}
~~~

イテレーターライブラリを使ってもよい。本物の`std::vector`では以下のように実装されている。


~~~cpp
size_type size() const noexcept
{
    return std::distance( begin(), end() ) ;
}
~~~

`empty`は空であれば`true`、そうでなければ`false`を返す。「空」というのは要素数がゼロという意味だ。

~~~cpp
bool empty() const noexcept
{
    return size() == 0 ;
}
~~~

しかし`size() == 0`というのは、`begin() == end()`ということだ。なぜならば要素数が0であれば、イテレーターのペアはどちらも終端のイテレーターを差しているからだ。本物の`std::vector`では以下のように実装されている。

~~~cpp
bool empty() const noexcept
{
    return begin() == end() ;
}
~~~

`capacity`は、追加の動的メモリー確保をせずに追加できる要素の最大数を返す。これを計算するには、動的確保したストレージの末尾の1つ次のポインターであるデータメンバーである`reserved_last`を使う。最初の要素へのポインターである`first`から`reserved_last`までの距離が答えだ。ポインターの距離はイテレーターと同じく引き算する。

~~~cpp
size_type capacity() const noexcept
{
    return reserved_last - first ;
}
~~~

### 要素アクセス

#### operator []

`std::vector`の`operator []`相当のものを簡易`vector`にも実装しよう。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;
    v[1] ; // 2
    v[3] ; // 4
}
~~~

`operator []`は非`const`版と`const`版の2種類がある。

~~~cpp
reference operator []( size_type i )
{ return first[i] ; }
const_reference operator []( size_type i ) const
{ return first[i] ; }
~~~

#### at

メンバー関数`at(i)`は`operator [](i)`と同じだが、範囲外のインデックスを指定した場合、`std::out_of_range`が例外として投げられる。

~~~cpp
int main()
{
    try {
        // 有効なインデックスはv[0]からv[4]まで
        std::vector<int> v = {1,2,3,4,5} ;
        v[0] = 0 ; // OK
        v[3] = 0 ; // OK
        v[5] = 0 ; // エラー
    } catch( std::out_of_range e )
    {
        std::cout << e.what() ;
    }
}
~~~

実装はインデックスを`size()`と比較して、範囲外であれば`std::out_of_range`を`throw`する。`operator []`と同じく、非`const`版と`const`版がある。

~~~cpp
reference at( size_type i )
{
    if ( i >= size() )
        throw std::out_of_range( "index is out of range." ) ;

    return first[i] ;
}
const_reference at( size_type i ) const
{
    if ( i >= size() )
        throw std::out_of_range( "index is out of range." ) ;

    return first[i] ;
}
~~~

#### front/back

`front()`は先頭要素へのリファレンスを返す。

`back()`は末尾の要素へのリファレンスを返す

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;
    v.front() ; // 1
    v.back() ; // 5
}
~~~

これにも`const`版と非`const`版がある。`vector`の`last`が最後の要素の次のポインターを指していることに注意。

~~~cpp
reference front()
{ return first ; }
const_reference front() const
{ return first ; }
reference back()
{ return last - 1 ; }
const_reference back() const
{ return last - 1 ; }
~~~

#### data

`data()`は先頭の要素へのポインターを返す。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3} ;
    int * ptr = v.data() ;
    *ptr ; // 1
}
~~~

実装は`first`を返すだけだ。

~~~cpp
pointer data() noexcept
{ return first ; }
const_pointer data() const noexcept
{ return first ; }
~~~
