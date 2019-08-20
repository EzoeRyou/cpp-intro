# arrayをさらに実装

`'std::array'`をもっと実装していこう。前章では以下のような簡単な`'array'`を実装した。

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

実は`std::array`はこのように書かれていない。この章では、`'array'`の実装を`'std::array'`に近づけていく。

## ネストされた型名

エイリアス宣言を覚えているだろうか。型名に別名を付ける機能だ。

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

クラスの中で宣言されたエイリアス宣言による型名を、`ネストされた型名`という。`std::array`ではテンプレート引数を直接使う代わりに、`ネストされた型名`が使われている。

~~~cpp
template < typename T, std::size_t N >
struct array
{
    using value_type = T ;
    using reference = T & ;

    using size_type = std::size_t ;

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

信じられないことに昔のC++には`auto`がなかったのだ。その他、さまざまな利点があるのだが、そのすべてを理解するには、まだ読者のC++力が足りない。

## 要素数の取得: size()

`std::array<T,N>`には`size()`というメンバー関数がある。要素数を返す。

`array`の場合、`N`を返せばよい。

~~~cpp
int main()
{
    std::array<int, 5> a ;
    a.size() ; // 5

    std::array<int, 10> b ;
    b.size() ; // 10
}
~~~

さっそく実装しよう。

~~~cpp
template < typename T, std::size_t N >
struct array
{
    using size_type = std::size_t ;

    size_type size() ;
    // ... 省略
} ;
~~~

ここでは`size`の宣言だけをしている。

関数は宣言と定義が分割できる。

~~~cpp
// 関数の宣言
void f() ;
// 関数の定義
void f() { }
~~~

メンバー関数も宣言と定義が分割できる。

~~~cpp
// クラスの宣言
struct S
{
    // メンバー関数の宣言
    void f() ;
} ;

// メンバー関数の定義
void S::f() { }
~~~

メンバー関数の定義をクラス宣言の外で書くには、関数名がどのクラスに属するのかを指定しなければならない。これには`クラス名::`を使う。この場合、`S::f`だ。



## メンバー関数のconst修飾

`const`を付けた変数は値を変更できなくなることはすでに学んだ。

~~~cpp
int main()
{
    int x = 0 ;
    x = 1 ;
    int const cx = 0 ;
    cx = 0 ; // エラー
}
~~~

`const`は変更する必要のない場面でうっかり変更することを防いでくれるとても便利な機能だ。`'array'`は大きいので関数の引数として渡すときにコピーするのは非効率的だ。なのでコピーを防ぐリファレンスで渡したい。

`std::array<T,N>`を受け取って要素をすべて出力する関数を書いてみよう。

~~~cpp
template < typename Array >
void print( Array & c )
{
    for ( std::size_t i = 0 ; i != c.size() ; ++i )
    {
        std::cout << c[i] ;
    }
}

int main()
{
    std::array<int, 5> a = {1,2,3,4,5} ;
    print( a ) ;
}
~~~

関数`print`がテンプレートなのは任意の`T`と`N`を使った`std::array<T,N>`を受け取れるようにするためだ。

関数のリファレンスを引数として渡すと、関数の中で変更できてしまう。しかし、上の例のような関数`print`では、引数を書き換える必要はない。この関数を使う人間も、引数を勝手に書き換えないことを期待している。この場合、`const`を付けることで値の変更を防ぐことができる。

~~~cpp
template < typename Container >
void print( Container const & c )
{
    for ( std::size_t i = 0 ; i != c.size() ; ++i )
    {
        std::cout << c[i] ;
    }
}
~~~

ではさっそくこれまで実装してきた自作の`array`クラスを使ってみよう。

~~~cpp
int main()
{
    array<int, 5> a = {1,2,3,4,5} ;

    print( a ) ; // エラー
}
~~~

なぜかエラーになってしまう。

この理由はメンバー関数を呼び出しているからだ。

クラスのメンバー関数はデータメンバーを変更できる。

~~~cpp
struct S
{
    int data {} ;
    void f()
    {
        ++data ;
    }
} ;

int main()
{
    S s ;
    s.f() ; // s.dataを変更
}
~~~

ということは、`const S`はメンバー関数`f()`を呼び出すことができない。

~~~cpp
int main()
{
    S s ;
    S const & ref = s ;

    ++ref.data ;  // エラー
    ref.f() ;     // エラー
}
~~~

ではメンバー関数`f()`がデータメンバーを変更しなければいいのだろうか。試してみよう。

~~~cpp
struct S
{
    int data {} ;
    void f()
    {
        // 何もしない
    }
} ;

int main()
{
    S const s ;
    s.f() ; // エラー
}
~~~

まだエラーになる。この理由を完全に理解するためには、まだ説明していない`ポインター`という機能について学ばなければならない。ポインターの説明はこの次の章で行うとして、いまはさしあたり必要な機能である`メンバー関数のconst修飾`を説明する。

`const`を付けていないメンバー関数を`const`なクラスのオブジェクトから呼び出せない理由は、メンバー関数がデータメンバーを変更しない保証がないからだ。その保証を付けるのが`メンバー関数のconst修飾`だ。

メンバー関数は関数の引数のあと、関数の本体の前に`const`を書くことで`const`修飾できる。

~~~cpp
struct S
{
    void f() const
    { }
} ;

int main()
{
    S s ;
    s.f() ; // OK

    S const cs ;
    cs.f() ; // OK

}
~~~

`const`修飾されたメンバー関数は`const`なクラスのオブジェクトからでも呼び出すことができる。

`const`修飾されたメンバー関数と、`const`修飾されていないメンバー関数が両方ある場合、クラスのオブジェクトの`const`の有無によって適切なメンバー関数が呼び出される。

~~~cpp
struct S
{
    void f() { }        // 1
    void f() const { }  // 2
} ;

int main()
{
    S s ;
    s.f() ;     // 1

    S const cs ;
    cs.f() ;    // 2
}
~~~

そしてもう1つ重要なのは、`const`修飾されたメンバー関数がデータメンバーへのリファレンスを返す場合、

~~~cpp
struct S
{
    int data {} ;
    // データメンバーへのリファレンスを返す
    int & get()
    {
        return data ;
    }
} ;
~~~

`const`修飾されたメンバー関数は自分のデータメンバーを変更できないので、データメンバーの値を変更可能なリファレンスを返すことはできない。そのため以下のようになる。

~~~cpp
struct S
{
    int data {} ;
    int & get()
    {
        return data ;
    }

    // const版
    // constリファレンスを返すので変更不可
    int const & get() const
    {
        return data ;
    }
} ;
~~~

自作の`'array'`の`operator []`を`const`に対応させよう。`'std::array'`は`const`なリファレンスを`const_reference`というネストされた型名にしている。

~~~cpp
template < typename T, std::size_t N >
struct array
{
    T storage[N] ;

    using reference = T & ;
    using const_reference = T const & ;

    // 非const版
    reference operator [] ( std::size_t i )
    {
        return storage[i] ;
    }
    // const版
    const_reference operator [] ( std::size_t i ) const
    {
        return storage[i] ;
    }
} ;
~~~

これで`const array`にも対応できるようになった。

## 先頭と末尾の要素：front/back

メンバー関数`front`は最初の要素へのリファレンスを返す。`back`は最後の要素へのリファレンスを返す。

~~~cpp
int main()
{
    std::array<int, 5> a = {1,2,3,4,5} ;

    int & f = a.front() ;   // 1
    int & b = a.back() ;    // 5
}
~~~

`front/back`には`reference`を返すバージョンと`const_reference`を返すバージョンがある。

~~~cpp
template < typename T, std::size_t N >
struct array
{
    T storage[N] ;

    using reference = T & ;
    using const_reference = T const & ;

    reference front()
    { return storage[0] ; }
    const_reference front() const
    { return storage[0] ; }

    reference back()
    { return storage[N-1] ; }
    const_reference back() const
    { return storage[N-1] ; }

} ;
~~~

## 全要素に値を代入: fill

~~~cpp
int main()
{
    std::array<int, 5> a = {1,2,3,4,5} ;
    a.fill(0) ;
    // aは{0,0,0,0,0}
}
~~~

すでにアルゴリズムで実装した`'std::fill'`と同じだ。

~~~cpp
template < typename T, std::size_t N >
struct array
{
    T storage[N] ;

    void fill( T const & u )
    {
        for ( std::size_t i = 0 ; i != N ; ++i )
        {
            storage[i] = u ;
        }
    }

} ;
~~~

しかし、せっかく`std::fill`があるのだから以下のように書きたい。

~~~cpp
void fill( T const & u )
{
    std::fill( begin(), end(), u ) ;
}
~~~

残念ながらこれは動かない。なぜならば、自作の`array`はまだ`begin()/end()`と`イテレーター`に対応していないからだ。これは次の章で学ぶ。
