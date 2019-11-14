# ムーブ

## ムーブの使い方

ムーブ(move)とはコピー(copy)と対になる概念だ。ムーブはちょっと特殊なコピーと考えることもできる。コピーが値をコピー（複製）するのに対し、ムーブは値をムーブ（移動）させる。

コピーの仕方を振り返ってみよう。コピーにはコピー構築とコピー代入がある。

~~~cpp
T source ;
// コピー構築
T a = source ;
T b( source ) ;
T c{ source ) ;

T e ;
// コピー代入
e = source ;
~~~

コピーにはコピー先とコピー元がある。

~~~cpp
std::vector<int> source = {1,2,3} ;
std::vector<int> destination = source ;
// destinationは{1,2,3}
~~~

一般にコピー後のコピー先の値はコピー元の値と等しくなることが期待されている。


ムーブはコピーと似ている。コピーをするときに、ムーブ元の変数を`source`を`std::move(source)`のように標準ライブラリ`std::move`に渡してその戻り値をコピー元の値とすることでムーブになる。ムーブにもコピーと同様にムーブ構築とムーブ代入がある。

~~~cpp
T source ;
// ムーブ構築
T a = std::move(source) ;
T b( std::move(source) ) ;
T c{ std::move(source) ) ;

T e ;
// ムーブ代入
e = std::move(source) ;
~~~

ムーブにもムーブ先とムーブ元がある。

~~~cpp
std::vector<int> source = {1,2,3} ;
// destinationはムーブ先
// sourceはムーブ元
std::vector<int> destination = std::move(source) ;
// destinationの値は{1,2,3}
// sourceの値はわからない
~~~

コピーと同じく、ムーブ後のムーブ先の値は、ムーブ前のムーブ元の値と等しくなる。

ムーブ後のムーブ元の値はわからない。なぜわからないかというと、値を移動しているからだ。

ムーブのコストはコピーとまったく同じか、コピーよりも低くなる。

ムーブはムーブ元の値をムーブ後に使わない場合に、コピーの代わりに使うことができる。

~~~cpp
int main()
{
    std::vector<int> v ;

    std::vector<int> w = {1,2,3,4,5} ;
    // ムーブ
    v = std::move(w) ;
    // このあとwは使えない

    std::for_each( std::begin(v), std::end(v), 
        []( auto x ){
            std::cout << x ;
        } ) ;
}
~~~

実際には、上記のコードはムーブ後に変数`w`を使っている。`main`関数のスコープを抜けるときに`w`が破棄されるが、そのときにデストラクターが実行される。

C++の標準ライブラリはムーブ後の状態について、その値は「妥当だが未規定の状態」になる。

なのでこの場合でもデストラクターを正常に呼び出すことはできる。このとき、`w.size()`が返す値はわからない。ただし、`w.resize(n)`を呼び出すと`n`個の要素を持つようになる。この結果、再び使うこともできるようになる。

~~~cpp
int main()
{
    std::vector<int> v ;
    std::vector<int> w = {1,2,3,4,5} ;
    v = std::move(w) ;
    // 要素数5
    w.resize(5) ;
    // 妥当に使える
    w[0] = 1 ;
}
~~~

## ムーブの中身

ムーブはいったい何をしているのか。ムーブの実装方法を理解するためには、`rvalueセマンティクス`と`値カテゴリー`とテンプレートの`フォワードリファレンス`という難しいC++の機能を理解しなければならない。この機能は次の章から解説するが、その機能を学ぶ動機づけにムーブが何をしているのかを具体的に学ぼう。

`int`や`double`といった単なるバイト列で表現された値だけで表現できる基本型のオブジェクトの場合、ムーブというのはコピーと何ら変わらない。単に値を表現するバイト列をコピーするだけだ。

~~~cpp
int a = 0 ;
// コピー
int b = a ;
// ムーブ
// 中身は単なるコピー
int c = std::move(a) ;
~~~

そのため、`int`や`double`のムーブでは、ムーブ後もムーブ元のオブジェクトをそのまま使うことができるし、値も変わらない。

~~~cpp
int a = 123 
int b = std::move(a) ;
// 123
std::cout << a ;
a = 456 ;
~~~

生のポインターのムーブもコピーと同じだ。

~~~cpp
int object { } ;
int * source = &object ;
// 中身は単なるコピー
int * destination = std::move(source) ;
~~~

クラスはどうか。クラスはデフォルトのコピーコンストラクターとコピー代入演算子を生成するように、デフォルトのムーブコンストラクターとムーブ代入演算子を生成する。これはコピーと同じく、メンバーごとにムーブを行う。

以下のように書くと、

~~~cpp
struct X
{
    int x ;
    int y ;
    int z ;
} ;

int main()
{
    X a{1,2,3} ;
    X b ;
    b = std::move(a) ;
}
~~~

以下のように書いたものとほぼ同じになる。


~~~cpp
int main()
{
    X a{1,2,3} ;
    X b ;
    b.x = std::move(a.x) ;
    b.y = std::move(a.y) ;
    b.z = std::move(a.z) ;
}
~~~

この場合のムーブは単なるコピーなので、実際には以下のように書くのと同じだ。

~~~cpp
int main()
{
    X a{1,2,3} ;
    X b ;
    b = a ;
}
~~~

C++の基本型とクラスのデフォルトのムーブの実装は、単なるコピーと同じだ。コピーと同じなのでムーブ後の値もそのまま使うことができる。

ではなぜコピーとムーブが区別され、ムーブ後のオブジェクトは使えないのか。C++ではコピーとムーブが区別されているので、自作のクラスはコピーとムーブで別の実装をすることができる。

ムーブ後のオブジェクトは使えない状態になるということは、ムーブ後のオブジェクトの値はどうなってもいいということだ。


`std::vector`のようなクラスは動的メモリー確保をしてポインターでストレージを参照している。自作の`vector`にコピーを実装するときは、コピー先でも動的メモリー確保をして要素を1つずつコピーしなければならないことを学んだ。

とても簡単な、`T`型の配列を確保する`dynamic_array<T>`を考えてみよう。

~~~cpp
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

このクラスのコピーコンストラクターの定義は以下のように書ける。

~~~cpp
template < typename T >
dynamic_array<T>::dynamic_array( const dynamic_array & r )
    : first( new T[r.size()] ), last( first + r.size() ) 
{
    std::copy( r.begin(), r.end(), begin() ) ;
}
~~~

これはコストがかかる。以下のようにすればコストがかからないがなぜできないのだろう。

~~~cpp
 < typename T >
dynamic_array<T>::dynamic_array( const dynamic_array & r )
    : first( r.first ), last( r.last ) 
{
    // 何もしない
}
~~~

コピーの章でも学んだように、この実装ではコピー先とコピー元が同じポインターを所有してしまうために、デストラクターが実行されるときに同じポインターが2回`delete`されてしまう。

~~~cpp
int main()
{
    dynamic_array<int> source(10) ;
    dynamic_array<int> destination = source ;
    // destinationに対してデストラクターが実行される
    // sourceに対してデストラクターが実行される
}
~~~

ならば、コピー元からポインターの所有権を奪ってしまえばいいのではないだろうか。


~~~cpp
 < typename T >
dynamic_array<T>::dynamic_array( dynamic_array & r )
    : first( r.first ), last( r.last ) 
{
    // コピー元を変更
    r.first = nullptr ;
    r.last = nullptr ;
}
~~~

引数が`const`ではないことに注目しよう。リファレンス型の引数を変更するには、`const`にはできない。

このコピーコンストラクターはコピー元を変更する。`delete式`は`nullptr`に対して適用した場合、何もしないことが保証されている。そのため、この場合にデストラクターでnullポインターのチェックは必要がない。

このコピーコンストラクターはとてもコストが低いが、このようなコピーの実装はユーザーが期待していない。この実装ではコピー後にコピー元が使えなくなってしまうからだ。

例えば、以下のコードが動かないとしたらどうだろう。

~~~cpp
int main()
{
    std::vector<int> v = {1,2,3,4,5} ;
    std::vector<int> w = v ;

    // これがエラーだとしたら？
    v[0] = 0 ; 
}
~~~

C++ではコピーはコピー元を変更しないという慣習がある。このような慣習はすべてC++の標準規格で定められている。

このため、C++はコピーのほかにムーブを定めている。ムーブを使うにはムーブ元の変数`x`を`std::move(x)`のようにしてコピーする。`std::move`はこのコピーはコピーではなくムーブしてもよいというヒントになる。


ムーブを実装するためには、まず基礎知識として次の章で学ぶ`rvalue`リファレンス、値カテゴリー、テンプレートのフォワードリファレンスの深い理解が必要になる。
