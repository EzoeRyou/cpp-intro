# クラスの基本

C++はもともとC言語に`クラス`の機能を追加することを目的とした言語だった。

`クラス`とは何か。クラスにはさまざまな機能があるが、最も基本的な機能としては以下の2つがある。

+ 変数をまとめる
+ まとめた変数に関数を提供する

この章は`クラス`の数ある機能のうち、この2つの機能だけを説明する。

## 変数をまとめる

2次元座標上の点`(x,y)`を表現するプログラムを書くとする。

とりあえず`int`型で表現してみよう。

~~~cpp
int main()
{
    // 表現
    int point_x = 0;
    int point_y = 0;
}
~~~

これはわかりやすい。ところでものは相談だが、点は複数表現したい。

~~~cpp
int main()
{
    int x1 = 0 ;
    int y1 = 0 ;

    int x2 = 0 ;
    int y2 = 0 ;

    int x3 = 0 ;
    int y3 = 0 ;
}
~~~

これはわかりにくい。ところで点はユーザーがいくつでも入力できるものとしよう。

~~~cpp
int main()
{
    std::vector<int> xs ;
    std::vector<int> ys ;

    // xs.at(i)とys.at(i)は同じ点のための変数

    int x {} ;
    int y {} ;
    while ( std::cin >> x >> y )
    {
        xs.push_back(x) ;
        ys.push_back(y) ;
    }
}
~~~

これはとてもわかりにくい。

ここで`クラス`の出番だ。`クラス`を使うと点を表現するコードは以下のように書ける。

~~~cpp
struct point
{
    int x = 0 ;
    int y = 0 ;
} ;

int main()
{
    point p ;

    std::cout << p.x << p.y ;
}
~~~



点を複数表現するのもわかりやすい。

~~~cpp
point p1 ;
point p2 ;
point p3 ;
~~~

ユーザーが好きなだけ点を入力できるプログラムもわかりやすく書ける。

~~~cpp
struct point
{
    int x = 0 ;
    int y = 0 ;
} ;

int main()
{
    std::vector<point> ps ;

    int x { } ;
    int y { } ;

    while( std::cin >> x >> y )
    {
        ps.push_back( point{ x, y } ) ;
    }    
}
~~~

これが`クラス`の変数をまとめる機能だ。

`クラス`を定義するには、キーワード`struct`に続いて`クラス名`を書く。

~~~cpp
struct class_name 
{

} ;
~~~

変数は`{}`の中に書く。

~~~cpp
struct S
{
    int a = 0 ;
    double b = 0.0 ;
    std::string c = "hello"s ;
} ;
~~~

このクラスの中に書かれた変数のことを、`データメンバー`という。正確には変数ではない。

定義した`クラス`は変数として宣言して使うことができる。`クラス`の`データメンバー`を使うには、クラス名に引き続いてドット文字を書きデータメンバー名を書く。

~~~cpp
// 名前と年齢を表現するクラスPerson
struct Person
{
    std::string name ;
    int age ;
} ;

int main()
{
    Person john ;
    john.name = "john" ;
    john.age = 20 ;
}
~~~

`クラス`の`データメンバー`の定義は変数ではない。オブジェクトではない。つまり、それ自体にストレージが割り当てられてはいない。

~~~cpp
struct S
{
    // これは変数ではない
    int data ;
} ;
~~~

クラスの変数を定義したときに、その変数のオブジェクトに紐付いたストレージが使われる。

~~~cpp
struct S
{
    int data ;
} ;

int main()
{
    S s1 ; // 変数
    // オブジェクトs1に紐付いたストレージ
    s1.data = 0 ;

    S s2 ;
    // 別のストレージ
    s2.data = 1 ; 

    // false
    bool b = s1.data == s2.data ;
}
~~~

クラスの変数を定義するときにデータメンバーを初期化できる。

~~~cpp
struct S
{
    int x ;
    int y ;
    int z ;
} ;

int main()
{
    S s { 1, 2, 3 } ;
    // s.x == 1
    // s.y == 2
    // s.z == 3
}
~~~

クラスの初期化で`{1,2,3}`と書くと、クラスの最初のデータメンバーが`1`で、次のデータメンバーが`2`で、その次のデータメンバーが`3`で、それぞれ初期化される。

クラスをコピーすると、データメンバーがそれぞれコピーされる。

~~~cpp
struct S { int a ; double b ; std::string c ; } ;

int main()
{
    S a{123, 1.23, "123"} ;
    // データメンバーがそれぞれコピーされる
    S b = a ;
}
~~~

## まとめた変数に関数を提供する

分数を表現するプログラムを書いてみよう。

~~~cpp
int main()
{
    int num = 1 ;
    int denom = 2 ;

    // 出力
    std::cout << static_cast<double>(num) / static_cast<double>(denom) ;
}
~~~

分子`num`と分母`denom`はクラスにまとめることができそうだ。そうすれば複数の分数を扱うのも楽になる。


~~~cpp
struct fractional
{
    int num ;
    int denom ;
} ;

int main()
{
    fractional x{1, 2} ;

    // 出力
    std::cout << static_cast<double>(x.num) / static_cast<double>(x.denom) ;
}
~~~


ところで、この出力を毎回書くのが面倒だ。こういう処理は関数にまとめたい。

~~~cpp
double value( fractional & x )
{
    return static_cast<double>(x.num) / static_cast<double>(x.denom) ;
}

int main()
{
    fractional x{ 1, 2 } ;
    std::cout << value( x ) ;
}
~~~

この関数`value`はクラス`fractional`専用だ。であれば、この関数をクラス自体に関連付けたい。そこでC++には`メンバー関数`という機能がある。

`メンバー関数`はクラスの中で定義する関数だ。

~~~cpp
struct S
{
    void member_function( int x )
    {
        return x ;
    }
} ;
~~~

`メンバー関数`はクラスの`データメンバー`を使うことができる。

~~~cpp
struct fractional
{
    int num ;
    int denom ;

    double value()
    {
        return static_cast<double>(num) / static_cast<double>(denom) ;
    }
} ;
~~~

メンバー関数を呼び出すには、クラスのオブジェクトに続いてドット文字を書き、メンバー関数名を書く。あとは通常の関数のように書く。

~~~cpp
int main()
{
    fractional x{ 1, 2 } ;
    std::cout << x.value() ;
}
~~~

`メンバー関数`から使える`データメンバー`は、メンバー関数が呼ばれたクラスのオブジェクトのデータメンバーだ。

~~~cpp
struct S
{
    int x ;
    void print()
    {
        std::cout << x ;
    }
} ;

int main()
{
    S s1(1) ;
    s1.print() ; // 1

    S s2(2) ;
    s2.print() ; // 2
}
~~~

この`print`を非メンバー関数として書くと以下のようになる。

~~~cpp
void print( S & s )
{
    std::cout << s.x ;
}
~~~

メンバー関数は隠し引数としてクラスのオブジェクトを受け取っている関数だ。メンバー関数の呼び出しには、対応するクラスのオブジェクトが必要になる。

~~~cpp
struct S
{
    void f() { }
} ;

int main()
{
    f() ; // エラー
    S s ;
    s.f() ; // OK
}
~~~

`メンバー関数`はデータメンバーを変更することもできる。

~~~cpp
struct X
{
    int data ;
    void f()
    {
        data = 3 ;
    }
} ;
~~~

先ほどの分数クラスに値を設定するための`メンバー関数`を追加してみよう。

~~~cpp
struct fractional
{
    int num ;
    int denom ;

    void set( int num_ )
    {
        num = num_ ;
        denom = 1 ;
    }
    void set( int num_, int denom_ )
    {
        num = num_ ;
        denom = denom_ ;
    }
} ;

int main()
{
    fractional x ;


    x.set(5) ;
    // x.num == 5
    // x.denom == 1

    x.set( 2, 3 ) ;
    // x.num == 2
    // x.denom == 3
}
~~~

メンバー関数`set(num)`を呼び出すと、値が$\frac{num}{1}$になる。メンバー関数`set(num, denom)`を呼び出すと、値が$\frac{num}{denom}$になる。

ところで上のコードを見ると、`データメンバー`と引数の名前の衝突を避けるために、アンダースコアを使っている。

`データメンバー`と引数の名前が衝突するとどうなるのか。確かめてみよう。

~~~cpp
struct S
{
    int x ;
    void f( int x )
    {
        x = x ;
    }
} ;

int main()
{
    S s{0} ;
    s.f(1) ;

    std::cout << s.x ;
}
~~~

結果は`0`だ。メンバー関数`f`の中の名前`x`は引数名の`x`だからだ。

すでに名前は`スコープ`に属するということは説明した。実はクラスも`スコープ`を持つ。上のコードは以下のようなスコープを持つ。

~~~cpp
// グローバル名前空間スコープ
int x ;

struct S
{
    // クラススコープ
    int x ;

    void f( int x )
    {
        // 関数のブロックスコープ
        x = x ;
    }
} ;
~~~

内側の`スコープ`は外側の`スコープ`の名前を隠す。そのため、クラススコープの`x`はグローバル名前空間スコープ`x`を隠す。関数のブロックスコープの`x`はクラススコープの`x`を隠す。

名前がどのスコープに属するかを明示的に指定することによって、隠された名前を使うことができる。

~~~cpp
int x ;

struct S
{
    int x ;

    void f( int x )
    {
        // 関数のブロックスコープのx
        x = 0 ;
        // クラススコープのx
        S::x = 0 ;
        // グローバル名前空間のスコープ
        ::x = 0 ;
    }
} ;
~~~

名前空間スコープを明示するために`namespace_name::name`を使うように、クラススコープを明示するために`class_name::name`を使うことができる。

これを使えば、分数クラスは以下のように書ける。

~~~cpp
struct fractional
{
    int num ;
    int denom ;

    void set( int num, int denom )
    {
        fractional::num = num ;
        fractional::denom = denom ;
    }
}
~~~
