# arrayをさらに実装

'std::array'をもっと実装していこう。前回、以下のような簡単な'array'を実装した。

~~~cpp
template < typename T, std::size__t N >
struct array
{
    T storage[N] ;

    T & operator [] ( std::size_t i )
    {
        return storage[i] ;
    }
} ;
~~~

実は`std::array`はこのように書かれていない。この章では、'array'の実装を'std::array'に近づけていく。

## ネストされた型名

エイリアス宣言を覚えているだろうか。型名に別名をつける機能だ。

~~~cpp
int main()
{
    using number = int ;
    number x = 123 ;
}
~~~

エイリアス宣言はクラスの中でも使うことができる。

~~~cpp
struct S
{
    using number = int ;
    number data ;
} ;

int main()
{
    S s{123} ;

    S::number x = s.data ;
}
~~~

クラスの中で宣言されたエイリアス宣言による型名を、'ネストされた型名'という。`std::array`ではテンプレート引数を直接使う代わりに、`ネストされた型名`が使われている。

~~~cpp
template < typename T, std::size__t N >
struct array
{
    using value_type = T ;
    using reference = T & ;

    using size_type = std::size_t

    value_type storage[N] ;

    reference operator [] ( size_type i )
    {
        return storage[i] ;
    }
} ;
~~~

こうすると、`T &`のようなわかりにくい型ではなく`reference`のようにわかりやすい名前を使える。さらに、クラス外部から使うこともできる。

~~~cpp
int main()
{
    using array_type = std::array<int, 5> ;
    array_type a = {1,2,3,4,5} ;
    array_type::value_type x = 0 ;
    array_type::reference ref = a[0] ;
}
~~~

もちろんこれは`auto`で書くこともできるが、


~~~cpp
int main()
{
    using array_type = std::array<int, 5> ;
    array_type a = {1,2,3,4,5} ;
    auto x = 0 ;
    auto ref = a[0] ;
}
~~~

信じられないことに昔のC++には`auto`がなかったのだ。その他、様々な利点があるのだが、そのすべてを理解するには、まだ読者のC++力が足りない。


