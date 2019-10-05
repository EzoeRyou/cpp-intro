# C++の実行

プログラミング言語を学ぶには、まず書いたソースコードをプログラムとして実行できるようになることが重要だ。自分が正しく理解しているかどうかを確認するために書いたコードが期待どおりに動くことを確かめてこそ、正しい理解が確認できる。

## C++の実行の仕組み

C++は慣習的に、ソースファイルをコンパイルしてオブジェクトファイルを生成し、オブジェクトファイルをリンクして実行可能ファイルを生成し、実行可能ファイルを直接実行することで実行する言語だ。

ほかの言語では、ソースファイルをそのままパースし、解釈して実行するインタープリター形式の言語が多い。もっとも、いまとなってはソースファイルから中間言語に変換して、VM(Virtual Machine)と呼ばれる中間言語を解釈して実行するソフトウェア上で実行するとか、JIT(Just-In-Time)コンパイルしてネイティブコードを生成して実行するといった実装もあるため、昔のように単純にインタープリター型の言語ということはできなくなっている事情はある。ただし、最終的にJITコンパイルされてネイティブコードが実行される言語でも、コンパイルやコード生成はプログラマーが意識しない形で行われるため、プログラマーはコンパイラーを直接使う必要のない言語も多い。

C++はプログラマーが直接コンパイラーを使い、ソースファイルをプログラムに変換する言語だ。

## 簡単な1つのソースファイルからなるプログラムの実行

ここでは、典型的なC++のソースファイルをどのようにコンパイルし実行するか、一連の流れを学ぶ。

### サンプルコード

以下のC++のソースファイルは標準出力に`hello`と出力するものだ。

~~~cpp
#include <iostream>

int main()
{
    std::cout << "hello" ;
}
~~~

コードの詳細な意味はさておくとして、このサンプルコードを使ってC++の実行までの流れを見ていこう。

まずは端末から作業用の適当な名前のディレクトリーを作る。ここでは`cpp`としておこう。ディレクトリーの作成は`mkdir`コマンドで行える。

~~~
$ mkdir cpp
$ cd cpp
~~~

好きなテキストエディターを使って上のサンプルコードをテキストファイルとして記述する。ファイル名は`hello.cpp`としておこう。

~~~
$ vim hello.cpp
~~~

C++のソースファイルの名前は何でもよいが、慣習で使われている拡張子がいくつかある。本書では`.cpp`を使う。

無事にソースファイルが作成できたかどうか確認してみよう。現在のカレントディレクトリー下のファイルの一覧を表示するには`ls`、ファイルの内容を表示するには`cat`を使う。

~~~
$ ls
hello.cpp
$ cat hello.cpp
#include <iostream>

int main()
{
    std::cout << "hello" ;
}
~~~

### コンパイル

さて、ソースファイルが用意できたならば、いよいよコンパイルだ。

C++のソースファイルから、実行可能ファイルを生成するソフトウェアをC++コンパイラーという。C++コンパイラーとしては、GCC(GNU Compiler Collection)とClang(クラン)がある。使い方はどちらもほぼ同じだ。

GCCを使って先ほどの`hello.cpp`をコンパイルするには以下のようにする。

~~~
$ g++ -o hello hello.cpp
~~~

GCCという名前のC++コンパイラーなのに`g++`なのは、`gcc`はC言語コンパイラーの名前としてすでに使われているからだ。この慣習はClangも引き継いでいて、ClangのC++コンパイラーは`clang++`だ。

サンプルコードを間違いなくタイプしていれば、カレントディレクトリーに`hello`という実行可能ファイルが作成されるはずだ。確認してみよう。

~~~
$ ls
hello hello.cpp
~~~

### 実行

さて、いよいよ実行だ。通常のOSではカレントディレクトリーが`PATH`に含まれていないため、実行するにはカレントディレクトリーからパスを指定する必要がある。

~~~
$ ./hello
hello
~~~

上出来だ。初めてのC++プログラムが実行できた。さっそくC++を学んでいきたいところだが、その前にC++プログラミングに必要なツールの使い方を学ぶ必要がある。

## GCC: C++コンパイラー

GCCはC++のソースファイルからプログラムを生成するC++コンパイラーだ。

GCCの基本的な使い方は以下のとおり。

~~~
g++ その他のオプション -o 出力するファイル名 ソースファイル名
~~~

ソースファイル名は複数指定することができる。

~~~
$ g++ -o abc a.cpp b.cpp c.cpp
~~~

これについては分割コンパイルの章で詳しく解説する。

コンパイラーはメッセージを出力することがある。コンパイルメッセージには、エラーメッセージと警告メッセージとがある。

エラーメッセージというのは、ソースコードに文法上、意味上の誤りがあるため、コンパイルできない場合に生成される。エラーメッセージはエラーの箇所も教えてくれる。ただし、文法エラーは往々にして適切な誤りの箇所を指摘できないこともある。これは、C++の文法としては正しくないテキストファイルから、妥当なC++であればどういう間違いなのかを推測する必要があるためだ。

警告メッセージというのは、ソースコードにコンパイルを妨げる文法上、意味上の誤りは存在しないが、誤りの可能性が疑われる場合に出力される。

### コンパイラーオプション

GCCのコンパイラーオプションをいくつか学んでいこう。

`-std=`はC++の規格を選択するオプションだ。C++17に準拠したいのであれば`-std=c++17`を指定する。読者が本書を読むころには、C++20や、あるいはもっと未来の規格が発行されているかもしれない。常に最新のC++規格を選択するオプションを指定するべきだ。

`-Wall`はコンパイラーの便利な警告メッセージのほとんどすべてを有効にするオプションだ。コンパイラーによる警告メッセージはプログラムの不具合を未然に発見できるので、このオプションは指定すべきだ。

`--pedantic-errors`はC++の規格を厳格に守るオプションだ。規格に違反しているコードがコンパイルエラー扱いになる。

これをまとめると、GCCは以下のように使う。

~~~
g++ -std=c++17 -Wall --pedantic-errors -o 出力ファイル名 入力ファイル名
~~~

ところで、GCCのオプションはとても多い。すべてを知りたい読者は、以下のようにしてGCCのマニュアルを読むとよい。

~~~
$ man gcc
~~~

手元にマニュアルがない場合、GCCのWebサイトにあるオンラインマニュアルも閲覧できる。

+ <https://gcc.gnu.org/>
+ <https://gcc.gnu.org/onlinedocs/>

### ヘッダーファイルの省略


先ほどのソースコードをもう一度見てみよう。冒頭に以下のような行がある。

~~~cpp
#include <iostream>
~~~

これは`#includeディレクティブ`(#include directive)といい、プリプロセッサー(preprocessor)の一部だ。プリプロセッサーについて詳しくは煩雑になるので巻末資料を参照してもらうとして、このコードは`iostream`ライブラリを使うために必要で、その意味としてはヘッダーファイル`iostream`の取り込みだ。

C++の標準ライブラリを使うには、ライブラリごとに対応した`#includeディレクティブ`を書かなければならない。それはあまりにも煩雑なので、本書では標準ライブラリのヘッダーファイルをすべて`#include`した`ヘッダーファイル`(header file)を作成し、それを`#include`することで、`#include`を書かなくて済むようにする。

そのためにはまず標準ライブラリのヘッダーファイルのほとんどすべてを`#include`したヘッダーファイル、`all.h`を作成する。

~~~cpp
#include <cstddef>
#include <limits>
#include <climits>
#include <cfloat>
#include <cstdint>
#include <cstdlib>
#include <new>
#include <typeinfo>
#include <exception>
#include <initializer_list>
#include <cstdalign>
#include <stdexcept>
#include <cassert>
#include <cerrno>
#include <system_error>
#include <string>

#if __has_include(<string_view>)
#   include <string_view>
#endif

#include <array>
#include <deque>
#include <forward_list>
#include <list>
#include <vector>
#include <map>
#include <set>
#include <unordered_map>
#include <unordered_set>
#include <queue>
#include <stack>
#include <iterator>
#include <algorithm>
#include <cfenv>
#include <random>
#include <numeric>
#include <cmath>
#include <iosfwd>
#include <iostream>
#include <ios>
#include <streambuf>
#include <istream>
#include <ostream>
#include <iomanip>
#include <sstream>
#include <fstream>

#if __has_include(<filesystem>)
#   include <filesystem>
#endif

#include <cstdio>
#include <cinttypes>


#include <regex>
#include <atomic>
#include <thread>
#include <mutex>
#include <shared_mutex>
#include <condition_variable>
#include <future>

using namespace std::literals ;
~~~

このようなヘッダーファイル`all.h`を作成したあとに、ソースファイルで以下のように書けば、ほかのヘッダーファイルを`#include`する必要がなくなる。

~~~cpp
#include "all.h"

// その他のコード
~~~

`//`から行末まではコメントで、好きなテキストを書くことができる。

しかし、この最初の1行の`#include`も面倒だ。そこでGCCのオプション`-include`を使い、`all.h`を常に`#include`した扱いにする。

~~~
$ g++ -include all.h -o program main.cpp
~~~

このようにすると、`main.cpp`が以下のコードでもコンパイルできるようになる。

~~~cpp
// main.cpp
// 面倒な#includeなどなし

int main()
{
    std::cout << "hello" ;
}
~~~

これでヘッダーファイルが省略できるようになった。

### コンパイル済みヘッダー(precompiled header)

C++はソースファイルをコンパイルする必要がある言語だ。コンパイルには時間がかかる。コンパイルにどれだけ時間がかかっているかを計測するには、以下のようにするとよい。

~~~
$ time g++ -std=c++17 -Wall --pedantic-errors -include all.h -o program main.cpp
~~~

どうだろうか。読者の環境にもよるが、知覚できるぐらいの時間がかかっているのではないだろうか。プログラミングの習得にはコードを書いてから実行までの時間が短い方がよい。そこで本格的にC++を学ぶ前に、コンパイル時間を短縮する方法を学ぶ。

プログラムで変更しないファイルを事前にコンパイルしておくと、変更した部分だけコンパイルすればよいので、コンパイル時間の短縮になる。GCCでは、ヘッダーファイルを事前にコンパイルする特別な機能がある。標準ライブラリのヘッダーファイルは変更しないので、事前にコンパイルしておけばコンパイル時間の短縮になる。

事前にコンパイルしたヘッダーファイルのことをコンパイル済みヘッダー(precompiled header)という。

すでに作成した`all.h`はコンパイル済みヘッダーとするのに適切なヘッダーファイルだ。

コンパイル済みヘッダーファイルを作成するには、ヘッダーファイル単体をGCCに与え、出力するファイルを`ヘッダーファイル名.gch`とする。ヘッダーファイル名が`all.h`の場合、`all.h.gch`となる。

GCCのオプションにはほかのソースファイルをコンパイルするときと同じオプションを与えるほか、ヘッダーファイルがC++で書かれていることを示すオプション`-x c++-header`を与える。

~~~
$ g++ -std=c++17 -Wall --pedantic-errors -x c++-header -o all.h.gch all.h
~~~

こうすると、コンパイル済みヘッダーファイル`all.h.gch`が生成できる。

GCCはヘッダーファイルを使うときに、同名の`.gch`ファイルが存在する場合は、そちらをコンパイル済みヘッダーファイルとして使うことで、ヘッダーファイルの処理を省略する。

~~~
$ g++ -std=c++17 -Wall --pedantic-errors -include all.h -o program main.cpp
~~~

コンパイル済みヘッダーは1回のコンパイルにつき1つしか使うことができない。そのため、コンパイル済みヘッダーとするヘッダーファイルを定め、そのヘッダーファイル内にほかのヘッダーをすべて記述する。本書ではコンパイル済みヘッダーファイルとする元のヘッダーファイルの名前を`all.h`とする。

さっそくコンパイル時間の短縮効果を確かめてみよう。

~~~
$ ls
all.h main.cpp
$ g++ -std=c++17 -Wall --pedantic-errors -x c++-header -o all.h.gch all.h
$ ls
all.h all.h.gch main.cpp
$ time g++ -std=c++17 -Wall --pedantic-errors -include all.h -o program main.cpp
~~~

## Make: ビルドシステム

### コンパイルと実行のまとめ

ここまで、我々はソースファイルをコンパイルして実行可能ファイルを生成し、プログラムを実行する方法について学んできた。これまでに学んできたことを一連のコマンドで振り返ってみよう。

~~~
$ ls
all.h main.cpp
$ cat all.h
#include <iostream>
$ cat main.cpp
int main() { std::cout << "hello"s ; }
~~~

まず、カレントディレクトリーには`all.h`と`main.cpp`がある。この2つのファイルは実行可能ファイルを生成するために必要なファイルだ。今回、その中身は最小限にしてある。本当の`all.h`は、実際には前回書いたように長い内容になる。

~~~
$ g++ -std=c++17 -Wall --pedantic-errors -x c++-header -o all.h.gch all.h
$ ls
all.h all.h.gch main.cpp
~~~

次に、ソースファイルのコンパイルを高速化するために、ヘッダーファイル`all.h`から、コンパイル済みヘッダーファイル`all.h.gch`を生成する。

~~~
$ g++ -std=c++17 -Wall --pedantic-errors -include all.h -o program main.cpp
$ ls
all.h all.h.gch main.cpp program
~~~

プリコンパイル済みヘッダーファイル`all.h.gch`とC++ソースファイル`main.cpp`から、実行可能ファイル`program`を生成する。

~~~
$ ./program
hello
~~~

実行可能ファイル`program`を実行する。

これで読者はC++のプログラミングを学び始めるにあたって必要なことはすべて学んだ。さっそくC++を学んでいきたいところだが、その前にもう1つ、ビルドシステムを学ぶ必要がある。

### 依存関係を解決するビルドシステム

以上のC++のソースファイルからプログラムを実行するまでの流れは、C++のプログラムとしてはとても単純なものだが、それでも依存関係が複雑だ。

プログラムの実行にあたって最終的に必要なのはファイル`program`だが、このファイルはGCCで生成しなければならない。ところでGCCでファイル`program`を生成するには、事前に`all.h`, `all.h.gch`, `main.cpp`が必要だ。`all.h.gch`は`all.h`からGCCで生成しなければならない。

一度コンパイルしたプログラムのソースファイルを書き換えて再びコンパイルする場合はどうすればいいだろう。`main.cpp`だけを書き換えた場合、`all.h`は何も変更されていないので、コンパイル済みヘッダーファイル`all.h.gch`の再生成は必要ない。`all.h`だけを書き換えた場合は、`all.h.gch`を生成するだけでなく、`program`も再生成しなければならない。

プログラムのコンパイルには、このような複雑な依存関係の解決が必要になる。依存関係の解決を人間の手で行うのはたいへんだ。例えば読者が他人によって書かれた何千ものソースファイルと、プログラムをコンパイルする手順書だけを渡されたとしよう。手順書に従ってコンパイルをしたとして、ソースファイルの一部だけを変更した場合、いったいどの手順は省略できるのか、手順書から導き出すのは難しい。するとコンパイルを最初からやり直すべきだろうか。しかし、1つのソースファイルのコンパイルに1秒かかるとして、何千ものソースファイルがある場合、何千秒もかかってしまう。たった1つのソースファイルを変更しただけですべてをコンパイルし直すのは時間と計算資源の無駄だ。

この依存関係の問題は、ビルドシステムによって解決できる。本書ではGNU Makeというビルドシステムを学ぶ。読者がこれから学ぶビルドシステムによって、以下のような簡単なコマンドだけで、他人の書いた何千ものソースファイルからなるプログラムがコンパイル可能になる。

何千ものソースファイルから実行可能ファイルを生成したい。

~~~
$ make
~~~

これだけだ。`make`というコマンド1つでプログラムのコンパイルは自動的に行われる。

何千ものソースファイルのうち、1つのソースファイルだけを変更し、必要な部分だけを効率よく再コンパイルしたい。

~~~
$ make
~~~

これだけだ。`make`というコマンド1つでプログラムの再コンパイルは自動的に行われる。

ところで、生成される実行可能ファイルの名前はプログラムごとにさまざまだ。プログラムの開発中は、共通の方法でプログラムを実行したい。

~~~
$ make run
~~~

これでどんなプログラム名でも共通の方法で実行できる。

ソースファイルから生成されたプログラムなどのファイルをすべて削除したい。

~~~
$ make clean
~~~

これで生成されたファイルをすべて削除できる。

テキストエディターにはVimを使っているがわざわざVimからターミナルに戻るのが面倒だ。

~~~
:make
~~~

VimはノーマルモードからMakeを呼び出すことができる。もちろん、`:make run`や`:make clean`もできる。

### 依存関係を記述するルール

依存関係はどのように表現したらいいのだろうか。GNU Makeでは`Makefile`という名前のファイルの中に、`ターゲット`(targets)、`事前要件`(prerequisites)、`レシピ`(recipes)という3つの概念で依存関係を`ルール`(rules)として記述する。`ルール`は以下の文法だ。

~~~
ターゲット : 事前要件
[TAB文字]レシピ
~~~

レシピは必ず`TAB文字`を直前に書かなければならない。スペース文字ではだめだ。これは`make`の初心者を混乱させる落とし穴の1つとなっている。忘れずに`TAB文字`を打とう。

問題を簡単に理解するために、以下のような状況を考えよう。

~~~
$ ls
source
$ cat source > program
~~~

この例では、ファイル`program`を生成するためにはファイル`source`が必要だ。ファイル`source`はすでに存在している。

`ターゲット`は生成されるファイル名だ。この場合`program`となる。

~~~
program : 事前要件
	レシピ
~~~

`事前要件`は`ターゲット`を生成するために必要なファイル名だ。この場合`source`となる。

~~~
program : source
	レシピ
~~~

`レシピ`は`ターゲット`を生成するために必要な動作だ。この場合、`cat source > program`となる

~~~makefile
program : source
	cat source > program
~~~

さっそくこのルールを、ファイル`Makefile`に書き込み、`make`を呼び出してみよう。

~~~
$ ls
Makefile source 
$ cat Makefile
program : source
	cat source > program
$ make
cat source > program
$ ls
Makefile program source
~~~

これがMakeの仕組みだ。`ターゲット`の生成に必要な`事前要件`と、`ターゲット`を生成する`レシピ`を組み合わせた`ルール`で依存関係を記述する。`make`を実行すると、実行した`レシピ`が表示される。

もう少しMakeの`ルール`を追加してみよう。例えばファイル`source`はあらかじめ存在するのではなく、ファイル`source01`, `source02`, `source03`の中身をこの順番で連結して生成するとしよう。以下のように書ける。

~~~makefile
program : source
	cat source > program

source : source01 source02 source03
	cat source01 source02 source03 > source
~~~

GNU Makeはカレントディレクトリーにあるファイル`Makefile`の一番上に書かれたルールを実行しようとする。`program`を生成するには`source`が必要だが、`source`の生成には別のルールの実行が必要だ。`Makefile`はこの依存関係を自動で解決してくれる。

~~~
$ touch source01 source02 source03
$ ls
Makefile source01 source02 source03
$ make
cat source01 source02 source03 > source
cat source > program
$ ls
Makefile program source source01 source02 source03
~~~

すでに`make`を実行したあとで、もう一度`make`を実行するとどうなるだろうか。

~~~
$ make
make: 'program' is up to date.
~~~

このメッセージの意味は「`program`は最新だ」という意味だ。`make`はファイルのタイムスタンプを調べ、もしファイル`program`より`source`のタイムスタンプの方が若い場合、つまり`program`が変更されたよりもあとに`source`が変更された場合、`ルール`を実行する。

試しにファイル`source02`のタイムスタンプを更新してみよう。

~~~
$ touch source02
$ make
cat source01 source02 source03 > source
cat source > program
~~~

ファイル`source`は`事前要件`に`source02`を含む。`source02`のタイムスタンプが`source`より若いので、`source`が再び生成される。すると、`source`のタイムスタンプが`program`のタイムスタンプよりも若くなったので、`program`も生成される。

もう1つ例を見てみよう。

~~~
$ touch a b c
$ ls
a b c Makefile
~~~

あるディレクトリーにファイル`a`, `b`, `c`がある。

`Makefile`は以下の内容になっている。

~~~makefile
D : A B C
	cat A B C > D

A : a
	cat a > A

B : b
	cat b > B

C : c
	cat c > C
~~~

この`Makefile`を呼び出したときに作られるのはファイル`D`だ。ファイル`D`を作るにはファイル`A`, `B`, `C`が必要だ。このファイルはそれぞれファイル`a`, `b`, `c`から生成されるルールが記述してある。

これを`make`すると以下のようにファイル`A`, `B`, `C`, `D`が作られる。

~~~
$ ls
a b c Makefile
$ make
cat a > A
cat b > B
cat c > C
cat A B C > D
~~~

ここで、ファイル`b`のタイムスタンプだけを更新して`make`してみよう。

~~~
$ touch b
$ make
cat b > B
cat A B C > D
~~~

ファイル`b`のタイムスタンプがファイル`B`より若くなったので、ファイル`B`がターゲットとなったルールが再び実行される。ファイル`A`, `C`のルールは実行されない。そしてファイル`B`のタイムスタンプがファイル`D`より若くなったので、ファイル`D`がターゲットとなったルールが再び実行される。

`make`により、処理する必要のあるルールだけが部分的に処理されていることがわかる。

`make`は適切な`ルール`さえ書けば、依存関係の解決を自動的に行ってくれる。

### コメント

`Makefile`にはコメントを書くことができる。`#`で始まる行はコメント扱いされる。

~~~makefile
# programを生成するルール
program : source
	cat source > program

# sourceを生成するルール
source : source01 source02 source03
	cat source01 source02 source03 > source
~~~

### 変数

`Makefile`には`変数`を書くことができる。

変数の文法は以下のとおり。

~~~
variable = foobar

target : $(variable)
~~~

これは、

~~~
target : foobar
~~~

と書いたものと同じように扱われる。

変数は`=`の左側に変数名、右側に変数の内容を書く。

変数を使うときは、`$(変数名)`のように、`$()`で変数名を包む。


### 自動変数

GNU Makeは便利なことに、いくつかの変数を自動で作ってくれる。

#### `$@` ターゲット

`$@`はルールのターゲットのファイル名になる。


~~~makefile
target :
	echo $@
~~~

この`Makefile`を実行すると以下のように出力される。

~~~
$ make
echo target
~~~

#### `$<` 最初の事前要件

`$<`はルールの最初の事前要件のファイル名になる。

~~~makefile
target : A B C
	echo $<
~~~

この`Makefile`を実行すると以下のように出力される。

~~~
$ make
echo A
~~~

#### `$^` すべての事前要件

`$^`はすべての事前要件のファイル名が空白区切りされたものになる

~~~makefile
target : A B C
	echo $^
~~~

この`Makefile`を実行すると以下のように出力される。

~~~
$ make
echo A B C
~~~

#### 自動変数の組み合わせ

例えば`ターゲット`を生成するために`事前要件`と`ターゲット`のファイル名をレシピに書く場合、

~~~makefile
target : prerequisite
	cat prerequisite > target
~~~

と書く代わりに、

~~~makefile
target : prerequisite
    cat $< > $@
~~~

と書ける。

### PHONYターゲット

PHONYターゲットとは、ファイル名を意味せず、単にレシピを実行するターゲット名としてのみ機能するターゲットのことだ。

~~~makefile
hi :
	echo hi

hello :
	echo hello
~~~

これを実行すると以下のようになる。

~~~
$ make
echo hi
hi
$ make hi
echo hi
hi
$ make hello
echo hello
hello
~~~

`make`を引数を付けずに実行すると、一番上に書かれたルールが実行される。引数としてターゲットを指定すると、そのターゲットのルールと、依存するルールが実行される。

ただし、ターゲットと同じファイル名が存在すると、ルールは実行されない。

~~~
$ touch hello
$ make hello
make: 'hello' is up to date.
~~~

GNU Makeはこの問題に対処するため、`.PHONY`ターゲットという特殊な機能がある。これはPHONYターゲットを`.PHONY`ターゲットの事前要件とすることで、ターゲットと同じファイル名の存在の有無にかかわらずルールを実行させられる。

~~~makefile
hello :
	echo hello

.PHONY : hello
~~~

PHONYターゲットはコンパイルしたプログラムの実行や削除に使うことができる。

~~~makefile
hello : hello.cpp
	g++ -o $@ $<

run : hello
	./hello

clean :
	rm -rf ./hello

.PHONY : run clean
~~~

## 入門用の環境構築

以上を踏まえて、C++入門用の環境構築をしてこの章のまとめとする。

今回構築する環境のファイル名とその意味は以下のとおり。

`main.cpp`
:   C++のコードを書く
`all.h`
:   標準ライブラリのヘッダーファイルを書く
`all.h.gch`
:   コンパイル済みヘッダー
`program`
:   実行可能ファイル
`Makefile`
:   GNU Makeのルールを書く

使い方は以下のとおり。

`make`
:   コンパイルする
`make run`
:   コンパイルして実行
`make clean`
:   コンパイル結果を削除


GCCに与えるコンパイラーオプションを変数にまとめる。

~~~makefile
gcc_options = -std=c++17 -Wall --pedantic-error
~~~

言語はC++17、すべての警告を有効にし、規格準拠ではないコードはエラーとする。

プログラムをコンパイルする部分は以下のとおり。

~~~makefile
program : main.cpp all.h all.h.gch
	g++ $(gcc_options) -include all.h $< -o $@

all.h.gch : all.h
	g++ $(gcc_options) -x c++-header -o $@ $<
~~~

実行可能ファイル`program`と、コンパイル済みヘッダー`all.h.gch`をコンパイルするルールだ。

PHONYターゲットは以下のとおり。

~~~makefile
run : program
	./program

clean :
	rm -f ./program
	rm -f ./all.h.gch

.PHONY : run clean
~~~

`make`でコンパイル。`make run`で実行。`make clean`でコンパイル結果の削除。

`Makefile`全体は以下のようになる。

~~~makefile
gcc_options = -std=c++17 -Wall --pedantic-errors

program : main.cpp all.h all.h.gch
	g++ $(gcc_options) -include all.h $< -o $@

all.h.gch : all.h
	g++ $(gcc_options) -x c++-header -o $@ $<

run : program
	./program

clean :
	rm -f ./program
	rm -f ./all.h.gch

.PHONY : run clean
~~~
