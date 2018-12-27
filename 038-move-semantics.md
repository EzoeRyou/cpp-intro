# ムーブセマンティクス

ムーブ(move)とはコピー(copy)と対になる概念だ。ムーブというのはやや特殊なコピーとみなすこともできる。


## コピーの問題点

コピーには問題がある。コピーにはコストがかかる。

例えば以下のような自作のクラス`dynamic_array`をコピーする場合、

~~~c++
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

    // コピーコンストラクター
    dynamic_array( const dynamic_array & r ) ;
} ;
~~~

まずコピー元と同じサイズのストレージを動的メモリ確保し、要素を1つづつコピーしなければならない。

~~~c++
template < typename T >
dynamic_array<T>::dynamic_array( const dynamic_array & r )
    : first( new T[r.size()]), last( first + r.size() ) 
{
    std::copy( r.begin(), r.end(), begin() ) ;
}
~~~

もしこれが単なるポインターのコピーだけでいいのならば、コピーのコストはとても低くなる。

~~~c++
template < typename T >
dynamic_array<T>::dynamic_array( const dynamic_array & r )
    : first( r.first ), last( r.last )
{ }
~~~

しかし、このような実装は実際に使うと問題になる。

~~~c++
int main()
{
    dynamic_array<T> a(10) ;
    dynamic_array<T> b =a ;

    // bが破棄される
    // エラー、aが破棄される
}
~~~

なぜ問題かというと、関数`main`を抜けるときに、変数が構築の逆順に破棄される。変数`b`が破棄されるとき、デストラクターが実行され、ストレージが開放されてしまう。

