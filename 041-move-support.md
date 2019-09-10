# 自作の数値クラスで演算をムーブに対応する方法

自作の数値計算をするクラスを実装するとしよう。無限精度整数、ベクトル、行列など、自作のクラスで実装したい数値と演算は世の中にたくさんある。

そのとき、数値の状態を表現するためにストレージを動的確保するとしよう。ここでは例のため、とても簡単な整数型を考える。

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

コンストラクターは動的確保をする。デストラクターは解放する。コピーは動的確保をする。ムーブは所有権の移動をする。とてもよくあるクラスの実装だ。

実用的には`std::unique_ptr<int>`を使うべきだが、低級な処理を説明するためにあえて生のポインターを使っている。

今回のコピー代入演算子は単に値をコピーしているが、コピー元とコピー先で確保したストレージのサイズが異なるような型、たとえば無限精度整数や動的なサイズのベクトルや行列などの場合は、コピー代入演算子でもコピー先のストレージを破棄してコピー元と同じサイズのストレージを確保するなどの処理が必要な場合もある。

~~~cpp
// 行列クラス
class matrix
{
    // オブジェクトごとにサイズが異なる
    unique_ptr<double> ptr ;
    std::size_t rows ;
    std::size_t columns ;
public :
    // コピー代入演算子
    matrix & operator = ( const matrix & r )
    {
        // 自分自身への代入
        if ( this == &r )
            return *this ;

        // 行列のサイズが同じかどうか確認
        if ( rows == r.rows && columns == r.columns )
        {
            // コピー元の行列の値をコピー先にコピー
            // コピー先のストレージはそのまま使える
        }
        else
        {
            // コピー先のストレージを解放
            // コピー先はコピー元の行列サイズと同じストレージを確保
            // 値をコピー
        }
    }
} ;
~~~

## 複合代入演算子

複合代入演算子というのは、`operator +=`や`operator -=`のような演算子だ。これはコピー代入演算子と同じように実装できる。違いは代入の結果、演算をするだけだ。

クラス`Integer`の場合、演算の結果ストレージのサイズが変わるということはないので、愚直な実装で済む。

~~~cpp
Integer & operator +=( const Integer & r )
{
    *ptr += *r.ptr ;
    return *this ;
}

Integer & operator -=( const Integer & r )
{
    *ptr -= *r.ptr ;
    return *this ;
}
~~~

複合代入演算子をムーブ代入演算子として実装する理由は、通常はない。

## 単項演算子

演算を表現するクラスでオーバーロードしたい単項演算子には`operator +`と`operator -`がある。特に`operator -`は実用上の意味があるので実装してみよう。

~~~cpp
Integer a(10) ;
auto b = -a ;
// これは二項演算子 operator +の結果に
// 単項演算子operator -を適用
auto c = -(a + a) ;
~~~

`*this`が`lvalue`の場合の単項演算子の実装は以下のようになる。

~~~cpp
Integer operator -() const
{
    Integer result( -*ptr ) ;
    return result ;
}

// operator +()の実装は省略
~~~

単項演算子`operator -`は`*this`を書き換えない。負数にした値のコピーを返す。


変数`result`は`return文`のあとは使われないので、`return std::move(result)` と書くこともできる。しかし、そのように書く必要はない。というのも`return文`は特別な扱いを受けているので、関数の中の変数を`return`した場合、自動でムーブが行われるからだ。もちろん、`std::move`を明示的に書いてもよい。

単項演算子`operator -`は`*this`が`lvalue`のときには上のように実装するしかない。しかしこの実装は非効率的だ。なぜならば、コードを読めばわかるように、追加の一時変数が生成され、追加の動的メモリー確保が行われるからだ。

そのため、もしクラス`Integer`がコピーしか実装していない場合、

~~~cpp
Integer a ;
auto b = -a ;
~~~

というコードは、

~~~cpp
Integer a ;
auto b = a ;
b.make_it_negative() ; 
~~~

のような現在の値をそのまま負数にするメンバー関数`make_it_negative`を実装して使った方が効率がよくなる。

~~~cpp
class Integer 
{
    int * ptr ;
public :
    void make_it_negative()
    {
        *ptr = -*ptr ;
    }
} ;
~~~

幸い、クラス`Integer`はムーブコンストラクターを実装しているので、

~~~cpp
auto b = -a ;
~~~

というコードは、式`-a`によって生成された一時オブジェクトが変数`b`にムーブされる。

しかし、

~~~cpp
auto c = -(a + a) ;
~~~

というコードは依然として非効率的になる。まだ二項演算子`operator +`は実装していないが、これは、

~~~cpp
auto temp1 = a + a ;
auto temp2 = -temp1 ;
auto c = temp2 ;
~~~

になるからだ。すると以下のように書いた方が効率がよくなる。

~~~cpp
Integer a ;
auto c = a ;
c += a ;
c.make_it_negative() ;
~~~

こんなコードを書くのは面倒だ。単に`-(a+a)`と書いて効率的に動いてほしい。そのために単項演算子`operator -`をムーブに対応させる。

単項演算子はクラスのメンバー関数として実装する。

~~~cpp
class Integer
{
public ;
    Integer operator -() const ;
} ;
~~~

これが非メンバー関数ならば、単に`rvalue`リファレンスを取ればよい。

~~~cpp
Integer negate( Integer && object ) ;
~~~

メンバー関数の場合、`object`に相当するのは`*this`だ。

~~~cpp
class Integer
{
public :
    // *thisがobjectに相当する
    Integer negate() ;
} ;
~~~

`this`がポインターになっているのは歴史的な都合で、本来はリファレンスになっているべきだった。メンバー関数は以下のような隠し引数があるものとして考えるとよい。

~~~cpp
class Integer
{
public :
    // 隠し引数
    Integer negate( Integer & THIS )
    {
        Integer * this = &THIS ;
    }
} ;
~~~

もちろん、このような隠し引数`THIS`をC++のプログラムから参照する方法はない。あくまでも参考のためのコードだ。

メンバー関数を`const`修飾するというのは、

~~~cpp
class Integer 
{
public :
    Integer negate() const ;
} ;
~~~

この隠し引数を`const`修飾するのと同じだ。

~~~cpp
class Integer
{
public :
    Integer negate( const Integer & THIS )
    {
        const Integer * this = &THIS ;
        // ...
    }
} ;
~~~

これによって`const`修飾の有無でメンバー関数を呼び分けられる。

~~~cpp
struct X
{
    void f() ;
    void f() const ; 
} ;

int main()
{
    X x ;
    x.f() ; // 非const
    const X & cx = x ;
    cx.f() ; // const
}
~~~

C++には`const`修飾と同様に、「リファレンス修飾」という機能がある。これを使えば隠し引数に`lvalue`/`rvalue`リファレンスの修飾ができる。

~~~cpp
struct X
{
    // lvalueリファレンス修飾子
    void f() & ;
    // rvalueリファレンス修飾子
    void f() && ; 
} ;

int main()
{
    X lvalue ;
    // lvalueリファレンス
    lvalue.f() ;
    // rvalueリファレンス
    std::move(lvalue).f() ;
}
~~~

これは実質的以下のような隠し引数があるものと考えてよい。もちろん隠し引数を使うことはできない。

~~~cpp
struct X
{
    // lvalueリファレンス
    void f( X & THIS )
    {
        X * this = &THIS ;
    }
    void f( X && THIS )
    {
        X * this = &THIS ;
    }
} ;
~~~

`void f() &&`のメンバー関数の中では、`*this`は`lvalue`だ。`rvalue`リファレンスの変数は`lvalue`であることを思い出そう。

~~~cpp
void f( int & ) ;
void f( int && ) ;

int main()
{
    int lvalue {} ;
    int && rvalue = std::move(lvalue) ;
    // int &を呼び出す
    // rvalueリファレンスの変数はlvalue
    f( rvalue ) ;
}
~~~

クラスでメンバー関数にリファレンス修飾子を書かなかった場合、`lvalue`リファレンス修飾子を書いたものとみなされる。

~~~cpp
struct X
{
    // lvalueリファレンス
    void f() ;
} ;
~~~

もしメンバー関数にリファレンス修飾子を書いた場合、同じ名前のすべてのメンバー関数にリファレンス修飾子を書かなければならない。

~~~cpp
struct X
{
    // エラー、リファレンス修飾子がない
    void f() ;
    void f() & ;

    // OK、リファレンス修飾子がある
    void g() & ;
    void g() && ;

    // OK リファレンス修飾子を使っていない
    // デフォルトでlvalueリファレンス修飾子
    void h() ;
} ;
~~~

リファレンス修飾子を使い、`*this`が`lvalue`と`rvalue`の場合で実装を分けることができる。

~~~cpp
class Integer
{
    int * ptr ;
public :
    // lvalue版
    Integer operator -() const &
    {
        auto result = ( -*ptr ) ;
        return result ;
    }
    // rvalue版
    Integer operator -() &&
    {
        auto result = std::move(*this) ;
        *result.ptr = -*result.ptr ;
        return result ;
    }
} ;
~~~

`rvalue`リファレンス修飾子を使った単項演算子`operator -`の実装は、`*this`自身が`rvalue`であるので、自分自身をムーブしている。ムーブ以降、`this->ptr`は`nullptr`になる。なぜならば、`Integer`のムーブ代入演算子がそのような実装になっているからだ。

~~~cpp
/// 上で示したのと同じムーブ代入演算子の抜粋
Integer operator =( Integer && r )
{
    delete ptr ;
    ptr = r.ptr ;
    // ムーブ元のポインターをnullptrにする
    r.ptr = nullptr ;
    return *this ;
}
~~~



## 二項演算子

せっかく数値を表現するクラスなのだから二項演算子を使った演算がしたい。

~~~cpp
int main()
{
    Integer a(1) ;
    Integer b(2) ;
    Integer c = a + b ;
}
~~~

これをどうやって実装するのかというと、`operator +`演算子のオーバーロードで実装する。

演算子のオーバーロードはメンバー関数による方法と、非メンバー関数による方法がある。

~~~cpp
struct X
{
    // メンバー関数
    X operator +( const X & r ) ;
} ;

// 非メンバー関数
X operator +( const X & l, const X & r ) ;
~~~

`operator =`のような特殊な演算子以外は、どちらの方法で書いてもいい。メンバー関数として書いた場合、第一引数は`*this`に、第二引数が関数の引数`r`になる。

例えば以下のようなコードで、

~~~cpp
X a ;
X b ;
a + b ;
~~~

メンバー関数の場合、`*this`は`a`、`r`は`b`になる。

非メンバー関数の場合、`l`は`a`は、`r`は`b`になる。

### ムーブしない実装

二項演算子のオペランドがどちらも`lvalue`であった場合はムーブができないので、引数は`const`な`lvalue`リファレンスで受け取り、`prvalue`を返す。

メンバー関数の場合の実装は以下のようになる。

~~~cpp
class Integer
{
    int * ptr ;
public :
    // 省略...

    Integer operator +( const Integer & r ) const
    { return Integer( *ptr + *r.ptr ) ; } 
} ;
~~~

非メンバー関数の場合は、`Integer::ptr`が`private`メンバーであることが問題になる。

~~~cpp
Integer operator + ( const Integer & l, const Integer & r )
{
    // エラー、Integer::ptrはprivateメンバー
    return Integer( *l.ptr + *r.ptr ) ;
}
~~~

これを解決するための方法はいくつかある。

1. クラスのメンバー関数として処理を実装し、そのメンバー関数を呼び出す方法

~~~cpp
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

クラスが別のクラスや関数を`friend`宣言すると、その関数はクラスの`private`なメンバーを使えるようになる。

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

これを使うと、以下のように`friend`宣言すれば、動かなかった非メンバー関数による`operator +`のオーバーロードが動くようになる。

~~~cpp
class Integer
{
    friend Integer operator +( const Integer &, const Integer & ) ;
} ;
~~~

### ムーブをしたくなる状況

上の二項演算子の実装だけで、クラス`Integer`は加算ができるようになった。ただし、効率がよくない。

例えば以下のようなコードを考えよう。

~~~cpp
Integer a ;
auto b = a + a + a ;
~~~

これはどのように評価されるかというと、`a+a+a`は、`(a+a)+a`となり、`(a+a)`を評価した結果の一時オブジェクトが生成され、その一時オブジェクトを仮に`temp`と呼ぶと、`temp+a`される。

結果として、以下のようなコードと同じになる。

~~~cpp
Integer a ;
auto temp = a + a ;
auto b = temp + a ;
~~~

ムーブを実装していない場合、以下のように書いた方が効率がよくなる。

~~~cpp
Integer a ;
auto b = a ;
b += a ;
b += a ;
~~~

このようなコードは面倒だ。できれば`a + a + a`と書きたい。

二項演算子は`operator +`だけではない。

~~~cpp
auto result = a + b - c * d / e ;
~~~

のようなコードも書きたい。これを効率化のために、

~~~cpp
auto result = a;
a += b ;
auto temp = c ;
temp *= d ;
temp /= e ;
result -= temp ;
~~~

のように書かなければならないとしたら悲惨だ。

`a+a+a`のような式が効率的に動くためには、二項演算子で`lvalue`/`rvalue`リファレンスを取り、`rvalue`リファレンスの場合はムーブするコードを書く。`rvalue`からは所有権を横取りしてもよいからだ。

二項演算子は引数が2つあり、それぞれに`lvalue`/`rvalue`があるので、4通りのオーバーロードを書かなければならない。

非メンバー関数で実装するには、以下のように宣言を書く。

~~~cpp
class Integer 
{
    friend integer operator + ( const Integer & l, const Integer & r ) ;
    friend integer operator + ( Integer && l, const Integer & r ) ;
    friend integer operator + ( const Integer & l, Integer && r ) ;
    friend integer operator + ( Integer && l, Integer && r ) ;
} ;

// lvalue + lvalue
Integer operator + ( const Integer & l, const Integer & r ) ;
// rvalue + lvalue
Integer operator + ( Integer && l, const Integer & r ) ;
// lvalue + rvalue
Integer operator + ( const Integer & l, Integer && r ) ;
// rvalue + rvalue
Integer operator + ( Integer && l, Integer && r ) ;
~~~

具体的な実装としては、まず`rvalue`リファレンスで束縛したリファレンスを関数のローカル変数にムーブしたあとで、その変数を`return`する。

第一引数が`rvalue`の場合は、以下のようになる。

~~~cpp
Integer operator + ( Integer && l, const Integer & r )
{
    auto result = std::move(l) ;
    result += r ;
    return result ;    
}
~~~

第一引数は`rvalue`なので、ムーブしてもよい。

先ほども説明したように、`'return文'`が関数のローカル変数を返すときは自動でムーブしてくれる。もちろん`'return std::move(result)'` と書いてもよい。

第二引数が`rvalue`の場合は、ムーブすべきオブジェクトが第二引数になる。


~~~cpp
Integer operator + ( const Integer & l, Integer && r )
{
    auto result = std::move(r) ;
    result += l ;
    return result ;    
}
~~~

この実装はすべてに使えるわけではない。加算の場合は、一般に交換法則を満たすことが期待できる。つまり、

$$ a + b = b + a $$

であることが期待できるが、除算演算子`operator /`は交換法則を満たさない。今回の`Integer`のような簡単な作りのクラスならば実装できるが、クラスの実装と演算次第では第二引数のみが`rvalue`の場合にはムーブできない場合もあるだろう。そういう場合には実装しなくてもよい。実装できないものは実装しないのが正しい。

第一引数、第二引数のいずれかが`rvalue`であるときにムーブする演算子のオーバーロードを両方とも実装した場合、両方の引数が`rvalue`である場合のオーバーロードも実装しなければならない。

第一引数、第二引数が両方共`rvalue`である場合というのは、例えば以下のような場合だ。

~~~cpp
Integer a ;
auto b = (a + a) + (a + a) ;
~~~

`a+a`を評価した結果は`rvalue`だ。この式では`rvalue`と`rvalue`を`operator +`に渡しているので、引数は両方とも`rvalue`になる。

もし、`rvalue + lvalue`と`lvalue + rvalue`に対応する演算子しかオーバーロードしていない場合、関数呼び出しが曖昧になってしまう。そこで、`rvalue + rvalue`の演算子オーバーロードも書く。

~~~cpp
Integer operator +( Integer && l, Integer && r )
{
    return std::move(l) + r ;
} ;
~~~

この実装は単に`rvalue + lvalue`の演算子オーバーロードに実際の処理を丸投げしている。変数`r`はここでは`lvalue`だ。何度も言うように`rvalue`を束縛した`rvalue`リファレンスの変数は`lvalue`だ。ここでは第一引数をムーブし、第二引数は`lvalue`として扱っている。


メンバー関数で実装する場合、二項演算子の第一引数は`*this`、第二引数がメンバー関数の第一引数になる。

~~~cpp
class Integer
{
public :
    // lvalue + lvalue
    Integer operator + ( const Integer & r ) const & ;
    // rvalue + lvalue
    Integer operator + ( const Integer & r ) && ;
    // lvalue + rvalue
    Integer operator + ( Integer && r ) const & ;
    // rvalue + rvalue
    Integer operator + ( Integer && r ) && ;
} ;
~~~

`a + b`のとき、`*this`が`a`、`r`が`b`だ。あとの実装は非メンバー関数の場合と変わらない。

例えばメンバー関数で`rvalue + lvalue`の実装は以下のようになる。

~~~cpp
Integer Integer::operator +( const Integer & r ) &&
{
    auto result = std::move(*this) ;
    result += r ;
    return result ;
}
~~~


