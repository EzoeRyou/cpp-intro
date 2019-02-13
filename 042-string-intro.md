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

空白文字、水平タブ、垂直タブ、フォームフィード、改行の5文字と、以下の印字可能な以下の91文字だ。

~~~
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

C++の基本実行文字セットは特定の文字エンコードであると規定されていはいないが、ASCIIを参考にしている。ただしASCIIには基本実行文字セットにはない。ダラーサイン($)、アットマーク(@)といくつかの制御文字がある。

### Unicode

Unicode、もしくはISO/IEC 10646(Universal Coded Character Set, UCS)は文字のコードポイントを定める規格だ。

Unicodeは当初、16bitの符号なし整数値でコードポイントを表現する規格であった。この当時、1コードポイントは1文字であり16bitであった。

そのような当初の目論見はすぐに破綻し、今では1コードポイントは21bit弱(U+0000からU+10FFFF)であり、1コードポイントは1文字を意味しないようになった。複数のコードポイントを組み合わせて1文字が表現されることもあるからだ。

Unicodeはコードポイントについて定めた規格であり、バイト列で文字を表現する規格ではない。Unicodeを元にしたバイト列によって文字を表現するエンコード方式に、UTF-8, UTF-16, UTF-32が存在する。

#### UTF-16

UTF-16は16bitの符号なし整数値によってUnicodeのコードポイントを表現するエンコード方式だ。まだUnicodeが16bitのコードポイントですべての文字を表現すると考えていた頃に考案されたUCS-2が元になっている。

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

筆者の環境では"21"と表示される。これはつまり、2つのバイトのうち、下位バイトのほうが先に配置されているということだ。

世の中にはリトルエンディアン(Little Endian)とビッグエンディアン(Big Endian)がある。これは複数バイトの順序の違いだ。

リトルエンディアンは下位バイトから配置する。

ビッグエンディアンは上位バイトから配置する。

リトルエンディアン環境では、上のプログラムは"21"と表示する。ビッグエンディアン環境では、"12"と表示する。

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
+ Andorid
+ FreeBSD
+ DragonflyBSD
+ OpenBSD
+ NetBSD
+ Apple macOS
+ Apple iOS
+ Microsoft Windows

この他にもOSは様々あるが、情報を得るだけでもNDAを結ぶ必要がある表に出てこないOSであったり、実験的すぎたりして、C++を学習する環境としては不適切だ。


このうち、Microsoft Windowsを除くOSはUTF-8を使用している。

Microsoft WindowsはUTF-16を使用している。ただし、この状況はMicrosoft Windowsは最近UTF-8ロケールを実装したので将来的に変わるだろう。




## リテラル

### 通常の文字リテラル

通常の文字リテラルは単一引用符でひとつの文字を囲む。

~~~c++
`a`
`b`
`c`
~~~

通常の文字リテラルの型はcharだ。

~~~c++
char a = `a` ;
char b = 'b' ;
char c = 'c' ;
~~~

文字リテラルには以下のようなエスケープシーケンスがある。これは一部の印字不可能な文字や、文法上の理由で直接リテラルのなかに書くことができない文字を書けるようにするための代替手段だ。


意味                    リテラル
------------------      --------
改行                    \n
水平タブ                \t
垂直タブ                \v
バックスペース          \b
キャリッジリターン      \r
フォームフィード        \f
アラート                \a
バックスラッシュ        \\
疑問符                  \?
単一引用符              \'
二重引用符              \"


これを使えば、単一引用符の文字リテラルは

~~~c++
char c = '\'' ;
~~~

と書ける。エスケープシーケンスにはバックスラッシュを使うため、文字リテラルのなかでバックスラッシュを使うには、エスケープシーケンスが必要だ。

~~~c++
char c = '\\' ;
~~~


通常の文字がどのような文字エンコードを使っているかは実装定義だ。

その他にも文字の数値を直接指定するエスケープシーケンスとして、8進数エスケープシーケンスと16進数エスケープシーケンスがある。

~~~c++
char oct = '\101' ;
char hex = "\x41" ;
~~~

このコードは、8進数で`101`、16進数で`41`になる何らかの文字を表現している。もし通常の文字列リテラルがASCIIかUTF-8でエンコードされている場合、この文字は`A`になる。

### ユニバーサルキャラクター名

文字リテラルには特殊なエスケープシーケンスであるユニバーサルキャラクター名(Universal Character name)を使うことができる。

~~~c++
\uNNNN
\UNNNNNNNNN
~~~

文法は`\u`に続いて16進数を4文字かくとこれはUnicodeコードポイントにおける`U+0000NNN`になる。`\U`に続いて16進数を8文字書くと、これはUnicodeコードポイントにおける`U+NNNNNNNN`になる。





### 通常の文字列リテラル

通常の文字列リテラルは二重引用符で文字列を囲む。

~~~c++
"abc" ;
"hello" ;
"This is a pen." ;
~~~

通常の文字列リテラルの型はconstな文字型の配列になる。具体的な型としては`const char [n]`になる。`n`は文字列のサイズだ。通常の文字列リテラルの中の文字が基本実行文字だけであれば、書かれている文字数+1になる。しかし、この文字数というのも難しい。

文字列リテラルが連続している場合、1つにまとめられる。

~~~cpp
auto s = "abc" "def" ;
~~~

というコードは、

~~~cpp
auto s = "abcdef" ;
~~~

と書くのと同じだ。

文字リテラルの中のエスケープシーケンスは対応する文字になる。

~~~cpp
"\n" ;
~~~

という通常の文字リテラルは、バックスラッシュとラテンアルファベットnではなく、改行文字1文字になる。

通常の文字列リテラルは末尾にnull文字(`\0`)が付与される。このために、配列のサイズは文字数+1になる。


具体的な例では、`"abc"`という通常の文字列リテラルの型は'const char [4]'になる。これは以下のような配列に等しい。

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

配列の添字を書かない場合、文字列リテラルのサイズになるうう。

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

ワイド文字リテラルとワイド文字列リテラルはリテラルにエンコードプレフィクス`L`をつける。

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

ワイド文字は失敗した機能だ。まだUnicodeが16bitで世界中の文字を表現できるという妄想に囚われていた頃に提案された時代遅れの実装不可能な機能だ。

C++の規格では、「ワイド文字は`wchar_t`型のオブジェクト1つがシステムがサポートする任意の1文字を表現可能である」と規定している。そのような文字エンコード方式は未だかつて存在していない。Unicodeの1コードポイントは1文字を意味しないので、UTF-32を使ってもワイド文字の規定を満たすことはできない。そのため、現在規格準拠の方法でワイド文字を実装しているC++コンパイラーは存在しない。

Microsoft Windowsはワイド文字をUTF-16で表現している。それ以外の主要なOSはUTF-32を使っている。

## UTF-8/UTF-16/UTF-32

UTF-8の文字型は`char8_t`でエンコードプレフィクスは`u8`。

UTF-16の文字型は`char16_t`でエンコードプレフィクスは`u`。

UTF-32の文字型は`char32_t`でエンコードプレフィクスは`U`。

~~~c++
char8_t  utf8   = u8'a' ;
char16_t utf16  = u'あ' ;
char32_t utf32  = I'あ' ;
~~~

UTF-8文字型である`char8_t`はUTF-8の1単位なので、UTF-8の1単位で表現できる文字しか表現できない。

UTF-8/UTF-16/UTF-32の文字列リテラルは、それぞれのconstな文字型の配列になる。エンコードプレフィクスは文字リテラルと同じだ。

~~~c++
// char8_t [6]
char8_t s1[] = u8"hello" ;
// char16_t [6]
char16_t s2[] = u"hello" ;
// char32_t [6]
char32_t s3[] = U"hello" ;
~~~

`"いろは"`をそれぞれの文字列リテラルで表現すると以下のようになる。

~~~c++
// char8_t [10]
char8_t s1[] = u8"いろは" ;
// char16_t [4]
char16_t s2[] = u"いろは" ;
// char32_t [4]
char32_t s3[] = U"いろは" ;
~~~

これは以下のように書くのと同じだ。

~~~c++
char8_t s1[10] = { 0xe3, 0x81, 0x84, 0xe3, 0x82, 0x8d, 0xe3, 0x81, 0xaf, 0x0 } ;
char16_t s2[4] = { 0x3044, 0x308d, 0x306f, 0x0 } ;
char32_t s3[4] = { 0x3044, 0x308d, 0x306f, 0x0 } ;
~~~

文字'い'のUnicodeコードポイントは`U+3044`で、これはUTF-16/UTF-32では1単位で表現できるが、UTF-8では3単位で`0xe3, 0x81, 0x84`のように表現する。

臼(うす U+81FC)の別字である𦥑(うす U+26951)のコードポイントは16bit符号なし整数で表現できないので、UTF-16ではサロゲートペアを使って2単位表現される。UTF-8では4単位を使って表現される。

以下のコードは、

~~~c++
char8_t  s1[] = u8"𦥑" ;
char16_t s2[] = u"𦥑" ;
char32_t s3[] = U"𦥑" ;
~~~

以下のように解釈される。

~~~c++
char8_t s1[5] = { 0xf0, 0xa6, 0xa5, 0x91, 0x0 } ;
char16_t s2[2] = { 0xd85a, 0xdd51, 0x0 } ;
char32_t s3[2] = { 0x26951, 0x0 } ;
~~~

文字'が'はUnicodeコードポイントでは結合済みコードポイントの`U+304C`で表現できるが、コードポイントU+304B(HIRAGANA LETTER KA)の後に直ちに続いて、コードポイントU+3099(COMBINING KATAKANA-HIRAGANA VOICED SOUND MARK)を使って表現してもよい。

~~~c++
// u8"\u304C"
char8_t ga1[] = u8"が" ;
// u8"\u304B\u3099"
char8_t ga2[] = u8"か\u3099" ;
~~~

これは以下のコードと等しい。

~~~c++
char8_t ga1[4] = { 0xe3, 0x81, 0x8c, 0x0 } ;
char8_t ga2[7] = { 0xe3, 0x81, 0x8b, 0xe3, 0x82, 0x99, 0x0 } ;
~~~

変数`ga1, ga2`はどちらもUnicodeとして正しい「が」という1文字の表現だ。Unicodeでは複数のコードポイントで1文字を表現することもあるし、意味的に表示的に同じ文字に対して複数の表現方法がある。

Apple macOSはUnicodeの正規化として一般的なNFC(Canonical Compoosition)ではなくNormalization Form D(NFD)を使っているので、濁点や半濁点は必ず分解される。Apple macOSでは`u8"\u304B\u3099"`が一般的な表現で、それ以外の環境では`u8"\u304C"`が一般的な表現だ。しかし、どちらも意味上は同じ表現だ。

Unicodeの奇妙で面白い例は枚挙に暇がない。ここでは日本語を扱う際によくある注意点を説明したが、他にも絵文字、デーヴァナーガリー（ヒンディー語、マラーティー語、ネパール語）、モンゴル文字、アラビア文字、ヘブライ文字など扱いの難しい文字がたくさんある。

重要な点をまとめると、

+ 文字型の1つのオブジェクトは1文字ではない
+ 1コードポイントは1文字ではない

## 生文字列リテラル

エスケープシーケンスは文法上の理由で直接ソースコード上に記述することができない文字を文字りてらると文字列リテラルに記述できる機能だ。

~~~cpp
u8"\nは改行文字" ;
~~~

しかしエスケープシーケンスがあるために、バックスラッシュを普通に使うには、`\\`と書かなければならない。例えば上の文字列リテラルを改行文字に続いて「は改行文字」ではなく、本当に「\nは改行文字」という文字列にしたい場合、以下のように書かなければならない。

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

生文字列リテラルは以下のような文法で書く

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

C++の文字列リテラルは、末尾にnull文字が付与されたconstな文字型への配列だ。

~~~c++
"abc" ;
~~~

という文字列リテラルは型とその値としては

~~~c++
const char st[4] = { 'a', 'b', 'c', '\0' } ;
~~~

になる。

null終端文字列とはC言語から使われている文字列の表現方法だ。文字型の配列の末尾にnull文字を番兵として配置することで文字列の終端を表現している。C言語では文字列は文字型へのポインターとして表現される。ポインターが指す配列のサイズはわからないが、妥当な文字列はnull終端されているので、ポインターをインクリメントしていけばいずれnull文字が現れる。底が文字列の終わりだ。これによって文字列のサイズもわかる。

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

~~~c++
std::size_t strlen( const char * s )
{
    auto i = s ;
    while ( *i != '\0' )
    { ++i ; }
    return i - s ;
} 
~~~

ここで言う「文字列のサイズ」とは、ポインターが指し示す文字型の配列の要素数であって、文字数ではない。

null終端文字列は文字型へのポインター1つだけなので取り回しがよい。ただし、文字列のサイズは実行時に文字列の先頭から末尾までイテレートして計算しなければならない。これは文字列の長さに比例したオーダー`O(N)`の処理量がかかる。

### std::basic_string<CharT>

今まで文字列の方として使ってきた`std::string`は、実はクラステンプレートで実装されている。

~~~c++
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

~~~c++
namespace std {
    using string    = basic_string<char> ;
    using u8string  = basic_string<char8_t> ;
    using u16string = basic_string<char16_t> ;
    using u32string = basic_string<char32_t> ;  
    using wstring   = basic_string<wchar_t> ;
}
~~~

それぞれの文字型に対応した`basic_string`のクラスだ。

これに対して、ユーザー定義リテラルという機能を使い、文字列リテラルのサフィックスに`s`をつけることで、文字列リテラルを対応する`basic_string`のクラス型に変換できる。

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

~~~c++
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

~~~c++
// OK
int operator "" _abc( unsigned long long int ) ;
// エラー、アンダースコア1つから始まっていない
int operator ""abc( unsigned long long int ) ;
~~~

これは将来の拡張のためにアンダースコアから始まらないサフィックス名をC++規格が予約しているためだ。

`basic_string`による文字列の表現方法は、文字型配列の先頭要素へのポインター、文字型配列のサイズ、アロケーターだ。


~~~c++
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
    CharT * ptr ;
    CharT * last ;
    Allocator alloc ;
~~~

`std::vector`と同じで、どちらのほうが効率がいいかはアーキテクチャにより異なる。

`basic_string`は文字列を表現するためのストレージを所有するクラスだ。コンストラクターでストレージを動的確保し、デストラクターで解放する。

~~~cpp
int main()
{
    // 少なくともchar [5]を格納できるだけのストレージを動的確保する
    std::string hello("hello") ;
    // helloが破棄される
    // デストラクターはストレージを解放する。
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

~~~c++
namespace std {
    template <
        typename charT,
        typename traits = char_traits<charT>
    >
    class basic_string_view ;
}
~~~

その実装は文字型へのポインター2つか、文字型へのポインターひとつと配列のサイズを保持する整数型になる。

~~~c++
    charT * first ;
    charT * last ;
~~~

もしくは、

~~~c++
    charT * first ;
    std::size_t size ;
~~~

`basic_string_view`には`basic_string`と対になる各文字型に対する特殊化がある。


~~~c++
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

のように、どちらの文字列表現を使っても1つの関数を書くだけですむ。

`basic_string_view`はストレージを所有しないので関数の引数として使うときはリファレンスで取る必要はない。

~~~cpp
// リファレンスで取る必要はない
void f( const std::string_view & ref ) 
// これでいい
void g( std::string_view obj ) ;
~~~

## 文字列の操作


