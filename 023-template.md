# テンプレート

## 問題点

前章で我々は`'std::array'`のようなものを実装した。C++を何も知らなかった我々がとうとうクールなキッズは皆やっているというクラスを書くことができた。素晴らしい成果だ。

しかし、我々の書いた`'array_int_10'`は`'std::array'`とは異なる。

~~~cpp
// 標準ライブラリ
std::array<int, 10> a ;
// 我々のクラス
array_int_10 a ;
~~~

もし要素数を20個にしたければ`array_int_20`を新たに書かなければならない。すると`array_int_1`とか`array_int_10000`のようなクラスを無数に書かなければならないのだろうか。要素の型を`double`にしたければ`array_double_10`が必要だ。

しかし、そのようなクラスはほとんど同じような退屈な記述の羅列になる。

~~~cpp
struct array_int_1
{
    int storage[1] ;
    int & operator []( std::size_t i )
    { return storage[i] ; }
} ;

// array_int_2, array_int_3, ...

struct array_int_10000
{
    int storage[10000] ;
    int & operator []( std::size_t i )
    { return storage[i] ; }
} ;

struct array_double_1
{
    double storage[1] ;
    double & operator []( std::size_t i )
    { return storage[i] ; }
} ;

// array_double_2, array_double_3, ...
~~~

これは怠惰で短気なプログラマーには耐えられない作業だ。C++にはこのような退屈なコードを書かなくても済む機能がある。しかしその前に、引数について考えてみよう。

## 関数の引数

1を2倍する関数を考えよう。

~~~cpp
int one_twice()
{
    return 1 * 2 ;
}
~~~

上出来だ。では2を2倍する関数を考えよう。

~~~cpp
int two_twice()
{
    return 2 * 2 ;
}
~~~

素晴らしい。では3を2倍する関数、4を2倍する関数...と考えていこう。

ここまで読んで`three_twice`や`four_twice`を思い浮かべた読者にはプログラマーに備わるべき美徳が欠けている。怠惰で短気で傲慢なプログラマーはそんなコードを書かない。引数を使う。

~~~cpp
int twice( int n )
{
    return n * 2 ;
}
~~~

具体的な値を2倍する関数を値の数だけ書くのは面倒だ。具体的な値は定めず、引数で外部から受け取る。そして引数を2倍して返す。引数は汎用的なコードを任意の値に対して対応させるための機能だ。

## 関数のテンプレート引数

`twice`をさまざまな型に対応させるにはどうすればいいだろう。例えば`int`型と`double`型に対応させてみよう。

~~~cpp
int twice( int n )
{
    return n * 2 ;
}

double twice( double n )
{
    return n * 2.0 ;
}
~~~

整数型には`int`のほかにも、`short`, `long`, `long long`といった型がある。浮動小数点数型には`float`と`long double`もある。ということは以下のような関数も必要だ。

~~~cpp
short twice( short n )
{
    return n * 2 ;
}

long twice( long n )
{
    return n * 2 ;
}

long long twice( long long n )
{
    return n * 2 ;
}

float twice( float n )
{
    return n * 2 ;
}

long double twice( long double n )
{
    return n * 2 ;
}
~~~

ところで、整数型には符号付きと符号なしの2種類があるということは覚えているだろうか？

~~~cpp
int twice( int n )
{
    return n * 2 ;
}

unsigned int twice( unsigned int n )
{
    return n * 2 ;
}

// short, long, long longに対しても同様
~~~

C++ではユーザーが整数型のように振る舞うクラスを作ることができる。整数型を複数使って巨大な整数を表現できるクラスも作ることができる。

~~~cpp
// 多倍長整数クラス
// unsigned long longが256個分の整数の実装
struct bigint
{
    unsigned long long storage[256] ;
} ;

bigint operator * ( bigint const & right, int )
{
    return // 実装
}
~~~

このクラスに対応するには当然、以下のように書かなければならない。


~~~cpp
bigint twice( bigint n )
{
    return n * 2 ;
}
~~~

そろそろ怠惰と短気を美徳とするプログラマー読者は耐えられなくなってきただろう。これまでのコードは、単にある型`T`に対して、

~~~cpp
T twice( T n )
{
    return n * 2 ;
}
~~~

と書いているだけだ。型`T`がコピーと`operator *(T, int)`に対応していればいい。型`T`の具体的な型について知る必要はない。

関数が具体的な値を知らなくても引数によって汎用的なコードを書けるように、具体的な型を知らなくても汎用的なコードを書けるようになりたい。その怠惰と短気に答えるのが`テンプレート`だ。

## テンプレート

通常の関数が値を引数に取ることができるように、テンプレートは型を引数に取ることができる。

テンプレートは以下のように宣言する。

~~~c++
template < typename T >
    宣言 
~~~

テンプレートを関数に使う`関数テンプレート`は以下のように書く。

~~~cpp
template < typename T >
T twice( T n )
{
    return n * 2 ;
}

int main()
{
    twice( 123 ) ;  // int
    twice( 1.23 ) ; // double 
}
~~~

`template < typename T >`は型`T`を`テンプレート引数`に取る。テンプレートを使った宣言の中では、`T`が型として扱える。

~~~cpp
template < typename T >
T f( T n )
{
    T x = n ;
}
~~~

`関数`が`引数`を取るように、`テンプレート`は`テンプレート引数`を取る。

~~~cpp
// テンプレートはテンプレート引数template_parameterを取る
template < typename template_parameter >
// 関数は引数function_parameterを取る
// 引数の型はtemplate_parameter
void f( template_parameter function_parameter )
{
}
~~~

`テンプレート`が「使われる」ときに、`テンプレート引数`に対する具体的な型が決定する。

~~~cpp
template < typename T >
void f( T const & x )
{
    std::cout << x ;
}

int main()
{
    // Tはint
    f( 0 ) ;
    // Tはdouble
    f( 0.0 ) ;
    // Tはstd::string
    f( "hello"s ) ;
}
~~~

`テンプレート`を使うときに自動で`テンプレート引数`を推定してくれるが、`<T>`を使うことで明示的に`テンプレート引数`を`T`型に指定することもできる。

~~~cpp
template < typename T >
void f( T const & x )
{
    std::cout << x ;
}

int main()
{
    // Tはint
    f<int>(0) ;

    // Tはdouble
    // int型0からdouble型0.0への変換が行われる
    f<double>( 0 ) ;
}
~~~

`テンプレート引数`は型ではなく整数型の値を渡すこともできる。

~~~cpp
template < int N >
void f()
{
    std::cout << N ;
}

int main()
{
    // Nは0
    f<0>() ;
    // Nは123
    f<123>() ;
}
~~~


ただし、`テンプレート引数`はコンパイル時にすべてが決定される。なので`テンプレート引数`に渡せる値はコンパイル時に決定できるものでなければならない。

~~~cpp
template < int N >
void f() { }

int main()
{
    // OK
    f<1+1>() ;

    int x{} ;
    std::cin >> x ;
    // エラー
    f<x>() ;
}
~~~

`テンプレート引数`がコンパイル時に決定されるということは、配列のサイズのようなコンパイル時に決定されなければならない場面でも使えるということだ。

~~~cpp
template < std::size_t N >
void f()
{
    int buffer[N] ;
}

int main()
{
    // 配列bufferのサイズは10
    f<10>() ;
    // サイズは12
    f<12>() ;
}
~~~

テンプレートを使ったコードは、与えられた`テンプレート引数`に対して妥当でなければならない。

~~~cpp
template < typename vec >
void f( vec & v )
{
    v.push_back(0) ;
}

int main()
{
    std::vector<int> a ;
    // OK
    f( a ) ;
    std::vector<double> b ;
    // OK
    // intからdoubleへの変換
    f( b ) ;

    std::vector<std::string> c ;
    // エラー
    // intからstd::stringに変換はできない
    f( c ) ;

    // エラー
    // int型はメンバー関数push_backを持っていない
    f( 0 ) ;
}
~~~



## クラステンプレート

`テンプレート`は`クラス`にも使える。`関数テンプレート`は`関数`の前に`テンプレート`を書くように、

~~~cpp
template < typename T > // テンプレート
void f( ) ; // 関数
~~~

`クラステンプレート`は`クラス`の前に`テンプレート`を書く。

~~~cpp
template < typename T > // テンプレート
struct S { } ; // クラス
~~~

関数の中でテンプレート引数名を型や値として使えるように、

~~~cpp
template < typename T, T N >
T value()
{
    return N :
}

int main()
{
    value<int, 1>() ;
    value<short, 1>() ;
}
~~~

クラスの中でもテンプレート引数名を型や値として使える。

~~~cpp
template < typename T, std::size_t N >
struct array
{
    T storage[N] ;

    T & operator [] ( std::size_t i )
    {
        return storage[i] ;
    }
} ;
~~~

なんと、もう`'std::array'`が完成してしまった。
