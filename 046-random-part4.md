## サンプリング分布(sampling distributions)

サンプリング分布(sampling distributions)とは、標本から分布の特徴が分かっている場合に、その特徴を指定することにより、望みの分布を作り出す分布のことだ。

### 離散分布(`std::discrete_distribution<IntType>`)

#### 簡単な説明

離散分布(discrete distribution)は整数型の乱数$i$, $0 \leq i < n$を返す分布だ。例えば$n = 10$ならば、$0,1,2,3,4,5,6,7,8,9$の10個のうちのいずれかの整数値を乱数として返す。この際、乱数値として取りうる整数値一つ一つに、確率を設定できる。確率は$p_0, \dotsc, p_{n-1}$で設定し、$p_0$が$0$の確率, $p_1$が$1$の確率...$p_{n-1}$が$n$の確率となる。それぞれの乱数$i$は確率$\frac{p_i}{S}$で出現する。このとき$S$とはすべての確率の合計、つまり$S = p_0 + \dotsc + p_{n-1}$となる。確率$p_i$は`double`型で与える。

たとえば、`{1.0, 1.0, 1.0}`という確率群を渡した場合、離散分布は$0, 1, 2$のいずれかの乱数をそれぞれ$\frac{1.0}{3.0}$の確率で返す。

もし、`{1.0, 2.0, 3.0}`という確率群を渡した場合、離散分布は$0, 1, 2$のいずれかの乱数を返す。その時の確率は、$1$が$\frac{1}{6}$、$2$が$\frac{1}{3}$、$3$が$\frac{1}{2}$だ。

例えば公平な6面ダイスを作りたい場合、`{1.0, 1.0, 1.0, 1.0, 1.0, 1.0}`を指定すると$0 \leq i \leq 5$までの6個の乱数$i$がそれぞれ$\frac{1}{6}$の確率で生成される。この結果に`+1`すると$1 \leq i \leq 6$の乱数を得ることができる。

6の目だけ2倍高い確率で出るイカサマ6面ダイスを作りたい場合、`{1.0, 1.0, 1.0, 1.0, 1.0, 2.0}`を指定すると、0から4までの5つの目は$\frac{1}{7}$の確率で出現し、5だけは$\frac{2}{7}$の確率で出る乱数を作ることができる。

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

##### 初期化パラメーターの確認

`std::discrete_distribution`の内部状態はメンバー関数`probabilities`で取得できる。戻り値の型は`std::vector<double>`で、指定した確率群が要素になっている。

~~~cpp
int main()
{
    std::discrete_distribution d = { 1.0, 2.0, 3.0 } ;
    auto v = d.probabilities() ;
    // vは{1.0, 2.0, 3.0}
}
~~~
