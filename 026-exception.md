# 傲慢なエラー処理: 例外

## 例外を投げる

`std::array`の実装方法はほとんど解説した。読者は`std::array`の実装方法を知り、確固たる自信のもとに`std::array`を使えるようになった。ただし、ひとつだけ問題がある。

"std::array"のユーザーはあらかじめ設定した要素数を超える範囲の要素にアクセスすることができてしまう。

~~~c++
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

~~~c++
reference array::operator [] ( std::size_t i )
{
    // 範囲外チェック
    if ( i >= size() )
    {
        // エラー検出
        // しかし何をreturnすればいいのだろう。
    }

    return storage[i] ;
}
~~~

`operator []`は伝統的にエラーチェックをしない要素アクセスをするものだ。

`vector`で一番最初に説明した要素アクセスの方法であるメンバー関数`at`を覚えているだろうか。実はメンバー関数`at`はエラーチェックをする。試してみよう。

~~~c++
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

どうやらエラーメッセージのようだ。わかりづらいメッセージだが、なんとなく言わんとすることはわかる。`_Nm`がarrayの要素数で、`__n`がメンバー関数`at`に渡した実引数だ。要素数`_Nm`よりも`__n`が大きい。

このエラー処理は、「例外」を使って行われる。

例外は通常の処理をすっ飛ばして特別なエラー処理をする機能だ。何もエラー処理をしない場合、プログラムは終了する。例外を発生させることを、「例外を投げる」という。

例外は文字通り投げるという意味の`throw`キーワードを使い、何らかの値を投げる(throw)。

~~~c++
// int型の値123を投げる
throw 123 ;

// double型の値3.14を投げる
throw 3.14 ;

std::array<int, 5> value = {1,2,3,4,5} ;

// std::array<int,5>型の変数valueの値を投げる
throw value ;
~~~

この例では、int型、double型、`std::array<int,5>`型の値を投げている。

一度例外が投げられると、通常の実行はすっ飛ばされる。

以下は0を入力すると例外を投げるプログラムだ。

~~~cpp
int main()
{
    // 0を入力するなよ
    std::cout << "Don't type 0. >"s ;

    int input {} ;
    std::cin >> input ;

    /// 入力が0なら例外を投げる
    if ( input == 0 )
        throw 0 ;

    // 通常の処理
    std::cout << "Succcess!\n"s ;
}
~~~

このプログラムを実行すると、0以外を入力したならば"Success!\n"が出力される。0を入力した場合、例外が投げられる。例外が投げられると、通常の実行はすっ飛ばされる。エラー処理はしていないので、プログラムは終了する。

`std::array`や`std::vector`のメンバー関数`at(n)`は`n`が要素数を超える場合、例外を投げている。

~~~c++
array::reference array::at( std::size_t n )
{
    if ( n >= size() )
        throw 何らかの値

    return storage[n] ;
}
~~~

投げる例外は、`std::out_of_range`というクラスの値だ。このクラスを完全に説明するのは現時点では難しいが、以下のように振る舞うと考えておこう。

~~~c++
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

必要な情報は全て学んだ。あとはメンバー関数`at`を実装するだけだ。


~~~c++
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

## 例外による実行の巻き戻し
