%% clreptcl.cls
%% Celon Pharma clinical report class: scrartcl w/ custom titlepage.
%% Personal texmf tree -- update-safe (not touched by tlmgr update koma-script).
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{clreptcl}[2026/09/14 v1.0 Celon Pharma clinical report class]

\LoadClassWithOptions{scrartcl}

% Lower margin reduced 30% vs. typearea default (DIV=10).
\addtolength{\textheight}{1.24cm}

% Room for the bigger titlepage logo in the header, without shifting body-page text.
\setlength{\headheight}{58pt}
\addtolength{\topmargin}{-41pt}

\RequirePackage{graphicx}

% Titlepage fields ----
\newcommand*{\@internalstudyno}{}
\newcommand*{\internalstudyno}[1]{\renewcommand*{\@internalstudyno}{#1}}
\newcommand*{\@protocolno}{}
\newcommand*{\protocolno}[1]{\renewcommand*{\@protocolno}{#1}}
\newcommand*{\@reportversion}{}
\newcommand*{\reportversion}[1]{\renewcommand*{\@reportversion}{#1}}
\newcommand*{\@authorplain}{}
\newcommand*{\authorplain}[1]{\renewcommand*{\@authorplain}{#1}}

% Titlepage ----
\renewcommand*\maketitle[1][1]{%
  \begingroup
  \thispagestyle{titlepage}%
  % Footer gap sized to one table row (\LARGE baselineskip + 6pt row sep), local to this page.
  \setlength{\footskip}{32.5pt}%
  % Extra space above the logo, local to this page.
  \addtolength{\topmargin}{1cm}%
  % \null blocks top-of-page glue discard so the \vfill below actually stretches.
  \null\vfill
  \begin{center}
    \usekomafont{title}{\huge \@title\par}
    \ifx\@subtitle\@empty\else
      \vspace{6pt}
      \usekomafont{subtitle}{\Large \@subtitle\par}
    \fi
  \end{center}
  \vfill
  \noindent
  \begin{tabular}{@{}p{0.48\linewidth}p{0.48\linewidth}@{}}
    Internal Study No. & {\bfseries\LARGE \@internalstudyno} \\[6pt]
    \ifx\@protocolno\@empty\else
    Protocol No. & {\bfseries\LARGE \@protocolno} \\[6pt]
    \fi
    Sponsor & Celon Pharma S.A. \\[6pt]
    Version & \@reportversion \\[6pt]
    Issue date & \@date \\[6pt]
    Author & \@authorplain \\[6pt]
    Author's signature & \\[6pt]
    ~ & ~ \\[6pt]
    ~ & ~ \\[6pt]
  \end{tabular}
  \clearpage
  \endgroup
  \setcounter{footnote}{0}%
}
