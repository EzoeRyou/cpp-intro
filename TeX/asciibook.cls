\ProvidesClass{asciibook}[2015/01/30]
\LoadClassWithOptions{jsbook}

\iftombow
% B5変形判 234 × 182 mm
\setlength\paperheight{234truemm}
\setlength\paperwidth{182truemm}
% 1行 46文字
\setlength{\textwidth}{46zw}
% 1ページ 38行
\setlength{\textheight}{38\baselineskip}
% 版面のアキ 小口から20ミリ
\setlength{\evensidemargin}{-3truemm}
\setlength{\oddsidemargin}{0truemm}
% ヘッダの空き調整
\addtolength{\topmargin}{-55pt}
\addtolength{\headsep}{10pt}
% フッタの空き調整
\setlength\footskip{2.5\baselineskip}
\addtolength{\textheight}{\baselineskip}
\else
% A4判 364 × 257 mm
\setlength\paperheight{364mm}
\setlength\paperwidth{257mm}
% 1行 46文字
\setlength{\textwidth}{46zw}
% 1ページ 45行
\setlength{\textheight}{45\baselineskip}
% 版面のアキ 左右中央
\setlength{\evensidemargin}{10.8truemm}
\setlength{\oddsidemargin}{10.8truemm}
% ヘッダの空き調整
\addtolength{\topmargin}{-55pt}
\addtolength{\headsep}{10pt}
% フッタの空き調整
\setlength\footskip{2.5\baselineskip}
\addtolength{\textheight}{\baselineskip}
\fi
%
% 印刷位置の調整
\advance\hoffset 0.0in
\advance\voffset 0.0in
%
% 見出しフォントを太ゴシック（新ゴ）にする
\renewcommand{\headfont}{\sffamily\bfseries\ebseries}
%
% \bfseries, \textbfのデフォルトをb（Bold）に再定義する
\renewcommand{\bfdefault}{b}
%
% 本文のヘッダ、フッタ
\def\ps@asciiheadings{%
  \def\@evenhead{%
    {\hskip 0truemm}
      \textcolor{black}{
        \underline{\hbox to 136truemm{\autoxspacing
          \small \textcolor{black}{\thepage}\ \ \ \ \leftmark \hfil}
        }%
      }
    }%
  \def\@oddhead{%
    {\hskip 0truemm}
      \textcolor{black}{
        \underline{\hbox to 136truemm{\autoxspacing
          \small \hfil \rightmark\ \ \ \ \textcolor{black}{\thepage}}
        }%
      }
    }%
}
% 前付けのヘッダ、フッタ
\def\ps@frontheadings{%
  \def\@evenhead{}%
  \def\@oddhead{}%
  \def\@oddfoot{\hfil \thepage}%
  \def\@evenfoot{\thepage \hfil}%
}
% 章トビラのヘッダ、フッタの指定
\def\ps@chapterheadings{%
  \def\@evenhead{}%
  \def\@oddhead{}%
  \def\@oddfoot{}%
  \def\@evenfoot{}%
}
% 索引のスタイル
\makeatletter
\def\ps@indexfoot{%
  \def\@oddfoot{%
        {\hbox to \fullwidth{\hfil \thepage}}}%
  \let\@oddhead\@empty
  \def\@evenfoot{%
        \hss {\hbox to \fullwidth{\thepage \hfil}}}%
  \let\@evenhead\@empty}
\makeatother
%
% 見出しのレイアウト
%
% 章
\makeatletter
\renewcommand{\chapter}{%
  % 章扉は改丁
  \cleardoublepage
  \plainifnotempty % 元: \thispagestyle{plain}
  \global\@topnum\z@
  \if@english \@afterindentfalse \else \@afterindenttrue \fi
  \secdef
    {\@omit@numberfalse\@chapter}%
    {\@omit@numbertrue\@schapter}}
\def\@makechapterhead#1{%
  \vbox to 88mm{      % 小見出しの天地：88ミリ
    \vspace*{20mm}    % 章番号の前は45mmあき
    {
      \parindent \z@  % 段落の字下げをゼロにする
      \raggedright    % 見出しの位置を決める: 左揃え
      \normalfont     % フォント設定をリセット
      % 章番号
      \ifnum \c@secnumdepth >\m@ne
        \if@mainmatter
          {\hskip 6.0mm}\Large\headfont \@chapapp\thechapter\@chappos
          \par\nobreak
          \vskip 5mm % 章番号の後ろは5mmあき
        \fi
      \fi
      \interlinepenalty\@M % ペナルティの設定
      % 章見出し
%      {\hskip 6.0mm}\huge \headfont #1\par\nobreak
      \hbox{{\hskip 6.0mm}\vbox{\huge \headfont #1\vss}}\par\nobreak
      \vskip 3\Cvs   % 見出しの後ろは3行あき
    }
  \vss
  }
} 
\def\@makeschapterhead#1{%
  %\vspace*{77mm}    % 章番号の前は85mmあき
  {
    \parindent \z@  % 段落の字下げをゼロにする
    \raggedright    % 見出しの位置を決める: 左揃え
    \normalfont     % フォント設定をリセット
    \interlinepenalty\@M % ペナルティの設定
    % 章見出し
    \huge \headfont #1\par\nobreak
    \vskip 3\Cvs}} % 見出しの後ろは3行あき
\makeatother
%
% 節
\makeatletter
\renewcommand{\section}{%
  \if@slide\clearpage\fi
  \@startsection{section}{1}{\z@}%
  {\Cvs \@plus.5\Cdp \@minus.2\Cdp}% 前アキ
  {.5\Cvs \@plus.3\Cdp}% 後アキ
  {\normalfont\Large\headfont\raggedright}}
\makeatother
%
% 小節
\makeatletter
\renewcommand{\subsection}{\@startsection{subsection}{2}{\z@}%
  {\Cvs \@plus.5\Cdp \@minus.2\Cdp}% 前アキ
  {.2\Cvs \@plus.3\Cdp}% 後アキ
  {\normalfont\large\headfont}}
\makeatother
%
% 小小節
\makeatletter
\renewcommand{\subsubsection}{\@startsection{subsubsection}{3}{\z@}%
  {\Cvs \@plus.5\Cdp \@minus.2\Cdp}%
  {\if@slide .5\Cvs \@plus.3\Cdp \else \z@ \fi}%
  {\normalfont\normalsize\headfont}}
\makeatother
%
% パラグラフ
\makeatletter
\newcommand{\jsParagraphMark}{■}
\renewcommand{\paragraph}{\@startsection{paragraph}{4}{\z@}%
  {0.5\Cvs \@plus.5\Cdp \@minus.2\Cdp}%
  %{\if@slide .5\Cvs \@plus.3\Cdp \else -1zw\fi}% 改行せず 1zw のアキ
  {\if@slide .5\Cvs \@plus.3\Cdp \else \z@ \fi}%
  %{\normalfont\normalsize\headfont\jsParagraphMark}}
  {\normalfont\normalsize\sffamily\bfseries}}
\makeatother
%
% ハイパーリンク付きの見出し
%
% 部
\newcommand{\hyperpart}[2]{
  \hyperdef{}{#1}{
    \part{\texorpdfstring{\hyperref[#1]{#2}}{#2}
    }\label{#1}
  }
%  \thispagestyle{chapterheadings}
}
%
% 章
\newcommand{\hyperchapter}[3]{
  \hyperdef{}{#1}{
    \chapter[#3]{\texorpdfstring{\hyperref[#1]{#2}}{#2}
    }\label{#1}
  }
  \thispagestyle{chapterheadings}
}
%
% 節
\newcommand{\hypersection}[2]{
  \hyperdef{}{#1}{
    \section{\texorpdfstring{\hyperref[#1]{#2}}{#2}
    }\label{#1}
  }
}
\newcommand{\hypersectionn}[2]{
  \hyperdef{}{#1}{
    \section*{\texorpdfstring{\hyperref[#1]{#2}}{#2}
    }\label{#1}
  }
}
%
% 小節
\newcommand{\hypersubsection}[2]{
  \hyperdef{}{#1}{
    \subsection{\texorpdfstring{\hyperref[#1]{#2}}{#2}
    }\label{#1}
  }
}
%
% 小々節
\newcommand{\hypersubsubsection}[2]{
  \hyperdef{}{#1}{
    \subsubsection{\texorpdfstring{\hyperref[#1]{#2}}{#2}
    }\label{#1}
  }
}
\newcommand{\hypersubsubsectionn}[2]{
  \hyperdef{}{#1}{
    \subsubsection*{\texorpdfstring{\hyperref[#1]{#2}}{#2}
    }\label{#1}
  }
}
%
% パラグラフ
\newcommand{\hyperparagraph}[2]{
  \hyperdef{}{#1}{
    \paragraph{\texorpdfstring{\hyperref[#1]{#2}}{#2}
    }\label{#1}
  }
}
%
% 目次のスタイルを少し変更　
\makeatletter
\newdimen\jsc@mpt
\newdimen\jsc@tocl@width
\renewcommand{\tableofcontents}{%
  \settowidth\jsc@tocl@width{\headfont\prechaptername\postchaptername}%
  \settowidth\@tempdima{\headfont\appendixname}%
  \ifdim\jsc@tocl@width<\@tempdima \setlength\jsc@tocl@width{\@tempdima}\fi
  \ifdim\jsc@tocl@width<2zw \divide\jsc@tocl@width by 2 \advance\jsc@tocl@width 1zw\fi
  \if@twocolumn
    \@restonecoltrue\onecolumn
  \else
    \@restonecolfalse
  \fi
  %\chapter*{\contentsname}%
  \section*{\contentsname}%
  \@mkboth{\contentsname}{}%
  \@starttoc{toc}%
  \if@restonecol\twocolumn\fi
}
\renewcommand*{\l@chapter}[2]{%
  \ifnum \c@tocdepth >\m@ne
    \addpenalty{-\@highpenalty}%
    \addvspace{1.0em \@plus\jsc@mpt}
    \begingroup
      \parindent\z@
      \rightskip\@tocrmarg
      \parfillskip-\rightskip
      \leavevmode\headfont
      % \if@english\setlength\@lnumwidth{5.5em}\else\setlength\@lnumwidth{4.683zw}\fi
      \setlength\@lnumwidth{\jsc@tocl@width}\advance\@lnumwidth 2.683zw
      \advance\leftskip\@lnumwidth \hskip-\leftskip
      #1\nobreak\hfil\nobreak\hbox to\@pnumwidth{\hss#2}\par
      \penalty\@highpenalty
    \endgroup
  \fi}
\renewcommand*{\l@section}{%
          \@tempdima\jsc@tocl@width \advance\@tempdima -1zw
          %\@dottedtocline{1}{\@tempdima}{3.683zw}}
          \@dottedtocline{1}{\@tempdima}{3zw}}
\renewcommand*{\l@subsection}{%
          %\@tempdima\jsc@tocl@width \advance\@tempdima 2.683zw
          \@tempdima\jsc@tocl@width \advance\@tempdima 1zw
          \@dottedtocline{2}{\@tempdima}{3.5zw}}
\makeatother

