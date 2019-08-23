# より自然に振る舞うクラス

整数型の`int`について考えてみよう。

~~~cpp
int main()
{
    int a = 1 ;
    int b = a + a ;
    int c = a + b ;
}
~~~

同様のことを、前章の分数クラスで書いてみよう。

~~~cpp
struct fractional
{
    int num ;
    int denom ;
} ;

fractional add( fractional & l, fractional & r )
{
    // 分母が同じなら
    if ( l.denom == r.denom )
        // 単に分子を足す
        return fractional{ l.num + r.num, l.denom } ;

    // 分母を合わせて分子を足す
    return fractional{ l.num * r.denom + r.num * l.denom, l.denom * r.denom } ;
}

int main()
{
    fractional a{1,1} ;
    fractional b = add(a, a) ;
    fractional c = add(a, b) ;
}
~~~

これは読みにくい。できれば以下のように書きたいところだ。


~~~cpp
int main()
{
    fractional a = 1 ;
    fractional b = a + a ;
    fractional c = a + b ;
}
~~~

C++ではクラスをこのように自然に振る舞わせることができる。

## より自然な初期化

`int`型は初期化にあたって値を設定できる。

~~~cpp
int a = 0 ;
int b(0) ;
int c{0} ;
~~~

`クラス`でこのような初期化をするには、`コンストラクター`を書く。

~~~cpp
struct fractional
{
    int num ;
    int denom ;

    // コンストラクター
    fractional( int num )
        : num(num), denom(1)
    { }
} ;

int main()
{
    fractional a = 1 ;
    fractional b = 2 ;
}
~~~

`コンストラクター`は`クラス`の`特殊なメンバー関数`として定義する。`メンバー関数`としての`コンストラクター`は、名前がクラス名で、戻り値の型は記述しない。

~~~cpp
struct class_name
{
    // コンストラクター
    class_name() { }
} ;
~~~

`コンストラクター`は`データメンバー`の初期化に特別な文法を持っている。関数の本体の前にコロンを書き、データメンバー名をそれぞれカンマで区切って初期化する。

~~~cpp
struct class_name
{
    int data_member ;

    class_name( int value )
        : data_member(value)
    { }
    
} ;
~~~

このとき、引数名とデータメンバー名が同じでもよい。

~~~cpp
struct class_name
{
    int x ;
    class_name( int x )
        : x(x) { }
} ;
~~~

`x(x)`の最初の`x`は`class_name::x`として、次の`x`は引数名の`x`として認識される。そのためこのコードは期待どおりに動く。

`コンストラクター`の特別なメンバー初期化を使わずに、`コンストラクター`の関数の本体で`データメンバー`を変更してもよい。

~~~cpp
struct class_name
{
    int x ;
    class_name( int x )
    {
        class_name::x = x ;
    }
} ;
~~~

この場合、`x`は関数の本体が実行される前に一度初期化され、その後、値を代入されるという挙動の違いがある。

コンストラクターはクラスが初期化されるときに実行される。例えば以下のプログラムを実行すると、


~~~cpp
int main()
{
    S a(1) ;
    S b(2) ;
    S c(3) ;
}
~~~


以下のように出力される。

~~~
123
~~~

`コンストラクター`のついでに`デストラクター`も学んでおこう。`コンストラクター`はクラスのオブジェクトが初期化されるときに実行されるが、`デストラクター`はクラスのオブジェクトが破棄されるときに実行される。

`デストラクター`の宣言は`コンストラクター`と似ている。違う点は、クラス名の前にチルダ文字を書くところだ。

~~~cpp
struct S
{
    // デストラクター
    ~S()
    {
        // オブジェクトの破棄時に実行される
    }
} ;
~~~

関数のローカル変数は、ブロックスコープを抜ける際に破棄される。破棄は構築の逆順に行われる。

~~~cpp
int main()
{
    int a ;
    {
        int b ;
    // bが破棄される
    }
    int c ;
// cが破棄される
// aが破棄される
}
~~~

さっそく初期化時と終了時に標準出力をするクラスで確かめてみよう。

~~~cpp
struct S
{
    int n ;
    S( int n )
        : n(n)
    {
        std::cout << "constructed: "s << n << "\n"s ;
    }

    ~S()
    {
        std::cout << "destructed: "s << n << "\n"s ;
    }
} ;
~~~

このクラスを以下のように使うと、


~~~cpp
int main()
{
    S a(1) ;
    { S b(2) ; }
    S c(3) ;
}
~~~

以下のように出力される。

~~~
constructed: 1
constructed: 2
destructed: 2
constructed: 3
destructed: 3
destructed: 1
~~~

この出力は以下のような意味だ。

1. `a`が構築される
1. `b`が構築される
1. `b`が破棄される
1. `c`が構築される
1. `c`が破棄される
1. `a`が破棄される

`b`はブロックスコープの終わりに達したので`a`の構築のあと、`c`の構築の前に破棄される。破棄は構築の逆順で行われるので、`a`よりも先に`c`が破棄される。

`コンストラクター`と`デストラクター`は戻り値を返さないので、`return文`には値を書かない。

~~~cpp
struct class_name
{
    class_name()
    {
        return ;
    }
} ;
~~~

`コンストラクター`は複数の引数を取ることもできる。

~~~cpp
struct fractional
{
    int num ;
    int denom ;

    fractional( int num )
        : num(num), denom(1)
    { }

    fractional( int num, int denom )
        : num(num), denom(denom)
    { }
} ;

int main()
{
    // fractional(int)が呼ばれる
    fractional a = 1 ;

    // fractional(int,int)が呼ばれる
    fractional b(1, 2) ;
    fractional c{1, 2} ;
}
~~~

複数の引数を取るコンストラクターを呼び出すには`"="`は使えない。`"()"`か`"{}"`を使う必要がある。

上のコードを見ると、コンストラクターは引数の数以外にやっていることはほとんど同じだ。こういう場合、コンストラクターを1つにする方法がある。

実はコンストラクターに限らず、関数は`デフォルト実引数`を取ることができる。書き方は仮引数に`"="`で値を書く。

~~~cpp
void f( int x = 0 )
{ }

int main()
{
    f() ;  // f(0)
    f(1) ; // f(1)
}
~~~

`デフォルト実引数`を指定した関数の仮引数に実引数を渡さない場合、`デフォルト実引数`で指定した値が渡される。

ところで、`仮引数`、`実引数`という聞き慣れない言葉が出てきた。これは関数の引数を区別するための言葉だ。`仮引数`は関数の宣言の引数。実引数は関数呼び出しのときに引数に渡す値のことを意味する。

~~~cpp
// xは仮引数
void f( int x ) { }

int main()
{
    // 123は仮引数xに対する実引数
    f( 123 ) ;
}
~~~

`デフォルト実引数`は関数の実引数の一部を省略できる。

ただし、`デフォルト実引数`を使った以後の仮引数には、すべて`デフォルト実引数`がなければならない。

~~~cpp
// OK
void f( int x, int y = 0, int z = 0 ) { }
// エラー
// zにデフォルト実引数がない
void g( int x, int y = 0, int z ) { }
~~~

`デフォルト実引数`で途中の引数だけ省略することはできない。


~~~cpp
void f( int x = 0, int y = 0, int z = 0) { }

int main()
{
    // エラー
    f( 1, , 2 ) ;
}
~~~

`デフォルト実引数`を使うと、コンストラクターを1つにできる。

~~~cpp
struct fractional
{
    int num ;
    int denom ;

    fractional( int num, int denom = 1 )
        : num(num), denom(denom)
    { }
} ;

int main()
{
    fractional a = 1 ;
    fractional b(1,2) ;
    fractional c{1,2} ;
}
~~~

コンストラクターの数を減らす方法はもう1つある。`デリゲートコンストラクター`だ。

~~~cpp
struct fractional
{
    int num ;
    int denom ;

    fractional( int num, int denom )
        : num(num), denom(denom)
    { }

    // デリゲートコンストラクター
    fractional( int num )
        : fractional( num, 1 )
    { }
} ;
~~~

`デリゲートコンストラクター`は初期化処理を別のコンストラクターにデリゲート(丸投げ)する。丸投げ先のコンストラクターの初期化処理が終わり次第、デリゲートコンストラクターの関数の本体が実行される。

~~~cpp
struct S
{
    S()
        : S(1)
    {
        std::cout << "delegating constructor\n" ;
    }

    S( int n )
    {
        std::cout << "constructor\n" ;
    }
} ;

int main()
{
    S s ;
}
~~~

このプログラムを実行すると、以下のように出力される。

~~~
constructor
delegating constructor
~~~

まず`"S()"`が呼ばれるが、処理を`"S(int)"`にデリゲートする。`"S(int)"`の処理が終わり次第`"S()"`の関数の本体が実行される。そのためこのような出力になる。

コンストラクターを減らすのはよいが、減らしすぎても不便だ。以下の例を見てみよう。

~~~cpp
struct A { } ;
struct B { B(int) { } } ;

int main()
{
    A a ; // OK
    B b ; // エラー
}
~~~

クラス`A`の変数は問題ないのに、クラス`B`の変数はエラーになる。これはクラス`B`には引数を取らないコンストラクターがないためだ。

クラス`B`に引数を必要としないコンストラクターを書くと、具体的に引数を渡さなくても初期化ができるようになる。

~~~cpp
struct B
{
    B() { }
    B( int x ) { }
} ;

int main()
{
    B b ; // OK
}
~~~

もしくは、デフォルト引数を使ってもよい。

~~~cpp
struct B
{
    B( int x = 0 ) { }
} ;
~~~

もちろん、ユーザーが値を指定しなければならないようなクラスは値を指定するべきだ。

~~~cpp
// 人間クラス
// 必ず名前が必要
struct person
{
    std::string name
    person( std::string name )
        : name(name) { }
} ;
~~~

## 自然な演算子

`int`型は`+-*/`といった演算子を使うことができる。

~~~cpp
int main()
{
    int a = 1 ;
    int b = 1 ;
    a + b ;
    a - b ;
    a * b ;
    a / b ;
}
~~~

クラスも演算子を使った自然な記述ができる。クラスを演算子に対応させることを、`演算子のオーバーロード`という。

分数クラスの足し算を考えよう。

+ 分母が同じならば分子を足す
+ 分母が異なるならば互いの分母を掛けて、分母をそろえて足す

コードにすると以下のようになる。

~~~cpp
struct fractional
{
    int num ;
    int denom ;

// コンストラクターなど
} ;

fractional add( fractional & l, fractional & r )
{
    // 分母が同じなら
    if ( l.denom == r.denom )
        // 単に分子を足す
        return fractional{ l.num + r.num, l.denom } ;

    // 分母を合わせて分子を足す
    return fractional{ l.num * r.denom + r.num * l.denom, l.denom * r.denom } ;
}
~~~

しかし、この関数`add`を使ったコードは以下のようになる。

~~~cpp
int main()
{
    fractional a{1,2} ;
    fractional b{1,3} ;

    auto c = add(a, b) ;
}
~~~

これはわかりにくい。できれば、以下のように書きたい。

~~~cpp
auto c = a + b ;
~~~

C++では演算子は関数として扱うことができる。演算子の名前は`operator op`で、例えば`+演算子`の名前は`operator +`になる。

関数`operator +`は引数を2つ取り、戻り値を返す関数だ。

~~~cpp
fractional operator +( fractional & l, fractional & r )
{
    // 分母が同じなら
    if ( l.denom == r.denom )
        // 単に分子を足す
        return fractional{ l.num + r.num, l.denom } ;
    else
        // 分母を合わせて分子を足す
        return fractional{ l.num * r.denom + r.num * l.denom, l.denom * r.denom } ;
}
~~~

このように`operator +`を書くと、以下のようなコードが書ける。


~~~cpp
auto c = a + b ;
~~~

同様に、引き算は`operator -`、掛け算は`operator *`、割り算は`operator /`だ。

以下に関数の宣言を示すので実際に分数の計算を実装してみよう。

~~~cpp
fractional operator -( fractional & l, fractional & r ) ;
fractional operator *( fractional & l, fractional & r ) ;
fractional operator /( fractional & l, fractional & r ) ;
~~~

引き算は足し算とほぼ同じだ。

~~~cpp
fractional operator -( fractional & l, fractional & r )
{
    // 分母が同じ
    if ( l.denom == r.denom )
        return fractional{ l.num - r.num, l.denom } ;
    else
        return fractional{ l.num * r.denom - r.num * l.denom, l.denom * r.denom } ;
}
~~~

掛け算と割り算は楽だ。

~~~cpp
fractional operator *( fractional & l, fractional & r )
{
    return fractional{ l.num * r.num, l.denom * r.denom } ;
}

fractional operator /( fractional & l, fractional & r )
{
    return fractional{ l.num * r.denom, l.denom * r.num } ;
}
~~~

## 演算子のオーバーロード

### 二項演算子

C++にはさまざまな演算子があるが、多くが`二項演算子`と呼ばれる演算子だ。`二項演算子`は2つの引数を取り、値を返す。

~~~cpp
a + b ;
a - b ;
a * b ;
a / b ;
~~~

このような演算子は`operator +`のように、キーワード`operator`に続いて演算子の文字を書くことで、関数名とする。あとは通常の関数と変わらない。

~~~cpp
struct S { } ;

S add( S a, S b ) ;
S operator + ( S a, S b ) ;
~~~

戻り値の型は何でもよい。

~~~cpp
struct S { } ;

int operator +( S, S ) { return 0 ; }
void operator -( S, S ) { }

int main()
{
    S s ;
    int x = s + s ;
    s - s ; // 戻り値はない
}
~~~

演算子としてではなく、関数と同じように呼び出すこともできる。

~~~cpp
struct S { } ;

// S f( S, S )のようなもの
S operator + ( S, S ) { }

int main()
{
    S s ;
    // f(s,s)のようなもの
    operator +(s,s) ;
}
~~~

`演算子のオーバーロード`では、少なくとも1つのユーザー定義された型がなければならない。つまり以下のような演算子のオーバーロードはできないということだ。

~~~cpp
int operator +( int, int ) ;
int operator +( int, double ) ;
~~~

二項演算子には`オペランド`と呼ばれる式を取る。


~~~cpp
a + b ;
~~~

この場合、二項演算子`operator +`には`a`, `b`という2つのオペランドがある。

二項演算子をオーバーロードする場合、最初の引数が最初のオペランド、次の引数が次のオペランドに対応する。

~~~cpp
struct X { } ;
struct Y { } ;

void operator +( X, Y ) { }

int main()
{
    X x ;
    Y y ;

    // OK
    x + y ;

    // エラー
    // operator +(Y,X)は存在しない
    y + x ;
}
~~~

そのため、上の例で`"x+y"`と`"y+x"`を両方使いたい場合は、

~~~cpp
void operator +(Y,X) { }
~~~

も必要だ。

現実のコードでは、二項演算子のオーバーロードは以下のように書くことが多い。

~~~cpp
struct S { } ;

// 引数名はさまざま
S operator +( S const & left, S const & right )
{

}
~~~

`const &`という特別な書き方をする。`&`についてはすでに学んだように、リファレンスだ。リファレンスを使うことによって値をコピーせずに効率的に使うことができる。

`const`というのは値を変更しない変数を宣言する機能だ。

~~~cpp
int main()
{
    int x = 0 ;
    x = 1 ; // OK

    int const y = 0 ;
    y = 0 ; // エラー
}
~~~

`const`を付けると値を変更できなくなる。

一般に`operator +`のような演算子は、オペランドに渡した変数を書き換えない処理をすることが期待されている。

~~~cpp
int main()
{
    int a = 1 ;
    int b = 1 ;

    // a, bは書き換わらない
    int c = a + b ;
}
~~~

もちろん、`operator +`をオーバーロードして引数をリファレンスで取り、値を書き換えるような処理を書くこともできる。ただ、通常はそのような処理をすることはない。

しかし、処理の効率のためにリファレンスは使いたい。

そのようなときに、`const`かつリファレンスを使うと、効率的で値の変更ができないコードが書ける。

~~~cpp
struct IntLike{ int data ;} ;

IntLike operator + ( IntLike const & l, IntLike const & r )
{
    return IntLike{ l.data + r.data }
}
~~~

`const`リファレンスの変数をうっかり書き換えてしまった場合、コンパイラーが検出してくれるので、バグを未然に発見することができる。


### 単項演算子

`単項演算子`はオペランドを1つしか取らない演算子のことだ。

`単項演算子`についてはまだ説明していないものも多い。例えば、`operator +`や`operator -`がある。

~~~cpp
int main()
{
    int x = 1 ;
    +x ; //  1: operator +
    -x ; // -1: operator -
}
~~~

`単項演算子`は引数を1つしか取らない関数として書く。

~~~cpp
struct IntLike{ int data ;} ;

IntLike operator +( IntLike const & obj )
{
    return obj ;
}

IntLIke operator -( IntLike const & obj )
{
    return IntLike{ -obj.data } ;
}
~~~

### インクリメント/デクリメント

`インクリメント演算子`と`デクリメント演算子`はやや変わっている。この演算子には、オペランドの前に書く前置演算子(`++i`)と、あとに書く後置演算子(`i++`)がある。

~~~cpp
int main()
{
    int i = 0 ;
    ++i ;
    i++ ;

    --i ;
    i-- ;
}
~~~

前置演算子を評価すると、演算子を評価したあとの値になる。

~~~cpp
int i = 0 ;
++i ;   // 1
i ;     // 1
~~~

一方、後置演算子を評価すると、演算子を評価する前の値になる。

~~~cpp
int i = 0 ;
i++ ;   // 0
i ;     // 1
~~~

さらに前置演算子を評価した結果はリファレンスになるので代入やさらなる演算子の適用ができる。

~~~cpp
int i = 0 ;
++i = 0 ;   // iは0
++++i ;     // iは2

i++ = 0 ;   // エラー
i++++ ;     // エラー
~~~

インクリメントとデクリメントの前置演算子は、単項演算子と同じ方法で書くことができる。

~~~cpp
struct IntLike { int data ; } ;

IntLike & operator ++( IntLike & obj )
{
    ++obj.data ;
    return obj ;
}
IntLike & operator --( IntLike & obj )
{
    --obj.data ;
    return obj ;
}
~~~

引数を変更するので`const`ではないリファレンスを使う。戻り値は引数をそのままリファレンスで返す。

もちろん、この実装はインクリメントとデクリメントの挙動を自然に再現したい場合の実装だ。以下のような挙動を実装することも可能だ。

~~~cpp
struct S { } ;

void operator ++( S const & s )
{
    std::cout << "increment!\n" ;
}

int main()
{

    S s ;
    ++s ;
}
~~~

演算子のオーバーロードは演算子の文法で関数を呼べるという機能で、その呼び出した結果の関数が何をしようとも自由だからだ。

後置演算子は少し変わっている。以下が後置演算子の実装だ。

~~~cpp
struct IntLike { int data ; } ;

IntLike operator ++( IntLike & obj, int )
{
    auto temp = obj ;
    ++obj.data ;
    return temp ;
}
IntLike operator --( IntLike & obj, int )
{
    auto temp = obj ;
    --obj.data ;
    return temp ;
}
~~~

後置演算子は2つ目の引数として`int`型を取る。この引数はダミーで前置演算子と後置演算子を区別する以外の意味はない。意味はないので引数名は省略している。

~~~cpp
struct S { } ;

// 前置演算子
void operator ++( S ) ;
// 後置演算子
void operator ++( S, int ) ;
~~~

後置演算子はオペランドである引数を変更するが、戻り値は変更する前の値だ。なので変更前の値をまずコピーしておき、そのコピーを返す。

### メンバー関数での演算子のオーバーロード

実は演算子のオーバーロードはメンバー関数で書くことも可能だ。

例えば、

~~~cpp
S s ;
s + s ;
~~~

を可能にするクラス`S`に対する`operator +`は、

~~~cpp
struct S { }
S operator + ( S const &, S const & ) ;
~~~

でも実装できるが、メンバー関数としても実装できる。

~~~cpp
struct S
{
    S operator +( S const & right )
    {
        return S{} ;
    }
} ;
~~~

演算子のオーバーロードをメンバー関数で書く場合、最初のオペランドがメンバー関数の属するクラスのオブジェクト、2つ目のオペランドが1つ目の引数になる。

~~~cpp
struct IntLike
{
    int data ;

    IntLike operator +( IntLike const & right )
    {
        return IntLike { data + right.data } ;
    }
} ;

int main()
{
    IntLike a(1) ;
    IntLike b(2) ;

    IntLike c = a + b ;
}
~~~

この場合、メンバー関数は変数`a`に対して呼ばれ、変数`b`が`right`となる。

普通のメンバー関数のように呼ぶこともできる。

~~~cpp
IntLike c = a.operator +( b ) ;
~~~

一見戸惑うかもしれないが、これは普通のメンバー関数呼び出しと何ら変わらない。

~~~cpp
struct S
{
    void plus( S const & other ) { }
    void operator +( S const & other ) { }
} ;

int main()
{
    S a ;
    S b ;

    // これはメンバー関数呼び出し
    a.plus(b) ;
    // これもメンバー関数呼び出し
    a.operator +(b) ;
    // 同じくメンバー関数呼び出し
    a + b ;
}
~~~

演算子のオーバーロードはフリー関数とメンバー関数のどちらで実装すればいいのだろうか。答えはどちらでもよい。ただし、ごく一部の演算子はメンバー関数でしか実装できない。

こうして、この章の冒頭にある演算子を使った自然な四則演算の記述が、自作のクラスでも可能になる。
