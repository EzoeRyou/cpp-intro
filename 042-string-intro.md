# 文字列

## はじめに

とうとう文字列を学ぶべきときがやってきた。文字列自体は最初から使ってきた。

~~~cpp
auto s = "hello"s ;
~~~ 

これは文字列の表面的な使い方だけだ。しかも、本書ではこれまで文字列に日本語を使ってこなかった。これには理由がある。たとえば、

~~~cpp
int main()
{
    std::cout << "こんにちは"s ;
}
~~~

のようなコードが動くかどうかは実装依存だからだ。試しにコンパイルして実行してみよう。もし画面に「こんにちは」と表示されたのであれば、どうやら読者の環境はこのコードで日本語を出力、表示できるようだ。

## 基本ソース文字セット

C++では、基本ソース文字セットと呼ばれる文字がある。C++のソースコードで安全に使うことができる文字だ。ラテンアルファベットの大文字小文字、記号、制御文字からなる文字セットで、96文字ある。

空白文字、水平タブ、垂直タブ、フォームフィード、改行の5文字と、印字可能な以下の91文字だ。

~~~c++
a b c d e f g h i j k l m n o p q r s t u v w x y z
A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
0 1 2 3 4 5 6 7 8 9
_ { } [ ] # ( ) < > % : ; . ? * + - / ^ & | ~ ! = , \ " '
~~~


## 基本実行文字セット

基本実行文字セットは基本ソース文字セットにアラート、バックスペース、キャリッジリターン、null文字を加えたものだ。

null文字は整数の`0`に等しいという特別な特徴を持つ文字だ。


## 文字を表現する方法

文字をコンピューターで扱うには、ビット列で文字を表現できなければならない。C++でアドレス可能な最小単位はバイトなので、文字というのはバイト列で表現する。

### ASCII

ASCIIはとても広く普及した文字のエンコード方法だ。ASCIIでは7ビットの整数値で1文字を表現する。

C++の基本実行文字セットは特定の文字エンコードであると規定されてはいないが、ASCIIを参考にしている。ただしASCIIには基本実行文字セットにはない、ダラーサイン($)、アットマーク(@)、バッククオート(\`)といくつかの制御文字がある。

### Unicode

Unicode、もしくはISO/IEC 10646(Universal Coded Character Set, UCS)は文字のコードポイントを定める規格だ。

Unicodeは当初、16bitの符号なし整数値でコードポイントを表現する規格であった。この当時、1コードポイントは1文字であり16bitであった。

そのような当初の目論見はすぐに破綻し、いまでは1コードポイントは21bit弱(U+0000からU+10FFFF)であり、1コードポイントは1文字を意味しないようになった。複数のコードポイントを組み合わせて1文字が表現されることもあるからだ。

Unicodeはコードポイントについて定めた規格であり、バイト列で文字を表現する規格ではない。Unicodeを元にしたバイト列によって文字を表現するエンコード方式に、UTF-8, UTF-16, UTF-32が存在する。

#### UTF-16

UTF-16は16bitの符号なし整数値によってUnicodeのコードポイントを表現するエンコード方式だ。まだUnicodeが16bitのコードポイントですべての文字を表現すると考えていたころに考案されたUCS-2が元になっている。

その後、Unicodeのコードポイントが21bit弱に拡張されたので、UCS-2からUTF-16が考案された。

UTF-16は16bitを1単位とした符号なし整数で21bit弱のコードポイントを表現するために、1単位で表現できないコードポイントを、サロゲートペアと呼ばれる連続した2単位で表現する。

そのため、UTF-16の任意の1単位を切り出すと、それは1つのコードポイントを表現するサロゲートペアの片方である可能性があり、文字として壊れてしまう可能性がある。

#### UTF-32

UTF-32は32bitの符号なし整数値によってUnicodeのコードポイントを表現するエンコード方式だ。UTF-32の1単位は32bit符号なし整数なので、Unicodeの任意の1コードポイントを表現できる。

ただし問題は、Unicodeではもはや1コードポイントは1文字ではないということだ。したがってUTF-32の1単位は1文字ではない。

UTF-32の1単位は1コードポイントだが、UTF-32の任意の1単位を切り出すことはできない。

連続した複数のコードポイントによって表現された1文字が壊れる可能性があるからだ。

#### エンディアンの問題

UTF-16とUTF-32は1単位が複数のバイトからなるエンコード方式だ。複数バイトからなる整数にはエンディアン(Endian)の問題がある。

エンディアンとは複数の連続したバイト列の順序のことだ。

1バイトが8bitの環境で2バイトの符号なし整数を考えよう。C++には16bit符号なし整数型である`std::uint16_t`がある。

~~~c++
std::uint16_t value = 0b00000001'00000010 ;
~~~

2バイトの符号なし整数である`value`の2つの連続したバイトの上位桁を表現するバイトを上位バイト、下位桁を表現するバイトを下位バイトと呼ぶ。上のコードは上位バイトに1、下位バイトに2が表現されている。このバイト列を直接見てみよう。

~~~cpp
// byte表示用の関数
void print( std::byte x )
{
    std::cout << static_cast<unsigned int>(x) ;
} 

int main()
{
    // 上位バイトに1
    // 下位バイトに2
    std::uint16_t value = 0b00000001'00000010 ;

    // 2バイトの配列
    std::byte rep[2] ;

    // バイト列をコピー
    std::memcpy( rep, &value, 2 ) ;

    // 上位バイト
    print( rep[0] ) ;
    // 下位バイト
    print( rep[1] ) ;
}
~~~

筆者の環境では`"21"`と表示される。これはつまり、2つのバイトのうち、下位バイトの方が先に配置されているということだ。

世の中にはリトルエンディアン(Little Endian)とビッグエンディアン(Big Endian)がある。これは複数バイトの順序の違いだ。

リトルエンディアンは下位バイトから配置する。

ビッグエンディアンは上位バイトから配置する。

リトルエンディアン環境では、上のプログラムは`"21"`と表示する。ビッグエンディアン環境では、`"12"`と表示する。

エンディアンの存在により、UTF-16とUTF-32は2つのバイト列表現が存在することになる。

#### UTF-8

UTF-8は最も後発のUnicodeのコードポイントの文字エンコードだ。

UTF-8は8bitを1単位とし、1単位から4単位までの連続した単位列によってUnicodeの1コードポイントを表現する。

UTF-8が1単位だけでコードポイントを表現するとき、下位7bitはASCIIの文字の値に等しい。その点でUTF-8はASCIIと互換性がある。

これにより従来ASCIIを使っていたコードやシステムとの親和性が高く、普及した。

UTF-8は現在最も普及している文字コードだ。

## OS

C++プログラムが実行できるOSとしては以下のようなものがある。

+ GNU/Linux
+ Android
+ FreeBSD
+ DragonflyBSD
+ OpenBSD
+ NetBSD
+ Apple macOS
+ Apple iOS
+ Microsoft Windows

このほかにもOSはさまざまあるが、情報を得るだけでもNDAを結ぶ必要がある表に出てこないOSであったり、実験的すぎたりして、C++を学習する環境としては不適切だ。


このうち、Microsoft Windowsを除くOSはUTF-8を使用している。

Microsoft WindowsはUTF-16を使用している。ただし、この状況はMicrosoft Windowsは最近UTF-8ロケールを実装したので将来的に変わるだろう。




## リテラル

### 通常の文字リテラル

通常の文字リテラルは単一引用符で1つの文字を囲む。

~~~c++
'a'
'b'
'c'
~~~

通常の文字リテラルの型は`char`だ。

~~~c++
char a = 'a' ;
char b = 'b' ;
char c = 'c' ;
~~~

文字リテラルには以下のようなエスケープシーケンスがある。これは一部の印字不可能な文字や、文法上の理由で直接リテラルの中に書くことができない文字を書けるようにするための代替手段だ。


意味                    リテラル
------------------      --------
改行                    `\n`
水平タブ                `\t`
垂直タブ                `\v`
バックスペース          `\b`
キャリッジリターン      `\r`
フォームフィード        `\f`
アラート                `\a`
バックスラッシュ        `\\`
疑問符                  `\?`
単一引用符              `\'`
二重引用符              `\"`


これを使えば、単一引用符の文字リテラルは

~~~c++
char c = '\'' ;
~~~

と書ける。エスケープシーケンスにはバックスラッシュを使うため、文字リテラルのなかでバックスラッシュを使うには、エスケープシーケンスが必要だ。

~~~c++
char c = '\\' ;
~~~


通常の文字がどのような文字エンコードを使っているかは実装定義だ。

そのほかにも文字の数値を直接指定するエスケープシーケンスとして、8進数エスケープシーケンスと16進数エスケープシーケンスがある。

~~~c++
char oct = '\101' ;
char hex = '\x41' ;
~~~

このコードは、8進数で`101`、16進数で`41`になる何らかの文字を表現している。もし通常の文字リテラルがASCIIかUTF-8でエンコードされている場合、この文字は`A`になる。

### ユニバーサルキャラクター名

文字リテラルには特殊なエスケープシーケンスであるユニバーサルキャラクター名(Universal Character name)を使うことができる。

~~~c++
\uNNNN
\UNNNNNNNNN
~~~

文法は`\u`に続いて16進数を4文字書くとこれはUnicodeコードポイントにおける`U+0000NNNN`になる。`\U`に続いて16進数を8文字書くと、これはUnicodeコードポイントにおける`U+NNNNNNNN`になる。





### 通常の文字列リテラル

通常の文字列リテラルは二重引用符で文字列を囲む。

~~~c++
"abc" ;
"hello" ;
"This is a pen." ;
~~~

通常の文字列リテラルの型は`const`な文字型の配列になる。具体的な型としては`const char [n]`になる。`n`は文字列のサイズだ。通常の文字列リテラルの中の文字が基本実行文字だけであれば、書かれている文字数+1になる。しかし、この文字数というのも難しい。

文字列リテラルが連続している場合、1つにまとめられる。

~~~cpp
auto s = "abc" "def" ;
~~~

というコードは、

~~~cpp
auto s = "abcdef" ;
~~~

と書くのと同じだ。

文字列リテラルの中のエスケープシーケンスは対応する文字になる。

~~~cpp
"\n" ;
~~~

という通常の文字列リテラルは、バックスラッシュとラテンアルファベットnではなく、改行文字1文字になる。

通常の文字列リテラルは末尾にnull文字(`\0`)が付与される。このために、配列のサイズは文字数+1になる。



具体的な例では、`"abc"`という通常の文字列リテラルの型は`const char [4]`になる。これは以下のような配列に等しい。

~~~c++
const char s[4] = {'a', 'b', 'c', '\0'} ;
~~~

`"hello"`の型は`const char [6]`になる。

~~~c++
const char s[6] = {'h', 'e', 'l', 'l', 'o', '\0' } ;
~~~

`char`型の配列の初期化に通常の文字列リテラルを使うことができる。

~~~c++
char s[6] = "hello" ;
~~~

配列の添字を書かない場合、文字列リテラルのサイズになる。

~~~c++
// char [6]
char s[] = "hello" ;
~~~

また、文字列リテラルは配列であるので、先頭要素へのポインターに暗黙に型変換される。

~~~c++
const char * p = "hello" ;
~~~

文字列リテラルを`auto`で変数の初期化子に書くと、型はポインターになる。

~~~c++
// const char *
auto pointer = "hello" ;
~~~

`decltype(auto)`という`auto`と似ているがあまり暗黙の型変換を行わない別のキーワードを使うと、配列へのリファレンス型になる。

~~~c++
// const char (&) [6]
decltype(auto) reference = "hello" ;
~~~

## ワイド文字

ワイド文字リテラルとワイド文字列リテラルはリテラルにエンコードプレフィクス`L`を付ける。

~~~c++
// ワイド文字リテラル
L'A' ;
// ワイド文字列リテラル
L"hello" ;
~~~

ワイド文字リテラルの型は`wchar_t`、ワイド文字列リテラルの型は`const wchar_t [n]`になる。

~~~c++
wchar_t c = L'A' ;
const wchar_t (&ref)[6] = L"hello" ;
~~~

ワイド文字は失敗した機能だ。まだUnicodeが16bitで世界中の文字を表現できるという妄想にとらわれていたころに提案された時代遅れの実装不可能な機能だ。

C++の規格では、「ワイド文字は`wchar_t`型のオブジェクト1つがシステムがサポートする任意の1文字を表現可能である」と規定している。そのような文字エンコード方式はいまだかつて存在していない。Unicodeの1コードポイントは1文字を意味しないので、UTF-32を使ってもワイド文字の規定を満たすことはできない。そのため、現在規格準拠の方法でワイド文字を実装しているC++コンパイラーは存在しない。

Microsoft Windowsはワイド文字をUTF-16で表現している。それ以外の主要なOSはUTF-32を使っている。

## UTF-8/UTF-16/UTF-32

UTF-8の文字型は`char8_t`でエンコードプレフィクスは`u8`。

UTF-16の文字型は`char16_t`でエンコードプレフィクスは`u`。

UTF-32の文字型は`char32_t`でエンコードプレフィクスは`U`。

~~~c++
char8_t  utf8   = u8'a' ;
char16_t utf16  = u'あ' ;
char32_t utf32  = U'あ' ;
~~~

UTF-8文字型である`char8_t`はUTF-8の1単位なので、UTF-8の1単位で表現できる文字しか表現できない。

UTF-8/UTF-16/UTF-32の文字列リテラルは、それぞれの`const`な文字型の配列になる。エンコードプレフィクスは文字リテラルと同じだ。

~~~c++
// char8_t [6]
char8_t s1[] = u8"hello" ;
// char16_t [6]
char16_t s2[] = u"hello" ;
// char32_t [6]
char32_t s3[] = U"hello" ;
~~~

`"いろは"`をそれぞれの文字列リテラルで表現すると以下のようになる。

~~~cpp
// char8_t [10]
char8_t s1[] = u8"いろは" ;
// char16_t [4]
char16_t s2[] = u"いろは" ;
// char32_t [4]
char32_t s3[] = U"いろは" ;
~~~

これは以下のように書くのと同じだ。

~~~cpp
char8_t s1[10] = { 0xe3, 0x81, 0x84, 0xe3, 0x82, 0x8d, 0xe3, 0x81, 0xaf, 0x0 } ;
char16_t s2[4] = { 0x3044, 0x308d, 0x306f, 0x0 } ;
char32_t s3[4] = { 0x3044, 0x308d, 0x306f, 0x0 } ;
~~~

文字`'い'`のUnicodeコードポイントは`U+3044`で、これはUTF-16/UTF-32では1単位で表現できるが、UTF-8では3単位で`0xe3, 0x81, 0x84`のように表現する。

臼(うす U+81FC)の別字である𦥑(うす U+26951)のコードポイントは16bit符号なし整数で表現できないので、UTF-16ではサロゲートペアを使って2単位表現される。UTF-8では4単位を使って表現される。

以下のコードは、

~~~cpp
char8_t  s1[] = u8"𦥑" ;
char16_t s2[] = u"𦥑" ;
char32_t s3[] = U"𦥑" ;
~~~

以下のように解釈される。

~~~cpp
char8_t s1[5] = { 0xf0, 0xa6, 0xa5, 0x91, 0x0 } ;
char16_t s2[3] = { 0xd85a, 0xdd51, 0x0 } ;
char32_t s3[2] = { 0x26951, 0x0 } ;
~~~

文字`'が'`はUnicodeコードポイントでは結合済みコードポイントの`U+304C`で表現できるが、コードポイントU+304B(HIRAGANA LETTER KA)のあとに直ちに続いて、コードポイントU+3099(COMBINING KATAKANA-HIRAGANA VOICED SOUND MARK)を使って表現してもよい。

~~~cpp
// u8"\u304C"
char8_t ga1[] = u8"が" ;
// u8"\u304B\u3099"
char8_t ga2[] = u8"か\u3099" ;
~~~

これは以下のコードと等しい。

~~~cpp
char8_t ga1[4] = { 0xe3, 0x81, 0x8c, 0x0 } ;
char8_t ga2[7] = { 0xe3, 0x81, 0x8b, 0xe3, 0x82, 0x99, 0x0 } ;
~~~

変数`ga1, ga2`はどちらもUnicodeとして正しい「が」という1文字の表現だ。Unicodeでは複数のコードポイントで1文字を表現することもあるし、意味的に表示的に同じ文字に対して複数の表現方法がある。

Apple macOSはUnicodeの正規化として一般的なNFC(Canonical Composition)ではなくNormalization Form D(NFD)を使っているので、濁点や半濁点は必ず分解される。Apple macOSでは`u8"\u304B\u3099"`が一般的な表現で、それ以外の環境では`u8"\u304C"`が一般的な表現だ。しかし、どちらも意味上は同じ表現だ。

Unicodeの奇妙で面白い例は枚挙に暇がない。ここでは日本語を扱う際によくある注意点を説明したが、ほかにも絵文字、デーヴァナーガリー（ヒンディー語、マラーティー語、ネパール語）、モンゴル文字、アラビア文字、ヘブライ文字など扱いの難しい文字がたくさんある。

重要な点をまとめると、

+ 文字型の1つのオブジェクトは1文字ではない
+ 1コードポイントは1文字ではない

## 生文字列リテラル

エスケープシーケンスは文法上の理由で直接ソースコード上に記述することができない文字を文字リテラルと文字列リテラルに記述できる機能だ。

~~~cpp
u8"\nは改行文字" ;
~~~

しかしエスケープシーケンスがあるために、バックスラッシュを普通に使うには、`\\`と書かなければならない。例えば上の文字列リテラルを改行文字に続いて「は改行文字」ではなく、本当に「`\n`は改行文字」という文字列にしたい場合、以下のように書かなければならない。

~~~cpp
u8"\\nは改行文字" ;
~~~

また、単一引用符`'`や二重引用符`"`もエスケープシーケンスが必要だ。

~~~cpp
u8"\'は単一引用符" ;
u8"\"は二重引用符" ;
~~~

また、以下のような内容の文字列をリテラルとして書きたい場合、

~~~
foo
bar
baz
~~~

以下のように書かなければならない。

~~~cpp
"foo\nbar\nbaz" ;
~~~

このようなわかりにくい記述ではなく、ソースコードに書いたままの文字列を文字列として扱いたい。そのための機能が生文字列リテラル(Raw String Literal)だ。

生文字列リテラルは以下のような文法で書く。

~~~c++
R"(...)"
~~~

例えば以下のように書くと、

~~~cpp
R"(foo
bar
baz)" ;
~~~

以下のような文字列リテラルと同じ意味になる。

~~~
"foo\nbar\nbaz" ;
~~~

エスケープシーケンスも書いたままに文字列となる。

~~~cpp
R"(
'は単一引用符
"は二重引用符
\nは改行文字
)" ;
~~~

これは以下の文字列リテラルと同じ意味だ。

~~~cpp
"\n\'は単一引用符\n\"は二重引用符\n\\nは改行文字\n"
~~~

## 文字列の表現方法

文字列というのは文字型の配列で表現される。文字列を表現するには、配列の先頭へのポインターと配列のサイズが必要になる。

### null終端文字列

C++の文字列リテラルは、末尾にnull文字が付与された`const`な文字型への配列だ。

~~~c++
"abc" ;
~~~

という文字列リテラルは型とその値としては

~~~c++
const char st[4] = { 'a', 'b', 'c', '\0' } ;
~~~

になる。

null終端文字列とはC言語から使われている文字列の表現方法だ。文字型の配列の末尾にnull文字を番兵として配置することで文字列の終端を表現している。C言語では文字列は文字型へのポインターとして表現される。ポインターが指す配列のサイズはわからないが、妥当な文字列はnull終端されているので、ポインターをインクリメントしていけばいずれnull文字が現れる。そこが文字列の終わりだ。これによって文字列のサイズもわかる。

例えば、以下はC言語でよく書かれる典型的文字列を処理する関数だ。

~~~cpp
void process_string( const char * str )
{
    // strが指す配列のサイズを取得
    auto str_size = std:strlen( str ) ;
    // 残りの処理
}
~~~

`std::strlen`はポインターが指し示すnull終端された配列のnull文字を除くサイズを返す。以下のような実装だ。

~~~cpp
std::size_t strlen( const char * s )
{
    auto i = s ;
    while ( *i != '\0' )
    { ++i ; }
    return i - s ;
} 
~~~

ここで言う「文字列のサイズ」とは、ポインターが指し示す文字型の配列の要素数であって、文字数ではない。

null終端文字列は文字型へのポインター1つだけなので取り回しがよい。ただし、文字列のサイズは実行時に文字列の先頭から末尾までイテレートして計算しなければならない。これは文字列の長さに比例したオーダー$O(N)$の処理量がかかる。

### std::basic_string<CharT>

いままで文字列の型として使ってきた`std::string`は、実はクラステンプレートで実装されている。

~~~cpp
namespace std {
    template<
        typename charT,
        typename traits = char_traits<charT>,
        typename Allocator = allocator<charT>
    >
    class basic_string ;
}
~~~

テンプレートパラメーターのうち、`charT`が文字型、`traits`は文字を処理するための補助的なライブラリ、`Allocator`がアロケーターだ。

これに対し、以下のようなエイリアスが存在する。

~~~cpp
namespace std {
    using string    = basic_string<char> ;
    using u8string  = basic_string<char8_t> ;
    using u16string = basic_string<char16_t> ;
    using u32string = basic_string<char32_t> ;  
    using wstring   = basic_string<wchar_t> ;
}
~~~

それぞれの文字型に対応した`basic_string`のクラスだ。

これに対して、ユーザー定義リテラルという機能を使い、文字列リテラルのサフィックスに`s`を付けることで、文字列リテラルを対応する`basic_string`のクラス型に変換できる。

~~~cpp
// string
auto str    = "hello"s ;
// u8string
auto u8str  = u8"hello"s ;
// u16string
auto u16str = u"hello"s ;
// u32string
auto u32str = U"hello"s ;
// wstring
auto wstr   = L"hello"s ;
~~~

ユーザー定義リテラルの詳細については本書では詳しく説明しないが、演算子のオーバーロードと同じだ。演算子をオーバーロードするようにリテラル演算子をオーバーロードする。

~~~cpp
std::string operator ""s( const char * ptr, std::size_t n )
{ return std::string( ptr, n ) ; }
std::u8string operator ""s( const char8_t * ptr, std::size_t n )
{ return std::u8string( ptr, n ) ; }
std::u16string operator ""s( const char16_t * ptr, std::size_t n )
{ return std::u16string( ptr, n ) ; }
std::u32string operator ""s( const char32_t * ptr, std::size_t n )
{ return std::u32string( ptr, n ) ; }
std::wstring operator ""s( const wchar_t * ptr, std::size_t n )
{ return std::wstring( ptr, n ) ; }
~~~

ユーザー定義リテラルを正しく実装するには複雑なルールがある。例えばユーザー定義のサフィックス名はアンダースコア1つから始まっていなければならないなどだ。

~~~cpp
// OK
int operator "" _abc( unsigned long long int ) ;
// エラー、アンダースコア1つから始まっていない
int operator ""abc( unsigned long long int ) ;
~~~

これは将来の拡張のためにアンダースコアから始まらないサフィックス名をC++規格が予約しているためだ。

`basic_string`による文字列の表現方法は、文字型配列の先頭要素へのポインター、文字型配列のサイズ、アロケーターだ。


~~~cpp
template <
    typename charT,
    typename traits = char_traits<charT>,
    typename Allocator = allocator<charT>
>
class basic_string
{
    charT * ptr ;
    std::size_t size ;
    Allocator alloc ;
} ;
~~~

あるいは、配列のサイズを表現するために、配列の最後の要素の1つ次のポインターを使っているかもしれない。


~~~c++
    charT * ptr ;
    charT * last ;
    Allocator alloc ;
~~~

`std::vector`と同じで、どちらの方が効率がいいかはアーキテクチャにより異なる。

`basic_string`は文字列を表現するためのストレージを所有するクラスだ。コンストラクターでストレージを動的確保し、デストラクターで解放する。

~~~cpp
int main()
{
    // 少なくともchar [5]を格納できるだけのストレージを動的確保する
    std::string hello("hello") ;
    // helloが破棄される
    // デストラクターはストレージを解放する
}
~~~

コピーはストレージの動的確保、ムーブはストレージの所有権の移動になる。

~~~cpp
int main()
{
    std::string s1 = "hello" ;
    // コピー、動的確保
    std::string s2 = s1 ;
    // ムーブ、所有権の移動
    std::string s3 = std::move(s1) ;
}
~~~

### std::basic_string_view<CharT>

`basic_string_view`はストレージを所有しないクラスだ。以下のような宣言になる。

~~~cpp
namespace std {
    template <
        typename charT,
        typename traits = char_traits<charT>
    >
    class basic_string_view ;
}
~~~

その実装は文字型へのポインター2つか、文字型へのポインター1つと配列のサイズを保持する整数型になる。

~~~cpp
    charT * first ;
    charT * last ;
~~~

もしくは、

~~~c++
    charT * first ;
    std::size_t size ;
~~~

`basic_string_view`には`basic_string`と対になる各文字型に対する特殊化がある。


~~~cpp
namespace std {
    using string_view    = basic_string_view<char> ;
    using u8string_view  = basic_string_view<char8_t> ;
    using u16string_view = basic_string_view<char16_t> ;
    using u32string_view = basic_string_view<char32_t> ;  
    using wstring_view   = basic_string_view<wchar_t> ;
}
~~~

さらに、各`basic_string`に対するユーザー定義リテラルサフィックス`sv`がある。

~~~cpp
// string_view
auto str    = "hello"sv ;
// u8string_view
auto u8str  = u8"hello"sv ;
// u16string_view
auto u16str = u"hello"sv ;
// u32string_view
auto u32str = U"hello"sv ;
// wstring_view
auto wstr   = L"hello"sv ;
~~~

`basic_string_view`は文字列がnull終端文字列と`basic_string`のどちらで表現されていても問題なく受け取るためのクラスだ。この2つの文字列の表現を別々に使う場合、文字列を受け取る関数は、

~~~cpp
void process_string( const char * s )
{
    // 文字列に対する処理
}

void process_string( const std::string & s )
{
    // 文字列に対する上と同じ処理
}

int main()
{
    auto null_terminated_string = "hello" ;
    auto basic_string = "hello"s ;

    // const char *
    process_string( null_terminated_string ) ;
    // const std::string &
    process_string( basic_string ) ;
}
~~~

のようにほとんど同じ関数を2つ書かなければならない。`basic_string_view`を使えば、

~~~cpp
void process_string( std::string_view s )
{
    // 文字列に対する処理
}

int main()
{
    auto null_terminated_string = "hello" ;
    auto basic_string = "hello"s ;

    // どちらも同じ関数を呼ぶ
    process_string( null_terminated_string ) ;
    process_string( basic_string ) ;
}
~~~

のように、どちらの文字列表現を使っても1つの関数を書くだけで済む。

`basic_string_view`はストレージを所有しないので関数の引数として使うときはリファレンスで取る必要はない。

~~~cpp
// リファレンスで取る必要はない
void f( const std::string_view & ref ) 
// これでいい
void g( std::string_view obj ) ;
~~~

## 文字列の操作

### null終端文字列の操作

null終端文字列は文字列の先頭となる文字型へのポインター型のオブジェクト1つで表現されるので、文字型の配列のサイズを取得するにも、いちいちnull文字が見つかるまでポインターをインクリメントしていく必要がある。この処理をやってくれるのが`std::strlen`だ。

~~~cpp
void f( const char * ptr )
{
    auto size = std::strlen( ptr ) ;
}
~~~

文字列リテラルの型は`const`な文字型の配列なので、文字列を変更することができない。

~~~cpp
const char * ptr = "abc" ;
// エラー
ptr[0] = 'x' ;
~~~

文字型への配列ならば変更できる。

~~~cpp
int main()
{
    char s[] = "abc" ;
    s[0] = 'x' ;
    // sは{'x','b','c','\0'}
}
~~~

文字の長さを短くしたい場合は、終端をnull文字にする。

~~~cpp
int main()
{
    char s[] = "abc" ;
    s[1] = '\0' ;
    // sは{'a','\0', 'c','\0'}
}
~~~

この変数`s`の型は`char [4]`だが、null終端文字列としてのサイズは1だ。

文字列のサイズを長くするには、当然大きな配列が必要になる。

~~~cpp
int main()
{
    char s[10] = "abc" ;
    s[3] = 'd' ;
    s[4] = 'e' ;
    s[5] = 'f' ;
    s[6] = '\0' ;
}
~~~

このコードで、変数`s`は最終的に`"abcdef"`という文字列になる。最後のnull文字による終端を忘れてはならない。

ここで、配列`s`の要素数は7以上でなければならない。最終的なnull終端文字列を表現するには最低でも`char [7]`が必要だからだ。

例えば2つのnull終端文字列を結合する場合で、どちらも`const`であったり、十分なサイズがなかった場合、2つの文字列を保持できるサイズのメモリーを確保して、コピーしなければならない。

~~~cpp
// s1, s2を結合して使う関数
void concat_str( const char *  s1, const char * s2 )
{
    // 2つの文字列のサイズの合計 + null文字
    auto size = std::strlen( s1 ) + std::strlen( s2 ) + 1 ;
    // 文字列を保持するメモリーを確保する
    char * ptr = new char[size] ;

    char * i = ptr ;
    // s1をコピー
    while ( *s1 != '\0' )
    {
        *i = *s1 ;
        ++i ; ++s1 ;
    }
    // s2をコピー
    while ( *s2 != '\0' )
    {
        *i = *s2 ;
        ++i ; ++s2 ;
    }
    // null終端する
    *i = '\0' ;

    // 結合した文字列を使う

    // 使い終わったのでメモリーを解放する
    delete[] ptr ;
}
~~~

C言語の標準ライブラリにはnull終端文字列を扱うためのライブラリが多数ある。C言語の標準ライブラリを使えば、上のコードは以下のように書ける。

~~~cpp
void concat_str( const char *  s1, const char * s2 )
{
    auto size = std::strlen( s1 ) + std::strlen( s2 ) + 1 ;
    char * ptr = new char[size] ;

    // s1をptrにコピー
    std::strcpy( ptr, s1 ) ;
    // ptrとs2を結合
    std::strcat( ptr, s2 ) ;

    delete[] ptr ;
}
~~~



### basic_stringの操作

`basic_string`はストレージを所有するクラスだ。ストレージの解放と確保を自動でやってくれる上に、便利な操作がたくさんある。

例えば上の`concat_str`を`basic_string`で実装すると以下のようになる。

~~~cpp
void concat_str( const char *  s1, const char * s2 )
{
    std::string s = s1 ;
    s += s2 ;

    // sを使う
    // sは自動的に破棄される
}
~~~

C++の作法に従って、引数`s1, s2`をnull終端文字列文字型ではなく、`basic_string_view`にすると以下のようになる。

~~~cpp
void concat_str( std::string_view s1, std::string_view s2 )
{
    std::string s = s1 ;
    s += s2 ;

    // sを使う
    // sは自動的に破棄される
}
~~~

#### 初期化

`basic_string`はnull終端文字列、`basic_string_view`、`basic_string`で初期化、代入できる。

~~~cpp
// null終端文字列
std::string s1("hello") ;
// basic_string_view
std::string s2("hello"sv) ;
// basic_string
std::string s3("hello"s) ;
~~~

#### 結合

`basic_string`は`operator +`で文字列を結合できる。

~~~c++
// "foobar"
auto s = "foo"s + "bar"s ;
~~~

`operator +=`は第一オペランドを書き換える。

~~~c++
auto s = "foo"s ;
s += "bar"s ;
// sは"foobar"
~~~

`basic_string::append(s)`というメンバー関数もある。

~~~c++
auto s = "foo"s ;
s.append("bar"sv) ;
// sは"foobar" 
~~~

#### イテレーター

`basic_string`にはイテレーターがある。イテレーターの取得方法は`std::vector`と同じだ。

~~~cpp
int main()
{
    auto s = "hello"s ;
    for ( auto i = s.begin() ; i != s.end() ; ++i )
    {
        std::cout << *i ;
    }
}
~~~

これは以下のようにも書ける。

~~~cpp
for ( auto i = std::begin(s) ; i != std::end(s) ; ++i )
{
    std::cout << *i ;
}
~~~

#### 部分文字列の検索

イテレーターがあるので、`basic_string`は汎用的なアルゴリズムに渡すことができる。例えばある文字列がその一部の別の文字列を含むかどうかを調べる場合、以下のように書ける。

~~~cpp
int main()
{
    auto text = "quick brown fox jumps over the lazy dog."s ;
    auto word = "fox"s ;

    auto i = std::search( std::begin(text), std::end(text), std::begin(word), std::end(word) ) ;

    if ( i != std::end(text) )
        std::cout << "fox found!\n"sv ;
    else
        std::cout << "no fox...\n"sv ;
}
~~~

イテレーターを使うのは煩わしいが、C++20では`Range`ライブラリが追加され、以下のように書ける予定だ。

~~~c++
auto r = std::ranges::search( text, word ) ;
if ( !std::ranges::empty(r) )
    // ...
~~~

名前空間を省くと、`!empty( search( text, word) )` になるが、これでもまだわかりづらい。そこで`basic_string::find`がある。これは`<algorithm>`の`std::find`とは別物で、文字列から部分文字列を探し、その部分文字列に一致する文字へのインデックスを返す。

~~~cpp
int main()
{
    auto text = "quick brown fox jumps over the lazy dog."s ;

    // 12
    auto fox = text.find("fox"sv) ;
    // 32
    auto dog = text.find("dog"sv) ;
}
~~~

文字列`"fox"`に一致する部分文字列の先頭`'f'`の文字型の値へのインデックスは`12`で、`"dog"`の`'d'`は`36`だ。この結果は、上のソースコードに使っている文字が1文字につき1文字型の値を使うためだ。通常は文字数と連続した文字型の要素へのインデックスは等しくならない。




例えば以下のコードを実行すると、

~~~cpp
int main()
{
    auto text = u8"すばしっこい茶色の狐がノロマな犬を飛び越した。"s ;

    auto fox = text.find(u8"狐"sv) ;
    auto dog = text.find(u8"犬"sv) ;

    std::cout << "fox: "sv << fox << "\n"sv
            << "dog: "sv << dog ;
}
~~~

以下のように出力される。

~~~
fox: 27
dog: 45
~~~

もし部分文字列が見つからない場合、`basic_string::npos`が返る。`npos`は"no position"という意味で、`-1`と等しい。


~~~cpp
int main()
{
    auto text = "quick brown fox jumps over the lazy dog."s ;

    // 見つからない場合はnposが返る。   
    auto index = text.find("abc"sv) ;

    // 見つからなかった判定
    if ( index != std::string::npos )
        // 見つかった
        std::cout << "found." ;
    else
        // 見つからなかった
        std::cout << "not found." ;
}
~~~

この場合、変数`text`に文字列`"abc"`はないので、`npos`が返る。`npos`が返ったかどうかは`npos`と比較すればわかる。`npos`は`-1`と等しいので、以下のようにも書ける。

~~~cpp
if ( index != -1 )
    // ...
~~~


`find`の亜種として、`rfind`がある。

`find`は最初の部分文字列を見つけるが、`rfind`は最後の部分文字列を見つける。

~~~cpp
int main()
{
    auto text = "word word word"s ;

    // 0
    auto first = text.find("word"sv) ;
    // 10
    auto last = text.rfind("word"sv) ;
}
~~~

`find`は最初に一致した部分文字列の先頭へのインデックスを返すので、この場合`0`が返る。`rfind`は最後に見つかった部分文字列の先頭へのインデックスを返すので、この場合`10`になる。

C++20では、`starts_with/ends_with`という2つの便利なメンバー関数が追加される。

`starts_with(str)`は文字列が部分文字列`str`で始まっている場合に`true`を返す。そうでない場合は`false`を返す。

~~~cpp
int main()
{
    auto text = "aa bb cc"s ;

    // true
    bool b1 = text.starts_with("a"sv) ;
    bool b2 = text.starts_with("aa"sv) ;
    bool b3 = text.starts_with("aa "sv) ;

    // false
    bool b4 = text.starts_with("b"sv) ;
    bool b5 = text.starts_with("aaa"sv) ;
}
~~~

`ends_with(str)`は文字列が部分文字列`str`で終わっている場合に`true`を返す。そうでない場合は`false`を返す。

~~~cpp
int main()
{
    auto text = "aa bb cc"s ;

    // true
    bool b1 = text.ends_with("c"sv) ;
    bool b2 = text.ends_with("cc"sv) ;
    bool b3 = text.ends_with(" cc "sv) ;

    // false
    bool b4 = text.ends_with("b"sv) ;
    bool b5 = text.ends_with("ccc"sv) ;
}
~~~

#### その他のメンバー関数

`size`, `empty`, `resize`, `capacity`, `reserve`, `shrink_to_fit`, `clear`といったおなじみのメンバー関数もある。

~~~cpp
int main()
{
    std::string s ;
    s.size() ;
    s.resize(10) ;
    s.clear() ;
}
~~~

#### 文字列の挿入

文字列の挿入は`insert( pos, str )` で行える。

`pos`は挿入場所へのインデックスで、`str`は挿入する文字列だ。

文字列の先頭や末尾への挿入は以下のようになる。

~~~cpp
int main()
{
    auto text = "cat"s ;
    text.insert( 0, "long "sv ) ;
    // textは"long cat"
    text.insert( text.size(), " is loong."sv ) ;
    // textは"long cat is loong."
}
~~~

末尾への挿入は文字列の結合と同じ効果だ。

インデックスで中間に挿入するのは以下のとおり。

~~~cpp
int main()
{
    auto text = "big cat"s ;
    text.insert( text.find("cat"sv), "fat "sv ) ;
    // textは"big fat cat"
}
~~~

これは`text.find("cat"sv)`でまず部分文字列`"cat"`の先頭へのインデックスを探し、そこに文字列`"fat "`を挿入している。結果として変数`text`は`"big fat cat"`となる。

#### 部分文字列の削除

文字列から部分文字列を削除するには`erase( pos, n )`を使う。`pos`は削除すべき先頭のインデックスで、`n`は削除すべきインデックス数だ。

~~~cpp
int main()
{
    auto text = "dirty cat"s ;
    auto dirty = "dirty "sv ;
    text.erase( 0, dirty.size() ) ;
    // textは"cat"
}
~~~

このプログラムは文字列`"dirty cat"`から`"dirty "`を削除し、`"cat"`にする。

~~~cpp
int main()
{
    auto text = "big fat cat"s ;
    auto fat = "fat "sv ;
    text.erase( text.find(fat), fat.size() ) ;
    // textは"big cat"
}
~~~

このプログラムは文字列`"big fat cat"`から部分文字列`"fat"`を検索し、その先頭から変数`fat`のサイズ文の部分文字列を削除する。結果として変数`text`は`"big cat"`になる。

先頭から末尾までを削除すると、`clear()`と同じ意味になる。

~~~cpp
int main()
{
    auto text = "abc"s ;
    text.erase( 0, text.size() ) ;
    // text.empty() == true
}
~~~

#### 部分文字列の置換

`replace( pos, n1, str )`を使うと、文字列のインデックス`pos`から`n1`個までの文字型の値を、文字列`str`で置き換える。

~~~cpp
int main()
{
    auto text = "ugly cat"s ;
    auto ugly = "ugly"sv ;
    auto pretty = "pretty"sv ;
    text.replace( text.find(ugly), ugly.size(), pretty ) ;
    // textは"pretty cat"
}
~~~

このコードは、文字列`text`から部分文字列`"ugly"`を探し、その先頭へのインデックスと文字列`"ugly"`のサイズを指定することで、部分文字列`"ugly"`を、文字列`pretty`の値である`"pretty"`に置換する。結果として`text`は`"pretty cat"`になる。

#### その他の推奨できない操作

`basic_string`にはこのほかにさまざまな、現代では推奨できない操作がある。

例えば`operator []`で文字列をインデックスでアクセスできる。これは基本実行文字セットに対しては動く。

~~~cpp
int main()
{
    auto text = "abc"s ;
    // 'a'
    std::cout << text[0] ;
    // 'b'
    std::cout << text[1] ;

    text[0] = 'x' ;
    // textは"xbc"
}
~~~

これは、`basic_string`が設計された時代は、1文字型は1文字を表現できるという前提があったからだ。

現代の文字列の表現方法であるUnicodeとUTFによるエンコードではこの前提が成り立たない。例えば、最もよく使われているUTF-8の場合、以下のようになる。

~~~cpp
int main()
{
    auto text = u8"いろは"s ;
    // 0xe3
    auto c = text[0] ;
}
~~~

`text`のインデックス`0`にあたる文字型の値は`u8'い'`ではない。UTF-8は文字「い」を文字型1つで表現できないからだ。`u8"いろは"`というUTF-8文字列リテラルはすでに学んだように、以下のように表現される。

~~~cpp
// u8"いろは"
char8_t iroha[10] = { 0xe3, 0x81, 0x84, 0xe3, 0x82, 0x8d, 0xe3, 0x81, 0xaf, 0x0 } ;
~~~

文字「い」をUTF-8で表現するためには、`char8_t`型の値が3つ必要で、`0xe3, 0x81, 0x84`というシーケンスでなければならない。そのため、個々の文字型の値をインデックスでアクセスしても意味がない。また、`size()`は文字数を返すのではなく、インデックス数を返す。

`basic_string`にはリバースイテレーターを返す`rbegin/rend`もあるが、Unicodeでエンコードされた文字列では、複数の値のシーケンスで1文字を表現しているため、単に値単位で逆順のイテレートすることは、技術的には可能だが、意味的には壊れてしまう。

`basic_string`には最初に発見したいずれかの文字へのインデックスを返す`find_first_of`がある。

~~~cpp
int main()
{
    auto text = "quick brown fox jumps over the lazy dog."s ;
    // 3
    auto i = text.find_first_of("abc"sv) ;
}
~~~

`i`は`3`になる。なぜならば、`find_first_of("abc"sv)`は`a`, `b`, `c`のうちいずれかの文字である最初のインデックスを返すからだ。

この機能はUnicodeでは使えない。というのも1文字型で1文字を表現できないからだ。

### basic_string_viewの操作

`basic_string_view`は`basic_string`とほぼ同じ操作が行える。ただし、`basic_string_view`は書き換えることができないので、一部の操作が使えない。`append, insert, erase, replace`は使えない。`basic_string_view`同士の`operator +`もない。


C++20では、文字列の先頭と末尾を指定したインデックス数分削ることはできる。

先頭を削るには`remove_prefix(i)`を使う。

~~~cpp
int main()
{
    auto text = "quick brown fox jumps over the lazy dog." ;
    text.remove_prefix( "quick "sv.size() ) ;
    // textは"brown fox jumps over the lazy dog."
    text.remove_prefix( "brown"sv.size() ) ;
    // textは"fox jumps over the lazy dog."
}
~~~

末尾を削るには`remove_suffix(i)`を使う。

~~~cpp
int main()
{
    auto text = "quick brown fox jumps over the lazy dog." ;
    text.remove_suffix( " dog."sv.size() ) ;
    // textは"quick brown fox jumps over the lazy"
    text.remove_suffix( " lazy".sv.size() ) ;
    // textは"quick brown fox jumps over the"
}
~~~
