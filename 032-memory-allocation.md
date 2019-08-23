# 動的メモリー確保

## 概要

動的メモリー確保は任意のサイズのメモリーを確保できる機能だ。

例えば`std::vector`は任意個の要素を保持できる。

~~~cpp
int main()
{
    int input { } ;
    std::vector<int> v ;
    while ( std::cin >> input )
    {
        v.push_back( input ) ;
    }
}
~~~

このプログラムは任意個の`int`型の値を保持する。いくつ保持するかはコンパイル時にはわからないし、実行途中にもわからない。プログラムが終了するまで、実際にいくつ値を保持したのかはわからない。

このような事前にいくつの値を保持するかわからない状況では、動的メモリー確保を使う。

## malloc/free

`malloc`/`free`はC言語から受け継いだ素朴な動的メモリー確保のライブラリだ。

~~~cpp
namespace std {
    void *  malloc  ( std::size_t size ) ;
    void    free    ( void * ptr ) ;
}
~~~

`malloc(n)`は`n`バイトの生のメモリーを確保して、その先頭バイトへのポインターを返す。

~~~cpp
// 5バイトのメモリーを確保
void * ptr = std::malloc( 5 ) ;
~~~

これによって確保されるメモリーは、1バイトごとのメモリーが配列のように連続したメモリーだ。型で書くと、`std::byte [5]`のようなものだ。

確保したメモリーは`free`で解放するまで有効だ。`free(ptr)`は`malloc`が返したポインター`ptr`を解放する。その結果、メモリーはまた再び`malloc`によって再利用できるようになる。

~~~cpp
// 5バイトの生のメモリーを確保
void * ptr = std::malloc( 5 ) ;
// 解放
std::free( ptr ) ;
// これ以降、ptrの値は無効
~~~

## operator new/operator delete

C++の追加した生のメモリーを確保する方法が、`operator new`と`operator delete`だ。

~~~cpp
// グローバル名前空間
void *  operator new    ( std::size_t size );
void    operator delete ( void * ptr ) ;
~~~

使い方は`malloc`とほぼ同じだ。`"operator new"`までが名前なので少し混乱するが、通常の関数呼び出しと同じだ。

~~~cpp
void * ptr = ::operator new( 5 ) ;
~~~

グローバル名前空間であることを明示するために`::`を使っている。

`operator new`で確保したメモリーは、`operator delete`で解放するまで有効だ。

~~~cpp
void * ptr = ::operator new( 5 ) ;
::operator delete ( ptr ) ;
~~~

## 生のバイト列を基本的な型の値として使う方法

`int`や`double`のような基本的な型は、生のバイト列のポインターを型変換するだけで使える。

1. 生のメモリーを確保
2. ポインターを型変換
3. 値を代入

~~~cpp
int main()
{
    // 確保
    void * void_ptr = ::operator new( sizeof(int) ) ;
    // 型変換
    int * int_ptr = static_cast<int *>( void_ptr ) ;
    // 代入
    *int_ptr = 0 ;
    // 解放
    ::operator delete ( void_ptr ) ;
}
~~~

`int`型のサイズは`sizeof(int)`バイトなので、`sizeof(int)`バイトのメモリーを確保する。`void *`型から`int *`型に型変換する。あとはポインターを経由して使うだけだ。

ポインターの文法がわかりにくい場合、リファレンスを使うこともできる。

~~~cpp
int & int_ref = *int_ptr ;
~~~

`malloc`や`operator new`が返すメモリーの値は不定だ。なので、確保した生のメモリーへのポインターを、実際に使う型のポインターに型変換して、その値を参照しようとすると、結果は未定義だ。

~~~cpp
int main()
{
    // ここまでは定義された挙動
    int * ptr = static_cast<int *>( ::operator new(sizeof(int)) ) ;
    // 未定義の挙動
    std::cout << *ptr ;
}
~~~

このプログラムを実行した結果、何が起こるかはわからない。

## メモリー確保の失敗

メモリー確保は失敗する可能性がある。現実のコンピューターは有限のリソースしか持たないために、メモリーも当然有限のリソースだ。

`malloc`が失敗すると、`nullptr`が返される。`malloc`が失敗したかどうかを調べるには、戻り値を`nullptr`と比較すればよい。

~~~cpp
int main()
{
    void * ptr = std::malloc( 1 ) ;

    if ( ptr == nullptr ) {
        // メモリー確保失敗
    } else {
        // メモリー確保成功
    }
}
~~~

`operator new`が失敗すると、`std::bad_alloc`が投げられる。

~~~cpp
int main()
{
    try {
        void * ptr = ::operator new( 1 ) ;
        // メモリー確保成功
    } catch ( std::bad_alloc e )
    {
        // メモリー確保失敗
    }
}
~~~

たいていの環境ではメモリー確保が失敗したときにできることは少ない。そのままプログラムを終了するのが最も適切な処理だ。というのも、ほとんどの処理にはメモリー確保が必要だからだ。

例外の場合、`catch`しなければプログラムは終了する。`malloc`の場合、自分でメモリー確保が失敗したかどうかを調べてプログラムを終了しなければならない。プログラムを途中で強制的に終了するには、`std::abort`が使える。

~~~cpp
void f()
{
    void * ptr = malloc(1) ;

    // 失敗判定
    if ( ptr == nullptr )
        std::abort() ;

    // 成功
}
~~~

## クラス型の値の構築

動的に確保したメモリーを`int`や`double`のような基本的な型の値として使うには以下のように書けばよいことはすでに学んだ。


1. その型のサイズ分のメモリーを確保
2. ポインターを型変換
3. 適切な値を代入

より汎用的にテンプレートを使って書くと以下のようになる。

~~~cpp
// 動的確保したメモリーをT型の値として使う
template < typename T >
void dynamic_allocate()
{
    // 1. その型のサイズ分のメモリーを確保
    void * ptr = ::operator new( sizeof(T) ) ;
    // 2. ポインターを型変換
    T * T_ptr = static_cast<T * >( ptr ) ;
    // 3. 適切な値を代入
    *T_ptr = T{} ;
    ::operator delete( ptr ) ;
}

int main()
{
    dynamic_allocate<int>() ;
    dynamic_allocate<double>() ;
}
~~~

この方法は、ほとんどのクラスには使えない。例えば`std::vector<T>`には使えない。

~~~cpp
// エラー
dynamic_allocate< std::vector<int> >() ;
~~~

「ほとんどのクラス」と書いたからには、使えるクラスもあるということだ。例えば以下のようなクラスでは使える。

~~~cpp
struct Simple
{
    int i ;
    double d ;
} ;

int main()
{
    // 使える
    dynamic_allocate<Simple>() ;
}
~~~

なぜ`Simple`のようなクラスでは使えるのだろうか。`std::vector<T>`とはどう違うのか。この違いを厳密に解説するためには、とても長くて厳密なC++の標準規格の理解が必要だ。とても難しいため、本書では解説しない。

クラスの値を使うためには、メモリー上にクラスのオブジェクトを構築する必要がある。クラスの構築にはコンストラクター呼び出し以外にも、そのメモリーをクラスのオブジェクトとして使うのに必要な何らかの初期化が含まれる。

~~~cpp
// sizeof(std::vector<int>)バイトのメモリーを確保し
// そのメモリー上にクラスのオブジェクトを構築
std::vector<int> v ;
~~~

生のメモリー上にクラスのような複雑な型を構築するには、`newプレイスメント`を使う。

~~~c++
new ( 生のポインター ) 型 new初期化子
~~~

`new初期化子`というのは`()`か`{}`で囲んだコンストラクターへの引数だ。引数がない場合は省略もできる。

例えば`std::vector<int>`型を構築するには以下のようにする。

~~~cpp
// 生のメモリーを動的確保
void * ptr = ::operator new ( sizeof( std::vector<int> ) ) ;
// 生のメモリー上に型を構築
std::vector<int> * vector_ptr = new (ptr) std::vector<int>{} ;
~~~

こうすればクラスが適切にメモリー上に構築され、コンストラクターも呼ばれる。コンストラクターが呼ばれることを確かめてみよう。

~~~cpp
struct Logger
{
    std::string name ;
    Logger( std::string name )
        : name( name )
    { std::cout << name << " is constructed.\n"s ; }
    ~Logger()
    { std::cout << name << " is destructed.\n"s ; }
} ;

int main()
{
    void * ptr = ::operator new ( sizeof( Logger ) ) ;
    Logger * logger_ptr = new (ptr) Logger{"Alice"s} ;
}
~~~

このプログラムを実行すると、`"Alice is constructed."`と出力される。

クラスのオブジェクトを適切に破棄するためには、デストラクターを呼ばなければならない。通常の変数ならば、変数が寿命を迎えたときに自動的にデストラクターが呼ばれてくれる。

~~~cpp
int main()
{
    Logger Alice("Alice"s) ;
    {
        Logger Bob("Bob"s) ;
        // Bobの寿命はここまで
    }
    // Aliceの寿命はここまで
}
~~~

このプログラムを実行すると、以下のように出力される。

~~~
Alice is constructed.
Bob is constructed.
Bob is destructed.
Alice is destructed.
~~~

動的に確保されるメモリー上に構築されたオブジェクトは自動的に破棄されてくれない。クラスのオブジェクトの場合デストラクターを呼び出さなければならないが、動的メモリー確保したメモリー上に構築したクラスのオブジェクトの場合は、明示的に呼び出さなければならない。

~~~cpp
// 動的メモリー確保
void * raw_ptr = ::operator new( sizeof(Logger) ) ;
// 構築
Logger * logger_ptr = new(raw_ptr) Logger{ "Alice"s } ;
// デストラクター呼び出し
logger_ptr->~Logger() ;
// 破棄
::operator delete( raw_ptr ) ;
~~~

このようにすれば、コンストラクター、デストラクターが適切に呼ばれる。また確保したメモリーも解放される。


## new/delete

クラスのオブジェクトを動的確保するのに、生のメモリーの確保/解放と、クラスのオブジェクトの構築/破棄をすべて自前で行うのは面倒だ。幸い、確保と構築、破棄と解放を同時にやってくれる機能がある。`new式`と`delete式`だ。

~~~c++
new 型 new初期化子
delete ポインター
~~~

`new式`は生のメモリーを確保し、型のオブジェクトを構築し、そのオブジェクトへのポインターを返す。

~~~cpp
int * int_ptr = new int{123} ;
std::vector<int> * vector_ptr = new std::vector<int>{} ;
~~~

`delete式`は`new式`で返されたポインターの指し示すオブジェクトを破棄し、生のメモリーを解放する。

~~~cpp
delete int_ptr ;
delete vector_ptr ;
~~~

`new式`がメモリーの確保に失敗すると、`std::bad_alloc`例外を投げる。

~~~cpp
int main()
{
    try {
        new int{0} ;
        // 確保成功
    } catch( std::bad_alloc e )
    {
        // 確保失敗
    }
}
~~~

## 配列版new/delete

`new式`は配列型を動的確保することもできる。

~~~cpp
int * int_array_ptr =  new int[5]{1,2,3,4,5} ;
~~~

配列型を`new式`で動的確保した場合、`delete式`は通常の`delete`ではなく、`delete[]`を使わなければならない。

~~~cpp
delete [] int_array_ptr ;
~~~

## スマートポインター

クラスのオブジェクトの動的確保は、解放を明示的にしなければならないので間違いをしやすい。この問題はクラスを使って解決できる。

クラスのコンストラクターで動的確保し、デストラクターで解放すればよいのだ。

~~~cpp
template < typename T >
struct smart_ptr
{
    T * ptr ;
    // コンストラクターで構築
    smart_ptr()
        : ptr( new T{} )
    { }
    // デストラクターで破棄
    ~smart_ptr()
    { delete ptr ; }

    T & operator *() const noexcept
    { return *ptr ; }
} ;

int main()
{
    smart_ptr<int> ptr ;
    *ptr = 123 ;
    // 自動的に破棄される
}
~~~

このクラスはさまざまな点で実用的ではない。例えばこのクラスはコピーできてしまう。

~~~cpp
int main()
{
    smart_ptr<int> p1 ;
    // コピーされる
    auto p2 = p1 ;
    // p2の寿命
    // エラー、p1の寿命
}
~~~

このコードの何がまずいかというと、`smart_ptr::ptr`がコピーされてしまうということだ。`p2`が破棄されると、`delete ptr`が実行される。そのあとに`p1`が破棄されるのだが、もう一度`delete ptr`が実行されてしまうのだ。一度`delete`を呼び出したポインターはもう無効になっているので、それ以上`delete`を呼び出すことはできない。よってエラーになる。

この問題を解決するには、まだ学んでいないC++の機能がたくさん必要になる。この問題は必要な機能をすべて学び終えたあとの章で、もう一度挑戦することにしよう。
