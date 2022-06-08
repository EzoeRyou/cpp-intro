# アルゴリズム

アルゴリズムは難しい。アルゴリズム自体の難しさに加え、アルゴリズムを正しくコードで表記するのも難しい。そこでC++ではアルゴリズム自体をライブラリにしている。ライブラリとしてのアルゴリズムを使うことで、読者はアルゴリズムを自前で実装することなく、すでに正しく実装されたアルゴリズムを使うことができる。

## for_each

例えば`vector`の要素を先頭から順番に標準出力するコードを考えよう。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;

    for (
        auto i = std::begin(v),
             j = std::end(v) ;
        i != j ;
        ++i  )
    {
        std::cout << *i ;
    }
}
~~~

このコードを書くのは難しい。このコードを書くには、イテレーターで要素の範囲を取り、ループを実行するごとにイテレーターを適切にインクリメントし、イテレーターが範囲内であるかどうかの判定をしなければならない。

アルゴリズムを理解するだけでも難しいのに、正しくコード書くのはさらに難しい。例えば以下はコンパイルが通る完全に合法なC++だが間違っている。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;

    for (
        auto i = std::begin(v),
             j = std::end(v) ;
        i == j ;
        ++i  )
    {
        std::cout << i ;
    }
}
~~~

間違っている箇所がわかるだろうか。

まず比較の条件が間違っている。`i != j`となるべきところが`i == j`となっている。出力する部分も間違っている。イテレーター`i`が指し示す値を得るには`*i`としなければならないところ、単に`i`としている。

毎回このようなイテレーターのループをする`for`文を書くのは間違いの元だ。ここで重要なのは、要素のそれぞれに対して`std::cout << *i ;`を実行するということだ。要素を先頭から末尾まで順番に処理するというのはライブラリにやってもらいたい。

そこでこの処理を関数に切り出してみよう。イテレーター`[first,last)`を渡すと、イテレーターを先頭から末尾まで順番に処理してくれる関数は以下のように書ける。


~~~cpp
auto print_all = []( auto first, auto last )
{
    // ループ
    for ( auto iter = first ; iter != last ; ++iter )
    {
        // 重要な処理
        std::cout << *iter ;
    }
} ; 

int main()
{
    std::vector<int> v = {1,2,3,4,5} ;

    print_all( std::begin(v), std::end(v) ) ;
}
~~~

関数`print_all`は便利だが、重要な処理がハードコードされている。例えば要素の集合のうち100以下の値だけ出力したいとか、値を2倍して出力したいとか、値を出力するたびに改行を出力したいという場合、それぞれに関数を書く必要がある。

~~~cpp
// 値が100以下なら出力
auto print_if_le_100 = []( auto first, auto last )
{
    for ( auto iter = first ; iter != last ; ++iter )
    { // 特別な処理
        if ( *iter <= 100 )
            std::cout << *iter ;
    }
} ;


// 値を2倍して出力
auto print_twice = []( auto first, auto last )
{
    for ( auto iter = first ; iter != last ; ++iter )
    { // 特別な処理
        std::cout << 2 * (*iter) ;
    }
} ;


// 値を出力するたびに改行を出力
auto print_with_newline = []( auto first, auto last )
{
    for ( auto iter = first ; iter != last ; ++iter )
    { // 特別な処理
        std::cout << *iter << "\n"s ;
    }
} ;
~~~

これを見ると、`for`文によるイテレーターのループはまったく同じコードだとわかる。

まったく同じ`for`文を手で書くのは間違いの元だ。同じコードはできれば書きたくない。ここで必要なのは、共通な処理は一度書くだけで済ませ、特別な処理だけを記述すれば済むような方法だ。

この問題を解決するには、問題を分割することだ。問題を「`for`文によるループ」と「特別な処理」に分けることだ。

ところで、関数は変数に代入できる。

~~~cpp
int main()
{
    // 変数に代入された関数
    auto print = []( auto x ) { std::cout << x ; } ;

    // 変数に代入された関数の呼び出し
    print(123) ;
}
~~~

変数に代入できるということは、関数の引数として関数に渡せるということだ。

~~~cpp
int main()
{
    // 関数を引数に取り呼び出す関数
    auto call_func = []( auto func )
    {
        func(123) ;
    } ;

    // 引数を出力する関数
    auto print = []( auto x ) { std::cout << x ; } ;

    call_func( print ) ;

    // 引数を2倍して出力する関数
    auto print_twice = []( auto x ) { std::cout << 2*x ; } ;

    call_func( print_twice ) ;
}
~~~

すると、要素ごとの特別な処理をする関数を引数で受け取り、要素ごとに関数を適用する関数を書くとどうなるのか。

~~~cpp
auto for_each = []( auto first, auto last, auto f )
{
    for ( auto iter = first ; iter != last ; ++iter )
    {
        f( *iter ) ;
    }
} ;
~~~

この関数はイテレーターをループで回す部分だけを実装していて、要素ごとの処理は引数に取った関数に任せている。さっそく使ってみよう。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;

    // 引数を出力する関数
    auto print_value = []( auto value ) { std::cout << value ; } ;

    for_each( std::begin(v), std::end(v), print_value ) ;

    // 引数を2倍して出力する関数
    auto print_twice = []( auto value ) { std::cout << 2 * value ; } ;

    for_each( std::begin(v), std::end(v), print_twice ) ;

    // 引数を出力したあとに改行を出力する関数
    auto print_with_newline = []( auto value ) { std::cout << value << "\n"s ; } ;

    for_each( std::begin(v), std::end(v), print_with_newline ) ;
}
~~~

関数は変数に代入しなくても使えるので、上のコードは以下のようにも書ける。


~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;

    // 引数を出力する
    for_each( std::begin(v), std::end(v),
        []( auto value ) { std::cout << value ; } ) ;

    // 引数を2倍して出力する
    for_each( std::begin(v), std::end(v),
        []( auto value ) { std::cout << 2 * value ; } ) ;

    // 引数を出力したあとに改行を出力する関数
    for_each( std::begin(v), std::end(v),
        []( auto value ) { std::cout << value << "\n"s ; } ) ;
}
~~~

わざわざ`for`文を書かずに、問題の本質的な処理だけを書くことができるようになった。

このイテレーターを先頭から末尾までループで回し、要素ごとに関数を呼び出すという処理はとても便利なので、標準ライブラリには`std::for_each( first, last, f)`がある。使い方は同じだ。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;

    std::for_each( std::begin(v), std::end(v),
        []( auto value ) { std::cout << value ; } ) ;
}
~~~

C++17の時点ではまだ使えないが、将来のC++では、イテレーターを渡さずに、`vector`を直接渡すことができるようになる予定だ。

~~~cpp
// C++20予定

int main()
{
    std::vector<int> v = {1,2,3,4,5} ;

    std::for_each( v, []( auto value ) { std::cout << value ; } ) ;
}
~~~

ところでもう一度`for_each`の実装を見てみよう。


~~~cpp
auto for_each = []( auto first, auto last, auto f )
{
    for ( auto iter = first ; iter != last ; ++iter )
    {
        f( *iter ) ;
    }
} ;
~~~

`f(*iter)`がとても興味深い。もし関数`f`がリファレンスを引数に取っていたらどうなるだろうか。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;

    // 引数をリファレンスで取って2倍にする関数
    auto twice = [](auto & value){ value = 2 * value ; } ;

    std::for_each( std::begin(v), std::end(v), twice ) ;

    // 引数を出力する関数
    auto print = [](auto & value){ std::cout << value << ", "s ; } ;

    // 2, 4, 6, 8, 10, 
    std::for_each( std::begin(v), std::end(v), print ) ;
}
~~~

元の`vector`を書き換えることもできる。



## all_of/any_of/none_of

ほかのアルゴリズムも実装していくことで学んでいこう。

`all_of(first, last, pred)`は、`[first,last)`の間のイテレーター`iter`のそれぞれに対して、`pred(*iter)`がすべて`true`を返すならば`true`、そうではないならば`false`を返すアルゴリズムだ。

この`all_of`は要素がすべて条件を満たすかどうかを調べるのに使える。

~~~cpp
// 要素がすべて偶数かどうか調べる関数
auto is_all_of_odd = []( auto first, auto last )
{
    return std::all_of( first, last,
        []( auto value ) { return value % 2 == 0 ; } ) ;
} ;

// 要素がすべて100以下かどうか調べる関数
auto is_all_of_le_100 = []( auto first, auto last )
{
    return std::all_of( first, last,
        []( auto value ) { return value <= 100; } ) ;
} ;
~~~

ところで、もし要素がゼロ個の、つまり空のイテレーターを渡した場合どうなるのだろうか。

~~~cpp
int main()
{
    // 空のvector
    std::vector<int> v ;

    bool b = std::all_of( std::begin(v), std::end(v),
        // 特に意味のない関数
        [](auto value){ return false ; } ) ;
}
~~~

この場合、`all_of`は`true`を返す。

実装は以下のようになる。

~~~cpp
auto all_of = []( auto first, auto last, auto pred )
{
    for ( auto iter = first ; iter != last ; ++iter )
    {
        if ( pred( *iter ) == false )
            return false ;
    }

    return true ;
} ;
~~~

`[first,last)`が空かどうかを確認する必要はない。というのも、空であればループは一度も実行されないからだ。

`any_of(first, last, pred)`は`[first,last)`の間のイテレーター`iter`それぞれに対して、`pred(*iter)`が1つでも`true`ならば`true`を返す。空の場合、すべて`false`の場合は`false`を返す。

`any_of`は要素に1つでも条件を満たすものがあるかどうかを調べるのに使える。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;

    // 要素に1つでも3が含まれているか？
    // true
    bool has_3 = std::any_of( std::begin(v), std::end(v),
        []( auto x ) { return x == 3 ;}  ) ;

    // 要素に1つでも10が含まれているか？
    // false
    bool has_10 = std::any_of( std::begin(v), std::end(v),
        []( auto x ) { return x == 10 ;}  ) ;
}
~~~

これも実装してみよう。

~~~cpp
auto any_of = []( auto first, auto last, auto pred )
{
    for ( auto iter = first ; iter != last ; ++iter )
    {
        if ( pred( *iter ) )
            return true ;
    }
    return false ;
} ;
~~~

`none_of(first, last, pred)`は`[first,last)`の間のイテレーター`iter`それぞれに対して、`pred(*iter)`がすべて`false`ならば`true`を返す。空の場合は`true`を返す。それ以外は`false`を返す。

`none_of`はすべての要素が条件を満たさない判定に使える。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;

    // 値は100か？
    auto is_100 = [](auto x){ return x == 100 ; } ;

    bool b = std::none_of( std::begin(v), std::end(v), is_100 ) ;
}
~~~

これも実装してみよう。

~~~cpp
auto none_of = []( auto first, auto last, auto pred )
{
    for ( auto iter = first ; first != last ; ++iter )
    {
        if ( pred(*iter) )
            return false ;
    }
    return true ;
} ;
~~~



## find/find_if

`find( first, last, value )`はイテレーター`[first,last)`から`value`に等しい値を見つけて、そのイテレーターを返すアルゴリズムだ。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;

    // 3を指すイテレーター
    auto pos = std::find( std::begin(v), std::end(v), 3 ) ;

    std::cout << *pos ;
}
~~~

要素が見つからない場合は`last`が返る。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;

    auto pos = std::find( std::begin(v), std::end(v), 0 ) ;

    if ( pos != std::end(v) )
    {
        std::cout << "Found."s ; 
    }
    else
    {
        std::cout << "Not found."s ;
    }
}
~~~

イテレーターが`last`かどうかは実際に`last`と比較すればよい。

アルゴリズムを理解するには、自分で実装してみるとよい。さっそく`find`を実装してみよう。

~~~cpp
auto find = []( auto first, auto last, auto const & value )
{
    for ( auto iter = first ; iter != last ; ++iter )
    {
        // 値を発見したらそのイテレーターを返す
        if ( *iter == value )
            return iter ;
    }
    // 値が見つからなければ最後のイテレーターを返す
    return last ;
} ;
~~~

`value`が`auto const & value`になっているのは、リファレンスによってコピーを回避するためと、変更が必要ないためだ。しかし、`int`や`double`のような単純な型については、わざわざ`const`な`lvalue`リファレンスを使う必要はない。


`find_if(first, last, pred)`はイテレーター`[first,last)`から、要素を関数`pred`に渡したときに`true`を返す要素へのイテレーターを探すアルゴリズムだ。

関数`pred`についてはもう少し解説が必要だ。`pred`とは`predicate`の略で、以下のような形をしている。

~~~cpp
auto pred = []( auto const & value ) -> bool
{
    return true ;
} ;
~~~

関数`pred`は値を1つ引数に取り、`bool`型を返す関数だ。

さっそく使ってみよう。

~~~cpp
int main()
{
    std::vector<int> v = {1,3,5,7,9,11,13,14,15,16} ;

    // 偶数ならばtrueを返す
    auto is_even = []( auto value )
    {
        return value % 2 == 0 ;
    } ;
    // 奇数ならばtrueを返す
    auto is_odd = []( auto value )
    {
        return value % 2 == 1 ;
    } ;

    // 最初の偶数の要素
    auto even = std::find_if( std::begin(v), std::end(v), is_even ) ;
    // 最初の奇数の要素
    auto odd = std::find_if( std::begin(v), std::end(v), is_odd ) ;
}
~~~

実装はどうなるだろうか。

~~~cpp
auto find_if = []( auto first, auto last, auto pred )
{
    for ( auto iter = first ; iter != last ; ++iter )
    {
        // predがtrueを返した最初のイテレーターを返す
        if ( pred( *iter ) )
            return iter ;
    }

    return last ;
} ;
~~~

値との比較が関数になっただけだ。

つまりある値と比較する関数を渡したならば、`find_if`は`find`と同じ動きをするということだ。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;

    // 引数が3の場合にtrueを返す関数
    auto is_3 = []( auto x ) { return x == 3 ; } ;

    // 最初に関数がtrueを返す要素へのイテレーターを探すfind_if
    auto i = std::find_if( std::begin(v), std::end(v), is_3 ) ;

    // 最初に3と等しい要素へのイテレーターを返すfind
    auto j = std::find( std::begin(v), std::end(v), 3 ) ;

    // 同じイテレーター
    bool b = (i == j) ;
}
~~~

実は、関数は特別な`[=]`を使うことで、関数の外側の値をコピーして使うことができる。

~~~cpp
int main()
{
    int value = 123 ;

    auto f = [=]{ return value ; } ;

    f() ; // 123
}
~~~

特別な`[&]`を使うことで、関数の外側の値をリファレンスで使うことができる。

~~~cpp
int main()
{
    int value = 123 ;

    auto f = [&]{ ++value ; } ; 

    f() ;
    std::cout << value ; // 124
}
~~~

ということは、`find`は`find_if`で実装することもできるということだ。

~~~cpp
auto find = []( auto first, auto last, auto value )
{
    return std::find_if( first, last,
        [&]( auto elem ) { return value == elem ; } ) ;
} ;
~~~


##  count/count_if

`count(first, last, value)`は`[first,last)`の範囲のイテレーター`i`から`*i == value`になるイテレーター`i`の数を数える。

`count`は指定した値と同じ要素の数を数える関数だ。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,1,1,3,3} ;

    // 3
    auto a = std::count( std::begin(v), std::end(v), 1 ) ;
    // 1
    auto b = std::count( std::begin(v), std::end(v), 2 ) ;
    // 2
    auto c = std::count( std::begin(v), std::end(v), 3 ) ;
}
~~~

実装してみよう。

~~~cpp
auto count = []( auto first, auto last, auto value )
{
    auto counter = 0u ;
    for ( auto i = first ; i != last ; ++i )
    {
        if ( *i == value )
            ++counter ;  
    }
    return counter ;
} ;
~~~

`count_if(first, last, pred)`は`[first, last)`の範囲のイテレーター`i`から`pred(*i) != false`になるイテレーター`i`の数を返す。

`count_if`は要素を数える対象にするかどうかを判定する関数を渡せる`count`だ。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,1,1,3,3} ;

    // 奇数の数: 5
    auto a = std::count_if( std::begin(v), std::end(v),
        [](auto x){ return x%2 == 1 ; } ) ;

    // 偶数の数: 1
    auto b = std::count_if( std::begin(v), std::end(v),
        [](auto x){ return x%2 == 0 ; } ) ;

    // 2以上の数: 3
    auto c = std::count_if( std::begin(v), std::end(v),
        [](auto x){ return x >= 2 ; } ) ;
}
~~~

実装してみよう。

~~~cpp
auto count_if = []( auto first, auto last, auto pred )
{
    auto counter = 0u ;
    for ( auto i = first ; i != last ; ++i )
    {
        if ( pred(*i) != false )
            ++counter ;  
    }
    return counter ;
} ;
~~~

## equal

これまでのアルゴリズムは1つのイテレーターの範囲だけを扱ってきた。アルゴリズムの中には複数の範囲を取るものもある。

`equal(first1, last1, first2, last2)`は`[first1, last1)`と`[first2, last2)`が等しい場合に`true`を返す。「等しい」というのは、要素の数が同じで、各要素がそれぞれ等しい場合を指す。

~~~cpp
int main()
{
    std::vector<int> a = {1,2,3,4,5} ;
    // aと等しい
    std::vector<int> b = {1,2,3,4,5} ;
    // aと等しくない
    std::vector<int> c = {1,2,3,4,5,6} ;
    // aと等しくない
    std::vector<int> d = {1,2,2,4,6} ;

    // true
    bool ab = std::equal(
        std::begin(a), std::end(a),
        std::begin(b), std::end(b) ) ;

    // false
    bool ac = std::equal(
        std::begin(a), std::end(a),
        std::begin(c), std::end(c) ) ;

    // false
    bool ad = std::equal(
        std::begin(a), std::end(a),
        std::begin(d), std::end(d) ) ;
}
~~~

実装は、まず要素数を比較し、等しくなければ`false`を返す。次に各要素を1つずつ比較し、途中で等しくない要素が見つかれば`false`を、最後まで各要素が等しければ`true`を返す。

イテレーターの範囲`[first, last)`の要素数は`last-first`で取得できる。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;

    // 最初の要素
    auto first = std::begin(v) ;
    // 最後の1つ次の要素
    auto last = std::end(v) ;

    // 要素数: 5
    auto size = last - first ;

    // 最初の次の要素
    auto next = first + 1 ;

    // 4
    auto size_from_next = last - next ;
}
~~~

`last-first`という表記はわかりにくいので、C++には`distance(first, last)`というライブラリが用意されている。

~~~cpp
auto distance = []( auto first, auto last )
{
    return last - first ;
} ;
~~~

これを使えばわかりやすく書ける。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;

    // 最初の要素
    auto first = std::begin(v) ;
    // 最後の1つ次の要素
    auto last = std::end(v) ;

    // 要素数: 5
    auto size = std::distance( first, last ) ;

    // 4
    auto size_from_next = std::distance( first + 1, last ) ;
}
~~~

あとは実装するだけだ(この実装は最も効率のいい実装ではない。理由についてはイテレーターの章を参照)。

~~~cpp
auto equal = []( auto first1, auto last1, auto first2, auto last2)
{
    // 要素数が等しいことを確認
    auto size1 = std::distance( first1, last1 ) ;
    auto size2 = std::distance( first2, last2 ) ;

    if ( size1 != size2 )
        // 要素数が等しくなかった
        return false ;

    // 各要素が等しいことを確認
    for (   auto i = first1, j = first2 ;
            i != last1 ; ++i, ++j )
    {
        if ( *i != *j )
            // 等しくない要素があった
            return false ;
    }
    // 各要素がすべて等しかった
    return true ;
} ;
~~~

`for`文の終了条件では`i != last1`だけを見ていて、`j != last2`は見ていないが、これは問題がない。なぜならば、この`for`文が実行されるのは、要素数が等しい場合だけだからだ。

関数`pred`を取る`equal(first1, last1, first2, last2, pred)`もある。この`pred`は`pred(a, b)`で、`a`と`b`が等しい場合に`true`、そうでない場合に`false`を返す関数だ。つまり`a == b`の`operator ==`の代わりに使う関数を指定する。

`equal`に関数を渡すことにより、例えば小数点以下の値を誤差として切り捨てるような処理が書ける。

~~~cpp
int main()
{
    std::vector<double> v = {1.3, 2.2, 3.0, 4.9, 5.7} ;
    std::vector<double> w = {1.9, 2.4, 3.8, 4.5, 5.0} ;

    // 小数点以下は誤差として切り捨てる比較
    auto comp = []( auto a, auto b )
    {
        return std::floor(a) == std::floor(b) ;
    } ;

    bool b = std::equal(
        std::begin(v), std::end(v),
        std::begin(w), std::end(w),
        comp ) ;
}
~~~

`std::floor(x)`は浮動小数点数`x`の小数点数以下を切り捨てた結果を返す関数だ。`floor(0.999)`は`0.0`に、`floor(1.999)`は`1.0`になる。

本書をここまで読んできた読者であれば実装は自力でできるだろう。

## search

`search(first1, last1, first2, last2)`はイテレーター`[first2, last2)`の範囲で示された連続した要素の並びがイテレーター`[first1, last1)`の範囲に存在すれば、その要素の並びの最初のイテレーター、`[first2, last2)`が空である場合は`first1`、連続した要素の並びが見つからない場合は`last1`を返す。

こう書くと難しいが、例をみると

~~~cpp
int main()
{
    std::vector v1 = {1,2,3,4,5,6,7,8,9} ;
    std::vector v2 = {4,5,6} ;

    // v1の中の最初の連続した4,5,6の4を指すイテレーターを返す
    auto a = std::search( std::begin(v1), std::end(v1), std::begin(v2), std::end(v2) ) ;
    // true
    bool A = ( a == std::next( std::begin(v1), 3 ) ) ;

    // [first2, last2)は空のイテレーター
    // first1を返す
    auto b = std::search( std::begin(v1), std::end(v1), std::end(v2), std::end(v2) ) ;
    // true
    bool B = ( b == std::begin(v1) ) ;

    std::vector v3 = {3,2,1} ;
    // [first2, last2)は[fist1, last1)に存在しない
    // last1を返す
    auto c = std::search( std::begin(v1), std::end(v1), std::begin(v3), std::end(v3) ) ;
    // true
    bool C = ( c == std::end(v1) ) ;
}
~~~

この例では、`v1`の中に`v2`と同じ並びの`{4,5,6}`が存在するので戻り値`a`は`std::bigin(v1)`から3つ先のイテレーターに等しく、`[first2, last2)`に空のイテレーターが渡されたので戻り値bは`std::begtin(v1)`と等しく、`v3`と同じ並びの`{3,2,1}`は`v1`に存在しないので戻り値cは`std::end(v1)`に等しくなる。

`search`の実装例はいまの読者にはまだ理解できない。`equal`や`search`を効率的に実装するにはイテレーターの詳細な理解が必要だ。

## copy

これまでのアルゴリズムは`for_each`を除き要素の変更をしてこなかった。`copy`は要素の変更をするアルゴリズムだ。

イテレーター`i`は`*i`で参照する要素の値として使うことができるほか、`*i = x`で要素に値`x`を代入できる。

~~~cpp
int main()
{
    std::vector<int> v = {1} ;

    auto i = std::begin(v) ;

    // 参照する要素を値として使う
    std::cout << *i ;
    // 参照する要素に値を代入する。
    *i = 2 ;
}
~~~

`copy(first, last, result)`はイテレーター`[first, last)`の範囲の値を、先頭から順番にイテレーター`result`に書き込んでいくアルゴリズムだ。

~~~cpp
int main()
{
    std::vector<int> source = {1,2,3,4,5} ;
    // 要素数5のvector
    std::vector<int> destination(5) ;

    std::copy( std::begin(source), std::end(source), std::begin(destination) ) ;

    // destinationの中身は{1,2,3,4,5}
}
~~~

これは実質的に以下のような操作をしたのと等しい。


~~~cpp
int main()
{
    std::vector<int> source = {1,2,3,4,5} ;
    std::vector<int> destination(5) ;
    // 要素をそれぞれコピー 
   destination[0] = source[0] ;
   destination[1] = source[1] ;
   destination[2] = source[2] ;
   destination[3] = source[3] ;
   destination[4] = source[4] ;
   
}
~~~

イテレーター`result`は先頭のイテレーターのみで末尾のイテレーターは渡さない。イテレーター`result`はイテレーター`[first, last)`の範囲の要素数をコピーできるだけの要素数の範囲を参照していなければならない。

例えば以下の例はエラーになる。


~~~cpp
int main()
{
    std::vector<int> source = {1,2,3,4,5} ;
    // 要素数3のvector
    std::vector<int> destination(3) ;

    // エラー
    std::copy( std::begin(source), std::end(source), std::begin(destination) ) ;
}
~~~

要素数が3しかない`vector`に5個の要素をコピーしようとしている。

`copy`の戻り値は`[first,last)`の要素数だけ進めたイテレーター`result`になる。これはつまり、`result + (last - first)`だ。

~~~cpp
int main()
{
    std::vector<int> source = {1,2,3,4,5} ;
    std::vector<int> destination(5) ;
    
    auto first = std::begin(source) ;
    auto last = std::end(source) ;
    auto result = std::begin(destination) ;
    
    auto returned = std::copy( first, last, result ) ;

    // true
    bool b = (returned == (result + (last - first)) ;
}
~~~

ここで、`last-first`は`source`の要素数の`5`なので、`result + 5`は`copy`の戻り値のイテレーターと等しい。

`copy`には`[first,last)`の範囲が`result`から続く範囲とオーバーラップしてはいけないという制約がある。

オーバーラップというのは、同じ要素を参照しているという意味だ。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3} ;

    // [first,last)とresultがオーバーラップしている
    std::copy( std::begin(v), std::end(v), std::begin(v) ) ;
}
~~~

オーバーラップした場合、`copy`の動作は保証されない。

実装例。

~~~cpp
auto copy = []( auto first, auto last, auto result )
{
    for ( auto iter = first ; iter != last ; ++iter, ++result )
    { *result = *iter ; }

    return result ;
} ;
~~~


## transform

`transform(first, last, result, op)`は`copy`に似ているが、`result`へのコピーが`*result = *iter ;`ではなく、`*result = op(*iter) ;`になる。`op`は関数だ。

以下が実装例だ。`copy`とほぼ同じだ。

~~~cpp
auto transform = []( auto first, auto last, auto result, auto op )
{
    for ( auto iter = first ; iter != last ; ++iter, ++result )
    { *result = op(*iter) ; }

    return result ;
} ;
~~~

使い方は`copy`と似ているが、値をコピーをする際に関数を適用することができる。

~~~cpp
int main()
{
    std::vector<int> a = {1,2,3,4,5} ;

    std::vector<int> b(5) ;
    std::transform( std::begin(a), std::end(a), std::begin(b),
        [](auto x){ return 2*x ; } ) ;
    // bは{2,4,6,8,10}


    std::vector<int> c(5) ;
    std::transform( std::begin(a), std::end(a), std::begin(c),
        [](auto x){ return x % 3 ; } ) ;
    // cは{1,2,0,1,2}

    
    std::vector<bool> d(5) ;
    std::transform( std::begin(a), std::end(a), std::begin(d),
        [](auto x){ return x < 3 ; } ) ;
    // dは{true,true,false,false,false}
}
~~~

`result`に代入されるのは関数`op`の戻り値だ。関数`op`は値を1つの引数で受け取り値を返す関数だ。

## replace

`replace(first, last, old_value, new_value)`はイテレーター`[first,last)`の範囲のイテレーターが指す要素の値が`old_value`に等しいものを`new_value`に置換する関数だ。

~~~cpp
int main()
{
    std::vector<int> a = {1,2,3,3,4,5,3,4,5} ;
    std::replace( std::begin(a), std::end(a), 3, 0 ) ;
    // aは{1,2,0,0,4,5,0,4,5}
}
~~~

実装も簡単。

~~~cpp
auto replace = []( auto first, auto last, auto old_value, auto new_value )
{
    for ( auto iter = first ; first != last ; ++iter )
    {
        if ( *iter == old_value )
            *iter = new_value ;
    }
} ;
~~~

## fill

`fill(first, last, value)`はイテレーター`[first,last)`の範囲をイテレーターが参照する要素に`value`を代入する。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;
    std::fill( std::begin(v), std::end(v), 0 ) ;
    // vは{0,0,0,0,0}
}
~~~

`fill_n(first, n, value)`はイテレーター`[first, first+n)`の範囲のイテレーターが参照する要素に`value`を代入する関数だ。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;
    std::fill_n( std::begin(v), 5, 0 ) ;
    // vは{0,0,0,0,0}
}
~~~

実装例。

~~~cpp
auto fill_n = []( auto first, auto n, auto value )
{
    for ( auto i = 0 ; i != n ; ++i, ++first )
    {
        *first = value ;
    }
} ;
~~~


## generate

`generate`は`fill`に似ているが、値として`value`を取るのではなく、関数`gen`を取る。

`generate(first, last, gen)`はイテレーター`[first, last)`の範囲のイテレーターが参照する要素に`gen()`を代入する。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;
    auto gen_zero = [](){ return 0 ; } ;
    std::generate( std::begin(v), std::end(v), gen_zero ) ;
    // vは{0,0,0,0,0}
}
~~~

`generate_n(first, n, gen)`は`fill_n`の`generate`版だ。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;
    auto gen_zero = []{ return 0 ; } ;
    std::generate_n( std::begin(v), 5, gen_zero ) ;
    // vは{0,0,0,0,0}
}
~~~

実装例は単純だ。

~~~cpp
auto generate = []( auto first, auto last, auto gen )
{
    for ( auto iter = first ; iter != last ; ++iter )
    {
        *iter = gen() ;
    }
} ;

auto generate_n = []( auto first, auto n, auto gen )
{
    for ( auto i = 0 ; i != n ; ++i, ++first )
    {
        *first = gen() ;
    }
} ;
~~~

## remove


`remove(first, last, value)`はイテレーター`[first,last)`の範囲の参照する要素から、値`value`に等しいものを取り除く。そして新しい終端イテレーターを返す。


アルゴリズム`remove`が値を取り除くというとやや語弊がある。例えば以下のような数列があり、


~~~
1, 2, 3
~~~

この中から値`2`を`remove`のように取り除く場合、以下のようになる。

~~~
1, 3, ?
~~~

`remove`は取り除くべき値の入った要素を、後続の値で上書きする。この場合、1番目の`2`を2番目の`3`で上書きする。2番目は不定な状態になる。これは、`remove`アルゴリズムは2番目がどのような値になるかを保証しないという意味だ。

以下のような数列で値`2`を`remove`したとき

~~~
1,2,2,3,2,2,4
~~~


以下のようになる。

~~~
1,3,4,?,?,?,?
~~~

`remove`の戻り値は、新しいイテレーターの終端を返す。

~~~cpp
auto last2 = remove( first, last, value ) ;
~~~

この例では、`remove`は`[first, last)`から値`value`に等しい要素を取り除いたイテレーターの範囲を戻り値として返す。その戻り値が`last2`だ。`[first, last2)`が値を取り除いたあとの新しいイテレーターの範囲だ。

`remove`を呼び出しても元の`vector`の要素数が変わることはない。`remove`は`vector`の要素の値を変更するだけだ。

以上を踏まえて、以下が`remove`を使う例だ。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3} ;

    auto last = std::remove( std::begin(v), std::end(v), 2 ) ;

    // "13"
    std::for_each( std::begin(v), last,
        [](auto x) { std::cout << x ; } ) ;

    std::vector<int> w = {1,2,2,3,2,2,4} ;

    auto last2 = std::remove( std::begin(w), std::end(w), 2 ) ;

    // "134"
    std::for_each( std::begin(w), last2,
        [](auto x) { std::cout << x ; } ) ;
   
}
~~~

`remove_if(first, last, pred)`は、`[first, last)`の範囲の要素を指すイテレーター`i`のうち、関数`pred`に渡した結果`pred(*i)`が`true`になる要素を取り除くアルゴリズムだ。

~~~cpp
int main()
{
    // 偶数の場合true、奇数の場合falseを返す関数
    auto is_even = []( auto x ) { return x%2 == 0 ; } ;

    std::vector v = { 1,2,3,4,5,6,7,8,9 } ;
    // 偶数を取り除く
    auto last = std::remove_if( std::begin(v), std::end(v), is_even ) ;

    // [ std::begin(v), last)は{1,3,5,7,9}
}
~~~


`remove`は現在知っている知識だけではまだ完全に実装できない。以下は不完全な実装の例だ。`remove`を完全に理解するためには`ムーブセマンティクス`の理解が必要だ。

~~~cpp
auto remove_if = []( auto first, auto last, auto pred )
{
    // removeする最初の要素
    auto removing = std::find_if( first, last, pred ) ;
    // removeする要素がなかった
    if ( removing == last )
        return last ;

    // removeする要素の次の要素
    auto remaining = removing ;
    ++remaining ;

    // removeする要素に上書きする
    for (  ; remaining != last ; ++remaining )
    {
        // 上書き元も取り除くのであればスキップ
        if ( pred( *remaining ) == false )
        {
            *removing = *remaining ;
            ++removing ;
        }

    }
    // 新しい終端イテレーター
    return removing ;
} ;
~~~

