# ポインターの基礎

ポインターは難しいとよく言われる。世の中にはポインターのためにC言語とC++を挫折し、他の軟弱な言語に逃げるプログラマーがいる。ポインターしか解説していない本が出版される。Joel Spolskyがエッセイを書く。

ポインターの理解は優秀なプログラマーとなるために必須である。ポインターを理解できない人間は優秀なプログラマーにはなれない。もし、本書を呼んでポインターが理解できない場合、プログラマーには向いていないということだ。

ポインターを難しくしている原因には、意味上のポインターと、文法上のポインターと、ポインターの内部実装がある。いずれも難しいが、本書を読めばポインターは完全に理解できる。

## 意味上のポインター

### リファレンスと同じ機能

ポインターはオブジェクトを参照するための機能だ。この点ではリファレンスと同じ機能を提供している。

リファレンスを覚えているだろうか。T型へのリファレンスはT型のオブジェクトそのものではなく、T型のオブジェクトへの参照だ。リファレンスへの操作は、参照したオブジェクトへの操作になる。

~~~cpp
int main()
{
    // int型のオブジェクト
    int object = 0 ;

    // オブジェクトを変更
    object = 123 ;

    // 123
    std::cout << object ;

    // T型へのリファレンス
    // objectを参照する
    int & reference = object ;

    // objectが変更される
    reference = 456 ;

    // 456
    std::cout << object ;

    // referenceはobjectを参照している
    object = 789 ;

    // 参照するobjectの値
    // 789
    std::cout << reference ;
}
~~~

リファレンスは宣言と同時に初期化する。リファレンスの参照先をあとから返ることはできない。

~~~cpp
int main()
{
    int x = 0 ;

    // rはxを参照する
    int r = x ;

    int y = 1 ;

    // xに1が代入される
    r = y ;
}
~~~

最後の`r = y ;`はリファレンスrの参照先をyに変えるという意味ではない。リファレンスrの参照先にyの値を代入するという意味だ。

ポインターはリファレンスに似ている。並べてみるとほとんど同じ意味だ。

+ T型へのリファレンスはT型のオブジェクトを参照する
+ T型へのポインターはT型のオブジェクトを参照する

T型へのリファレンス型が`T &`であるのに対し、T型へのポインター型は`T *`だ。

~~~cpp
// intへのリファレンス型
using ref_type = int & ;
// intへのポインター型
using ptr_type = int * ;
~~~

リファレンスの初期化は、単に参照したい変数名をそのまま書けばよかった。

~~~c++
int object { } ;
int & reference = object ;
~~~

ポインターの場合、参照したい変数名に、`&`をつける必要がある。

~~~c++
int object { } ;
int * pointer = &object ;
~~~

リファレンスを経由してリファレンスが参照するオブジェクトを操作するには、単にリファレンス名を使えばよかった。

~~~c++
// 書き込み
reference = 0
// 読み込み
int read = reference ;  
~~~

ポインターの場合、ポインター名に`*`をつける必要がある。

~~~c++
// 書き込み
*pointer = 0 ;
// 読み込み
int read = *pointer ;
~~~

ポインター名をそのまま使った場合、それは参照先のオブジェクトの値ではなく、ポインターという値になる。

~~~cpp
// オブジェクト
int object { } ;

// オブジェクトのポインター値で初期化
int * p1 = &object

// p1のポインター値で代入
// つまりobjectを参照する
int * p2 = p1 ;
~~~

このように比較すると、ポインターはリファレンスと同じ機能を提供していることがわかる。実際、リファレンスというのはポインターのシンタックスシュガーにすぎない。ポインターの機能を制限して、文法をわかりやすくしたものだ。

### リファレンスと違う機能

リファレンスがポインターの機能制限版だというのであれば、ポインターにあってリファレンスにはない機能はなんだろうか。代入と、何も参照しない状態だ。

### 代入

リファレンスは代入ができないが、ポインターは代入ができる。

~~~c++
int x { } ;
int y { } ;

int & reference = x ;
// xにyの値を代入
// リファレンスの参照先は変わらない
reference = y ;

int * pointer = &x ;
// pointerの参照先をyに変更
pointer = &y ;
~~~

### 何も参照しない状態

リファレンスは必ず初期化しなければならない。

~~~c++
// エラー、初期化されていない
int & reference ; 
~~~

そのため、リファレンスは常にオブジェクトを参照している。

ポインターは初期化しなくてもよい。

~~~c++
int * pointer ;
~~~

この場合、具体的に何かを参照していない状態になる。この場合にポインターの値はどうなるかはわからない。初期化のない整数の値がわからないのと同じだ。

~~~c++
// 値はわからない
int data ;
~~~

このわからない値が発生することを、専門用語では「未規定の挙動」という。

わからない値の整数を読むことは推奨できない。書くことはできる。

~~~cpp
int main()
{
    // 値はわからない
    int data ; 

    // 推奨できない
    std::cout << data ;

    // OK
    data = 0 ;
}
~~~

このプログラムは何らかの値を出力するはずだが、具体的にどういう値を出力するのかはわからない。

そしてここからがポインターの恐ろしいところだが、ポインターの場合にもこのわからない値は発生する。わからない値を持ったポインターの参照先への読み書きは、「未定義の挙動」を引き起こす。

~~~cpp
int main()
{
    int * pointer ;

    // 未定義の挙動
    std::cout << *pointer ;

    // 未定義の挙動
    *pointer = 123 ;
}
~~~

なぜ未定義の挙動になるかというと、わからない値のポインターは、たまたまどこかの妥当なオブジェクトを参照してしまっているかもしれないからだ。

未定義の挙動は恐ろしい。未定義の挙動が発生した場合、何が起こっても文句は言えない。なぜならばその挙動は本来存在するはずがないのだから。上のプログラムはコンパイル時にエラーになるかもしれないし、実行時にエラーになるかもしれない。いや、もっとひどいことにはエラーにならないかもしれない。そして人生、宇宙、すべてのものの答えと、あろうことか答えに対する質問まで出力するかもしれない。

### 明示的に何も参照しないポインター: nullptr

ポインターを未初期化にしていると、よくわからない値になってしまう。そのため、何も参照していないことを明示的に示すためのポインターの値、nullポインター値がある。`nullptr`だ。

~~~cpp
int * pointer = nullptr ;
~~~

nullptrはどんな型へのポインターに対しても、何も参照していない値となる。

~~~cpp
// doubleへのポインター
double * p1 = nullptr ;

// std::stringへのポインター
std::string p2 = nullptr ;
~~~

C言語とC++では歴史的な理由で、`nullptr`の他にも`NULL`もnullポインター値

~~~cpp
int * pointer = NULL ;
~~~

C++ではさらに歴史的な理由で、`0`もnullポインター値として扱う。

~~~cpp
int * pointer = 0 ;
~~~

ただし、nullポインター値が実際に0である保証はない。ポインターの値についてはあとで詳しく扱う。

## 文法上のポインター 

ポインターが難しいと言われる理由の一つに、ポインターの文法が難しい問題がある。

### ポインターとconstの関係

型としてのポインターは、ある型Tがあるときに、Tへのポインター型となる。

Tへのポインター型は`T *`と書く。

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

リファレンスやconstも同じだ。

~~~cpp
// int型へのポインター型
using t1 = int * ;
// int型へのリファレンス型
using t2 = int & ;
// どちらも同じconstなint型
using t3 = const int ;
using t4 = int const ;
~~~

`const int`と`int const`は同じ型だ。この場合、constはint型のあとにつけても前につけても同じ意味になる。

すると当然の疑問が生じる。組み合わせるとどうなるのかということだ。

ポインター型へのリファレンス型はできる。

~~~cpp
// int *型へのリファレンス
using type = int * & ;
~~~

リファレンス型へのポインター型はできない。

~~~c++
// エラー、できない
using error = int & * ;
~~~

理由は、リファレンスへのポインターというのは意味がないからだ。ポインターへのリファレンスは意味がある。

リファレンスからポインターの値を得るには、参照先のオブジェクトと同じく`&`を使う。

~~~cpp
int data { } ;
int ref = data ;
// &dataと同じ
int * ptr = &ref ;
~~~

リファレンスは参照先のオブジェクトと全く同じように振る舞うのでリファレンス自体のポインターの値を得ることはできない。

ポインターのリファレンスを得るのは、ポインター以外の値と全く同じだ。

~~~cpp
int * ptr = nullptr ;
// ptrを参照する
int * & ref = ptr ;

int data { } ;
// ptrの値が&dataになる。
ref = &data ;
~~~

constとポインターの組み合わせは難しい。

まず型Tとそのconst版がある。

~~~cpp
using T = int ;
using const_T = const T ;
~~~

そして型Tとそのポインター版がある。

~~~cpp
using T = int ;
using T_pointer = T * ;
~~~

これを組みわせると、以下のようになる。

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

~~~c++
using T = int ;
// どちらもconstなT
using const_T_1 = const T ;
using const_T_2 = T const ;
// Tへのポインター
using T_pointer = T * ;
~~~

Tはここではint型だ。T型はどんな型でもよい。

`const T`と`T const`が同じ型であることを思い出せば、`const_T_1`と`const_T_2`は同じ型であることがわかるだろう。

`T_pointer`はTへのポインターだ。

次を見ていこう。

~~~c++
// どちらもconstなTへのポインター
using const_T_pointer_1 = const T * ;
using const_T_pointer_2 = T const * ;
~~~

これはどちらも同じ型だ。constなTへのポインターとなる。わかりにくければ以下のように書いてもよい。

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

constなintへのポインターなので、このポインターの参照先を変更することはできない。ポインターは変更できる。

~~~c++
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

constなのはintであってポインターではない。`const int *`、もしくは`int const *`は参照先のintがconstなので、参照先を変更することができない。ポインターはconstではないので、ポインターの値は変更できる。

constなT型へのリファレンスでconstではないT型のオブジェクトを参照できるように、constなT型へのポインターからconstではないT型のオブジェクトを参照できる。

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

~~~c++
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

その次はconstなポインターだ。

~~~c++
// Tへのconstなポインター
using T_const_pointer = T * const ;
~~~

これはポインターがconstなのであって、Tはconstではない。したがってポインターを経由して参照先を変更することはできるが、ポインターの値自体は変更できない型だ。

~~~c++
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

最後はconstなTへのconstなポインターだ。

~~~c++
// どちらもconstなTへのconstなポインター
using const_T_const_pointer_1 = const T * const ;
using const_T_const_pointer_2 = T const * const ;
~~~

これはconstなTなので、ポインターを経由して参照先を変更できないし、constなポインターなのでポインターの値も変更できない。

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

ポインター型というのは、「ある型Tへのポインター」という形で表現できる。この型Tにはどんな型でも使うことができる。ところで、ポインターというのは型だ。もしTがポインター型の場合はどうなるのだろう。

例えば、「T型へのポインター型」で、型Tが「U型へのポインター型」の場合、全体としては「U型へのポインター型へのポインター型」になる。これはC++の文法では`U **`となる。

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

xはintだ。pはintへのポインターだ。ここまでは今までどおりだ。

ppは`int **`という型で、「intへのポインターへのポインター」型だ。このポインターの値のためには「intへのポインターのポインター」が必要だ。変数pのポインターは`&p`で得られる。この場合、変数pは「intへのポインター」でなければならない。そうした場合、変数pのポインターは「intへのポインターのポインター」型の値になる。

変数ppは「intへのポインターのポインター」だ。変数ppの参照先の変数pを読み書きするには、`*pp`と書く。これはまだ「intへのポインター」だ。ここからさらに参照先のint型のオブジェクトにアクセスするには、その結果にさらに`*`を書く。結果として`**pp`となる。

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

もちろんconstもつけられる。

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

~~~c++
using f_pointer = f_type * ;
using g_pointer = g_type * ;
~~~

早速試してみよう。

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

~~~c++
// 関数へのポインターを経由した関数呼び出し
ptr(123) ;
~~~

ところで、変数ptrの宣言を、f_pointerというエイリアス宣言を使わずに書くと、以下のようになる。

~~~cpp
// 適当な関数
int f( int ) { return 0 ; }

// 変数ptrの宣言
// int (int)へのポインター
int (*ptr)(int) = &f ;
~~~

なぜこうなるのか。これを完全に理解するためにはC++の宣言子(declarator)という文法の詳細な理解が必要だ。

ここでは詳細を飛ばして重要な部分だけ伝えるが、型名のうちポインターであることを指定する`*`は、名前にかかる。

~~~c++
// この *はnameにかかる
int * name ;
~~~

つまり以下のような意味だ。

~~~c++
int (*name) ;
~~~

型名だけを指定する場合、名前が省略される。

~~~cpp
// 名前が省略されている
using type = int * ;
~~~

つまり以下のような意味だ。


~~~c++
using type = int (*) ;
~~~

そのため、`int * name( int )`と書いた場合、これは「int型の引数を取り、int型へのポインターを戻り値として返す関数」となる。

~~~cpp
int * f( int ){ return nullptr ; }
~~~

そうではなく、「int型の引数をとりint型の戻り値を返す関数へのポインター」を書きたい場合は、

~~~cpp
using type = int (*)(int) ;
~~~

としなければならない。

変数の名前を入れる場所は以下の通り
~~~cpp
using type =
int
( * // ポインター
// ここに変数が省略されている
)(int) ;
~~~

なので、

~~~
int (*ptr)(int) = nullptr ;
~~~

となる。あるいは以下のように書いてもいい。

~~~cpp
using function_type = int (int) ;
using function_pointer_type = function_type * ;

function_pointer_type ptr = nullptr ;
~~~

関数へのポインターは型であり、値でもある。値であるということは、関数は引数として関数へのポインターを受け取ったり、関数へのポインターを返したりできるということだ。

早速書いてみよう。

~~~cpp
int f( int x ) { return x ; }
using f_ptr = int (*) (int ) ;
// 関数へのポインターを引数にとり
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

これは動く。ところでこの関数gへのポインターはどう書けばいいのだろうか。つまり、

~~~
auto ptr = &g ;
~~~

を`auto`を使わずに書くとどうなるのだろうか。

以下のようになる。

~~~c++
int (*(*ptr)(int (*)(int)))(int) = &g ;
~~~

なぜこうなるのか。分解すると以下のようになる。

~~~c++
int (* // 戻り値型前半
    (*ptr) // 変数名
    (// 関数の引数
        int (*)(int) // 引数としての関数へのポインター
    )// 関数の引数

)(int) // 戻り値の型後半

 = &g ; // 初期化子
~~~

これはわかりにくい。戻り値の型を後ろに書く文法を使うと少し読みやすくなる。

~~~c++
auto (*ptr)( int (*)(int) ) -> int (*)(int) = &g ;
~~~

これを分解すると以下のようになる。

~~~c++
auto // プレイスホルダー
(*ptr) // 変数名
( int (*)(int) ) // 引数
-> int (*)(int) // 戻り値の型
= &g ; // 初期化子
~~~

もちろん、これでもまだわかりにくいので、エイリアス宣言を使ったほうがよい。

~~~c++
using func_ptr = int(*)(int) ;

auto (*ptr)(func_ptr) -> func_ptr = &g ;
~~~


### thisポインター
