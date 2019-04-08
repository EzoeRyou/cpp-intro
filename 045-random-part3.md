## 正規分布

### 正規分布(`std::normal_distribution<RealType>`)

`std::normal_distribution<RealType>`は浮動小数点数型の乱数$x$
以下の確率密度関数に従って分布する。

$$
 (x\,|\,\mu,\sigma)
      = \frac{1}{\sigma \sqrt{2\pi}}
        \cdot
        % e^{-(x-\mu)^2 / (2\sigma^2)}
        \exp{\left(- \, \frac{(x - \mu)^2}
                             {2 \sigma^2}
             \right)
            }
 \text{ .}
$$

分布パラメーターのうちの$\mu$と$\sigma$は、それぞれ分布の平均(mean)、標準偏差(standard deviation)とも呼ばれている。

変数の宣言。

~~~c++
std::normal_distribution<RealType> d( mean, stddev ) ;
~~~

`RealType`は浮動小数点数型でデフォルトは`double`。`mean`, `stddev`は浮動小数点数型。`mean`は平均。`stddev`は標準偏差で値の範囲は$0 < \text{stddev}$

使い方。

~~~cpp
int main()
{
    std::mt19937 e ;
    std::normal_distribution d( 0.0, 1.0 ) ;
    d.mean() ; // 0.0
    d.stddev() ; // 1.0

    for ( int i = 0 ; i != 10 ; ++i )
    {
        std::cout << d(e) << ", "sv ;
    }  
}
~~~

### 対数正規分布(`std::lognormal_distribution<RealType>`)

`std::lognormal_distribution<RealType>`は浮動小数点数の乱数$x > 0$を以下の確率密度関数に従って分布する。

$$
p(x\,|\,m,s) = \frac{1}{s x \sqrt{2 \pi}}
     \cdot \exp{\left(-\frac{(\ln{x} - m)^2}{2 s^2}\right)}
     \text{ .}
$$

変数の宣言。

~~~c++
std::lognormal_distribution<RealType> d( m, s ) ;
~~~

`RealType`は浮動小数点数型でデフォルトは`double`。`m`, `s`は`RealType`型。値の範囲は$0 < s$

使い方。

~~~cpp
int main()
{
    std::mt19937 e ;
    std::lognormal_distribution d( 0.0, 1.0 ) ;
    d.m() ; // 0.0
    d.s() ; // 1.0

    for ( int i = 0 ; i != 10 ; ++i )
    {
        std::cout << d(e) << ", "sv ;
    }  
}
~~~

### カイ二乗分布(`std::chi_squared_distribution<RealType>`)

`std::chi_squared_distribution<RealType>`は浮動小数点数型の乱数$x > 0$を以下の確率密度関数に従って分布する。

$$
p(x\,|\,n) = \frac{x^{(n/2)-1} \cdot e^{-x/2}}{\Gamma(n/2) \cdot 2^{n/2}} \text{ .} 
$$

変数の宣言。

~~~c++
std::chi_squared_distribution<RealType> d( n ) ;
~~~

`RealType`は浮動小数点数型でデフォルトは`double`。`n`は`RealType`型。値の範囲は$0 < n$

使い方。

~~~cpp
int main()
{
    std::mt19937 e ;
    std::chi_squared_distribution d( 1.0 ) ;
    d.n() ; // 1.0

    for ( int i = 0 ; i != 10 ; ++i )
    {
        std::cout << d(e) << ", "sv ;
    }  
}
~~~

### コーシー分布(`std::cauchy_distribution<RealType>`)

`std::cauchy_distribution<RealType>`は浮動小数点数型の乱数$x$を以下の確率密度関数に従って分布する。

$$
p(x\,|\,a,b) = \left(\pi b \left(1 + \left(\frac{x-a}{b} \right)^2 \, \right)\right)^{-1} \text{ .} 
$$

変数の宣言。

~~~c++
std::cauchy_distribution<RealType> d( a, b ) ;
~~~

`RealType`は浮動小数点数型でデフォルトは`double`。`a`, `b`は`RealType`型。値の範囲は$0 < b$

使い方。

~~~cpp
int main()
{
    std::mt19937 e ;
    std::chi_squared_distribution d( 0.0, 1.0 ) ;
    d.a() ; // 0.0
    d.b() ; // 1.0

    for ( int i = 0 ; i != 10 ; ++i )
    {
        std::cout << d(e) << ", "sv ;
    }  
}
~~~

### フィッシャーのF分布(`std::fisher_f_distribution<RealType>`)

