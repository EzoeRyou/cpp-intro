# ムーブの実装

ムーブ(move)とはコピー(copy)と対になる概念だ。ムーブというのはやや特殊なコピーとみなすこともできる。

ムーブの使い方とその内部の挙動についてはムーブの章で説明した。

実際に自作のクラスでムーブを実装するには、rvalueリファレンスの章で説明したrvalueリファレンス、値カテゴリー、テンプレートのフォワードリファレンスの詳細な理解が必要になる。

まだこの2つの章を読んでいない読者はこの章を理解する準備ができていない。一度だけしか読んでいない読者は完全に理解はできないだろうから、この章を読んだ後にもう一度立ち返って読み直すべきだ。

## コピーとムーブの判別

コピーはコピーコンストラクターとコピー代入演算子で実装する。

コピーはlvalueリファレンスを取る。通常はconstなlvalueリファレンス型を使う。

~~~cpp
struct X
{
    // コピーコンストラクター
    X( const X & ) ;
    // コピー代入演算子
    X & operator = ( const X & ) ;
} ;
~~~

ムーブはムーブコンストラクターとムーブ代入演算子で実装する。

ムーブはrvalueリファレンスを取る。

~~~cpp
struct X
{
    // ムーブコンストラクター
    X( X && ) ;
    // ムーブ代入演算子
    X & operator = ( X && ) ;
} ;
~~~

コピーとムーブの区別はlvalue/rvalueリファレンスで行われる。なぜこれで動くのかというと、rvalueリファレンスで束縛できる値は、

1. 無名の一時オブジェクト(prvalue)
2. 明示的にrvalueリファレンスにキャストされたオブジェクト(xvalue)

のどちらかだからだ。

~~~cpp
void f( const int & ) 
{
    std::cout << "lvalue\n"s ;
}
void f( int && )
{
    std::cout << "rvalue\n"s ;
}

int main()
{
    int object { } ;

    f( object ) ; // lvalue
    f( object + object ) ; // rvalue
    f( []{ return 0 ; }() ) ; // rvalue
    f( std::move(object) ) ; // rvalue
}
~~~

変数名を書いた式`object`を評価した結果はlvalueなのでlvalueと表示される。

変数を演算子`+`で加算する式`object + object`を評価した結果はprvalueなのでrvalueと表示される。

戻り値の型がint型のラムダ式を呼び出す式`[]{ return 0 ; }()`を評価した結果はprvalueなのでrvalueと表示される。

`std::move(object)`を評価したけかはxvalueなのでrvalueと表示される。

prvalueは無名の一時オブジェクトなので、その値はすぐに破棄される。どうせ破棄されるのであれば、所有権を横取りしてもよい。

xvalueはユーザーが明示的にrvalueリファレンスにキャストした値だ。明示的にrvalueリファレンスにキャストしたということは、ユーザーはその値について、それ以降興味がないという意思を示したことになる。なので、そのような値からは所有権を横取りしてもよい。

## ムーブの実装

以下のようなクラスにムーブを実装しよう。

~~~c++
template < typename T >
class dynamic_array
{
private :
    T * first ;
    T * last ;
public :
    dynamic_array( std::size_t size = 0 )
        : first( new T[size]), last( first + size )
    { }
    ~dynamic_array()
    { delete[] first ; }
} ;
~~~
