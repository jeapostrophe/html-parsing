#lang scribble/doc
@; THIS FILE IS GENERATED
@(require scribble/manual)
@(require (for-label sxml/html))
@(require (for-label racket))
@title[#:version "0.3"]{@bold{html-parsing}: Permissive Parsing of HTML to SXML/xexp in Racket}
@author{Neil Van Dyke}


License: @seclink["Legal" #:underline? #f]{LGPL 3} @(hspace 1) Web: @link["http://www.neilvandyke.org/racket-html-parsing/" #:underline? #f]{http://www.neilvandyke.org/racket-html-parsing/}

@defmodule[sxml/html]

      

@section{Introduction}


      

The @tt{html-parsing} library provides a permissive HTML parser.  The parser is useful for software agent extraction of information from Web pages, for programmatically transforming HTML files, and for implementing interactive Web browsers.  @tt{html-parsing} emits @link["http://www.neilvandyke.org/racket-xexp/"]{SXML/@emph{xexp}}, so that conventional invalid HTML may be processed with XML tools such as @link["http://pair.com/lisovsky/query/sxpath/"]{SXPath}.  Like Oleg Kiselyov's @link["http://pobox.com/~oleg/ftp/Scheme/xml.html#HTML-parser"]{SSAX-based HTML parser}, @tt{html-parsing} provides a permissive tokenizer, but @tt{html-parsing} extends this by attempting to recover syntactic structure.


      

The @tt{html-parsing} parsing behavior is permissive in that it accepts erroneous HTML, handling several classes of HTML syntax errors gracefully, without yielding a parse error.  This is crucial for parsing arbitrary real-world Web pages, since many pages actually contain syntax errors that would defeat a strict or validating parser.  @tt{html-parsing}'s handling of errors is intended to generally emulate popular Web browsers' interpretation of the structure of erroneous HTML.  We euphemistically term this kind of parse ``pragmatic.''


      

@tt{html-parsing} also has some support for XHTML, although XML namespace qualifiers are accepted but stripped from the resulting SXML/@emph{xexp}. Note that @emph{valid} XHTML input might be better handled by a validating XML parser like Kiselyov's @link["http://pobox.com/~oleg/ftp/Scheme/xml.html#XML-parser"]{SSAX}.


      

This package obsoletes @link["http://www.neilvandyke.org/racket-xexp/"]{HtmlPrag}.


    
      

@section{Interface}


      

@defproc[ (html->xexp (input any/c)) any/c]{
          

Permissively parse HTML from @schemevarfont{input}, which is either an input port or a string, and emit an SXML/@emph{xexp} equivalent or approximation.  To borrow and slightly modify an example from Kiselyov's discussion of his HTML parser:


          

@SCHEMEBLOCK[
(html->xexp
 "<html><head><title></title><title>whatever</title></head><body>
<a href=\"url\">link</a><p align=center><ul compact style=\"aa\">
<p>BLah<!-- comment <comment> --> <i> italic <b> bold <tt> ened</i>
still &lt; bold </b></body><P> But not done yet...")
==>
(*TOP* (html (head (title) (title "whatever"))
             (body "\n"
                   (a (\@ (href "url")) "link")
                   (p (\@ (align "center"))
                      (ul (\@ (compact) (style "aa")) "\n"))
                   (p "BLah"
                      (*COMMENT* " comment <comment> ")
                      " "
                      (i " italic " (b " bold " (tt " ened")))
                      "\n"
                      "still < bold "))
             (p " But not done yet...")))
]


          

Note that, in the emitted SXML/@emph{xexp}, the text token @tt{"still < bold"} is @emph{not} inside the @tt{b} element, which represents an unfortunate failure to emulate all the quirks-handling behavior of some popular Web browsers.


        }

    
      

@section{History}


      

@itemize[

@item{Version 0.3 --- 2011-08-27 - PLaneT @tt{(1 2)}
            

Converted test suite from Testeez to Overeasy.


          }


@item{Version 0.2 --- 2011-08-27 - PLaneT @tt{(1 1)}
            

Fixed embarrassing bug due to code tidying.  Thanks to Danny Yoo for reporting.


          }


@item{Version 0.1 --- 2011-08-21 - PLaneT @tt{(1 0)}
            

Part of forked development from HtmlPrag.


          }



]


    

@section[#:tag "Legal"]{Legal}



Copyright (c) 2003--2011 Neil Van Dyke.  This program is Free Software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 3 of the License (LGPL 3), or (at your option) any later version.  This program is distributed in the hope that it will be useful, but without any warranty; without even the implied warranty of merchantability or fitness for a particular purpose.  See http://www.gnu.org/licenses/ for details.  For other licenses and consulting, please contact the author.



@italic{@smaller{Standard Documentation Format Note: The API
signatures in this documentation are likely incorrect in some regards, such as
indicating type @tt{any/c} for things that are not, and not indicating when
arguments are optional.  This is due to a transitioning from the Texinfo
documentation format to Scribble, which the author intends to finish
someday.}}
