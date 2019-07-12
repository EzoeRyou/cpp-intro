# ムーブの実装

ムーブ(move)とはコピー(copy)と対になる概念だ。ムーブというのはやや特殊なコピーとみなすこともできる。

ムーブの使い方とその内部の挙動についてはムーブの章で説明した。

実際に自作のクラスでムーブを実装するには、`rvalue`リファレンスの章で説明した`rvalue`リファレンス、値カテゴリー、テンプレートのフォワードリファレンスの詳細な理解が必要になる。

まだこの2つの章を読んでいない読者はこの章を理解する準備ができていない。一度だけしか読んでいない読者は完全に理解はできないだろうから、この章を読んだ後にもう一度立ち返って読み直すべきだ。

この章ではサンプルコードの簡略化のために、メンバー関数の定義をあたかもクラスの中で書いたかのように扱う。

例えば、

~~~cpp
template < typename T >
struct S { T x ; } ;
~~~

があり、このクラス`S<T>`のコンストラクターを続いて

~~~cpp
S( T const & x ) : x(x) { }
~~~

と書くことがある。これは実際には間違いで、正しくは以下のように書かなければならない。

~~~cpp
template < typename T >
struct S
{
    T x ;
    // 宣言
    S( T const & ) ;
} ;
// 定義
template < typename T >
S<T>::S( T const & x ) : x(x) { }
~~~

この章では煩わしいので簡略した書き方を使う。


## コピーとムーブの判別

ムーブはムーブ元のオブジェクトを無効にする可能性がある。そのためムーブはムーブをしても安全な場合にしか行われない。

コピーはコピーコンストラクターとコピー代入演算子で実装する。

コピーは`lvalue`リファレンスを取る。通常は`const`な`lvalue`リファレンス型を使う。

~~~cpp
struct X
{
    // コピーコンストラクター
    X( const X & ) ;
    // コピー代入演算子
    X & operator = ( const X & ) ;
} ;
~~~

ムーブはムーブコンストラクターとムーブ代入演算子で実装する。

ムーブは`rvalue`リファレンスを取る。

~~~cpp
struct X
{
    // ムーブコンストラクター
    X( X && ) ;
    // ムーブ代入演算子
    X & operator = ( X && ) ;
} ;
~~~

コピーとムーブの区別は`lvalue`/`rvalue`リファレンスで行われる。なぜこれで動くのかというと、`rvalue`リファレンスで束縛できる値は、

1. 無名の一時オブジェクト(`prvalue`)
2. 明示的に`rvalue`リファレンスにキャストされたオブジェクト(`xvalue`)

のどちらかだからだ。

~~~cpp
void f( const int & ) 
{
    std::cout << "lvalue\n"s ;
}
void f( int && )
{
    std::cout << "rvalue\n"s ;
}

int main()
{
    int object { } ;

    f( object ) ; // lvalue
    f( object + object ) ; // rvalue
    f( []{ return object ; }() ) ; // rvalue
    f( std::move(object) ) ; // rvalue
}
~~~

変数名を書いた式`object`を評価した結果は`lvalue`なので`lvalue`と表示される。

変数を演算子`+`で加算する式`object + object`を評価した結果は`prvalue`なので`rvalue`と表示される。

戻り値の型が`int`型のラムダ式を呼び出す式`[]{ return 0 ; }()`を評価した結果は`prvalue`なので`rvalue`と表示される。

`std::move(object)`を評価した結果は`xvalue`なので`rvalue`と表示される。

`prvalue`は無名の一時オブジェクトなので、その値はすぐに破棄される。どうせ破棄されるのであれば、所有権を横取りしてもよい。

`xvalue`はユーザーが明示的に`rvalue`リファレンスにキャストした値だ。明示的に`rvalue`リファレンスにキャストしたということは、ユーザーはその値について、それ以降興味がないという意思を示したことになる。なので、そのような値からは所有権を横取りしてもよい。

特殊なルールとして、関数のローカル変数をオペランドに指定した`return`文はムーブをする可能性がある。

~~~cpp
std::vector<int> f()
{
    std::vector<int> v ;
    v.push_back(1) ;
    v.push_back(2) ;
    v.push_back(3) ;
    // ムーブをする可能性がある
    return v ;
}
~~~

これは関数のローカル変数は`return`文が実行されたときには無効になるので、特別に存在するルールだ。そもそも、関数の`return`文はコピーもムーブもしない可能性がある。

~~~cpp
int main()
{
    // 先ほどの関数f
    auto v = f() ;
}
~~~

C++コンパイラーは以下のようにコードを変形することも許されているからだ。

~~~cpp
int main()
{
    std::vector<int> v ;
    v.push_back(1) ;
    v.push_back(2) ;
    v.push_back(3) ;
}
~~~

## ムーブの実装

以下のようなクラスにムーブを実装しよう。

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
} ;
~~~

ムーブは所有権の移動だ。所有権の移動は、単にポインターをコピーするだけで済む。

~~~cpp
dynamic_array<int> source(10) ;
// ムーブ
dynamic_array<int> destination = std::move(source) ;
~~~

具体的な処理としては、

1. ムーブ先へ所有権の移動
2. ムーブ元の所有権の放棄

となる。

~~~cpp
// 1. ムーブ先へ所有権の移動
destination.first = source.first ;
destination.last = source.last ;
// 2. ムーブ元の所有権の放棄
source.first = nullptr ;
source.last = nullptr ;
~~~

とするのと同じだ。ストレージの所有権を`source`から`destination`に移動している。移動後、`source`の破棄に伴ってストレージが`delete`されないために、`source`のポインターの値は`nullptr`にする。移動後の`source`はもうストレージを所有していない。

### ムーブコンストラクター

ムーブコンストラクターは以下のように実装できる。

~~~cpp
dynamic_array( dynamic_array && r )
    // ムーブ先へ所有権の移動
    : first( r.first ), last( r.last )
{
    // ムーブ元の所有権の放棄
    r.first = nullptr ;
    r.last = nullptr ;
}
~~~

### ムーブ代入演算子

ムーブ代入の場合、すでにクラスのオブジェクトは構築されている。つまりムーブ先のクラスのオブジェクトはすでにストレージを所有しているかもしれない。

~~~cpp
dynamic_array<int> source(10) ;
dynamic_array<int> destination(10) ;
// destinationはすでにストレージを所有
destination = std::move(source) ;
~~~

そのため、ムーブ代入演算子はまず自身が所有しているストレージを解放する必要がある。そのため、処理は以下のようになる。

1. ムーブ先の所有権の解放
2. ムーブ先へ所有権の移動
3. ムーブ元の所有権の放棄

~~~cpp
// 1. ムーブ先の所有権の解放
delete destination.first ;
// 2. ムーブ先へ所有権の移動
destination.first = source.first ;
destination.last = source.last ;
// 3. ムーブ元の所有権の放棄
source.first = nullptr ;
source.last = nullptr ;
~~~

ただし、この実装は自分自身へのムーブ代入に対応できない。

~~~cpp
destination = std::move( destination ) ;
~~~

これは意図的なものだ。

一般的なムーブ代入、つまり、

~~~cpp
a = std::move(b) ;
~~~

というコードでムーブが実行された場合、変数`b`はその後使えない状態になる。もし`b`が`a`と同じである場合、`b`が使えない状態になるということは`a`も使えない状態になることはやむを得ないのが普通の挙動だ。

普通の挙動がコピー代入と異なるのは、歴史的経緯やムーブという破壊的な操作の性質から来るものだ。

C++の標準ライブラリは自分自身へのムーブ代入後のオブジェクトの状態について、「有効だが未規定の状態」としている。

たとえば、現在の主要なC++の実装では、`std::vector`で自分自身へのムーブ代入を行うと`clear()`が呼び出される。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;
    v = std::move(v) ;
    v.size() ; // 0
}
~~~

ムーブ代入でも、コピー代入のように何もしない実装にすることもできる。しかし、C++ではさまざまな議論の結果、ムーブ代入は自己代入を積極的に何もしない挙動にはしないということになっている。

自分自身へのムーブ代入は誤りである。

自分自身へのムーブ代入がうっかり発生する場合は、エイリアシングによるものだ。

~~~cpp
template < typename T >
void moving( T & a, T & b )
{
    a = std::move(b) ;
}
~~~

このコードが以下のように呼ばれた場合、変数`a`, `b`ともに同じオブジェクトを指しているので、自分自身へのムーブ代入になる。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,} ;
    moving( v, v ) ;
}
~~~

そのため、素性のわからない間接参照を挟むオブジェクトをムーブ代入するときは、自分自身へのムーブ代入の回避が必要になる。

そのための方法は2つある。

1つはポインターを比較することだ。


~~~cpp
template < typename T >
void moving( T & a, T & b )
{
    if ( &a != &b )
        a = std::move(b) ;
}
~~~

ただしこれは追加の比較が入るのでパフォーマンスに影響を与える。

もう1つは、ユーザーにエイリアシングを起こさないことを求めることだ。


~~~cpp
// 仕様
// この関数のa, bに同じオブジェクトを渡してはならない
// 渡した場合の挙動は未定義
template < typename T >
void moving( T & a, T & b )
{
    a = std::move(b) ;
}
~~~

これはつまり、ユーザーに責任を押し付けるということだ。

ムーブ代入演算子は以下のように実装できる。

~~~cpp
dynamic_array & operator = ( dynamic_array && r )
{
    // ムーブ先のストレージの解放
    delete first ;

    // ムーブ先へ所有権の移動
    first = r.first ;
    last = r.last ;
    // ムーブ元の所有権の放棄
    r.first = nullptr ;
    r.last = nullptr ;

    return *this ;
}
~~~

## デフォルトのムーブ

クラスがムーブを実装しない場合、デフォルトのムーブが暗黙に定義される。

~~~cpp
struct X
{
    int i {} ;
    std::vector<int> v ;
} ;

int main()
{
    X a ;
    X b ;
    b = std::move(a) ;
}
~~~

デフォルトのムーブはクラスのメンバーをそれぞれムーブする。

~~~cpp
b.i = std::move(a.i) ;
b.v = std::move(a.v) ;
~~~

デフォルトのコピーと似ている。
