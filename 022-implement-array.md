# 配列

## ナイーブなarray実装

`std::array`を実装してみよう。すでにクラスを作る方法については学んだ。

`std::array<T,N>`は`T`型の要素を`N`個保持するクラスだ。この`<T,N>`についてはまだ学んでいないので、今回は`int`型を3個確保する。いままでに学んだ要素だけで実装してみよう。

~~~cpp
struct array_int_3
{
    int m0 ;
    int m1 ;
    int m2 ;
} ;
~~~

そして`operator []`を実装しよう。引数が`0`なら`m0`を、`1`なら`m1`を、`2`なら`m2`を返す。それ以外の値の場合、プログラムを強制的に終了させる標準ライブラリ、`std::abort`を呼び出す。



~~~cpp
struct array_int_3
{
    int m0 ; int m1 ; int m2 ;

    int & operator []( std::size_t i )
    {
        switch(i)
        {
            case 0 :
                return m0 ;
            case 1 :
                return m1 ;
            case 2 :
                return m2 ;
            default :
                // 間違った引数
                // 強制終了
                std::abort() ;
        }
    }
} ;
~~~

これは動く。では要素数を10個に増やした`array_int_10`はどうなるだろうか。要素数100個はどう書くのだろうか。この方法で実装するとソースコードが膨大になり、ソースコードを出力するソースコードを書かなければならなくなる。これは怠惰で短気なプログラマーには耐えられない作業だ。

## 配列

`std::array`を実装するには、`配列(array)`を使う。

`int`型の要素数10の配列`a`は以下のように書く。

~~~cpp
int a[10] ;
~~~

`double`型の要素数5の配列`b`は以下のように書く。

~~~cpp
double b[5] ;
~~~

`配列`の要素数は`std::array<T,N>`の`N`と同じようにコンパイル時定数でなければならない。

~~~cpp
int main()
{
    std::size_t size ;
    std::cin >> size ;
    // エラー
    int a[size] ;
}
~~~

配列は`={1,2,3}`のように初期化できる。

~~~cpp
int a[5] = {1,2,3,4,5} ;
double b[3] = {1.0, 2.0, 3.0 } ;
~~~

配列の要素にアクセスするには`operator []`を使う。

~~~cpp
int main()
{
    int a[5] = {1,2,3,4,5} ;

    // 4
    std::cout << a[3] ;

    a[2] = 0 ;
    // {1,2,0,4,5}
}
~~~

配列にはメンバー関数はない。`at(i)`や`size()`のような便利なメンバー関数はない。

配列のサイズは`sizeof`で取得できる。配列のサイズは配列の要素の型のサイズ掛けることの要素数のサイズになる。

~~~cpp
int main()
{
    auto print = [](auto s){ std::cout << s << "\n"s ; } ;
    int a[5] ;
    print( sizeof(a) ) ;
    print( sizeof(int) * 5 ) ;

    double b [5] ;
    print( sizeof(b) ) ;
    print( sizeof(double) * 5 ) ;
}
~~~

`sizeof`は型やオブジェクトのバイト数を取得するのに対し、`vector`や`array`のメンバー関数`size()`は要素数を取得する。この違いに注意すること。

~~~cpp
int main()
{
    auto print = [](auto s){ std::cout << s << "\n"s ; } ;
    std::array<int, 5> a ;

    // aのバイト数
    print( sizeof(a) ) ;
    // 要素数: 5
    print( a.size() ) ;

}
~~~

`配列`はとても低級な機能だ。その実装はある型を連続してストレージ上に並べたものになっている。

~~~cpp
int a[5] ;
~~~

のような配列があり、`int`型が4バイトの環境では、20バイトのストレージが確保され、その先頭の4バイトが最初の0番目の要素に、その次の4バイトが1番目の要素になる。最後の4番目の要素は最後の4バイトになる。

~~~
配列のストレージ上のイメージ図

□1つが1バイトのストレージ
     1番目のint
    |--|
□□□□□□□□□□□□□□□□□□□□
|--|            |--|
 0番目のint       4番目のint
~~~
fig/fig22-01.png

配列にはメンバー関数がない上、コピーもできない。`std::array`はコピーできる。

~~~cpp
int main()
{
    int a[5] = {1,2,3,4,5} ;
    // エラー、コピーできない
    int b[5] = a ;

    std::array<int, 5> c = {1,2,3,4,5} ;
    // OK、コピーできる
    std::array<int, 5> d = c ;
}
~~~

`配列`は低級で使いにくいので、`std::array`という配列をラップした高級なライブラリが標準で用意されている。

さて、配列の使い方は覚えたので、さっそく`std::array_int_10`を実装してみよう。

まずクラスのデータメンバーとして配列を宣言する。

~~~cpp
struct array_int_10
{
    int storage[10] ;
} ;
~~~

配列はコピーできないが、クラスのデータメンバーとして宣言した配列は、クラスのコピーの際に、その対応する順番の要素がそれぞれコピーされる。

~~~cpp
struct array_int_3 { int storage [3] ; } ;

int main()
{
    array_int_3 a = { 0,1,2 } ;

    array_int_3 b = a ;
    // b.storage[0] == a.storage[0] 
    // b.storage[1] == a.storage[1] 
    // b.storage[2] == a.storage[2] 
}
~~~

これはあたかも以下のように書いたかのように動く。

~~~cpp
struct array_int_3
{
    int storage[3] ;

    array_int_3( array_int_3 const & other )
    {
        std::copy(
            std::begin(other.storage), std::end(other.storage),
            std::begin(storage)
        ) ;

    }
}
~~~

`operator []`も実装しよう。

~~~cpp
struct array_int_10
{
    int storage[10] ;

    int & operator [] ( std::size_t i )
    {
        return storage[i] ;
    }
} ;

int main()
{
    array_int_10 a = {0,1,2,3,4,5,6,7,8,9} ;
    a[3] = 0 ;
    std::cout << a[6] ;
}
~~~

`std::array`にはまださまざまなメンバーがある。1つずつ順番に学んでいこう。
