# vectorの実装 : メモリ確保

## メモリ確保の起こるタイミング

`std::vector`はどこでメモリを確保しているのだろうか。

デフォルト構築すると空になる。

~~~cpp
int main()
{
    std::vector<int> v ;
    v.empty() ; // true
}
~~~

コンストラクターに要素数を渡すことができる。

~~~cpp
int main()
{
    std::vector<int> v(100) ;
    v.size() ; // 100
}
~~~

すると`std::vector`は指定した要素数の有効な要素をもつ。

コンストラクターに要素数と初期値を渡すことができる。

~~~cpp
int main()
{
    std::vector<int> v(100, 123) ;
    v[0] ; // 123
    v[12] ; // 123
    v[68] ; // 123
}
~~~

すると、指定した要素数で、要素の値はすべて初期値になる。

vectorのオブジェクトを構築した後でも、メンバー関数`resize(size)`で要素数を`size`個にできる。

~~~cpp
int main()
{
    std::vector<int> v ;
    v.resize(10) ;
    v.size() ; // 10
    // 減らす
    v.resize(5) ;
    v.size() ; // 5
}
~~~

`resize`で要素数が増える場合、増えた要素の初期値も指定できる。

~~~cpp
int main()
{
    std::vector<int> v ;
    v.resize(3, 123) ;
    // vは{123,123,123}
}
~~~

`resize`で要素数が減る場合、末尾が削られる。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;
    v.resize(3) ;
    // vは{1,2,3}
}
~~~

メンバー関数`push_back(value)`を呼び出すと要素数が1増え、要素の末尾の要素が値`value`になる。

~~~cpp
int main()
{
    std::vector<int> v ;
    // vは{}
    v.push_back(1) ;
    // vは{1}
    v.push_back(2) ;
    // vは[1,2}
    v.push_back(3) ;
    // vは{1,2,3}
}
~~~

`reserve(size)`は少なくとも`size`個の要素が追加の動的メモリ確保なしで追加できるようにメモリを予約する。

~~~cpp
int main()
{
    std::vector<int> v ;
    // 少なくとも3個の要素を追加できるように動的メモリ確保
    v.reserve(3) ;
    v.size() ; // 0
    v.capacity() ; // 3以上

    // 動的メモリ確保は発生しない
    v.push_back(1) ;
    v.push_back(2) ;
    v.push_back(3) ;
    // 動的メモリ確保が発生する可能性がある。
    v.push_back(3) ;
}
~~~

この章ではここまでの実装をする。

## デフォルトコンストラクター

簡易vectorのデフォルトコンストラクターは何もしない。

~~~c++
vector( ) { }
~~~

何もしなくてもポインターはすべてnullptrで初期化され、アロケーターもデフォルト構築されるからだ。

これで簡易vectorの変数を作れるようになった。ただしまだ何もできない。

~~~c++
int main()
{
    vector<int> v ;
    // まだ何もできない。
}
~~~

## アロケーターを取るコンストラクター

`std::vector`のコンストラクターは最後の引数にアロケーターを取れる。

~~~cpp
int main()
{
    std::allocator<int> alloc ;
    // 空
    std::vector<int> v1(alloc) ;
    // 要素数5
    std::vector<int> v2(5, alloc) ;
    // 要素数5で初期値123
    std::vector<int> v3(5, 123, alloc) ;
}
~~~

これを実装するには、アロケーターを取ってデータメンバーにコピーするコンストラクターを書く。

~~~c++
vector( const allocator_type & alloc ) noexcept
    alloc( alloc )
{ }
~~~

他のコンストラクターはこのコンストラクターにまずデリゲートすればよい。

~~~c++
vector()
    : vector( allocator_type() )
{ }

vector( size_type size, const allocator_type & alloc = allocator_type() )
    : vector( alloc )
{ /*実装*/ }
vector( size_type size, const_reference value, const allocator_type & alloc = allocator_type() )
    : vector( alloc )
{ /*実装*/ }
~~~

## 要素数と初期値を取るコンストラクターの実装

要素数と初期値を取るコンストラクターは`resize`を使えば簡単に実装できる。

~~~c++
vector( size_type size, const allocator_type & alloc )
    : vector( alloc )
{
    resize( size ) ;
}
vector( size_type size, const_reference value, const allocator_type & alloc )
    : vector( alloc )
{
    resize( size, value ) ;
}
~~~

しかしこれは実装を`resize`に丸投げしただけだ。`resize`の実装をする前に、実装を楽にするヘルパー関数を実装する。

## ヘルパー関数

ここではvectorの実装を楽にするためのヘルパー関数をいくつか実装する。このヘルパー関数はユーザーから使うことは想定しないので、privateメンバーにする。

~~~c++
// 例
struct vector
{
private :
    // ユーザーからは使えないヘルパー関数
    void helper_function() ;
public :
    // ユーザーが使える関数
    void func()
    {
        // ヘルパー関数を使って実装
        helper_function() ;
    }
} ;
~~~

### ネストされた型名traits

アロケーターは`allocator_traits`を経由して使う。実際のコードはとても冗長になる。

~~~c++
template < typename Allocator >
void f( Allocator & alloc )
{
    std::allocator_traits<Allocator>::allocate( alloc, 1 ) ;
}
~~~

この問題はエイリアス名を使えば解決できる。

~~~c++
private :
    using traits = std::allocator_traits<allocator_type> ;

    template < typename Allocator >
    void f( Allocator & alloc )
    {
        traits::allocate( alloc, 1 ) ;
    }
~~~

### allocate/deallocate

`allocate(n)`はアロケーターから`n`個の要素を格納できる生のメモリの動的確保をして先頭要素へのポインターを返す。

`deallocate(ptr)`はポインター`ptr`を解放する。

~~~c++
private: 
    pointer allocate( size_type n )
    { return traits::allocate( alloc, n ) ; }
    void deallocate( )
    { traits::deallocate( alloc, first, capacity() ) ; }
~~~

### construct/destroy

`construct(ptr)`は生のメモリへのポインター`ptr`に`vector`の`value_type`型の値をデフォルト構築する。

`construct(ptr, value)`は生のメモリへのポインター`ptr`に値`value`のオブジェクトを構築する。

~~~c++
    void construct( pointer ptr )
    { traits::construct( alloc, ptr ) ; }
    void construct( pointer ptr, const_reference value )
    { traits::construct( alloc, ptr, value ) ; }
    // ムーブ用
    void construct( pointer ptr, value_type && value )
    { traits::construct( alloc, ptr, std::move(value) ) ; }
~~~

ムーブ用の`construct`についてはまだ気にする必要はない。この理解には、まずムーブセマンティクスを学ぶ必要がある。

`destroy(ptr)`は`ptr`の指すオブジェクトを破棄する。

~~~c++
private :
    void destroy( pointer ptr )
    { traits::destroy( alloc, ptr ) ; }
~~~

### `destroy_all/destroy_until`

`destroy_all()`は`vector`の要素を末尾から先頭に向けて順番に破棄する。

`std::vector`の初期化では、要素は先頭から末尾に向けて順番に構築される。C++では破棄は構築の逆順に行われるので、`std::vector`の破棄にあたっては、要素は末尾から先頭に向けて順番に破棄される。

~~~cpp
struct X
{
    X() { }
    ~X() { }
} ;

int main()
{
    std::vector<X> v(3) ;
}
~~~

このコードでは、`v[0], v[1], v[2]`の順番に要素が構築され、`v[2], v[1], v[0]`の順番で破棄される。

`destroy_all`の実装は、この次に説明する`destroy_until`を使う。

~~~c++
private :
    void destroy_all()
    {
        destroy_until( rend() ) ;
    }
~~~

`destroy_until(rend)`は、`vector`が保持する`rbegin()`からリバースイテレーター`rend`までの要素を破棄する。リバースイテレーターを使うので、要素の末尾から先頭に向けて順番に破棄される。


~~~c++
private :
    void destroy_until( reverse_iterator rend )
    {
        for ( auto riter = rbegin() ; riter != rend ; ++riter, --last )
        {
            destroy( &*riter ) ;
        }
    }
~~~

`&*riter`はやや泥臭い方法だ。簡易`vector<T>`の`iterator`は単なる`T *`だが、`riter`はリバースイテレーターなのでポインターではない。ポインターを取るために`*riter`でまず`T &`を得て、そこに`&`を適用することで`T *`を得ている。

破棄できたら有効な要素数を減らすために`--last`する。

## デストラクター

ヘルパー関数を組み合わせることでデストラクターが実装できるようになった。

`std::vector`のデストラクターは、

1. 要素を末尾から先頭に向かう順番で破棄
2. 生のメモリを解放する

この2つの処理はすでに実装した。デストラクターの実装は単にヘルパー関数を並べて呼び出すだけでよい。

~~~c++
~vector()
{
    // 1. 要素を末尾から先頭に向かう順番で破棄
    destroy_all() ;
    // 2. 生のメモリを解放する
    deallocate() ;    
}         
~~~


## reserveの実装

reserveの実装は生の動的メモリを確保してデータメンバーを適切に設定する。

ただし、いろいろと考慮すべきことが多い。


現在の`capacity`より小さい要素数が`reserve`された場合、無視してよい。

~~~cpp
int main()
{
    // 要素数5
    std::vector<int> v = {1,2,3,4,5} ;
    // 3個の要素を保持できるよう予約
    v.reserve( 3 ) ;
    // 無視する
}
~~~

すでに指定された要素数以上に予約されているからだ。

動的メモリ確保が行われていない場合、単に動的メモリ確保をすればよい。

~~~cpp
int main()
{
    std::vector<int> v ;
    // おそらく動的メモリ確保
    v.reserve( 10000 ) ;
}
~~~

「おそらく」というのは、C++の規格はvectorのデフォルトコンストラクターが予約するストレージについて何も言及していないからだ。すでに要素数10000を超えるストレージが予約されている実装も規格準拠だ。本書で実装している`vector`は、デフォルトコンストラクターでは動的メモリ確保をしない実装になっている。


有効な要素が存在する場合、その要素の値は引き継がなければならない。

~~~cpp
int main()
{
    // 要素数3
    std::vector<int> v = {1,2,3} ;
    // 1万個の要素を保持できるだけのメモリを予約
    v.reserve( 10000 ) ;
    // vは{1,2,3}
}
~~~

つまり動的メモリ確保をした後に、既存の要素を新しいストレージにコピーしなければならないということだ。

まとめよう。

1. すでに指定された要素数以上に予約されているなら何もしない
2. まだ動的メモリ確保が行われていなければ動的メモリ確保をする
3. 有効な要素がある場合は新しいストレージにコピーする。

古いストレージから新しいストレージに要素をコピーするとき、古いストレージと新しいストレージが一時的に同時に存在しなければならない。

疑似コード風に記述すると以下のようになる。

~~~c++
template < typename T >
void f()
{
    // すでに動的確保した古いストレージ
    auto old_ptr = new T ;

    // いま構築した新しいストレージ
    auto new_ptr = new T ;
    // 古いストレージから新しいストレージにコピー
    // *new_ptr = *old_ptr ;
    // 古いストレージを解放
    delete old_value ;
}
~~~

このとき、`T`型がコピーの最中に例外を投げると、後続の`delete`が実行されなくなる。この問題に対処して例外安全にするために、C++20に入る見込みの標準ライブラリ、`std::scope_exit`を使う。

　
~~~c++
template < typename T >
void f()
{
    // すでに動的確保した古いストレージ
    auto old_ptr = new T ;

    // いま構築した新しいストレージ
    auto new_ptr = new T ;

    // 関数fを抜けるときに古いストレージを解放する。
    std::scope_exit e( [&]{ delete old_ptr ; } ) ;

    // 古いストレージから新しいストレージにコピー
    // *new_ptr = *old_ptr ;

    // 変数eの破棄に伴って古いストレージが開放される
}
~~~

これを踏まえて`reserve`を実装する。

~~~c++
void reserve( size_type sz )
{
    // すでに指定された要素数以上に予約されているなら何もしない
    if ( sz <= capacity() )
        return ;

    // 動的メモリ確保をする
    auto ptr = allocate( sz ) ;

    // 古いストレージの情報を保存
    auto old_first = first ;
    auto old_last = last ;
    auto old_capacity = capacity() ;

    // 新しいストレージに差し替え
    first = ptr ;
    last = first ;
    reserved_last = first + sz ;

    // 例外安全のため
    // 関数を抜けるときに古いストレージを破棄する
    std::scope_exit e( [&]{ traits::deallocate( alloc, old_first, old_capacity  ) ; } ) ;

    // 古いストレージから新しいストレージに要素をコピー構築
    for ( auto old_iter = old_first ; old_iter != old_last ; ++old_iter, ++last )
    {
        // このコピーの理解にはムーブセマンティクスの理解が必要
        construct( last, std::move(*old_iter) ) ;
    }
}
~~~


## resize

`resize(sz)`は要素数を`sz`個にする。

~~~cpp
int main()
{
    // 要素数0
    std::vector<int> v ;
    // 要素数10
    v.resize(10) ;
    // 要素数5
    v.resize(5)
    // 要素数変わらず
    v.resize(5)
}
~~~

`resize`は呼び出し前より要素数を増やすことも減らすこともある。また変わらないこともある。

要素数が増える場合、増えた要素数の値はデフォルト構築された値になる。

~~~cpp
struct X
{
    X() { std::cout << "default constructed.\n" ; }
} ;

int main()
{
    std::vector<X> v ;
    v.resize(5) ;
}
~~~

このプログラムを実行すると、"default constructed.\n"は5回標準出力される。

`resize(sz, value)`は`resize`を呼び出した結果要素が増える場合、その要素を`value`で初期化する。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3} ;
    v.resize(5, 4) ;
    // vは{1,2,3,4,4} 
}
~~~

要素数が減る場合、要素は末尾から順番に破棄されていく。

~~~cpp
struct X
{
    ~X()
    { std::cout << "destructed.\n"s ; }
} ;

int main()
{
    std::vector<X> v(5) ;
    v.resize(2) ;
    std::cout << "resized.\n"s ;
}
~~~

このプログラムを実行すると、以下のように出力される。

~~~c++
destructed.
destructed.
destructed.
resized.
destructed.
destructed.
~~~

最初の`v.resize(2)`で、`v[4], v[3], v[2]`が書いた順番で破棄されていく。`main`関数を抜けるときに残りの`v[1], v[0]`が破棄される。

`resize(sz)`を呼び出したときに`sz`が現在の要素数と等しい場合は何もしない。

~~~cpp
int main()
{
    // 要素数5
    std::vector<int> v(5) ;
    v.resize(5) ; // 何もしない   
}
~~~

まとめると`resize`は以下のように動作する。

1. 現在の要素数より少なくリサイズする場合、末尾から要素を破棄する
2. 現在の要素数より大きくリサイズする場合、末尾に要素を追加する
3. 現在の要素数と等しくリサイズする場合、何もしない。

実装しよう。

~~~c++
    void resize( size_type sz )
    {
        // 現在の要素数より少ない
        if ( sz < size() )
        {
            auto diff = size() - sz ;
            destroy_until( rbegin() + diff ) ;
            last = first + sz ;
        }
        // 現在の要素数より大きい
        else if ( sz > size() )
        {
            reserve( sz ) ;
            for ( ; last != reserved_last ; ++last )
            {
                construct( last ) ;
            }
        }
    }
~~~

要素を破棄する場合、破棄する要素数だけ末尾から順番に破棄する。

要素を増やす場合、`reserve`を呼び出してメモリを予約してから、追加の要素を構築する。

`sz == size()`の場合は、どちらのif文の条件にも引っかからないので、何もしない。

`size(sz, value)`は、追加の引数を取るほか、`construct( iter )`の部分が`constrcut( iter, value )`に変わるだけだ。

~~~c++
void resize( size_type sz, const_reference value )
{
    // ...
            construct( iter, value ) ;
    // ...
}
~~~

これで自作のvectorはある程度使えるようになった。コンストラクターで要素数を指定できるし、リサイズもできる。

~~~c++
int main()
{
    vector<int> v(10, 1) ;
    v[2] = 99 ;
    v.resize(5) ;
    // vは{1,1,99,1,1}
}
~~~

## push_back

`push_back`は`vector`の末尾に要素を追加する。

~~~cpp
int main()
{
    std::vector<int> v ;
    // vは{}
    v.push_back(1) ;
    // vは{1}
    v.push_back(2) ;
    // vは{1,2}
}
~~~

push_backの実装は、末尾の予約された未使用のストレージに値を構築する。もし予約された未使用のストレージがない場合は、新しく動的メモリ確保する。

追加の動的メモリ確保なしで保持できる要素の個数はすでに実装した`capacity()`で取得できる。`push_back`は要素をひとつ追加するので、`size() + 1 <= capacity()`ならば追加の動的メモリ確保はいらない。逆に、`size() + 1 > capacity()`ならば追加の動的メモリ確保をしなければならない。追加の動的メモリ確保はすでに実装した`reserve`を使えばよい。


~~~c++
void push_back( const_reference value ) 
{
    // 予約メモリが足りなければ拡張
    if ( size() + 1 > capacity() )
    {
        // ひとつだけ増やす
        reserve( size() + 1 ) ;
    }

    // 要素を末尾に追加
    construct( last, value ) ;
    // 有効な要素数を更新
    ++last ;
}
~~~

これは動く。ただし、効率的ではない。自作のvectorを使った以下のような例を見てみよう。

~~~c++
int main()
{
    // 要素数10000
    vector<int> v(1000) ;
    // 10001個分のメモリを確保する
    // 10000個の既存の要素をコピーする
    v.push_back(0) ;
    // 10002個分のメモリを確保する
    // 10001個の既存の要素をコピーする
    v.push_back(0) ;
}
~~~

たった1つの要素を追加するのに、毎回動的メモリ確保と既存の全要素のコピーをしている。これは無駄だ。

`std::vector`は`push_back`で動的メモリ確保が必要な場合、`size()+1`よりも多くメモリを確保する。こうすると、`push_back`を呼び出すたびに毎回動的メモリ確保と全要素のコピーを行う必要がなくなるので、効率的になる。

ではどのくらい増やせばいいのか。10個づつ増やす戦略は以下のようになる。

~~~cpp
void push_back( const_reference value ) 
{
    // 予約メモリが足りなければ拡張
    if ( size() + 1 > capacity() )
    {
        // 10個増やす
        reserve( capacity() + 10 ) ;
    }
    construct( last, value ) ;
    ++last ;
}
~~~

しかしこの場合、以下のようなコードで効率が悪い。

~~~cpp
int main()
{
    std::vector<int> v ;
    for ( auto i = 0 ; i != 10000 ; ++i )
    {
        v.push_back(i) ;
    }
}
~~~

10個づつ増やす戦略では、この場合に1000回の動的メモリ確保と全要素のコピーが発生する。

上のような場合、`vector`の利用者が事前に`v.reserve(10000)`とすれば効率的になる。しかし、コンパイル時に要素数がわからない場合、その手も使えない。

~~~cpp
int main()
{
    std::vector<int> inputs ;
    // 要素数は実行時にしかわからない
    // 10万個の入力が行われるかも知れない
    std::copy(
        std::ostream_iterator<int>(std::cin),
        std::ostream_iterator<int>(),
        std::back_inserter(inputs) ) ;
}
~~~

よくある実装は、現在のストレージサイズの2倍のストレージを確保する戦略だ。

~~~cpp
void push_back( const_reference value ) 
{
    // 予約メモリが足りなければ拡張
    if ( size() + 1 > capacity() )
    {
        // 現在のストレージサイズ
        auto c = size() ;
        // 0の場合は1に
        if ( c == 0 )
            c = 1 ;
        else
            // それ以外の場合は2倍する
            c *= 2 ;

        reserve( c ) ;
    }
    construct( last, value ) ;
    ++last ;
}
~~~

`size()`は`0`を返す場合もあるということに注意。単に`reserve(size()*2)`としたのでは`size() == 0`のときに動かない。

### `shrink_to_fit`

`shrink_to_fit()`は`vector`が予約しているメモリのサイズを実サイズに近づけるメンバー関数だ。

本書で実装してきた自作の`vector`は、`push_back`時に予約しているメモリがなければ、現在の要素数の2倍のメモリを予約する実装だった。すると以下のようなコードで、

~~~c++
int main()
{
    vector<int> v ;
    std::copy( std::istream_iterator<int>(std::cin), std::istream_iterator<int>(),
        std::back_inserter(v) ) ;
}
~~~

ユーザーが4万個のint型の値を入力した場合、65536個のint型の値を保持できるだけのメモリが確保されてしまい、差し引き`sizeof(int) * 25536`バイトのメモリが未使用のまま確保され続けてしまう。

メモリ要件の厳しい環境ではこのようなメモリの浪費を避けたい。しかし、実行時にユーザーから任意の個数の入力を受けるプログラムを書く場合には、`push_back`を使いたい。

こういうとき、`shrink_to_fit`はvectorが予約するメモリを切り詰めて実サイズに近くする、かもしれない。「かもしれない」というのは、C++の標準規格は`shrink_to_fit`が必ずメモリの予約サイズを切り詰めるよう規定してはいないからだ。

自作の`vector`では必ず切り詰める実装にしてみよう。


まず予約するメモリを切り詰めるとはどういうことか。現在予約しているメモリで保持できる最大の要素数は`capacity()`で得られる。実際に保持している要素数を返すのは`size()`だ。すると`size() == capacity()`になるようにすればいい。

~~~c++
vector<int> v ;
// ...
v.shrink_to_fit() ;
v.size() == v.capacity() ; // trueにする
~~~

`shrink_to_fit()`を呼んだとき、すでに`size() == capacity()`が`true`である場合は、何もしなくてもよい。

それ以外の場合は、現在の有効な要素数分の新しいストレージを確保し、現在の値を新しいストレージにコピーし、古いメモリは破棄する。

~~~c++
void shrink_to_fit()
{
    // 何もする必要がない
    if ( size() == capacity() )
        return ;

    // 新しいストレージを確保
    auto ptr = allocate( size() ) ;
    // コピー
    auto current_size = size() ;
    for (   auto raw_ptr = ptr, iter = begin(), iter_end = end() ;
            iter != iter_end ; ++iter, ++raw_ptr )
    {
        construct( raw_ptr, *iter ) ;
    }
    // 破棄
    destroy_all() ;
    deallocate() ;
    // 新しいストレージを使う
    first = ptr ;
    last = ptr + current_size ;
    reserved_last = last ;
}
~~~

この実装は`reserve`と似ている。

