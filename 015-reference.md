# lvalueリファレンスとconst

    ポップカルチャーリファレンスというのは流行の要素をさり気なく作品中に取り入れることで、流行作品を知っている読者の笑いを誘う手法である
    -- キャプテン・オブビウス、ポップカルチャーリファレンスについて

## lvalueリファレンス

変数に変数を代入すると、代入元の値が代入先にコピーされる。代入先の値を変更しても、コピーされた値が変わるだけで、代入元にはいっさい影響がない。

~~~cpp
int main()
{
    int a = 1 ;
    int b = 2 ;

    b = a ;
    // b == 1

    b = 3 ;
    // a == 1
    // b == 3
}
~~~

これは関数も同じだ。

~~~cpp
void assign_3( int x )
{
    x = 3 ;
}

int main()
{
    int a = 1 ;
    assign_3( a ) ;

    // a == 1
}
~~~

しかし、ときには変数の値を直接書き換えたい場合がある。このとき`lvalue`リファレンス(reference)が使える。`lvalue`リファレンスは変数に`&`を付けて宣言する

~~~cpp
int main()
{
    int a = 1 ;
    int & ref = a ;

    ref = 3 ;

    // a == 3
    // refはaなので同じく3
}
~~~

この例で、変数`ref`は変数`a`への参照(リファレンス)なので、変数`a`と同じように使える。

`lvalue`リファレンスは必ず初期化しなければならない。

~~~cpp
int main()
{
    // エラー
    int & ref ;
}
~~~

`lvalue`リファレンスは関数でも使える。

~~~cpp
void f( int & x )
{
    x = 3 ;
}

int main()
{
    int a = 1 ;
    f( a ) ;

    // a == 3
}
~~~


選択ソートで2つの変数の値を交換する必要があったことを覚えているだろうか。

~~~cpp
int main()
{
    std::vector<int> v = {3,2,1,4,5} ;

    // 0番目と2番目の要素を交換したい
    auto temp = v.at(0) ;
    v.at(0) = v.at(2) ;
    v.at(2) = temp ;
}
~~~

いちいち交換のために別の変数`temp`を作って3回代入を書くのは面倒だ。これを関数にしてしまいたい。

~~~cpp
// 値を交換
swap( v.at(0), v.at(2) ) ;
~~~

このような関数`swap`は普通に書くことはできない。

~~~cpp
// この実装は正しくない
auto swap = []( auto a, auto b )
{
    auto temp = a ;
    a = b ;
    b = temp ;
} ;
~~~


この実装では、変数は単にコピーされるだけなので、関数の呼び出し元には何の影響もない。

これを`lvalue`リファレンスに変えると、関数の呼び出し元の変数の値を交換する関数`swap`が作れる。


~~~cpp
// lvalueリファレンス
auto swap = []( auto & a, auto & b )
{
    auto temp = a ;
    a = b ;
    b = temp ;
} ;
~~~

C++の標準ライブラリには`std::swap`があるので、読者はわざわざこのような関数を自作する必要はない。

~~~cpp
int main()
{
    int a = 1 ;
    int b = 2 ;

    std::swap( a, b ) ;

    // a == 2
    // b == 1
}
~~~

ところで、この章では一貫して`lvalue`リファレンスと書いているのに気が付いただろうか。`lvalue`とは何なのか、`lvalue`ではないリファレンスはあるのか。その疑問はあとの章で解決する。

## const

値を変更したくない変数は、`const`を付けることで変更を禁止できる。

~~~cpp
int main()
{
    int x = 0 ;
    x = 1 ; // OK、変更できる

    const int y = 0 ;
    y = 0 ; // エラー、変更できない。
}
~~~

`const`はちょっと文法が変わっていて混乱する。例えば、`const int`でも`int const`でも意味が同じだ。

~~~cpp
int main()
{
    // 意味は同じ
    const int x = 0 ;
    int const y = 0 ;
}
~~~

`const`は`lvalue`リファレンスと組み合わせることができる。


~~~cpp
int main()
{
    int x = 0 ;

    int & ref = x ;
    // OK
    ++ref ;

    const int & const_ref = x ;

    // エラー
    ++const_ref ;
}
~~~

`const`は本当に文法が変わっていて混乱する。`const int &`と`int const &`は同じ意味だが、`int & const`はエラーになる。

~~~cpp
int main()
{
    int a = 0 ;

    // OK、意味は同じ
    const int & b = a ;
    int const & c = a ;

    // エラー
    int & const d = a ;
}
~~~

これはとても複雑なルールで決まっているので、こういうものだとあきらめて覚えるしかない。


`const`が付いていない型のオブジェクトを`const`な`lvalue`リファレンスで参照することができる。

~~~cpp
int main()
{
    // constの付いていない型のオブジェクト
    int x = 0 ;

    // OK
    int & ref = x ;
    // OK、constは付けてもよい
    const int & cref = x ;
}
~~~

`const`の付いている型のオブジェクトを`const`の付いていない`lvalue`リファレンスで参照することはできない。

~~~cpp
int main()
{
    // constの付いている型のオブジェクト
    const int x = 0 ;

    // エラー、constがない
    int & ref = x ;

    // OK、constが付いている
    const int & cref = x ;
}
~~~

`const`の付いている`lvalue`リファレンスは何の役に立つのかというと、関数の引数を取るときに役に立つ。

例えば以下のコードは非効率的だ。

~~~cpp
void f( std::vector<int> v )
{
    std::cout << v.at(1234) ;
}

int main()
{
    // 10000個の要素を持つvector
    std::vector<int> v(10000) ;

    f( v ) ;
}
~~~

なぜかというと、関数の引数に渡すときに、変数`v`はコピーされるからだ。

リファレンスを使うと不要なコピーをしなくて済む。

~~~cpp
void f( std::vector<int> & v )
{
    std::cout << v.at(1234) ;
}
~~~

しかし、リファレンスで受け取ると、うっかり変数を変更してしまった場合、その変更が関数の呼び出し元に反映されてしまう。

~~~cpp
// 値を変更するかもしれない
void f( std::vector<int> & v ) ;

int main()
{
    // 要素数10000のvector
    std::vector<int> v(10000) ;

    f(v) ;

    // 値は変更されているかもしれない
}
~~~

このとき、`const`な`lvalue`リファレンスを使うと、引数に取った値を変更しないことを保証できる。

~~~cpp
void f( std::vector<int> const & v ) ;
~~~
