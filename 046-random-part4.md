## サンプリング分布(sampling distributions)

サンプリング分布(sampling distributions)とは、標本から分布の特徴が分かっている場合に、その特徴を指定することにより、望みの分布を作り出す分布のことだ。

### 離散分布(`std::discrete_distribution<IntType>`)

#### 簡単な説明

離散分布(discrete distribution)は整数型の乱数$i$, $0 \leq i < n$を返す分布だ。例えば$n = 10$ならば、$0,1,2,3,4,5,6,7,8,9$の10個のうちのいずれかの整数値を乱数として返す。この際、乱数値として取りうる整数値一つ一つに、確率を設定できる。確率は$p_0, \dotsc, p_{n-1}$で設定し、$p_0$が$0$の確率, $p_1$が$1$の確率...$p_{n-1}$が$n$の確率となる。それぞれの乱数$i$は確率$\frac{p_i}{S}$で出現する。このとき$S$とはすべての確率の合計、つまり$S = p_0 + \dotsc + p_{n-1}$となる。確率$p_i$は`double`型で与える。

たとえば、`{1.0, 1.0, 1.0}`という確率群を渡した場合、離散分布は$0, 1, 2$のいずれかの乱数をそれぞれ$\frac{1.0}{3.0}$の確率で返す。

もし、`{1.0, 2.0, 3.0}`という確率群を渡した場合、離散分布は$0, 1, 2$のいずれかの乱数を返す。その時の確率は、$1$が$\frac{1}{6}$、$2$が$\frac{1}{3}$、$3$が$\frac{1}{2}$だ。

例えば公平な6面ダイスを作りたい場合、`{1.0, 1.0, 1.0, 1.0, 1.0, 1.0}`を指定すると$0 \leq i \leq 5$までの6個の乱数$i$がそれぞれ$\frac{1}{6}$の確率で生成される。この結果に`+1`すると$1 \leq i \leq 6$の乱数を得ることができる。

6の目だけ2倍高い確率で出るイカサマ6面ダイスを作りたい場合、`{1.0, 1.0, 1.0, 1.0, 1.0, 2.0}`を指定すると、0から4までの5つの目は$\frac{1}{7}$の確率で出現し、5だけは$\frac{2}{7}$の確率で出る乱数を作ることができる。

$S$はすべての確率の合計で、それぞれの値は$\frac{p_i}{S}$の確率で出る。なので、以下はすべて分布だ。

~~~
{1.0, 1.0, 1.0, 1.0, 1.0, 2.0}
{0.1, 0.1, 0.1, 0.1, 0.1, 0.2}
{2.0, 2.0, 2.0, 2.0, 2.0, 4.0}
~~~

#### 数学的な説明

`std::discrete_distribution<IntType>`は整数型の乱数$i$, $0 \leq i < n$を以下の離散確率関数に従って分布する。

$$
P(i \,|\, p_0, \dotsc, p_{n-1}) = p_i \text{ .}
$$

別に指定のない場合、分布パラメーターは$p_k = {w_k / S}$ for $k = 0, \dotsc, n - 1$として計算され、このとき値$w_k$は、一般に*ウエイト（wieght）*と呼ばれていて、値は非負数、非NaN、非無限でなければならない。さらに、以下の関係が成り立たねばならない。$0 < S = w_0 + \dotsb + w_{n - 1}$

#### 変数の宣言

`std::discrete_distribution`の変数を宣言するには3つの方法がある。いずれも`double`型の値を`n`個渡すための方法だ。

##### イテレーターのペア

変数の宣言。

~~~c++
std::discrete_distribution<IntType> d( firstW, lastW ) ;
~~~

`IntType`は整数型でデフォルトは`int`、`[firstW, lastW)`はイテレーターのペアで、`double`型に変換可能な値を参照している。

利用例。

~~~cpp
int main()
{
    std::array ps = {1.0, 2.0, 3.0} ;
    std::discrete_distribution d( std::begin(ps), std::end(ps) );

    std::mt19937 e ;
    d(e)
}
~~~

##### 初期化リスト

利用例。

~~~c++
std::discrete_distribution<IntType> d( {...} ) ;
std::discrete_distribution<IntType> d = {...} ;
~~~

`...`には`double`型の浮動小数点数を指定する

利用例。

~~~cpp
int main()
{
    std::discrete_distribution d( { 1.0, 2.0, 3.0 } );
    // もしくは
    // ... d = { 1.0, 2.0, 3.0 } ;

    std::mt19937 e ;
    d(e)
}
~~~

##### 個数、デルタ、関数

このコンストラクターは以下のように宣言されている。

~~~c++
template<class UnaryOperation>
    discrete_distribution(size_t nw, double xmin, double xmax, UnaryOperation fw);
~~~

`UnaryOperation`はひとつの実引数を取る関数オブジェクトで戻り値の型は`double`型に変換できること。さらに、`double`型は`UnaryOperation`の引数に変換可能なこと。もし$nw = 0$の場合は、$n = 1$とする。それ以外の場合、$n = \tcode{nw}$とする。このとき、$0 < \delta = (\tcode{xmax} - \tcode{xmin}) / n$となる関係が満たされなければならない。

もし$nw = 0$ならば$w_0 = 1$。それ以外の場合、$k = 0, \dotsc, n - 1$に対して、$w_k = \tcode{fw}(\tcode{xmin} + k \cdot \delta + \delta / 2)$とする。`fw`は`n`回を超えて呼ばれることはない。

~~~cpp
int main()
{
    std::discrete_distribution d( 5, 0.0, 1.0, [](auto x){
        std::cout << x << '\n' ;
        if ( x < 0.3 )
            x = 0.3 ;
        if ( x > 0.8 )
            x = 0.8 ;
        return x ;
    } );
}
~~~

この`d`は、

~~~c++
std::discrete_distribution d = {0.3, 0.3, 0.5, 0.7, 0.8 } ;
~~~

と初期化されたものと同じように初期化される。

#### 初期化パラメーターの確認

`std::discrete_distribution`の内部状態はメンバー関数`probabilities`で取得できる。戻り値の型は`std::vector<double>`で、指定した確率群が要素になっている。

~~~cpp
int main()
{
    std::discrete_distribution d = { 1.0, 2.0, 3.0 } ;
    auto v = d.probabilities() ;
    // vは{1.0, 2.0, 3.0}
}
~~~

#### 応用例

以下は6の目が2倍の確率で出るイカサマ6面ダイスの実装だ。

~~~cpp
template < typename Engine >
int roll_dice( Engine & e )
{
    std::discrete_distribution d = { 1.0, 1.0, 1.0, 1.0, 1.0, 2.0 } ;
    return d(e) + 1 ;
}
~~~

### 区分定数分布(`std::piecewise_constant_distribution<RealType>`)

#### 簡単な説明

区分定数分布(piecewise constant distribution)とは、区分と、区分ごとの確率を指定し、いずれかの区分の範囲の値に一様分布させる分布だ。

ひとつの区分は`double`型の値2つ$b_i, b_{i+1}$で与える。このとき区分の乱数$x$の範囲は$[b_i, b_{i+1})$、もしくは$b_i \leq x < b_{i+1}$だ。$n$個の値を指定すると、$n-1$個の区分を指定したことになる。

例えば`{0.0, 1.0}`という2つの`double`型の値をつかって1つの区分を与えた場合、これは$0.0 \leq x < 1.0$という値の範囲の区分である。`{0.0, 1.0, 2.0}`という3つの`double`型の値は2つの区分になり、それぞれ$0.0 \leq x < 1.0$, $1.0 \leq x < 2.0$になる。

一般に、$n$個の`double`型の値$b_0, \dotsc, b_n$で$n-1$個の区分を表現する。このとき、$b_i < b_{i+1}$が$i = 0, \dotsc, n-1$までの$i$について成り立たなければならない。つまり区分を指定する`double`型の値は、後続の値より小さくなければならないということだ。

以下は正しい区分の指定だ。

~~~
{1.0, 2.0, 100.0, 999.999}
{-1.0, 1.0, 2.0}
{-5.0, -4.0, -3.1}
~~~

以下は正しくない区分の指定だ。

~~~
{1.0, 0.0}
~~~

これは$b_0 > b_1$なので正しくない。

それぞれの区分$[b_i, b_{i+1})$に対して確率$p_i$を`double`型で指定する。$n$個の$b_i$によって$n-1$個の区分を指定し、それぞれに対して1つづつ確率を設定するので、確率の数は$n-1$個だ。


例えば`{0.0, 1.0}`という1つの区分と`{1.0}`という1つの確率を与えた場合、$0.0 \leq x < 1.0$の範囲の乱数$x$が生成される。

`{0.0, 1.0, 10.0}`という2つの区分と、`{1.0, 2.0}`という2つの確率を与えた場合、$\frac{1}{3}$の確率で$0.0 \leq x < 1.0$の範囲に一様分布した乱数になり、$\frac{2}{3}$の確率で$1.0 \leq x < 10.0$の範囲に一様分布した乱数になる。

#### 数学的な説明

`std::piecewise_constant_distribution<RealType>`は浮動小数点数型の乱数$x$, $b_0 \leq x < b_n$を以下の確率密度関数に従って、それぞれの部分区間(subinterval)$[b_i, b_{i+1}$の間で一様に分布させる。

$$
p(x \,|\, b_0, \dotsc, b_n, \; \rho_0, \dotsc, \rho_{n-1}) = \rho_i
   \text{ , for $b_i \le x < b_{i+1}$.} 
$$

この分布の区間境界(interval boundaries)ともいう$n+1$分布パラメーター$b_i$はすべての$i = 0, \dotsc, n - 1$に対して関係$b_i < b_{i + 1}$を満たさねばならない。別途指定なき場合、残りの$n$分布パラメーターは以下のように計算される。

$$
\rho_k = \frac{w_k}{S \cdot (b_{k+1}-b_k)} \text{ for } k = 0, \dotsc, n - 1 \text{ ,} 
$$

一般にウエイト(weight)と呼ばれている値$w_k$は、非負数、非NaN、非無限でなければならない。さらに、以下の関係を満たさなければならない。

$0 < S = w_0 + \dotsb + w_{n-1}$

#### 変数の宣言

`std::piecewise_constant_distribution`では、`double`型の値の集合を2つ渡す必要がある。ひとつは区間を指定するための$N$個の`double`型に変換可能な値で、もう一つは区間ごとの確率を指定するための$N-1$個の`double`型に変換可能な値だ。

##### イテレーターによる指定

イテレーターで区間と確率を指定するコンストラクターは以下の通り

~~~c++
template<class InputIteratorB, class InputIteratorW>
piecewise_constant_distribution(InputIteratorB firstB, Inp
~~~

`[firstB, lastB)`は区間を指定するための$N$個の値を参照する入力イテレーターのペアだ。`firstW`はそれぞれの区間の確率を指定する$N-1$個の値を参照する入力イテレーターの先頭だ。`lastW`がないのは、確率の個数は$N-1$個であると分かっているからだ。

もし`[firstB, lastB)`のサイズが1以下の場合、区間は`[0.0, 1.0)`になり、確率は$\frac{1}{1}$になる。


##### 利用例

~~~cpp
int main()
{
    std::array bs = {-1.0, 1.0, 2.0 } ;
    std::array ps = { 1.0, 5.0 } ;
    std::piecewise_constant_distribution d( std::begin(bs), std::end(bs), std::begin(ps) ) ;

    std::mt19937 e ;
    d(e) ;
}
~~~

`bs`は区間を指定する値の集合、`ps`は区間ごとの確率だ。

区間は`[-1.0, 1.0)`と`[1.0, 2.0)`の2つ。確率はそれぞれ$\frac{1}{6}$、$\frac{5}{6}$だ。

区間を表現する値が足りない場合は以下の通り。

~~~cpp
int main()
{
    // 区間を指定すべき値が足りない
    std::array bs = { 1.0 } ;
    std::array ps = { 1.0, 5.0 } ;
    // 引数は無視される。
    // 区間は[0.0, 1.0), 確率は100%
    std::piecewise_constant_distribution d( std::begin(bs), std::end(bs), std::begin(ps) ) ;
}
~~~

##### 初期化リストと関数による指定

初期化リストと関数を指定するコンストラクターは以下の通り。

~~~c++
template<class UnaryOperation>
piecewise_constant_distribution(initializer_list<RealType> bl, UnaryOperation fw);
~~~

イテレーターのペアと同じく、区間は`[bl.begin(), bl.end())`で指定する。

確率は$k = 0, \dotsc, n - 1$について、$w_k = \tcode{fw}\bigl(\bigl(b_{k+1} + b_k\bigr) / 2\bigr)$とする。

`bl.size()`が1以下の場合、区間は`[0.0, 1.0)`になり、確率は$\frac{1}{1}$になる。


##### 利用例

~~~cpp
int main()
{
    std::piecewise_constant_distribution d(
        {1.0, 2.0, 3.0, 4.0, 5.0},
        []( auto x )
        { return x ; }
    ) ;
}
~~~

この場合、区間は`[1.0, 2.0)`, `[2.0, 3.0)`, '[3.0, 4.0)', '[4.0, 5.0)'の4個になり、確率は`{1.5, 2.5, 3.5, 4.5}`となる。


