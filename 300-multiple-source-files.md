# 分割コンパイル

これまで、プログラムは1つのソースファイルから作っていた。プログラムは複数のソースファイルから作ることもできる。ソースファイルを複数に分割することで、ソースファイルの管理がしやすくなったり、プログラムのビルド時間の短縮にもつながる。


### ソースファイルとコンパイル

ソースファイルを分割すると、C++の書き方にも注意が必要になる。だがその前に、複数のソースファイルをコンパイルして1つのプログラムにする方法を学ぶ。

### 単一のソースファイルのコンパイル

C++のソースファイルをコンパイルして実行可能ファイルを作る方法をいま一度おさらいをしよう。

`source.cpp`という名前のソースファイルがあるとき、ここから`program`という名前の実行可能ファイルを作るには、

~~~
$ g++ -o program source.cpp
~~~

としていた。毎回このコマンドを入力するのは面倒なので、`Makefile`を以下のように書いていた。

~~~makefile
program: source.cpp
	g++ $< -o $@
~~~

### ヘッダーファイルはコピペ

すでに、ソースファイルのほかにヘッダーファイルというファイルも使っている。ヘッダーファイルはソースファイルではない。コンパイル前にソースファイルにコピペされるだけのものだ。

例えば以下のような内容の`header.h`というヘッダーファイルがあるとして、

~~~cpp
// header.h
++i ;
~~~

`source.cpp`が以下のようであるとき、

~~~cpp
int main()
{
    int i = 0 ;
#include "header.h"
#include "header.h"
#include "header.h"
    int result = i ;
}
~~~

`source.cpp`をコンパイルすると、まずヘッダーファイルが以下のように展開される。

~~~cpp
int main()
{
    int i = 0 ;
// header.h
++i ;
// header.h
++i ;
// header.h
++i ;
    int result = i ;
}
~~~

ヘッダーファイルとはこれだけのものだ。コンパイラーが`#include`された場所に、ヘッダーファイルの中身を愚直にコピペするだけだ。

### 複数のソースファイルのコンパイル

2つのソースファイル、`foo.cpp`と`bar.cpp`からなるプログラムをコンパイルするには、

~~~
$ g++ -o program foo.cpp bar.cpp
~~~

とする。

## オブジェクトファイル

単にソースファイルを分割したいだけならば、GCCに分割したソースファイルをすべて指定すればよい。しかしその場合、複数あるソースファイルの1つだけを編集した場合でも、すべてのソースファイルをコンパイルしなければならない。

C++では伝統的に、ソースファイルを部分的にコンパイルしてオブジェクトファイルを生成し、オブジェクトファイルをリンクしてプログラムを生成する方法がある。

ソースファイルをオブジェクトファイルにコンパイルするのは`コンパイラー`、オブジェクトファイルをプログラムにリンクするのは`リンカー`の仕事だ。

~~~
TODO: 図示
ソースファイル→(コンパイラー)→オブジェクトファイル→(リンカー)→プログラム
~~~
fig/fig300-01.png

GCCではC++コンパイラーの名前は`g++`で、リンカーの名前は`ld`だ。ただし、C++のオブジェクトファイルをリンクするのにリンカーを直接使うことはない。`g++`は`ld`を適切に呼び出してくれるからだ。

ソースファイル`source.cpp`をコンパイルしてオブジェクトファイルを生成するには、`-c`オプションを使う。

~~~
$ g++ -c source.cpp
~~~

生成されるオブジェクトファイルの名前はソースファイルの名前の拡張子を`.o`に置き換えたものになる。上のコマンドを実行した結果、オブジェクトファイル`source.o`が生成される。


生成したオブジェクトファイルは、`g++`の入力として使うことで、リンクしてプログラムにすることができる。`g++`は裏でリンカー`ld`を適切に呼び出してくれる。

~~~
$ g++ -o program source.o
~~~


オブジェクトファイル名を別の名前にしたい場合は、`-o object-file-name`オプションを使う。

~~~
$ g++ -o object.o -c source.cpp
~~~

複数のソースファイル、`foo.cpp`と`bar.cpp`からオブジェクトファイルを生成し、リンクして実行可能ファイル`program`を生成するには以下のようにする。

~~~
$ ls
bar.cpp  foo.cpp
$ g++ -c foo.cpp
$ g++ -c bar.cpp
$ ls
bar.cpp  bar.o  foo.cpp  foo.o
$ g++ -o program foo.o bar.o
$ ls
bar.cpp  bar.o  foo.cpp  foo.o  program
~~~

こうすることによって、1つのソースファイルを編集しただけで、すべてのソースファイルをコンパイルする必要がなくなる。

これを`Makefile`で書くには、出力するファイルと依存するファイルを考える。

+ `program`は`foo.o`と`bar.o`に依存する
+ `foo.o`は`foo.cpp`に依存する
+ `bar.o`は`bar.cpp`に依存する

これを素直に書き出していけばよい。

~~~
# programはfoo.oとbar.oに依存する
program : foo.o bar.o
	g++ -o $@ $^
# foo.oはfoo.cppに依存する
foo.o : foo.cpp
	g++ -c $<
# bar.oはbar.cppに依存する
bar.o : bar.cpp
	g++ -c $<
~~~

`$^`はそのルールの依存するファイル名をすべて空白区切りで得る自動変数だ。この場合、`foo.o bar.o`に置換される。

## 複数のソースファイルの書き方

C++の1つのソースファイルは、1つの`翻訳単位`(translation unit)として扱われる。別の翻訳単位の定義を使うには、さまざまな制約がある。具体的な例で学ぼう。

### 関数

以下のコードを見てみよう。

~~~cpp
#include <iostream>

void print_int( int x )
{
    std::cout << x ;    
}

int main()
{
    print_int( 123 ) ;
}
~~~

このコードには2つの定義がある。`print_int`と`main`だ。

関数`print_int`を別のソースファイルである`print_int.cpp`に分割してみよう。

~~~cpp
// print_int.cpp
#include <iostream>

void print_int( int x )
{
    std::cout << x ;    
}
~~~

このコードは問題なくコンパイルできる。

~~~
$ g++ -c print_int.cpp
~~~

すると残りのソースファイルを`main.cpp`とすると以下のようになる。

~~~cpp
// main.cpp
int main()
{
    print_int( 123 ) ;
}
~~~

このコードはコンパイルできない。なぜならば、C++では名前は使う前に宣言しなければならないからだ。

関数を宣言するには、関数の本体以外の部分を書き、セミコロンで終端する。

~~~cpp
// main.cpp
void print_int( int ) ;

int main()
{
    print_int( 123 ) ;
}
~~~

これでコンパイル、リンクができるようになった。

~~~
$ g++ -c main.cpp
$ g++ -o program main.o print_int.o
~~~

このとき、`main.cpp`で関数`print_int`を定義することはできない。

~~~cpp
// エラー、print_int.cppでも定義されている
void print_int( int ) { }

int main()
{
    print_int( 123 ) ;
}
~~~

C++では定義は全翻訳単位に1つしか書くことができないルール、ODR(One Definition Rule、単一定義原則)があるからだ。

~~~cpp
// 宣言
void f() ;

// OK、再宣言
void f() ;

// 定義
void f() { }

// エラー、再定義
// ODR違反
void f() { }
~~~

なぜODRがあるのか。なぜ定義は1つしか書けないのか。理由は簡単だ。もし定義が複数書けるならば、異なる定義を書くことができてしまうからだ。

~~~cpp
bool f() { return true ; }
bool f() { return false ; }
~~~

もし定義を複数書くことができる場合、この関数`f`は`true`を返すべきだろうか。それとも`false`を返すべきだろうか。

この問題を防ぐために、C++にはODRがある。

複数のソースファイル、つまり複数の翻訳単位からなるプログラムの場合でもODRは適用される。定義はすべての翻訳単位内で1つでなければならない。

引数リストが違う関数は別の関数で、別の定義になる。

~~~cpp
// 定義
void f() { }

// OK、別の定義
void f( int ) { }

// OK、別の定義
void f( double ) { }
~~~

名前は使う前に宣言が必要だが、肝心の定義は別のソースファイルに書いてある。宣言と定義を間違えてしまった場合はエラーになる。

~~~cpp
// print_int.cpp
// 失敗状態を返す
bool print_int( int x )
{
    std::cout << x ;
    return std::cout.fail() ;
}

// main.cpp
void print_int( int ) ;

int main()
{
    // エラー
    print_int( 123 ) ;
}
~~~

このような間違いを防ぐためのお作法として、宣言はヘッダーファイルに書いて`#include`する。

~~~cpp
// print_int.h
bool print_int( int x ) ;

// main.cpp
#include "print_int.h"

int main()
{
    // 間違えない
    bool result = print_int( 123 ) ;
}
~~~

### 変数

変数にも宣言と定義がある。通常、変数の宣言は定義を兼ねる。

~~~c++
// 宣言かつ定義
int variable ;
~~~

そのため、別の翻訳単位の変数を使うために変数を書くと、定義が重複してしまい、ODR違反になる。

~~~cpp
// global.cpp
int variable ;

// main.cpp
// エラー、ODR違反
int variable ;

int main()
{
    variable = 0 ;
}
~~~

変数を定義せずに宣言だけしたい場合は、`extern`キーワードを使う。

~~~cpp
// global.cpp
int variable ;

// main.cpp
// OK
// 別の翻訳単位の定義を参照する
extern int variable ;

int main()
{
    variable = 123 ;
}
~~~

`extern`キーワードを名前空間スコープで宣言された変数に使うと、定義せずに別の翻訳単位の定義を参照する意味になる。


変数の場合も、間違いを防ぐためにヘッダーファイルに書いて`#include`するとよい。

~~~cpp
// global.h
extern int variable ;

// main.cpp
#include "global.h"

int main()
{
    variable = 123 ;
}
~~~

### インライン関数/インライン変数

変数や関数の定義はODRにより重複できない。ということはヘッダーファイルに書いて複数の翻訳単位で`#include`できないということだ。

~~~cpp
// library.h
std::string delimiter{"\n"} ;

void print_int( int x )
{ std::cout << x << delimiter ; }

// foo.cpp
// エラー、ODR違反
#include "library.h"

// bar.cpp
// エラー、ODR違反
#include "library.h"
~~~

`library.h`には宣言だけを書いて、別途翻訳単位となるソースファイル、例えば`library.cpp`を用意しなければならない。

~~~cpp
// library.h
void print_int( int x ) ;

// library.cpp
std::string delimiter{"\n"} ;

void print_int( int x )
{ std::cout << x << delimiter ; }
~~~


小さなライブラリの場合、この制約は煩わしい。できればヘッダーファイルだけで済ませてしまいたい。このためにC++には特別なODRを例外的に回避する方法がある。

キーワード`inline`を付けて定義した関数と変数は、インライン関数、インライン変数となる。

~~~cpp
// library.h
// インライン変数
inline std::string delimiter{"\n"} ;
// インライン関数
inline void print_int( int x )
{ std::cout << x << delimiter ; }
~~~

インライン関数とインライン変数は、複数の翻訳単位で重複して定義できる。

~~~cpp
// foo.cpp
#include "library.h"

// bar.cpp
#include "library.h"
~~~

`inline`はODRを例外的に回避できるとはいえ、強い制約がある。

1. 異なる翻訳単位に限る

同じ翻訳単位の中で重複することはできない。

~~~cpp
// 1つの翻訳単位
inline int variable ;
// エラー、再定義
inline int variable ;
~~~

2. 同じトークン列である

インライン関数、インライン変数の定義のトークン列、つまりソースコードの文字列は完全に同じでなければならない。

たとえば以下はトークン列が違う。

~~~cpp
inline int f( int x ) { return x ; }
inline int f( int y ) { return y ; }
~~~

インライン関数と変数のトークン列を同じにするには、ヘッダーファイルに書いて`#include`で取り込むことを徹底する。

3. 意味が同じである

同じトークン列でも意味が異なることがある。

~~~cpp
// foo.cpp
void f( int ) {  }
inline bool g( )
{
    return f( 0 ) ;
}

// bar.cpp
void f( double ) {  }
inline bool g()
{
    return f( 0 ) ;
}
~~~

`foo.cpp`のインライン関数`g`は`f(int)`を呼び出すが、`bar.cpp`のインライン関数`g`は`f(double)`を呼び出す。インライン関数`g`のトークン列はどちらも同じだが、意味が異なる。

ODRの例外的な回避の怖いところは、間違えてしまってもコンパイラーがエラーメッセージを出してくれる保証がないところだ。上の同じトークン列で違う意味のような関数は、そのままコンパイルが通ってリンクされ、実行可能なプログラムが生成されてしまうかもしれない。そのようなプログラムの挙動がどうなるかはわからない。この理由は、ODR違反を完全に発見するコンパイラーの実装が技術的に困難だからだ。ODR違反をしないのはユーザーの責任だ。

インライン変数とインライン関数はわざわざ翻訳単位を分けて分割コンパイルするまでもないライブラリに使うとよい。

### クラス

クラスにも宣言と定義がある。

~~~c++
// 宣言
struct Foo ;

// 定義
struct Foo
{
    int data_member ;
    int member_function() ;
} ;
~~~

クラスを複数の翻訳単位で使うには、関数と同じように宣言と定義に分ければよいと考えるかもしれないが、残念ながらクラスの宣言だけでできることは少ない。

クラスの宣言だけでできることは、クラス名を型名として使うとか、クラスのポインター型を作るぐらいのものだ。

~~~cpp
struct Foo ;
using Bar = Foo ;
Foo * ptr = nullptr ;
~~~

宣言だけされたクラスのオブジェクトを作ることはできないし、ポインターの演算もできない。

~~~cpp
struct Foo ;

int main()
{
    // エラー
    Foo foo ;

    Foo * ptr = nullptr ;
    // エラー
    ++ptr ;
}
~~~

この理由は、宣言だけされたクラスは`不完全型`(Incomplete type)という特別な扱いの型になるからだ。クラスのオブジェクトを作ったりポインター演算をするには、クラスのオブジェクトのサイズを決定する必要があるが、そのための情報はまだコンパイラーが得ていないために起こる制約だ。

クラスの定義では、インライン変数やインライン関数と同じく、ODRの例外的な回避が認められている。条件も同じで、1. 異なる翻訳単位で、2. 同じトークン列で、3. 意味も同じ場合だ。

ODR違反を起こさないために、クラス定義はインクルードファイルに書いて`#include`するのがお作法だ。

~~~cpp
// Foo.h
// クラス定義
struct Foo
{
    int data_member ;
    // メンバー関数の宣言
    int member_function() const noexcept;
} ;

// Foo.cpp
#include "Foo.h"
// メンバー関数の定義
int Foo::member_function() const noexcept
{
    return data_member ;
} 

// main.cpp
#include "Foo.h"

int main()
{
    Foo foo ;
    foo.data_member = 42 ;
    int value = foo.member_function() ;
}
~~~

クラス定義の中で定義されたメンバー関数は、自動的にインライン関数になる。

~~~cpp
// Foo.h
struct Foo
{
    int data_member ;
    // インライン関数
    int member_function() const noexcept
    {
        return data_member ;
    }
} ;
~~~

このように書くと、ヘッダーファイル`Foo.h`を`#include`するだけでどこでもクラス`Foo`が使えるようになる。メンバー関数を定義するための`Foo.cpp`は必要がなくなる。

クラスのデータメンバーは具体的なオブジェクトではないので、インライン変数ではない。

~~~cpp
struct S
{
    // これはオブジェクトではない
    int data_member ;
} ;

void main()
{
    // オブジェクト
    S s ;
    // サブオブジェクト
    s.data_member ; 
}
~~~

##### staticメンバー
クラスのメンバーは非`static`メンバーと`static`メンバーに分けることができる。`static`メンバーは`static`キーワードを付けて宣言する。


~~~cpp
struct S
{
    // 非staticメンバー
    int data_member ;
    void member_function() ;

    // staticメンバー
    inline static int static_data_member ;
    static void static_member_function() ;
} ;
~~~

`static`メンバー関数はクラスのオブジェクトには依存していない。そのため、クラスのオブジェクトなしで呼び出すことができる。

~~~cpp
struct S
{
    // 非staticメンバー
    void member_function() { }

    // staticメンバー
    static void static_member_function() { }
} ;

int main()
{
    S s ;
    // オブジェクトが必要
    s.member_function() ;

    // オブジェクトは不要
    S::static_member_function() ;
    // このように呼び出すこともできる
    s.static_member_function() ;
}
~~~

`static`メンバー関数の呼び出しにクラスのオブジェクトを必要としない。そのため、`this`も使うことはできない。

~~~cpp
struct S
{
    int data_member() ;

    void f()
    {// thisが使える
        this->data_member ;
    }

    static void g()
    {// thisは使えない
    }
} ;
~~~

`static`データメンバーはクラスのオブジェクトの外の独立したオブジェクトだ。`static`データメンバーのクラス定義内での宣言は定義ではないので、クラスの定義外で定義する必要がある。

~~~cpp
struct S
{
    // 宣言
    static int static_data_member ;
} ;
// 定義
int S::static_data_member ;

int main()
{
    S::static_data_member = 123 ;
}
~~~

複数の翻訳単位からなるプログラムの場合、ODRにより定義は1つしか書けないので、どこか1つのソースファイルだけに定義を書くことになる。

~~~cpp
// S.h
struct S
{
    // 宣言
    static int static_data_member ;
} ;

// S.cpp
#include "S.h"
// 定義
int S::static_data_member ;
~~~

これは面倒なので、通常は`static`変数はインライン変数にする。

~~~cpp
// S.h
struct S
{
    // インライン変数かつstatic変数
    inline static int static_data_member ;
} ;
~~~

これで`static`変数を定義するだけのソースファイルを用意する必要はない。ただしインライン変数はC++17以降の機能なので、読者が昔のC++で書かれたコードを読む際には、まだ昔ながらの`static`データメンバーの定義に出くわすだろうから、覚えておこう。

`static`メンバーはクラススコープの下に関数と変数というだけで、その実態は名前空間スコープ内の関数と変数と同じだ。

~~~cpp
// 名前空間
namespace A {
    int variable ;
    void function() { }
}
// クラス
struct B {
    inline static int variable ;
    static void function() { }
} ;

int main()
{
    // 名前空間
    A::variable = 1 ;
    A::function() ;
    // クラス
    B::variable = 1 ;
    B::function() ;
}
~~~

### テンプレート

テンプレートにもODRの例外が認められている。

テンプレートは具体的なテンプレート引数が与えられて実体化する。

~~~cpp
template < typename T >
struct holder
{
    T value ;
} ;

holder<int> a ;
holder<double> b ;
~~~

このため、翻訳単位ごとに、同じトークン列で同じ意味のテンプレートコードが必要だ。インクルードファイルに書いて`#include`するお作法も同じだ。

~~~cpp
// holder.h
template < typename T >
struct holder
{
    T value ;
} ;

holder<int> a ;
holder<double> b ;
~~~

C++に将来的に追加される予定のモジュールが入るまでは、テンプレートコードはすべてをインクルードファイルに書いて`#include`して使う慣習が続くだろう。
