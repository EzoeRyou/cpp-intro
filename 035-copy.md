# コピー

クラスにコピーを正しく実装するためには、まずコピーが何であるかを理解しなければならない。

## 普通のコピー

C++を書くユーザーは、クラス型のオブジェクトを使うとき、クラスが普通の型(regular type)のように振る舞うことを期待している。この普通にはさまざまな意味がある。


`int`型の変数をコピーするとき、コピー先の変数はコピー元の変数と等しくなる。

~~~cpp
int source = 42 ;
int destination = source ;
~~~

この例では変数`destination`は変数`source`と等しくなる。`source == destination`は`true`となり、`destination`の値は`42`になる。

コピーの結果、コピー先の変数は値が書き換えられる。コピー元の変数は変わらない。上の例で、変数`source`が勝手に別の値になることは「普通」はない。

我々が普通にコピーと認識しているものは、C++の文法的にはコピー構築とコピー代入に分けることができる。

~~~cpp
T source ;
// コピー構築
T a = source ;
T b(source) ;
T c{source}

T d ;
// コピー代入
d = source ;
~~~

ユーザーは普通、コピー構築とコピー代入のコピーが両方とも同じ挙動をすると期待している。コピー構築とコピー代入のどちらか片方が使えるならば、もう片方も使えるべきで、そのコピーの挙動は同じであるべきだ。

コピー代入にはコピーの普通に加えて、さらにユーザーが代入に期待する普通がある。

代入式を評価した結果は、代入されるオブジェクトへの`lvalue`リファレンスになる。

~~~cpp
int main()
{
    int x, y, z ;
    // x, y, zに0を代入
    x = y = z = 0 ;
}
~~~

これはまず`z = 0`が評価される。変数`z`の値は`0`になり、式を評価した結果の値は`z`への`lvalue`リファレンスだ。なので、`y = z = 0`というのは、`y = (z=0)`となる。`z=0`については`z`であるので、`y = z`となる。ここでの`z`は`0`を代入されたあとの`z`なので、値は`0`だ。その結果変数`y`の値は`0`になる。変数`x`の場合も同様だ。

以下のような例も見てみよう。

~~~cpp
int main()
{
    int x ;
    (x = 0) = 1 ;
}
~~~

これは`(x = 0)`の結果に`1`を代入している。`x=0`の結果は`x`なので、`x`には`0`が代入されたあとに`1`が代入される。結果として`x`の値は`1`になる。

## コピーコンストラクター

コピー構築の場合、コピーコンストラクターが呼ばれる。

~~~cpp
struct Value
{
    // コピーコンストラクター
    Value( const Value & source )
    { }
} ;

int main()
{
    Value source ;
    // コピーコンストラクターを呼ぶ
    Value b = source ;
    Value c(source) ;
    Value d{source} ;
}
~~~

コピーコンストラクターは`クラス型へのlvalueリファレンス型`を引数に取る`コンストラクター`だ。

~~~cpp
struct X
{
    X( const X & source ) { }
} ;
~~~

引数は通常は`constなlvalueリファレンス型`だが、`非constなlvalueリファレンス型`を引数に取るコンストラクターも`コピーコンストラクター`となる。

~~~cpp
struct X
{
    X( X & source ) { }
} ;
~~~

ただし、非`const`な`lvalue`リファレンス型を引数に取るコピーコンストラクターは通常は使わない。なぜならば、コピーの結果、コピー元が書き換えられるような挙動は不自然だからだ。

~~~cpp
struct funny_number
{
    int n ;
    funny_number( int n = 0 )
        : n(n) { }
    funny_number( funny_number & source )
        : n( source.n )
    {
        source.n = 0 ;
    }
} ;

int main()
{
    funny_number a = 1 ;
    // コピー
    funny_number b = a ;
    // a == 0
    // b == 1
}
~~~

このおかしな`funny_number`のコピーコンストラクターはコピー元を0に書き換えてしまう。このコードは完全に合法なC++のコードだが、このようにコピーコンストラクターを実装するのはおすすめできない。なぜならば、ユーザーはコピーについて上で示したような意味を普通だと想定しているため、普通から外れるような型はユーザーのあてが外れてしまうからだ。

## コピー代入演算子

コピー代入演算子は`クラス型へのlvalueリファレンス型`を引数に取る`operator =`のオーバーロードだ。

~~~cpp
struct X
{
    X & operator = ( const X & source )
    {
        return *this ;
    }
} ;
~~~

コピーコンストラクターと同じく、コピー代入演算子の引数は非`const`な`lvalue`リファレンスでもよい。ただし、ユーザーの期待する普通にはそぐわない結果になる。

コピー代入演算子の戻り値の型はクラス型への非`const`な`lvalue`リファレンスでなくてもよい。ただし、その場合もユーザーの期待にそぐわないことになる。

~~~cpp
struct X
{
    void operator = ( const X & source ) { }
} ;

int main()
{
    X a, b, c ;
    // OK
    a = b ;
    // エラー
    a = b = c ;
}
~~~

`a = b = c`は、クラス`X`のコピー代入演算子の戻り値の型が`void`なので動かない。ユーザーは普通、これが動くことを期待している。ユーザーの普通の期待に答えるためにはクラスへの非`const`な`lvalue`リファレンスを返さなければならない。

## コピーの挙動

クラスのコピーは何をすればいいのだろうか。クラスにコピーコンストラクターとコピー代入演算子を書かない場合、デフォルトのコピーコンストラクター、コピー代入演算子が生成される。

デフォルトのコピーは、クラスのデータメンバーをそれぞれコピーする。

~~~cpp
struct Point
{
    int x ;
    int y ;
    int z ;
} ;

int main()
{
    Point a{1,2,3} ;
    Point b = a ;
    Point c ;
    c = a ;
}
~~~

上記のコードは、以下のように書いたのと同じだ。

~~~cpp
Point b{ a.x, a.y, a.z } ;
Point c ;
c.x = a.x ;
c.y = a.y ;
c.z = a.z ;
~~~

つまり、以下のようなコピーコンストラクターとコピー代入演算子を書いたのと同じだ。

~~~cpp
struct Point
{
    int x ;
    int y ;
    int z ;

    Point( const Point & r )
        : x(r.x), y(r.y), z(r.z)
    { }

    Point & operator = ( const Point & r )
    {
        x = r.x ;
        y = r.y ;
        z = r.z ;
    }
} ;
~~~

では`std::vector`のコピーはどうなるだろうか。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;
    std::vector<int> w = v ;
    // wは{1,2,3,4,5}
}
~~~

`std::vector`をコピーした場合、その値がコピーされる。

自作の`vector`のコピーはどのように実装すればいいだろうか。デフォルトのコピーに任せてもいいのだろうか。デフォルトのコピーを使う場合、コピーコンストラクターは以下のように書いたものと同じだ。

~~~cpp
template < typename T, typename Allocator = std::allocator<T> >
class vector
{
    // ... その他のメンバー
private :
    pointer first = nullptr ;
    pointer last = nullptr ;
    pointer reserved_last = nullptr ;
    allocator_type alloc ;

public :
    // コピーコンストラクター
    vector( const vector & r )
        : first( r.first ), last( r.last ),
        , reserved_last( r.reserved_last ),
        , alloc( r.alloc )
    { }
} ;
~~~

これは問題だ。以下のコードを考える。

~~~cpp
int main()
{
    vector<int> v{1} ;
    vector<int> w = v ;
    // wのデストラクターが呼ばれる
    // vのデストラクターが呼ばれる
}
~~~

`w = v`で、`v`のデータメンバーの値がそれぞれ`w`のデータメンバーにコピーされる。

`main`関数を抜けるので、構築の逆順に変数が破棄される。この場合`w`が先に破棄される。破棄にあたっては`w`のデストラクターが呼ばれる。

この場合、`w`のデストラクターは、

1. ポインター`first`が指すオブジェクトのデストラクターを呼び出す
2. ポインター`first`の指す生のストレージを解放

する。

次に`v`が破棄される。`v`のデストラクターは`w`のデストラクターとまったく同じことをする。ただし、ポインター`first`の指すオブジェクトはすでにデストラクターが呼び出されているし、ポインター`first`の指す生のストレージも解放されている。

すでにデストラクターを呼び出したオブジェクトに対してもう一度デストラクターを呼び出した場合の挙動は未定義だ。すでに解放したストレージを指すポインターに対してもう一度ストレージの解放した場合の挙動は未定義だ。したがって、このプログラムの挙動は未定義となる。

コピー代入も同じ問題を抱えている。しかも別の問題まである。例えば以下の例を見てみよう。

~~~cpp
int main()
{
    vector<int> v = {1,2,3} ;
    vector<int> w = {4,5,6} ;
    w = v ;
}
~~~

変数`w`はまず要素を保持するためのメモリーを動的確保する。その後、`w`に`v`が代入されるわけだが、このとき`w`が動的確保したメモリーを指すポインターの値が上書きされてしまう。`w`が破棄されるとき、`w`がもともと持っていた要素は破棄されなくなり、ストレージも解放されなくなる。


## 所有するクラス

この問題は「所有」という考え方を使うと解決できる。

問題を簡単にするために、以下のようなクラスを考えよう。

~~~cpp
template < typename T >
class own
{
private :
    T * ptr ;
public :
    own( )
        : ptr( new T )
    { }
    ~own()
    { delete ptr ; }

    T * get() const { return ptr ; }

} ;
~~~

このクラスはコンストラクターでテンプレートパラメーター`T`型のオブジェクトを動的メモリー確保をし、デストラクターでメモリーの解放をする。

コピーコンストラクターとコピー代入演算子は定義していないので、デフォルトのコピーが使われる。

デフォルトのコピーを使うことを明示する方法もある。`= default`を使うのだ。

~~~cpp
class own
{
    // その他のメンバー
public :
    own( const own & ) = default ;
    own & operator =( const own & ) = default ;
}
~~~

コピーコンストラクター、コピー代入演算子となる宣言に`= default`を使うと、デフォルトのコピー実装を使うということを明示的に宣言したことになる。この文法はややわかりにくいが、こういうものだと思って覚えておこう。

このようなクラスを「デフォルトのコピー」でコピーしたとき、コピーされるのはポインターの値だ。ポインターが参照する先は同じだ。

この場合、クラスはポインターの参照するオブジェクトを所有していると考えることができる。ポインターの値をコピーするということは、所有権を共有するということだ。所有権を共有していることを考慮しないまま、クラスのオブジェクトが破棄されたときにポインターの参照先まで破棄してしまうと、所有したつもりになっているクラスのオブジェクトが出来上がってしまう。

普通の型のように振る舞うコピーを実装するには、コピーの際に所有権を共有しない実装をする。具体的には、コピーのときに新しく動的メモリー確保し、値をコピーするのだ。

コピーコンストラクターは以下のようになる。

~~~cpp
own( const own & r )
    : ptr( new T( *r.ptr ) )
{ }
~~~

今回の場合、コピー代入演算子で動的メモリー確保をする必要はない。なぜならば、コピー代入演算子が呼ばれたということは、いずれかのコンストラクターがすでに呼ばれていて、動的メモリー確保はされているからだ。

~~~cpp
own & operator = ( const own & r )
{
    *ptr = *r.ptr ;
    return *this ;
}
~~~

このコードには少し問題がある。変数は自分自身に代入ができるのだ。

~~~cpp
// 1GBもの巨大なサイズのクラス
struct one_giga_byte { std::byte storage[1'000'000'000] ; }

int main()
{
    own<one_giga_byte> x ;
    // 1GBのコピーが発生
    x = x ;
}
~~~

自分自身に代入というのは少し奇妙だが、これはC++では普通のことだ。クラス型はできるだけ普通に振る舞うべきだ。

普通のクラスは、自分自身への代入で特に何かをする必要はない。したがって、単に自分自身への代入が行われたことを判定したならば、コピーを行わないという処理でいい。

自分自身への代入を判定するには、コピー代入演算子の引数のリファレンスが指すオブジェクトのポインターが`this`ポインターと等しいかどうかを調べればよい。

~~~cpp
own & operator = ( const own & r )
{
    // 自分自身への代入でなければ
    if ( this != &r )
    {
        // コピー処理
        *ptr = *r.ptr ;
    }
    return *this ;
}
~~~

## `own<U>`から`own<T>`への変換

C++では、`int`型から`long`型に、変換することができる。

~~~cpp
int main()
{
    int a = 123 ;
    // 変換してコピー
    long b = a ;
}
~~~

これは厳密には変換であってコピーではないのだが、コピーによく似ている。

これと同じことを、`own<T>`でやるにはどうすればいいのだろうか。つまり`own<int>`から`own<long>`への変換だ。

~~~cpp
int main()
{
    own<int> a ;
    *a.get() = 123 ;
    own<long> b = a ;
    *b.get() ; // long型の123
}
~~~

単に`own<int>`からの変換だけであれば、`own<int>`型から変換するコンストラクターを書けばよい。

~~~cpp
template < typename T >
class own
{
private :
    T * ptr ;
public :
    // 変換コンストラクター
    own( const own<int> & r )
        : ptr( new T(*r.get()) )
    { }
    // ...
}
~~~

このような自分自身以外の型の引数を1つだけ取るコンストラクターのことを、`変換コンストラクター`という。

しかしこれでは`own<int>`からの変換にしか対応できない。しかも`int`型から変換できない型を使うとエラーとなる。

~~~cpp
// int型から変換できない型
struct I_hate_int
{
    // デフォルトのデフォルトコンストラクター
    I_hate_int() = default ;
    // intからの変換コンストラクター
    I_hate_int(int) = delete ;
}

int main()
{
    // エラー
    own<I_hate_int> a ;
}
~~~

関数の宣言に`= delete`を書くと、その関数を消すことができる。「消す」というのは、その関数を使った時点でプログラムがコンパイルエラーになるという意味だ。

この問題を解決するにはテンプレートを使う。


~~~cpp
template < typename T >
class own
{
private :
    T * ptr ;
public :
    template < typename U >
    own( const own<U> & r )
        : ptr( new T(*r.get()) )
    { }
    // ...
}
~~~

こうすると任意の型`T, U`について、`U`型から`T`型に変換構築できるのであれば、`own<U>`から`own<T>`への変換構築ができる。

しかし、上のクラス`I_hate_int`型は任意の型から変換できないので、この変換コンストラクターテンプレートの存在は問題にならならないのだろうか。心配御無用。テンプレートは具体的なテンプレート実引数が与えられて初めてコードが生成される。実際に使わない限りは問題にならない。

~~~cpp
int main()
{
    // 問題なし
    own<I_hate_int> a ;
    // 問題なし
    own<int> b ;

    // エラー
    // 実際に使われた
    a = b ;
}
~~~


## もう少し複雑な所有するクラス

同じく所有するクラスだが、もう少し複雑な例を考えよう。

~~~cpp
template < typename T >
class dynamic_array
{
private :
    T * first ;
    T * last ;
public :
    dynamic_array( std::size_t size = 0 )
        : first( new T[size]), last( first + size )
    { }
    ~dynamic_array()
    { delete[] first ; }

    T & operator [] ( std::size_t i )  const noexcept
    { return first[i] ; }
    std::size_t size() const noexcept
    { return last - first ; }
    T * begin() const noexcept
    { return first ; }
    T * end() const noexcept
    { return last ; }
} ;

int main()
{
    dynamic_array<int> a(10) ;
    a[0] = 1 ;
    a[1] = 2 ;
}
~~~

この`dynamic_array<T>`は`T`型の動的な配列クラスだ。配列のサイズは実行時に指定できる。

このようなクラスのコピーはどうなるだろうか。

コピーコンストラクターは簡単だ。コピー元と同じサイズの配列を動的確保し、要素をコピーすればいいだけだ。

~~~cpp
dynamic_array( const dynamic_array & r )
    : first( new T[r.size()]), last( first + r.size() )
{
    std::copy( r.begin(), r.end(), begin() ) ;
}
~~~

コピー代入演算子でも、場合によっては動的メモリー確保が必要になる。現在所有しているメモリーとは異なるサイズのオブジェクトからコピーする場合だ。

~~~cpp
int main()
{
    dynamic_array<int> a(5) ;
    dynamic_array<int> b(10) ;
    // aの所有するメモリーはサイズ不足
    a = b ;
}
~~~

コピー元よりコピー先の方がメモリーが多い場合、つまり`b = a`の場合は動的メモリー確保をしないという実装もできるが、その場合実際に確保したメモリーサイズと、クラスが認識しているメモリーサイズが異なることになる。今回はサイズが違う場合は必ず動的メモリー確保をすることにしよう。

~~~cpp
dynamic_array & operator = ( const dynamic_array & r )
{
    // 自分自身への代入ではない場合
    // かつ
    // サイズが違う場合
    if ( this != &r && size() != r.size() )
    {
        // コピー処理
    }
    return *this ;
}
~~~

`new`したメモリーは`delete`しなければならない。そこで、コピー代入演算子はまず自分の所有するメモリーを`delete`してから`new`し、値をコピーすることになる。

~~~cpp
dynamic_array & operator = ( const dynamic_array & r )
{
    if ( this != &r && size() != r.size() )
    {
        // コピー先が所有しているメモリーの解放
        delete first ;
        // コピー元と同じサイズの動的メモリー確保
        first = new T[r.size()] ;
        last = first + r.size() ;
        // コピー元の値をコピー
        std::copy( r.begin(), r.end(), begin() ) ;
    }
    return *this ;
}
~~~

## vectorのコピー

自作の`vector`のコピーを実装していこう。

### コピーコンストラクター

`std::vector`では、アロケーターのコピーだけがちょっと特殊になっている。コンテナーのコピーにあたってアロケーターをコピーすべきかどうかは、アロケーターの実装が選べるようになっている。このために、`std::allocator_traits<allocator_type>::select_on_container_copy_construction(alloc)`を呼び出し、その戻り値でアロケーターを初期化する。`std::allocator_traits<allocator_type>`という型については、すでに`traits`というエイリアスを宣言しているので、以下のようにする。

~~~cpp
vector( const vector & r )
    // アロケーターのコピー
    : alloc( traits::select_on_container_copy_construction(r.alloc) )
{
    // コピー処理
}
~~~

残りのコピー処理を実装していこう。

1. コピー元の要素数を保持できるだけのストレージを確保
2. コピー元の要素をコピー構築

~~~cpp
vector( const vector & r )
    : alloc( traits::select_on_container_copy_construction( r.alloc ) )
{
    // コピー元の要素数を保持できるだけのストレージを確保
    reserve( r.size() ) ;
    // コピー元の要素をコピー構築
    // destはコピー先
    // [src, last)はコピー元
    for (   auto dest = first, src = r.begin(), last = r.end() ;
            src != last ; ++dest, ++src )
    {
        construct( dest, *src ) ;
    }
    last = first + r.size() ;
}
~~~

### コピー代入演算子

コピー代入演算子ではアロケーターのコピーをする必要はない。ただし自分自身への代入への対応が必要だ。そして、コピー代入のコピー先とコピー元の要素数が同じであるとは限らない。

コピー先とコピー元の要素数が同じである場合、単に要素にコピー代入をすればよい。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3} ;
    std::vector<int> w(3) ;
    w = v ;
}
~~~

これは単に以下のようなコードを実行したものと同じになる。

~~~cpp
w[0] = v[0] ;
w[1] = v[1] ;
w[2] = v[2] ;
~~~

要素数が違う場合、2通りの場合がある。

コピー先がコピー元の要素数以上の予約数を持っている場合、有効な要素についてはコピー代入され、それ以降の要素はコピー構築される。

~~~cpp
int main()
{
    // 要素数5
    std::vector<int> v = {1,2,3,4,5} ;
    // 要素数3
    std::vector<int> w(3) ;
    // 予約数5
    w.reserve(5) ;
    w = v ;
}
~~~

この場合、`w[0], w[1], w[2]`についてはそれぞれ`v[0], v[1], v[2]`からコピー代入される。`w[3],w[4]`はそれぞれ`v[3], v[4]`からコピー構築される。

コピー先がコピー元の要素数以上の予約数を持っていない場合、コピー元の要素数以上のストレージが予約される。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;
    // 予約数2だとする。
    std::vector<int> w(2) ;
    // 古いストレージが破棄され
    // 新しいストレージが確保され
    // コピー構築される
    w = v ;
}
~~~

このとき、コピー先の既存の要素をわざわざ新しいストレージにコピー構築する必要はない。なぜならば、既存の要素の値はもういらないからだ。

まとめよう。

1. 自分自身への代入であれば何もしない
2. 要素数が同じならば要素ごとにコピー代入
3. それ以外の場合で、予約数が十分ならば有効な要素にはコピー代入、残りはコピー構築
4. それ以外の場合で、予約数が不十分ならば、現在の要素はすべて破棄して新たなストレージを確保してコピー構築

~~~cpp
vector & operator = ( const vector & r )
{
    // 1. 自分自身への代入なら何もしない
    if ( this == &r )
        return *this ;

    // 2. 要素数が同じならば
    if ( size() == r.size() )
    {   // 要素ごとにコピー代入
        std::copy( r.begin(), r.end(), begin() ) ;
    }
    // 3. それ以外の場合で
    else
        // 予約数が十分ならば、
        if ( capacity() >= r.size() )
        {
            // 有効な要素はコピー
            std::copy( r.begin(), r.begin() + r.size(), begin() ) ;
            // 残りはコピー構築
            for (   auto src_iter = r.begin() + r.size(), src_end = r.end() ;
                    src_iter != src_end ; ++src_iter, ++last )
            {
                construct( last, *src_iter ) ;
            }
        }
        // 4. 予約数が不十分ならば
        else
        {
            // 要素をすべて破棄
            destroy_all() ;
            // 予約
            reserve( r.size() ) ;
            // コピー構築
            for ( auto src_iter = r.begin(), src_end = r.end(), dest_iter = begin() ;
                src_iter != src_end ; ++src_iter, ++dest_iter, ++last )
            {
                construct( dest_iter, *src_iter ) ;
            }
        }
    return *this ;  
}
~~~
