# スマートポインター

この章では、コピーできないがムーブできる型として、スマートポインターを説明する。

ストレージを動的確保した場合、解放しなければならない。

~~~cpp
void f()
{
    int * ptr = new int(0) ;
    delete * ptr ;
}
~~~

これを正しく行うのは難しい。というのも、動的確保を複数する場合、動的確保が失敗する可能性があるからだ。

~~~cpp
void f()
{
    int * p1 = new int(0) ;
    int * p2 = new int(1) ;

    delete p2 ;
    delete p1 ;
}
~~~

この何気ない一見問題のなさそうなコードには問題がある。もし`new int(1)`が失敗した場合、例外が投げられ、そのまま関数`f`の実行は終わってしまう。後続の`delete`は実行されない。

そのような場合にスマートポインターが使える。スマートポインターはポインターの解放とムーブを代わりに行ってくれる便利なライブラリだ。

## unique_ptr

`std::unique_ptr<T>`は以下のように使う。

~~~c++
auto ptr = std::make_unique<型>( 初期化コンストラクターへの引数 )
~~~

具体的には以下のようになる。

~~~cpp
void f()
{
    // std::unique_ptr<int>
    auto p1 = std::make_unique< int >( 0 ) ;
    auto p2 = std::make_unique< int >( 1 ) ;
}
~~~

`delete`がないが問題はない。`delete`は`unique_ptr`のデストラクターが自動で呼んでくれるからだ。

`p2`の動的確保が失敗した場合でも問題はない。

`unique_ptr`はポインターとほぼ同じように使うことができる。例えばポインターが参照するオブジェクトを間接的に使いたい場合は`operator *`を使う。

~~~cpp
int main()
{
    auto p = std::make_unique< int >( 0 ) ;

    *p = 123 ;
    std::cout << *p ;
}
~~~

メンバーにアクセスするときには`operator ->`も使える。

~~~cpp
int main()
{
    auto p = std::make_unique< std::vector<int> > () ;
    p->push_back(0) ;
}
~~~

`unique_ptr`はたいへん便利なのであらゆる箇所で生のポインターの代わりに使うべきだが、古い関数に生のポインターを渡さなければならない場合などは`unique_ptr`を渡せない。そのような場合のために`unique_ptr`、生のポインターを得る方法がある。メンバー関数`get`だ。

~~~cpp
// 古臭い時代遅れの生ポインターを引数に取る関数
void old_outdated_ugly_function( int * ptr ) ;

int main()
{
    auto ptr = std::make_unique<int>(0) ;
    old_outdated_ugly_function( ptr.get() ) ;
}
~~~

ただし`get`を使うときは生のポインターを使う期間が`unique_ptr`の寿命の期間内でなければならない。

以下のような場合は使えない。

~~~cpp
// 前回渡したポインターの参照する値と
// 今回渡したポインターの参照する値が
// 等しい場合にtrueを返す
int * last_ptr ;
bool is_equal_to_last_ptr( int * ptr )
{
    if ( last_ptr == nullptr )
        last_ptr = ptr ;

    bool b =  *ptr == *last_ptr ;
    last_ptr = ptr ;
    return b ;
}

void f()
{
    auto p = std::make_unique<int>(0) ;
    is_equal_to_last_ptr( p.get() ) ;
}

int main()
{
    f() ;
    // エラー
    f() ; 
}
~~~

これは関数`f`が`unique_ptr`の寿命の期間を超えてポインターを保持して参照しているからだ。

`unique_ptr`はコピーができない。

~~~cpp
int main()
{
    auto p = std::make_unique<int>(0) ;
    // エラー、コピーはできない
    auto q = p ;
}
~~~

これはポインターの値をコピーして、ポインターの所有権を持つオブジェクトが複数存在することを防ぐためだ。

ムーブはできる。


~~~cpp
int main()
{
    auto p = std::make_unique<int>(0) ;
    auto q = std::move(p) ;
}
~~~

ムーブしたあとの変数`p`はポインターの所有権を持たない。

`unique_ptr`の実装はとても簡単だ。例えば簡易的なものならば1ページに収まるほどのコード量で書ける。

~~~cpp
template < typename T >
class unique_ptr
{
    T * ptr = nullptr ;
public :
    unique_ptr() { }
    explicit unique_ptr( T * ptr )
        : ptr( ptr ) { }
    ~unique_ptr()
    { delete ptr ; }

    // コピーは禁止
    unique_ptr( const unique_ptr & ) = delete ;
    unique_ptr & operator =( const unique_ptr & ) = delete ;

    // ムーブ
    unique_ptr( unique_ptr && r )
        : ptr( r.ptr )
    { r.ptr = nullptr ; }
    unique_ptr & operator = ( unique_ptr && r )
    {
        delete ptr ;
        ptr = r.ptr ;
        r.ptr = nullptr ;
    }

    T & operator * () noexcept { return *ptr ; }
    T * operator ->() noexcept { return ptr ; } 
    T * get() noexcept { return ptr ; }
} ;
~~~

コンストラクターでポインターを受け取り、デストラクターで破棄する。コピーは禁止。ムーブは所有権を移動。特に解説するまでもなくコードを読むだけでいいほどの単純な実装だ。

現実の`unique_ptr`はもう少し便利な機能を提供しているので、実装はもう少し複雑になっているが、基本的な実装としては変わらない。

## shared_ptr

`unique_ptr`は便利だがコピーができない。コピーができないのは`unique_ptr`がポインターの所有権を排他的に独占するからだ。これはどうにもならないが、コピーしたいものはコピーしたい。

そこで、コピーができるスマートポインターとして`shared_ptr`がある。

`unique_ptr<T>`は`make_unique<T>(...)`で作るように、`shared_ptr<T>`は`std::make_shared<T>(...)`で作る。

~~~cpp
int main()
{
    auto p = std::make_shared<int>(0) ;
}
~~~

`unique_ptr`と同じようにポインターのように使うことができる。

`shared_ptr`はコピーができる。

~~~cpp
auto p1 = std::make_shared<int>(0) ;
auto p2 = p1 ;
auto p3 = p1 ;
~~~

しかも、コピーはすべて同じポインターを持っている。例えば以下のようにすると、

~~~cpp
*p3 = 123 ;
~~~

`*p1, *p2, *p3`はいずれも`123`になる。

これはどれも同じポインターの値を保持しているためだ。`p1.get(), p2.get(), p3.get()`はすべて同じポインターの値を返す。

`shared_ptr`は本当に何も考えずに気軽にコピーしてもよい。例えば以下のような本当に汚いコードですら動く。

~~~cpp
std::shared_ptr<int> last_ptr ;

bool is_equal_to_last_ptr( std::shared_ptr<int> ptr )
{
    if ( last_ptr == nullptr )
        last_ptr = ptr ;

    bool b = *last_ptr == *ptr ;
    last_ptr = ptr ;
    return b ; 
}

int main()
{
    auto p1 = std::make_shared<int>(1) ;
    auto p2 = std::make_shared<int>(2) ;

    // true
    is_equal_to_last_ptr( p1 ) ;
    // false
    is_equal_to_last_ptr( p2 ) ;
    *p2 = 1 ;
    // true
    is_equal_to_last_ptr( p1 ) ;
}
~~~

`shared_ptr`はコピーされたすべての`shared_ptr`のオブジェクトが同じポインターを共有する。ポインターを所有する最後の`shared_ptr`のオブジェクトが破棄されたときに、ポインターが`delete`される。

そのため、`shared_ptr`を使うときは、ポインターが有効なオブジェクトを指すかどうかを気にしなくてよい。そのポインターを所有する`shared_ptr`のオブジェクトが1つでも生き残っている限り、ポインターは有効になっている。

`shared_ptr`はどうやって実装されているのだろうか。`shared_ptr<T>`は`T`へのポインターのほかに、現在何個の`shared_ptr`のオブジェクトがポインターを所有しているのかを数えるカウンターへのポインターを持っている。

~~~cpp
template < typename T >
class shared_ptr
{
    T * ptr ;
    std::size_t * count ;
} ;
~~~

`shared_ptr`が初めて作られるとき、このカウンター用にストレージが動的確保され、値が`1`になる。

~~~cpp
explicit shared_ptr( T * ptr )
    : ptr( ptr ), count( new std::size_t(1) )
{ }
~~~

コピーされるとき、カウンターがインクリメントされる。

~~~cpp
shared_ptr( const shared_ptr & r )
    : ptr( r.ptr ), count( r.count )
{
    ++*count ;
}
~~~

デストラクターでは、カウンターがデクリメントされる。そしてカウンターがゼロの場合、ポインターが`delete`される。

~~~cpp
~shared_ptr()
{
    // カウンターが妥当なポインターを指しているかどうか確認
    if ( count == nullptr )
        return ;

    // デクリメント
    --*count ;
    // 所有者が0ならば
    if ( *count == 0 )
    {   // 解放する
        delete ptr ;
        ptr = nullptr ;
        delete count ;
        count = nullptr ;
    }
}
~~~

全体としては少し長いが、以下のようになる。

~~~cpp
template < typename T >
class shared_ptr
{
    T * ptr = nullptr ;
    std::size_t * count = nullptr ;

    void release()
    {
        if ( count == nullptr )
            return ;

        --*count ;
        if ( *count == 0 )
        {
            delete ptr ;
            ptr = nullptr ;
            delete count ;
            count = nullptr ;
        }
    }
public :

    shared_ptr() { }
    explicit shared_ptr( T * ptr )
        : ptr(ptr), count( new std::size_t(1) )
    { }
    ~shared_ptr()
    {
        release() ;
    }

    shared_ptr( const shared_ptr & r )
        : ptr( r.ptr ), count( r.count )
    {
        ++*count ;
    }
    shared_ptr & operator =( const shared_ptr & r )
    {
        if ( this == &r )
            return *this ;

        release() ;
        ptr = r.ptr ;
        count = r.count ;
        ++*count ;
    }

    shared_ptr( shared_ptr && r )
        : ptr(r.ptr), count(r.count)
    {
        r.ptr = nullptr ;
        r.count = nullptr ;
    }

    shared_ptr & operator =( shared_ptr && r )
    {
        release() ;
        ptr = r.ptr ;
        count = r.count ;
        r.ptr = nullptr ;
        r.count = nullptr ;
    }

    T & operator * () noexcept { return *ptr ; }
    T * operator ->() noexcept { return ptr ; } 
    T * get() noexcept { return ptr ; }
} ;
~~~

これはとても簡易的な`shared_ptr`の実装だ。本物の`std::shared_ptr`はもっと複雑で、もっと高度な機能を提供している。
