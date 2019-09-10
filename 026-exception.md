# 傲慢なエラー処理: 例外

## 例外を投げる

`std::array`の実装方法はほとんど解説した。読者は`std::array`の実装方法を知り、確固たる自信の元に`std::array`を使えるようになった。ただし、1つだけ問題がある。

`"std::array"`のユーザーはあらかじめ設定した要素数を超える範囲の要素にアクセスすることができてしまう。

~~~cpp
int main()
{
    // 妥当な要素はa[0]のみ
    std::array<int, 1> a = {1} ;

    // エラー、範囲外
    a[1000] = 0 ;
}
~~~

`array`を自力で実装できる傲慢な読者としては、ユーザーごときが間違った使い方をできるのが許せない。間違いを起こした時点でエラーを発生させ、問題を知らしめ、対処できるようにしたい。

`operator []`に範囲外チェックを入れるのは簡単だ。問題は、エラーをユーザーに通知する方法がない。

~~~cpp
reference array::operator [] ( std::size_t i )
{
    // 範囲外チェック
    if ( i >= size() )
    {
        // エラー検出
        // しかし何をreturnすればいいのだろう
    }

    return storage[i] ;
}
~~~

`operator []`は伝統的にエラーチェックをしない要素アクセスをするものだ。

`vector`で一番最初に説明した要素アクセスの方法であるメンバー関数`at`を覚えているだろうか。実はメンバー関数`at`はエラーチェックをする。試してみよう。

~~~cpp
int main()
{
    std::array<int, 1> a = {1} ;

    std::cout << a.at(1000) = 0 ;
}
~~~

以下が実行結果だ。

~~~
terminate called after throwing an instance of 'std::out_of_range'
  what():  array::at: __n (which is 1000) >= _Nm (which is 1)
~~~

何やらよくわからないがエラーのようだ。以下のような意味であることがわかる。

~~~
`std::out_of_range`がthrowされたあとにterminateが呼ばれた
  what(): array_at: __n(値は1000) >= _Nm (値は1)
~~~

どうやらエラーメッセージのようだ。わかりづらいメッセージだが、なんとなく言わんとすることはわかる。`_Nm`が`array`の要素数で、`__n`がメンバー関数`at`に渡した実引数だ。要素数`_Nm`よりも`__n`が大きい。

このエラー処理は、「例外」を使って行われる。

例外は通常の処理をすっ飛ばして特別なエラー処理をする機能だ。何もエラー処理をしない場合、プログラムは終了する。例外を発生させることを、「例外を投げる」という。

例外は文字どおり投げるという意味の`throw`キーワードを使い、何らかの値を投げる(throw)。

~~~cpp
// int型の値123を投げる
throw 123 ;

// double型の値3.14を投げる
throw 3.14 ;

std::array<int, 5> value = {1,2,3,4,5} ;

// std::array<int,5>型の変数valueの値を投げる
throw value ;
~~~

この例では、`int`型、`double`型、`std::array<int,5>`型の値を投げている。

一度例外が投げられると、通常の実行はすっ飛ばされる。

以下は`0`を入力すると例外を投げるプログラムだ。

~~~cpp
int main()
{
    // 0を入力するなよ、絶対するなよ
    std::cout << "Don't type 0. >"s ;

    int input {} ;
    std::cin >> input ;

    /// 入力が0なら例外を投げる
    if ( input == 0 )
        throw 0 ;

    // 通常の処理
    std::cout << "Success!\n"s ;
}
~~~

このプログラムを実行すると、非`0`を入力した場合、`"Success!\n"`が出力される。`0`を入力した場合、例外が投げられる。例外が投げられると、通常の実行はすっ飛ばされる。エラー処理はしていないので、プログラムは終了する。

`std::array`や`std::vector`のメンバー関数`at(n)`は`n`が要素数を超える場合、例外を投げている。

~~~cpp
array::reference array::at( std::size_t n )
{
    if ( n >= size() )
        throw 何らかの値

    return storage[n] ;
}
~~~

投げる例外は、`std::out_of_range`というクラスの値だ。このクラスを完全に説明するのは現時点では難しいが、以下のように振る舞うと考えておこう。

~~~cpp
namespace std {

struct out_of_range
{
    // エラー内容の文字列を受け取るコンストラクター
    out_of_range( std::string const & ) ;
    // エラー内容の文字列を返すメンバー関数
    auto what() ;
} ;

}
~~~

とりあえず使ってみよう。

~~~cpp
int main()
{
    std::out_of_range err("I am error.") ;

    // I am error.
    std::cout << err.what() ;
}
~~~

コンストラクターでエラー内容を表現した文字列を受け取り、メンバー関数`what`でエラー内容の文字列を取得する。

必要な情報はすべて学んだ。あとはメンバー関数`at`を実装するだけだ。


~~~cpp
array::reference array::at( std::size_t n )
{
    if ( n >= size() )
        throw std::out_of_range("Error: Out of Range") ;

    return storage[n] ;
}
~~~

## 例外を捕まえる

現状では、エラーを発見して例外を投げたら即座にプログラムが終了してしまう。投げた例外を途中で捕まえて、プログラムを通常の実行に戻す機能がほしい。その機能が「例外のキャッチ」だ。

例外のキャッチには`try`キーワードと`catch`キーワードを使う。

~~~c++
try {
    // 例外を投げるコード
} catch( 型 名前 )
{
    エラー処理
}
~~~

`try {}`ブロックの中で投げられた例外は、`catch`で型が一致する場合にキャッチされる。例外がキャッチされた場合、`catch`のブロックが実行される。そして実行が再開される。


~~~cpp
int main()
{

    try {
        throw 123 ; // int型
    }
    // キャッチする
    catch( int e )
    {
        std::cout << e ;
    }

    // 実行される
    std::cout << "resumed.\n"s ;
}
~~~


`catch`の型と投げられた例外の型が一致しない場合は、キャッチしない。

~~~cpp
int main()
{
    try {
        throw 3.14 ; // double型
    }
    // キャッチしない
    catch( int e ) { }

    // 実行されない
    std::cout << "You won't read this.\n"s ;
}
~~~

`catch`は複数書くことができる。

~~~cpp
int main()
{
    try {
        throw "error"s ; // std::string型
    }
    // キャッチしない
    catch( int e ) { }
    // キャッチしない
    catch( double e ) { }
    // キャッチする
    catch( std::string & e )
    {
        std::cout << e ;
    }
}
~~~


`tryブロック`の中で投げられた例外は、たとえ複雑な関数呼び出しの奥底にある例外でもあますところなくキャッチされる。

~~~cpp
void f()
{
    throw 123 ;
}

void g() { f() ; } 
void h() { g() ; }


int main()
{
    try {
        h() ;
    }
    // キャッチされる
    catch( int e ) { }
}
~~~

関数`h`は関数`g`を呼び出し、関数`g`は関数`f`を呼び出し、関数`f`は例外を投げる。このように複雑な関数呼び出しの結果として投げられる例外もキャッチできる。

すでに学んだように、`std::array<T>::at`に範囲外のインデックスを渡したときは`std::out_of_range`クラスが例外として投げられる。これをキャッチしてみよう。

~~~cpp
int main()
{
    std::array<int, 1> a = {0} ;

    try { a[1000] ; }
    catch( std::out_of_range & e )
    {
        // エラー内容を示す文字列
        std::cout << e.what() ;
    }
}
~~~



## 例外による巻き戻し

例外が投げられた場合、その例外が投げられた場所を囲む`try`ブロックと対応する`catch`に到達するまで、関数呼び出しが巻き戻される。これを`スタックアンワインディング`(stack unwinding)という。

~~~cpp
void f() { throw 0 ; } 
void g() { f() ; }
void h() { g() ; }

int main()
{
    try { h() ; }
    catch( int e ) { }

}
~~~

この例では、関数`main`が関数`h`を呼び出し、その結果として最終的に関数`f`の中で例外が投げられる。投げられた例外は関数呼び出しを巻き戻して関数`main`の中の`try`ブロックまで到達し、対応する`catch`に捕まる。

もし関数`main`を抜けてもなお対応する`catch`がない場合はどうなるのか。

~~~cpp
int main()
{
    throw 0 ;
    // 対応するcatchがない
}
~~~

その場合、`std::terminate()`という関数が呼ばれる。この関数が呼ばれた場合、プログラムは終了する。

~~~cpp
int main()
{
    // プログラムは終了する
    std::terminate() ;
}
~~~

`tryブロック`はネストできる。その場合、対応する`catch`が見つかるまで巻き戻しが起こる。

~~~cpp
void f()
{
    try { throw 0 ; }
    catch ( double e ) { }
}

int main()
{
    try { // try 1
        try { // try 2
            f() ;
        } catch( std::string & e ) { }
    } catch ( int e )
    {
        // ここで捕まる
    }
}
~~~

上のコードは複雑な`tryブロック`のネストが行われている。プログラムがどのように実行されるのかを考えてみよう。

まず関数`main`が関数`f`を呼び出す。関数`f`は例外を投げる。関数`f`の中の`try`ブロックは対応する`catch`がないので関数`main`に巻き戻る。関数`main`の内側の`try`ブロック、ソースコードでは`// try 2` とコメントをしている`try`ブロックの`catch`には対応しない。さらに上の`try`ブロックに巻き戻る。`// try 1`の`tryブロック`の`catch`は`int`型なので、この`catch`に捕まる。

例外が投げられ、`スタックアンワインディング`による巻き戻しが発生した場合、通常のプログラムの実行は行われない。例えば以下のプログラムは何も出力しない。

~~~cpp
void f()
{
    throw 0 ;
    // 例外を投げたあとの実行
    std::cout << "function f\n"s ;
}

void g()
{
    f() ;
    // 関数fを呼んだあとの実行
    std::cout << "function g\n"s ;
}

int main()
{
    g() ;
    // 関数gを呼んだあとの実行
    std::cout << "function main\n"s ;
}
~~~

`スタックアンワインディング`中に通常の実行は行われないが、変数の破棄は行われる。これはとても重要だ。変数が破棄されるとき、デストラクターが実行されるのを覚えているだろうか。

~~~cpp
struct Object
{
    std::string name ;
    // コンストラクター
    Object( std::string const & name ) : name(name) 
    { std::cout << name << " is constructed.\n"s ; }

    // デストラクター
    ~Object()
    { std::cout << name << " is destructed.\n"s ; }
} ;

int main()
{
    // 変数objが構築される
    Object obj("obj"s) ;

    // 変数objが破棄される
}
~~~

実行結果

~~~
obj is constructed.
obj is destructed.
~~~

例外のスタックアンワインディングでは関数内の変数が破棄される。つまりデストラクターが実行される。

~~~cpp
void f()
{
    Object obj("f"s) ;
    throw 0 ;
}

void g()
{
    Object obj("g"s) ;
    f() ;
}

int main()
{
    Object obj("main"s) ;

    try {
        g() ;
    } catch( int e )
    {
        std::cout << "caught.\n"s ;
    }

}
~~~

このプログラムを実行した結果は以下のようになる。

~~~
main is constructed.
g is constructed.
f is constructed.
f is destructed.
g is destructed.
caught.
main is destructed.
~~~

なぜこの順番に出力されるか考えてみよう。

1. プログラムの実行は関数`main`から始まる。そのためまず`main`が構築される
2. 関数`main`は関数`g`を呼ぶ。`g`が構築される
3. 関数`g`は関数`f`を呼ぶ。`f`が構築される
4. 関数`f`は例外を投げるので、`f`は破棄される
5. 関数`g`に巻き戻ったが`catch`がないのでさらに巻き戻る。`g`が破棄される
6. 関数`main`に巻き戻ったところ対応する`catch`があるのでスタックアンワインディングは停止する
7. `caught.`が出力される
8. `main`が破棄される

例外が投げられると通常の実行は飛ばされるので、例外が投げられるかもしれない処理のあとに、例外の有無にかかわらず絶対に実行したい処理がある場合は、クラスのデストラクターに書くとよい。

C++20以降では、標準ライブラリに`std::scope_exit`が追加される予定だ。`std::scope_exit`は渡した関数オブジェクトをデストラクターで実行してくれる。

~~~cpp
int f()
{
    auto ptr = new ;
    std::scope_exit e( [&]{ delete ptr ; } ) ;

    // 処理
}
~~~

このように書くと、後続の処理で`return`で関数から戻ろうが、`throw`しようが、`delete ptr`が実行される。
