## 正規分布

### 正規分布(`std::normal_distribution<RealType>`)

`std::normal_distribution<RealType>`は浮動小数点数型の乱数$x$を以下の確率密度関数に従って分布する。

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

変数の宣言:

~~~c++
std::normal_distribution<RealType> d( mean, stddev ) ;
~~~

`RealType`は浮動小数点数型でデフォルトは`double`。`mean`, `stddev`は浮動小数点数型。`mean`は平均。`stddev`は標準偏差で値の範囲は$0 < \text{stddev}$。

使い方:

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

変数の宣言:

~~~c++
std::lognormal_distribution<RealType> d( m, s ) ;
~~~

`RealType`は浮動小数点数型でデフォルトは`double`。`m`, `s`は`RealType`型。値の範囲は$0 < s$。

使い方:

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

変数の宣言:

~~~c++
std::chi_squared_distribution<RealType> d( n ) ;
~~~

`RealType`は浮動小数点数型でデフォルトは`double`。`n`は`RealType`型。値の範囲は$0 < n$。

使い方:

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

変数の宣言:

~~~c++
std::cauchy_distribution<RealType> d( a, b ) ;
~~~

`RealType`は浮動小数点数型でデフォルトは`double`。`a`, `b`は`RealType`型。値の範囲は$0 < b$。

使い方:

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

### フィッシャーの$F$分布(`std::fisher_f_distribution<RealType>`)

フィッシャーの$F$分布(Fisher's $F$-distribution)の名前は数学者サー・ロナルド・エイルマー・フィッシャー(Sir Ronald Aylmer Fisher)に由来する。

`std::fisher_f_distribution<RealType>`は浮動小数点数の乱数$x > 0$を以下の関数密度関数に従って分布する。

$$
p(x\,|\,m,n) = \frac{\Gamma\big((m+n)/2\big)}{\Gamma(m/2) \; \Gamma(n/2)}
     \cdot \left(\frac{m}{n}\right)^{m/2}
     \cdot x^{(m/2)-1}
     \cdot \left(1 + \frac{m x}{n}\right)^{-(m + n)/2}
     \text{ .}
$$

変数の宣言:

~~~c++
std::fisher_f_distribution<RealType> d( m, n ) ;
~~~


`RealType`は浮動小数点数型でデフォルトは`dobule`。`m`, `n`は`RealType`型。値の範囲は$0 < m$ かつ $0 < n$。

使い方:

~~~cpp
int main()
{
    std::fisher_f_distribution d( 1.0 ) ;
    d.n() ; // 1.0

    std::mt19937 e ;
    d(e) ;
}
~~~

### スチューデントの$t$分布(`std::student_t_distribution<RealType>`)

スチューデントの$t$分布(Student's $t$-distribution)はウィリアム・シーリー・ゴセット(William Sealy Gosset)によって考案された。当時、ウィリアムはギネス醸造所で働いていたが、ギネスは従業員に科学論文を発表することを禁じていたために、ウィリアムはスチューデントという偽名で発表した。

`std::student_t_distribution<RealType>`は浮動小数点数型の乱数$x$を以下の確率密度関数に従って分布する。

$$
p(x\,|\,n) = \frac{1}{\sqrt{n \pi}}
     \cdot \frac{\Gamma\big((n+1)/2\big)}{\Gamma(n/2)}
     \cdot \left(1 + \frac{x^2}{n} \right)^{-(n+1)/2}
     \text{ .}
$$

変数の宣言:

~~~c++
std::student_t_distribution<RealType> d( n ) ;
~~~

`RealType`は浮動小数点数型でデフォルトは`double`。`n`は`RealType`型で、値の範囲は$0 < n$。

使い方:

~~~cpp
int main()
{
    std::student_t_distribution d( 1.0 ) ;
    d.n() ; // 1.0

    std::mt19937 e ;
    d(e) ;
}
~~~

