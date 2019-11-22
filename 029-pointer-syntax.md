
## 文法上のポインター 

ポインターが難しいと言われる理由の1つに、ポインターの文法が難しい問題がある。

### ポインターとconstの関係

型としてのポインターは、ある型`T`があるときに、`T`へのポインター型となる。

`T`へのポインター型は`T *`と書く。

~~~cpp
// intへのポインター型
using t1 = int * ;
// doubleへのポインター型
using t2 = double * ;
// std::stringへのポインター型
using t3 = std::string * ;
// std::array<int,5>へのポインター型
using t4 = std::array<int,5> * ;
// std::array<double,10>へのポインター型
using t5 = std::array<double,10> * ;
~~~

リファレンスや`const`も同じだ。

~~~cpp
// int型へのポインター型
using t1 = int * ;
// int型へのリファレンス型
using t2 = int & ;
// どちらも同じconstなint型
using t3 = const int ;
using t4 = int const ;
~~~

`const int`と`int const`は同じ型だ。この場合、`const`は`int`型のあとに付いても前に付いても同じ意味になる。

すると当然の疑問が生じる。組み合わせるとどうなるのかということだ。

ポインター型へのリファレンス型はできる。

~~~cpp
// int *型へのリファレンス
using type = int * & ;
~~~

リファレンス型へのポインター型はできない。

~~~cpp
// エラー、できない
using error = int & * ;
~~~

理由は、リファレンスへのポインターというのは意味がないからだ。ポインターへのリファレンスは意味がある。

リファレンスからポインターの値を得るには、参照先のオブジェクトと同じく`&`を使う。

~~~cpp
int data { } ;
int & ref = data ;
// &dataと同じ
int * ptr = &ref ;
~~~

リファレンスは参照先のオブジェクトとまったく同じように振る舞うのでリファレンス自体のポインターの値を得ることはできない。

ポインターのリファレンスを得るのは、ポインター以外の値とまったく同じだ。

~~~cpp
int * ptr = nullptr ;
// ptrを参照する
int * & ref = ptr ;

int data { } ;
// ptrの値が&dataになる。
ref = &data ;
~~~

`const`とポインターの組み合わせは難しい。

まず型`T`とその`const`版がある。

~~~cpp
using T = int ;
using const_T = const T ;
~~~

そして型`T`とそのポインター版がある。

~~~cpp
using T = int ;
using T_pointer = T * ;
~~~

これを組み合わせると、以下のようになる。

~~~cpp
// 型T
using T = int ;
// どちらもconstなT
using const_T_1 = const T ;
using const_T_2 = T const ;
// Tへのポインター
using T_pointer = T * ;

// どちらもconstなTへのポインター
using const_T_pointer_1 = const T * ;
using const_T_pointer_2 = T const * ;

// Tへのconstなポインター
using T_const_pointer = T * const ;

// どちらもconstなTへのconstなポインター
using const_T_const_pointer_1 = const T * const ;
using const_T_const_pointer_2 = T const * const ;
~~~

順番に見ていこう。まずは組み合わせない型から。

~~~cpp
using T = int ;
// どちらもconstなT
using const_T_1 = const T ;
using const_T_2 = T const ;
// Tへのポインター
using T_pointer = T * ;
~~~

`T`はここでは`int`型だ。`T`型はどんな型でもよい。

`const T`と`T const`が同じ型であることを思い出せば、`const_T_1`と`const_T_2`は同じ型であることがわかるだろう。

`T_pointer`は`T`へのポインターだ。

次を見ていこう。

~~~cpp
// どちらもconstなTへのポインター
using const_T_pointer_1 = const T * ;
using const_T_pointer_2 = T const * ;
~~~

これはどちらも同じ型だ。`const`な`T`へのポインターとなる。わかりにくければ以下のように書いてもよい。

~~~cpp
// constなT
using const_T = const int ;
// constなTへのポインター
using const_T_pointer = const_T * ;
~~~

実際に使ってみよう。

~~~cpp
int main()
{
    const int data = 123 ;
    // int const *でもよい
    const int * ptr = &data ;

    // 読み込み
    int read = *ptr ;
}
~~~

`const`な`int`へのポインターなので、このポインターの参照先を変更することはできない。ポインターは変更できる。

~~~cpp
int main()
{
    const int x {} ;
    const int * ptr = &x ;

    // エラー
    // constな参照先を変更できない
    *ptr = 0 ;

    int y {} ;
    // OK
    // ポインターはconstではないので値が変更できる
    ptr = &y ;
}
~~~

`const`なのは`int`であってポインターではない。`const int *`、もしくは`int const *`は参照先の`int`が`const`なので、参照先を変更することができない。ポインターは`const`ではないので、ポインターの値は変更できる。

`const`な`T`型へのリファレンスで`const`ではない`T`型のオブジェクトを参照できるように、`const`な`T`型へのポインターから`const`ではない`T`型のオブジェクトを参照できる。

~~~cpp
int main()
{
    // constではない
    int data { } ;

    // OK
    const int & ref = data ;
    // OK
    const int * ptr = &data ;
}
~~~

この場合、リファレンスやポインターは`const int`扱いなので、リファレンスやポインターを経由して読むことはできるが変更はできない。

~~~cpp
int main()
{
    int data = 123 ;
    const int * ptr = &data ;
    // エラー
    // 変更できない
    *ptr = 0 ;

    // 変更できる
    data = 0 ;
}
~~~

その次は`const`なポインターだ。

~~~cpp
// Tへのconstなポインター
using T_const_pointer = T * const ;
~~~

これはポインターが`const`なのであって、`T`は`const`ではない。したがってポインターを経由して参照先を変更することはできるが、ポインターの値自体は変更できない型だ。

~~~cpp
int main()
{
    int data { } ;

    // constなポインター
    int * const ptr = &data ;

    // OK、参照先は変更できる
    *ptr = 1 ;

    // エラー、値は変更できない
    ptr = nullptr ;
}
~~~

最後は`const`な`T`への`const`なポインターだ。

~~~cpp
// どちらもconstなTへのconstなポインター
using const_T_const_pointer_1 = const T * const ;
using const_T_const_pointer_2 = T const * const ;
~~~

これは`const`な`T`なので、ポインターを経由して参照先を変更できないし、`const`なポインターなのでポインターの値も変更できない。

~~~cpp
int main()
{
    int data = 123 ;

    int const * const ptr = &data ;

    // OK、参照先は読める
    int read = *ptr ;
    // エラー、参照先は変更できない
    *ptr = 0 ;
    // エラー、ポインターは変更できない
    ptr = nullptr ;
}
~~~

### ポインターのポインター

ポインター型というのは、「ある型`T`へのポインター」という形で表現できる。この型`T`にはどんな型でも使うことができる。ところで、ポインターというのは型だ。もし`T`がポインター型の場合はどうなるのだろう。

例えば、「`T`型へのポインター型」で、型`T`が「`U`型へのポインター型」の場合、全体としては「`U`型へのポインター型へのポインター型」になる。これはC++の文法では`U **`となる。

C++のコードで確認しよう。

~~~cpp
// 適当なU型
using U = int ;
// ポインターとしてのT型
using T = U * ;
// T型へのポインター型
// つまりU型へのポインター型へのポインター型
// つまりU **
using type = T * ;
~~~

具体的に書いてみよう。

~~~cpp
int main()
{
    // int
    int x = 123 ;
    // intへのポインター
    int * p = &x ;
    // intへのポインターのポインター
    int ** pp = &p ;


    // 123
    // ポインターを経由したポインターを経由したxの読み込み
    int value1 = **pp ; 

    int y = 456 ;
    // ポインターを経由した変数pの変更
    *pp = &y ;

    // 456
    // ポインターを経由したポインターを経由したyの読み込み
    int value2 = **pp ;
}
~~~

`x`は`int`だ。`p`は`int`へのポインターだ。ここまではいままでどおりだ。

`pp`は`int **`という型で、「`int`へのポインターへのポインター」型だ。このポインターの値のためには「`int`へのポインターのポインター」が必要だ。変数`p`のポインターは`&p`で得られる。この場合、変数`p`は「`int`へのポインター」でなければならない。そうした場合、変数`p`のポインターは「`int`へのポインターのポインター」型の値になる。

変数`pp`は「`int`へのポインターのポインター」だ。変数`pp`の参照先の変数`p`を読み書きするには、`*pp`と書く。これはまだ「`int`へのポインター」だ。ここからさらに参照先の`int`型のオブジェクトにアクセスするには、その結果にさらに`*`を書く。結果として`**pp`となる。

わかりにくければ変数に代入するとよい。

~~~cpp
int main()
{
    int object { } ;

    int *   a = &object ;
    int **  b = &a ;

    // cとaは同じ値
    int * c = *pointer_to_pointer_to_object ;

    // objectに1が代入される
    *c = 1 ;
    // objectに2が代入される
    **b = 2 ;
}
~~~

リファレンスを使うという手もある。

~~~cpp
int main()
{
    int object { } ;

    int *   a = &object ;
    int **  b = &a ;

    int & r1 = *a ;

    // objectに1が代入される
    r1 = 1 ;

    int &r2 = **b ;

    // objectに2が代入される
    r2 = 2 ;
}
~~~

「ポインターへのポインター」があるということは、「ポインターへのポインターへのポインター」もあるということだろうか。もちろんある。

~~~cpp
// intへのポインターへのポインターへのポインター型
using type = int *** ;

// intへのポインターへのポインターへのポインターへのポインター型
// int ****
using pointer_to_type = type * ;
~~~

もちろん`const`も付けられる。

~~~cpp
using type = int const * const * const * const ;
~~~

### 関数へのポインター

関数へのポインターを説明する前に、まず型としての関数を説明しなければならない。

関数にも型がある。例えば以下のような関数、

~~~cpp
int f( int ) ;
double g( double, double ) ;
~~~

の型は、

~~~cpp
using f_type = int ( int ) ;
using g_type = double ( double, double ) ;
~~~

となる。関数から関数名を取り除いたものが関数の型だ。すると関数へのポインター型は以下のようになる。

~~~cpp
using f_pointer = f_type * ;
using g_pointer = g_type * ;
~~~

さっそく試してみよう。

~~~cpp
// 実引数を出力して返す関数
int f( int x )
{
    std::cout << x ;
    return x ;
}

int main()
{
    using f_type = int ( int ) ;
    using f_pointer = f_type * ;

    f_pointer ptr = &f ;

    // 関数へのポインターを経由した関数呼び出し
    (*ptr)(123) ;
}
~~~

動くようだ。最後の関数呼び出しはまず参照先を得て`(*ptr)`、その後に関数呼び出し`(123)`をしている。これは面倒なので、C++では特別に関数へのポインターはそのまま関数呼び出しすることができるようになっている。

~~~cpp
// 関数へのポインターを経由した関数呼び出し
ptr(123) ;
~~~

ところで、変数`ptr`の宣言を、`f_pointer`というエイリアス宣言を使わずに書くと、以下のようになる。

~~~cpp
// 適当な関数
int f( int ) { return 0 ; }

// 変数ptrの宣言
// int (int)へのポインター
int (*ptr)(int) = &f ;
~~~

なぜこうなるのか。これを完全に理解するためにはC++の宣言子(declarator)という文法の詳細な理解が必要だ。

ここでは詳細を飛ばして重要な部分だけ伝えるが、型名のうちポインターであることを指定する`*`は、名前にかかる。

~~~cpp
// この *はnameにかかる
int * name ;
~~~

つまり以下のような意味だ。

~~~cpp
int (*name) ;
~~~

型名だけを指定する場合、名前が省略される。

~~~cpp
// 名前が省略されている
using type = int * ;
~~~

つまり以下のような意味だ。


~~~cpp
using type = int (*) ;
~~~

そのため、`int * name( int )`と書いた場合、これは「`int`型の引数を取り、`int`型へのポインターを戻り値として返す関数」となる。

~~~cpp
int * f( int ){ return nullptr ; }
~~~

そうではなく、「`int`型の引数を取り`int`型の戻り値を返す関数へのポインター」を書きたい場合は、

~~~cpp
using type = int (*)(int) ;
~~~

としなければならない。

変数の名前を入れる場所は以下のとおり。

~~~cpp
using type =
int
( * // ポインター
// ここに変数が省略されている
)(int) ;
~~~

なので、

~~~cpp
int (*ptr)(int) = nullptr ;
~~~

となる。あるいは以下のように書いてもいい。

~~~cpp
using function_type = int (int) ;
using function_pointer_type = function_type * ;

function_pointer_type ptr = nullptr ;
~~~

関数へのポインターは型であり、値でもある。値であるということは、関数は引数として関数へのポインターを受け取ったり、関数へのポインターを返したりできるということだ。

さっそく書いてみよう。

~~~cpp
int f( int x ) { return x ; }
using f_ptr = int (*) (int ) ;
// 関数へのポインターを引数に取り
// 関数へのポインターを戻り値として返す
// 関数g
f_ptr g( f_ptr p )
{
    p(0) ;
    return p ;
}

int main()
{
    g(&f) ;
}
~~~

これは動く。ところでこの関数`g`へのポインターはどう書けばいいのだろうか。つまり、

~~~
auto ptr = &g ;
~~~

を`auto`を使わずに書くとどうなるのだろうか。

以下のようになる。

~~~cpp
int (*(*ptr)(int (*)(int)))(int) = &g ;
~~~

なぜこうなるのか。分解すると以下のようになる。

~~~cpp
int (* // 戻り値型前半
    (*ptr) // 変数名
    (// 関数の引数
        int (*)(int) // 引数としての関数へのポインター
    )// 関数の引数

)(int) // 戻り値の型後半

 = &g ; // 初期化子
~~~

これはわかりにくい。戻り値の型を後ろに書く文法を使うと少し読みやすくなる。

~~~cpp
auto (*ptr)( int (*)(int) ) -> int (*)(int) = &g ;
~~~

これを分解すると以下のようになる。

~~~cpp
auto // プレイスホルダー
(*ptr) // 変数名
( int (*)(int) ) // 引数
-> int (*)(int) // 戻り値の型
= &g ; // 初期化子
~~~

もちろん、これでもまだわかりにくいので、エイリアス宣言を使った方がよい。

~~~cpp
using func_ptr = int(*)(int) ;

auto (*ptr)(func_ptr) -> func_ptr = &g ;
~~~

### 配列へのポインター

配列へのポインターについて学ぶ前に、配列の型について学ぶ必要がある。

配列の型は、要素の型を`T`、要素数を`N`とすると、`T [N]`となる。

~~~cpp
// 要素型int、要素数5の配列型
using int5 = int [5] ;
// 要素型double、要素数10の配列型
using double10 = double [10] ;
~~~

関数型と同じく、ポインター宣言子である`*`は名前に付く。

~~~cpp
// 要素型int、要素数5の配列へのポインター型
using pointer_to_array_type = int (*)[5] ;

int main()
{
    int a[5] ;
    pointer_to_array_type ptr = &a ;
}
~~~

エイリアス宣言を使わない変数の宣言は以下のようになる。

~~~cpp
int main()
{
    int a[5] ;
    int (*p)[5] = &a ;
}
~~~

配列とポインターは密接に関係している。そのため、配列名は配列の先頭要素へのポインターに暗黙に変換される。

~~~cpp
int main()
{
    int a[5] = {1,2,3,4,5} ;

    // &a[0]と同じ
    int * ptr = a ;
}
~~~

配列とポインターの関係については、ポインターの詳細で詳しく説明する。

### ポインター型の作り方

`T`型へのポインター型は`T *`で作ることができる。

ただし、`T`が`int (int)`のような関数型である場合は、`int (*)(int)`になる。配列型の場合は要素数`N`まで必要で`T (*)[N]`になる。

エイリアス宣言で型に別名を付けると`T *`でよくなる。

~~~cpp
using function_type = int (int) ;
using pointer_to_function_type = function_type * ;
~~~

ポインターの型を書く際に、このようなことをいちいち考えるのは面倒だ。ここで必要のなのは、ある型`T`を受け取ったときに型`T *`を得るような方法だ。ところで、物覚えのいい読者は前にも似たような文章を読んだことに気が付くだろう。そう、テンプレートだ。

テンプレートは型を引数化できる機能だ。いままではクラスや関数にしか使っていなかったが、実はエイリアス宣言にも使えるのだ。

~~~cpp
template < typename T >
using type = T ;
~~~

これは引数と同じ型になるエイリアステンプレートだ。使ってみよう。

~~~cpp
template < typename T > using type = T ;

// aはint
type<int> a = 123 ;
// bはdouble
type<double> b = 1.23 ;
// cはstd::vector<int>
type<std::vector<int>> c = {1,2,3,4,5} ;
~~~

`using type = int ;`というエイリアス宣言があるとき`type`の型は`int`だ。エイリアス宣言は新しい`type`という型を作るわけではない。

同様に、上のエイリアステンプレート`type`による`type<int>`の型は`int`だ。新しい`type<int>`という型ができるわけではない。

もう少し複雑な使い方もしてみよう。

~~~cpp
// int
type<type<int>> a = 0 ;
// int
type<type<type<int>>> b = 0 ;
~~~

`type<int>`の型は`int`なので、それを引数に渡した`type< type<int> >`も`int`だ。`type<T>`をいくつネストしようとも`int`になる。


~~~cpp
// std::vector<int>
std::vector< type<int> > a = {1,2,3,4,5} ;
// std::vector<int>
type<std::vector<type<int>>> b = {1,2,3,4,5} ;
~~~

`type<int>`は`int`なので、`std::vector<type<int>>`は`std::vector<int>`になる。それをさらに`type<T>`で囲んでも同じ型だ。

`type<T>`は面白いが何の役に立つのだろうか。`type<T>`は型として使える。つまり`type<T> *`はポインターとして機能するのだ。

~~~cpp
template < typename T > using type = T ;

// int *
type<int> * a = nullptr ;
// int (*)(int)
type<int(int)> * b = nullptr ;
// int (*) [5]
type<int [5]> * c = nullptr ;
~~~

`type<int> *`は`int *`型だ。`type<int(int)> *`は`int(*)(int)`型だ。`type<int [5]> *`は`int (*) [5]`型だ。これでもう`*`をどこに書くかという問題に悩まされることはなくなった。

しかしわざわざ`type<T> *`と書くのは依然として面倒だ。`T`型は引数で受け取っているのだから、最初からポインターを返してどうだろうか。

~~~cpp
template < typename T >
using add_pointer_t = T * ;
~~~

さっそく試してみよう。

~~~cpp
// int *
add_pointer_t<int> a = nullptr ;
// int **
add_pointer_t<int *> b = nullptr ;
// int(*)(int)
add_pointer_t<int(int)> c = nullptr ;
// int(*)[5]
add_pointer_t<int [5]> d = nullptr ;
~~~

どうやら動くようだ。もっと複雑な例も試してみよう。

~~~cpp
// int **
add_pointer_t<add_pointer_t<int>> a = nullptr ;
~~~

`add_pointer_t<int>`は`int *`なので、その型を`add_pointer_t<T>`で囲むとその型へのポインターになる。結果として`int **`になる。

ここで実装した`add_pointer_t<T>`は`T`がリファレンスのときにエラーになる。

~~~cpp
template < typename T > using add_pointer_t = T * ;
// エラー
add_pointer_t<int &> ptr = nullptr ;
~~~

実は標準ライブラリにも`std::add_pointer_t<T>`があり、こちらはリファレンス`U &`を渡しても、`U *`になる。

~~~cpp
// OK
// int *
std::add_pointer_t<int &> ptr = nullptr ;
~~~

標準ライブラリ`std::add_pointer_t<T>`は、`T`がリファレンス型の場合、リファレンスは剝がしてポインターを付与するという実装になっている。これをどうやって実装するかについてだが、まだ読者の知識では実装できない。テンプレートについて深く学ぶ必要がある。いまは標準ライブラリに頼っておこう。

標準ライブラリにはほかにも、ポインターを取り除く`std::remove_pointer_t<T>`もある。

~~~cpp
// int
std::remove_pointer_t<int * > a = 0 ;
// int
std::remove_pointer_t<
    std::add_pointer_t<int>
    > b = 0 ;
~~~



### クラスへのポインター

クラスへのポインターはいままでに学んだものと同じ文法だ。

~~~cpp
struct C { } ;

int main()
{
    C object ;
    C * pointer = &object ;
} 
~~~


ただし、ポインターを経由してメンバーにアクセスするのが曲者だ。

以下のようなメンバーにアクセスするコードがある。

~~~cpp
struct C
{
    int data_member ;
    void member_function() {}
} ;

int main()
{
    C object ;

    object.data_member = 0 ;
    object.member_function() ;
}
~~~

これをポインターを経由して書いてみよう。

以下のように書くとエラーだ。

~~~cpp
int main()
{
    C object ;
    C * pointer = &object ;

    // エラー
    *pointer.data_member = 0 ;
    // エラー
    *pointer.member_function() ;
}
~~~

この理由は演算子の優先順位の問題だ。上の式は以下のように解釈される。

~~~cpp
*(pointer.data_member) = 0 ;
*(pointer.member_function()) ;
~~~

ポインターを参照する演算子`*`よりも、演算子ドット(`'.'`)の方が演算子の優先順位が高い。

このような式を可能にする変数`pointer`とは以下のようなものだ。

~~~cpp
struct Pointer
{
    int data  = 42 ;
    int * data_member = &data ;
    int * member_function()
    {
        return &data ;
    }
} ;

int main()
{
    Pointer pointer ;

    *pointer.data_member = 0;
    *pointer.member_function() ;
}
~~~

`pointer.data_member`はポインターなのでそれに演算子`*`を適用して参照した上で`0`を代入している。

`pointer.member_function()`は関数呼び出しで戻り値としてポインターを返すのでそれに演算子`*`を適用している。


演算子`*`を先にポインターの値である`pointer`に適用するには、括弧を使う。

~~~cpp
(*pointer).data_member = 0 ;
(*pointer).member_function() ;
~~~

リファレンスを使ってポインターを参照した結果をリファレンスに束縛して使うこともできる。

~~~cpp
C & ref = *pointer ;
ref.data_member = 0 ;
ref.member_function() ;
~~~

ただし、ポインターを介してクラスを扱う際に、毎回括弧を使ったりリファレンスを使ったりするのは面倒なので、簡単なシンタックスシュガーとして演算子`->`が用意されている。

~~~cpp
pointer->data_member = 0 ;
pointer->member_function() ;
~~~

`a->b`は、`(*(a)).b`と同じ意味になる。そのため、上は以下のコードと同じ意味になる。

~~~cpp

(*(pointer)).data_member = 0 ;
(*(pointer)).member_function() ;
~~~

### thisポインター

メンバー関数はクラスのデータメンバーにアクセスできる。このときのデータメンバーはメンバー関数が呼ばれたクラスのオブジェクトのサブオブジェクトになる。

~~~cpp
struct C
{
    int data { } ;

    void set( int n )
    {
        data = n ;
    }
} ;

int main()
{
    C a ;
    C b ;

    // a.dataを変更
    a.set(1) ;
    // b.dataを変更
    b.set(2) ;
}
~~~

すでに説明したように、メンバー関数が自分を呼び出したクラスのオブジェクトのサブオブジェクトを参照できるのは、クラスのオブジェクトへの参照を知っているからだ。内部的には以下のような隠し引数を持つコードが生成されたかのような挙動になる。

~~~cpp
// コンパイラーが生成するコードのたとえ
struct C
{
    int data { } ;
} ;

// 隠し引数
void set( C & obj, int n )
{
    obj.data = n ;
}
~~~

つまり、メンバー関数は自分を呼び出したクラスのオブジェクトへの参照を知っている。その参照にアクセスする方法が`this`キーワードだ。

`this`キーワードはクラスのメンバー関数の中で使うと、メンバー関数を呼び出したクラスのオブジェクトへのポインターとして扱われる。

~~~cpp
struct C
{
    int data { } ;

    void set( int n )
    {
        // このメンバー関数を呼び出したクラスのオブジェクトへのポインター
        C * pointer = this ;
        this->data = n ;
    }
} ;
~~~

先ほど、関数`C::set`の中で`data = n ;`と書いたのは、`this->data = n ;`と書いたのと同じ意味になる。

`this`はリファレンスではなくてポインターだ。この理由は歴史的なものだ。本来ならばリファレンスの方がよいのだが、いまさら変更できないのでポインターになっている。わかりにくければリファレンスに束縛してもよい。

~~~cpp
struct S
{
    void f()
    {
        auto & this_ref = *this ;
    }
} ;
~~~

`const`なメンバー関数の中では、`this`の型も`const`なクラス型へのポインターになる。

~~~cpp
struct S
{
    void f()
    {
        // thisの型はS *
        S * pointer = this ;
    }

    void f() const
    {
        // thisの型はS const *
        S const * pointer = this ;
    }
} ;
~~~

この理由は、`const`なメンバー関数はクラスのオブジェクトへの参照として`const`なリファレンスを隠し引数として持つからだ。

~~~cpp
// コンパイラーが生成するコードのたとえ
struct S { } ;

// 非constなメンバー関数
void f( S & obj ) ;

// constなメンバー関数
void f( S const & obj ) ;
~~~


### メンバーへのポインター

メンバーへのポインターはかなり文法的にややこしい。そもそも、通常のポインターとは概念でも実装でも異なる。

ここで取り扱うのはメンバーへのポインターという概念で、クラスのオブジェクトのサブオブジェクトへのポインターではない。サブオブジェクトへのポインターは通常のポインターと同じだ。

~~~cpp
struct Object
{
    // サブオブジェクト
    int subobject ;
} ;

int main()
{
    // クラスのオブジェクト
    Object object ;

    // サブオブジェクトへのポインター
    int * pointer = &object.subobject ;

    *pointer = 123 ;
    int read = object.subobject ;
}
~~~

メンバーへのポインターとは、クラスのデータメンバーやメンバー関数を参照するもので、クラスのオブジェクトとともに使うことでそのデータメンバーやメンバー関数を参照できるものだ。

細かい文法の解説はあとにして例を見せよう。

~~~cpp
struct Object
{
    int data_member ;
    void member_function()
    { std::cout << data_member ; }
} ;

int main()
{
    // Object::data_memberメンバーへのポインター
    int Object::* int_ptr = &Object::data_member ;
    // Object::member_functionメンバーへのポインター
    void (Object::* func_ptr)() = &Object::member_function ;

    // クラスのオブジェクト
    Object object ;

    // objectに対するメンバーポインターを介した参照
    object.*int_ptr = 123 ;
    // objectに対するメンバーポインターを介した参照
    // 123
    (object.*func_ptr)() ;

    // 別のオブジェクト
    Object another_object ;
    another_object.data_member = 456 ;
    // 456
    (another_object.*func_ptr)() ;
}
~~~

細かい文法はあとで学ぶとして、肝心の機能としてはこうだ。クラスのオブジェクトからは独立したデータメンバーやメンバー関数自体へのポインターを取得する。

~~~cpp
struct Object
{
    int data_member ;
} ;

// メンバーへのポインター
int Object::*int_ptr = &Object::data_member ; 
~~~

このポインターをクラスのオブジェクトと組み合わせることで、ポインターが参照するクラスのメンバーで、かつオブジェクトのサブオブジェクトの部分を参照できる。

~~~cpp
Object object ;

// メンバーへのポインターをオブジェクトに適用してサブオブジェクトを参照する
object.*int_ptr = 123 ;
~~~

では文法の説明に入ろう。

メンバーへのポインターは文法がややこしい。

あるクラス名`C`の型名`T`のメンバーへのポインター型は以下のようになる。

~~~c++
型名 クラス名::*
T C::*
~~~

以下のクラスの各データメンバーへの型はそれぞれコメントのとおりになる。

~~~cpp
struct ABC
{
    // int ABC::*
    int x ;
    // int ABC::*
    int y ;
    // double ABC::*
    double d ;
    // int * ABC::*
    int * ptr ;
} ;

struct DEF
{
    // ABC * DEF::*
    ABC * abc ;
} ;
~~~

順を追って説明していこう。まずクラス`ABC`のメンバー、

~~~cpp
// int ABC::*
int x ;
// int ABC::*
int y ;
~~~

このメンバーへのポインターの型はどちらも`int ABC::*`になる。データメンバーの型は`int`で、クラス名が`ABC`なので、`型名 クラス名::*`に当てはめると`int ABC::*`になる。

~~~cpp
// double ABC::*
double d ;
~~~

このメンバーへのポインターの型は`double ABC::*`になる。

最後のクラス`ABC`のメンバー、

~~~cpp
// int * ABC::*
int * ptr ;
~~~

これが`int * ABC::*`になる理由も、最初に説明した`型名 クラス名::*`のルールに従っている。型名が`int *`、クラス名が`ABC`なので、`int * ABC::*`だ。

最後の例はクラス`DEF`のメンバーとしてクラス`ABC`のポインター型のメンバーだ。`ABC DEF::*`になる。

クラス名`C`のメンバー名`M`のメンバーへのポインターを得るには以下の文法を使う。

~~~c++
&クラス名::メンバー名
&C::M
~~~

具体的な例を見てみよう。

~~~cpp
struct C
{
    int x = 1 ;
    int y = 2 ;
} ;

int main()
{
    int C::* x_ptr = &C::x ;
    int C::* y_ptr = &C::y ;

    C object ;

    // 1
    std::cout << object.*x_ptr ;
    // 2 
    std::cout << object.*y_ptr ;
}
~~~

わかりづらければエイリアス宣言を使うとよい。

~~~cpp
using type = int C::* ;
type x_ptr = &C::x ;
~~~

あるいは`auto`を使うという手もある。

~~~cpp
// int C::*
auto x_ptr = &C::x ;
~~~

メンバー関数へのポインターは、メンバーへのポインターと関数へのポインターを組み合わせた複雑な文法となるので、とてもわかりづらい。

復習すると、`int`型の引数を1つ受け取り`int`型の戻り値を返す関数へのポインターの型は`int (*)(int)`だ。

~~~cpp
int f(int) { return 0 ; }
int (*ptr)(int) = &f ;
~~~

この関数がクラス`C`のメンバー関数の場合、以下のようになる。

~~~cpp
struct C
{
    int f(int) { return 0 ; }
} ;
~~~

ところで、メンバーへのポインターは`型名 クラス名::*`だった。この2つを組み合わせると、以下のように書ける。

~~~cpp
struct C
{
    int f(int) { return 0 ; }
} ;

int main()
{
    // メンバー関数へのポインター
    int (C::*ptr)(int) = &C::f ;
    // クラスのオブジェクト
    C object ;

    // オブジェクトを指定したメンバー関数へのポインターを介した関数呼び出し
    (object.*ptr)( 123 ) ;
}
~~~

メンバー関数へのポインターは難しい。

関数`f`の型は`int (int)`で、そのポインターの型は`int (*)(int)`だ。するとクラス名`C`のメンバー関数`f`へのポインターの型は、`int (C::*)(int)`になる。

メンバー関数へのポインター型の変数を宣言してその値を`C::f`へのポインターに初期化しているのが以下の行だ。

~~~cpp
// メンバー関数へのポインター
int (C::*ptr)(int) = &C::f ;
~~~

この`ptr`を経由したメンバー関数`f`の呼び出し方だが、まずクラスのオブジェクトが必要になるので作る。

~~~cpp
C object ;
~~~

そして演算子の`operator .*`を使う。

~~~cpp
(object.*ptr)(123) ;
~~~

`object.*ptr`を括弧で囲んでいるのは、演算子の優先順位のためだ。もしこれを以下のように書くと、

~~~cpp
object.*ptr(123)
~~~

これは`ptr(123)`という式を評価した結果をメンバーへのポインターと解釈してクラスのオブジェクトを介して参照していることになる。例えば以下のようなコードだ。

~~~cpp
struct C { int data { } ; } ;

auto ptr( int ) -> int C::*
{ return &C::data ; }

int main()
{
    C object ;
    object.*ptr(123) ;
}
~~~

演算子の優先順位の問題のために、`(object.*ptr)`と括弧で包んで先に評価させ、その後に関数呼び出し式である`(123)`を評価させる。

実は演算子`operator .*`のほかに、`operator ->*`という演算子がある。

`.*`はクラスのオブジェクトがリファレンスの場合の演算子だが、`->*`はクラスのオブジェクトがポインターの場合の演算子だ。

~~~cpp
struct C{ int data { } ; } ;

int main()
{
    auto data_ptr = &C::data ;

    C object ;
    auto c_ptr = &object ;

    c_ptr->*data_ptr = 123 ;
}
~~~

演算子`a->b`が`(*(a)).b`となるように、演算子`a->*b`も`(*(a)).*b`と置き換えられるシンタックスシュガーだ。

上の例で、

~~~cpp
c_ptr->*object = 123 ;
~~~

は、以下と同じだ。

~~~cpp
(*(c_ptr)).*object = 123 ;
~~~

`.*`や`->*`の文法を覚えるのが面倒な場合、標準ライブラリに`std::invoke( f, t1, ... )`という便利な関数が用意されている。

`f`がデータメンバーへのポインターで、`t1`がクラスのオブジェクトの場合、`std::invoke(f, t1)`は以下のような関数になる。

~~~cpp
template < typename F, typename T1 >
適切な戻り値の型 std::invoke( F f, T1 t1 )
{
    return t1.*f ;
}
~~~


なので以下のように書ける。

~~~cpp
struct C { int data { } ; } ;

int main()
{
    auto data_ptr = &C::data ;

    C object ;

    // どちらも同じ意味
    object.*data_ptr = 123 ;
    std::invoke( data_ptr, object ) = 123 ;
}
~~~

便利なことに`t1`がポインターの場合は、

~~~cpp
template < typename F, typename T1 >
適切な戻り値の型 std::invoke( F f, T1 t1 )
{
    return (*(t1)).*f ;
}
~~~

という関数として振る舞う。そのため、リファレンスでもポインターでも気にせずに使うことができる。

~~~cpp
C * c_ptr = &object ;

// どちらも同じ意味
c_ptr->*data_ptr = 123 ;
std::invoke( data_ptr, c_ptr ) = 123 ;
~~~


`std::invoke`がさらにすごいことに、メンバー関数へのポインターにも対応している。


`std::invoke( f, t1, ... )`で、`f`がメンバー関数へのポインターで、`t1`がクラスのオブジェクトへのリファレンスで、`...`が関数呼び出しの際の引数の場合、以下のような関数として振る舞う。

~~~c++
template < typename F, typename T1,
    // まだ知らない機能
    typename ... Ts >
適切な戻り値の型
invoke( F f, T1 t1,
// まだ知らない機能
Ts ... ts )
{
    return (t1.*f)(ts...)
}
~~~

厳密にはこの宣言は間違っているのだが、まだ知らない機能を使っているので気にしなくてもよい。大事なことは、`std::invoke`の第三引数以降の実引数が、関数呼び出しの実引数として使われるということだ。

~~~cpp
struct C
{
    int f0() { return 0 ; }
    int f1(int) { return 1 ; } 
    int f2( int, int ) { return 2 ; }
} ;

int main()
{
    C object ;

    // 同じ
    (object.*&C::f0)() ;
    std::invoke( &C::f0, object ) ;
    // 同じ
    (object.*&C::f1)(1) ;
    std::invoke( &C::f1, object, 1) ;
    // 同じ
    (object.*&C::f2)(1,2) ;
    std::invoke( &C::f2, object, 1,2) ;
}
~~~

この場合も、`object`が`C`へのリファレンスではなく、`C`へのポインターでも自動で認識していいように処理してくれる。
