# 自作の数値クラスで演算をムーブに対応する方法

自作の数値計算をするクラスを実装するとしよう。無限精度整数、ベクトル、行列など、自作のクラスで実装したい数値と演算は世の中にたくさんある。

その時、数値の状態を表現するためにストレージを動的確保するとしよう。ここでは例のため、とても簡単な整数型を考える。

~~~cpp
class Integer
{
    int * ptr ;
} ;
~~~

## 基本の実装

まずは基本となるコンストラクターとデストラクター、コピー、ムーブを実装しよう。

~~~cpp
struct Integer
{
    int * ptr ;
public :
    explicit Integer( int value = 0 )
        : ptr ( new int(value) ) { }
    ~Integer( )
    { delete ptr ; } 

    // コピー
    Integer( const Integer & r )
        : ptr( new int( *r.ptr ) ) { }
    Integer & operator = ( const Integer & r )
    {
        if ( this != &r )
            *ptr = *r.ptr ;
        return *this ;
    }

    // ムーブ
    Integer( Integer && r )
        : ptr( r.ptr )
    { r.ptr = nullptr ; }
    Integer operator =( Integer && r )
    {
        delete ptr ;
        ptr = r.ptr ;
        r.ptr = nullptr ;
        return *this ;
    }
} ;
~~~

コンストラクターは動的確保をする。デストラクターは解放する。コピーは動的確保をする。ムーブは所有権の移動をする。とても良くあるクラスの実装だ。

## 二項演算子

せっかく数値を表現するクラスなのだから二項演算子を使った演算がしたい。

~~~c++
int main()
{
    Integer a(1) ;
    Integer b(2) ;
    Integer c = a + b ;
}
~~~

これをどうやって実装するのかというと、`operator +`演算子のオーバーロードで実装する。

演算子のオーバーロードはメンバー関数による方法と、非メンバー関数による方法がある。

~~~c++
struct X
{
    // メンバー関数
    X operator +( const X & r ) ;
} ;

// 非メンバー関数
X operator +( const X & l, const X & r ) ;
~~~

`operator =`のような特殊な演算子以外は、どちらの方法で書いてもいい。メンバー関数として書いた場合、第一引数は`*this`に、第二引数が関数の引数になる。

例えば以下のようなコードで、

~~~c++
X a, b ;
a + b ;
~~~

メンバー関数の場合、`*this`は`a`、`r`は`b`になる。

非メンバー関数の場合、`l`は`a`は、`r`は`b`になる。

### ムーブしない実装

二項演算子のオペランドがどちらも`lvalue`であった場合はムーブができないので、引数はconstなlvalueリファレンスで受け取り、`prvalue`を返す。

メンバー関数の場合の実装は以下のようになる。

~~~c++
class Integer
{
    int * ptr ;
public :
    // 省略...

    Integer operator +( const Integer & r ) const
    { return Integer( *ptr + *r.ptr ) ; } 
} ;
~~~

非メンバー関数の場合は、`Integer::ptr`がprivateメンバーであることが問題になる。

~~~c++
Integer operator + ( const Integer & l, const Integer & r )
{
    // エラー、Integer::ptrはprivateメンバー
    return Integer( *l.ptr + *r.ptr ) ;
}
~~~

これを解決するための方法はいくつかある。

1. クラスのメンバー関数として処理を実装し、そのメンバー関数を呼び出す方法

~~~c++
class Integer
{
    int * ptr ;
public :
    Integer plus( const Integer & r ) const
    { return Integer( *ptr + r.ptr ) ; }
} ;

Integer operator + ( const Integer & l, const Integer & r )
{
    return l.plus( r ) ;
}
~~~

2. friend宣言する方法

クラスが別のクラスや関数をfriend宣言すると、その関数はクラスのprivateなメンバーを使えるようになる。

~~~cpp
class X
{
    int member ;
    // friend宣言
    friend int get_member( const X & ) ;
} ;

int get_member( const X & obj )
{
    // OK、friendなので使える
    return obj.member ;
}
~~~

これを使うと、以下のようにfriend宣言すれば、動かなかった非メンバー関数による`operator +`のオーバーロードが動くようになる。

~~~c++
class Integer
{
    friend Integer operator +( const Integer &, const Integer & ) ;
} ;
~~~

### ムーブをしたくなる状況

上の二項演算子の実装だけで、クラス`Integer`は加算ができるようになった。ただし、効率が良くない。

例えば以下のようなコードを考えよう。

~~~c++
Integer a ;
auto b = a + a + a ;
~~~

これはどのように評価されるかというと、`a+a+a`は、`(a+a)+a`となり、`(a+a)`を評価した結果の一時オブジェクトが生成され、その一時オブジェクトを仮に`temp`と呼ぶと、`temp+a`される。

結果として、以下のようなコードと同じになる。

~~~c++
Integer a ;
auto temp = a + a ;
auto b = temp + a ;
~~~


