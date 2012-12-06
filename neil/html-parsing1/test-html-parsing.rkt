#lang racket/base
;; See file "html-parsing.rkt" for legal info.
;; $Id: test-html-parsing.rkt,v 1.8 2011/08/28 03:48:35 neilpair Exp $

(require neil/overeasy1/main
         "html-parsing.rkt")

(with-test-section
 #:id 'test-html-parsing

 (test (html->xexp "<a>>") '(*TOP* (a ">")))
 (test (html->xexp "<a<>") '(*TOP* (a "<" ">")))

 (test (html->xexp "<>")      '(*TOP* "<" ">"))
 (test (html->xexp "< >")
       ;; `(*TOP* "<" ">")
       '(*TOP* "<" " " ">"))
 (test (html->xexp "< a>")
       ;; `(*TOP* (a))
       '(*TOP*  "<" " a" ">"))
 (test (html->xexp "< a / >")
       ;; `(*TOP* (a))
       '(*TOP* "<" " a / " ">"))

 (test (html->xexp "<a<")  '(*TOP* (a "<")))
 (test (html->xexp "<a<b") '(*TOP* (a (b))))

 (test (html->xexp "><a>") '(*TOP* ">" (a)))

 (test (html->xexp "</>") '(*TOP*))

 (test (html->xexp "<\">") '(*TOP* "<" "\"" ">"))

 (test (html->xexp (string-append "<a>xxx<plaintext>aaa" "\n"
                                  "bbb" "\n"
                                  "c<c<c"))
       `(*TOP*
         (a "xxx" (plaintext ,(string-append "aaa" "\n")
                             ,(string-append "bbb" "\n")
                             "c<c<c"))))

 (test (html->xexp "aaa<!-- xxx -->bbb")
       `(*TOP*
         "aaa" (*COMMENT* " xxx ")   "bbb"))

 (test (html->xexp "aaa<! -- xxx -->bbb")
       `(*TOP*
         "aaa" (*COMMENT* " xxx ")   "bbb"))

 (test (html->xexp "aaa<!-- xxx --->bbb")
       `(*TOP*
         "aaa" (*COMMENT* " xxx -")  "bbb"))

 (test (html->xexp "aaa<!-- xxx ---->bbb")
       `(*TOP*
         "aaa" (*COMMENT* " xxx --") "bbb"))

 (test (html->xexp "aaa<!-- xxx -y-->bbb")
       `(*TOP*
         "aaa" (*COMMENT* " xxx -y") "bbb"))

 (test (html->xexp "aaa<!----->bbb")
       `(*TOP*
         "aaa" (*COMMENT* "-")       "bbb"))

 (test (html->xexp "aaa<!---->bbb")
       `(*TOP*
         "aaa" (*COMMENT* "")        "bbb"))

 (test (html->xexp "aaa<!--->bbb")
       `(*TOP* "aaa" (*COMMENT* "->bbb")))

 (test (html->xexp "<hr>")   `(*TOP* (hr)))
 (test (html->xexp "<hr/>")  `(*TOP* (hr)))
 (test (html->xexp "<hr />") `(*TOP* (hr)))

 (test (html->xexp "<hr noshade>")
       `(*TOP* (hr (@ (noshade)))))
 (test (html->xexp "<hr noshade/>")
       `(*TOP* (hr (@ (noshade)))))
 (test (html->xexp "<hr noshade />")
       `(*TOP* (hr (@ (noshade)))))
 (test (html->xexp "<hr noshade / >")
       `(*TOP* (hr (@ (noshade)))))
 (test (html->xexp "<hr noshade=1 />")
       `(*TOP* (hr (@ (noshade "1")))))
 (test (html->xexp "<hr noshade=1/>")
       `(*TOP* (hr (@ (noshade "1/")))))

 (test (html->xexp "<q>aaa<p/>bbb</q>ccc</p>ddd")
       `(*TOP* (q "aaa" (p) "bbb") "ccc" "ddd"))

 (test (html->xexp "&lt;") `(*TOP* "<"))
 (test (html->xexp "&gt;") `(*TOP* ">"))

 (test (html->xexp "Gilbert &amp; Sullivan")
       `(*TOP* "Gilbert & Sullivan"))
 (test (html->xexp "Gilbert &amp Sullivan")
       `(*TOP* "Gilbert & Sullivan"))
 (test (html->xexp "Gilbert & Sullivan")
       `(*TOP* "Gilbert & Sullivan"))

 (test (html->xexp "Copyright &copy; Foo")
       `(*TOP* "Copyright "
               (& copy)
               " Foo"))
 (test (html->xexp "aaa&copy;bbb")
       `(*TOP*
         "aaa" (& copy) "bbb"))
 (test (html->xexp "aaa&copy")
       `(*TOP*
         "aaa" (& copy)))

 (test (html->xexp "&#42;")  '(*TOP* "*"))
 (test (html->xexp "&#42")   '(*TOP* "*"))
 (test (html->xexp "&#42x")  '(*TOP* "*x"))
 (test (html->xexp "&#151")  `(*TOP* ,(integer->char 151)))
 (test (html->xexp "&#1000") `(*TOP* ,(integer->char 1000)))
 (test (html->xexp "&#x42")  '(*TOP* "B"))
 (test (html->xexp "&#xA2")  `(*TOP* ,(integer->char 162)))
 (test (html->xexp "&#xFF")  `(*TOP* ,(integer->char 255)))
 (test (html->xexp "&#x100") `(*TOP* ,(integer->char 256)))
 (test (html->xexp "&#X42")  '(*TOP* "B"))
 (test (html->xexp "&42;")   '(*TOP* "&42;"))

 (test (html->xexp (string-append "aaa&copy;bbb&amp;ccc&lt;ddd&&gt;"
                                  "eee&#42;fff&#1000;ggg&#x5a;hhh"))
       `(*TOP*
         "aaa"
         (& copy)
         "bbb&ccc<ddd&>eee*fff"
         ,(integer->char 1000)
         "gggZhhh"))

 (test (html->xexp
        (string-append
         "<IMG src=\"http://e.e/aw/pics/listings/"
         "ebayLogo_38x16.gif\" border=0 width=\"38\" height=\"16\" "
         "HSPACE=5 VSPACE=0\">2</FONT>"))
       `(*TOP*
         (img (@
               (src
                "http://e.e/aw/pics/listings/ebayLogo_38x16.gif")
               (border "0") (width "38") (height "16")
               (hspace "5") (vspace "0")))
         "2"))

 (test (html->xexp "<aaa bbb=ccc\"ddd>eee")
       `(*TOP* (aaa (@ (bbb "ccc") (ddd)) "eee")))
 (test (html->xexp "<aaa bbb=ccc \"ddd>eee")
       `(*TOP* (aaa (@ (bbb "ccc") (ddd)) "eee")))

 (test (html->xexp
        (string-append
         "<HTML><Head><Title>My Title</Title></Head>"
         "<Body BGColor=\"white\" Foo=42>"
         "This is a <B><I>bold-italic</B></I> test of </Erk>"
         "broken HTML.<br>Yes it is.</Body></HTML>"))
       `(*TOP*
         (html (head (title "My Title"))
               (body (@ (bgcolor "white") (foo "42"))
                     "This is a "
                     (b (i "bold-italic"))
                     " test of "
                     "broken HTML."
                     (br)
                     "Yes it is."))))

 (test (html->xexp
        (string-append
         "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\""
         " \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">"))
       `(*TOP*
         (*DECL*
          DOCTYPE
          html
          PUBLIC
          "-//W3C//DTD XHTML 1.0 Strict//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd")))

 (test (html->xexp
        (string-append
         "<html xmlns=\"http://www.w3.org/1999/xhtml\" "
         "xml:lang=\"en\" "
         "lang=\"en\">"))
       `(*TOP*
         (html (@ (xmlns "http://www.w3.org/1999/xhtml")
                  (xml:lang "en") (lang "en")))))

 (test (html->xexp
        (string-append
         "<html:html xmlns:html=\"http://www.w3.org/TR/REC-html40\">"
         "<html:head><html:title>Frobnostication</html:title></html:head>"
         "<html:body><html:p>Moved to <html:a href=\"http://frob.com\">"
         "here.</html:a></html:p></html:body></html:html>"))
       `(*TOP*
         (html (@ (xmlns:html "http://www.w3.org/TR/REC-html40"))
               (head (title "Frobnostication"))
               (body (p "Moved to "
                        (a (@ (href "http://frob.com"))
                           "here."))))))

 (test (html->xexp
        (string-append
         "<RESERVATION xmlns:HTML=\"http://www.w3.org/TR/REC-html40\">"
         "<NAME HTML:CLASS=\"largeSansSerif\">Layman, A</NAME>"
         "<SEAT CLASS=\"Y\" HTML:CLASS=\"largeMonotype\">33B</SEAT>"
         "<HTML:A HREF=\"/cgi-bin/ResStatus\">Check Status</HTML:A>"
         "<DEPARTURE>1997-05-24T07:55:00+1</DEPARTURE></RESERVATION>"))
       `(*TOP*
         (reservation (@ (,(string->symbol "xmlns:HTML")
                          "http://www.w3.org/TR/REC-html40"))
                      (name (@ (class "largeSansSerif"))
                            "Layman, A")
                      (seat (@ (class "Y") (class "largeMonotype"))
                            "33B")
                      (a (@ (href "/cgi-bin/ResStatus"))
                         "Check Status")
                      (departure "1997-05-24T07:55:00+1"))))

 (test (html->xexp
        (string-append
         "<html><head><title></title><title>whatever</title></head><body>"
         "<a href=\"url\">link</a><p align=center><ul compact style=\"aa\">"
         "<p>BLah<!-- comment <comment> --> <i> italic <b> bold <tt> ened </i>"
         " still &lt; bold </b></body><P> But not done yet..."))
       `(*TOP*
         (html (head (title) (title "whatever"))
               (body (a (@ (href "url")) "link")
                     (p (@ (align "center"))
                        (ul (@ (compact) (style "aa"))))
                     (p "BLah"
                        (*COMMENT* " comment <comment> ")
                        " "
                        (i " italic " (b " bold " (tt " ened ")))
                        " still < bold "))
               (p " But not done yet..."))))

 (test (html->xexp "<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
       `(*TOP*
         (*PI* xml "version=\"1.0\" encoding=\"UTF-8\"")))

 (test (html->xexp "<?php php_info(); ?>")
       `(*TOP* (*PI* php "php_info(); ")))
 (test (html->xexp "<?php php_info(); ?")
       `(*TOP* (*PI* php "php_info(); ?")))
 (test (html->xexp "<?php php_info(); ")
       `(*TOP* (*PI* php "php_info(); ")))

 (test (html->xexp "<?foo bar ? baz > blort ?>")
       `(*TOP*
         (*PI* foo "bar ? baz > blort ")))

 (test (html->xexp "<?foo b?>x")
       `(*TOP* (*PI* foo "b") "x"))
 (test (html->xexp "<?foo ?>x")
       `(*TOP* (*PI* foo "")  "x"))
 (test (html->xexp "<?foo ?>x")
       `(*TOP* (*PI* foo "")  "x"))
 (test (html->xexp "<?foo?>x")
       `(*TOP* (*PI* foo "")  "x"))
 (test (html->xexp "<?f?>x")
       `(*TOP* (*PI* f   "")  "x"))
 (test (html->xexp "<??>x")
       `(*TOP* (*PI* #f  "")  "x"))
 (test (html->xexp "<?>x")
       `(*TOP* (*PI* #f  ">x")))

 (test (html->xexp "<foo bar=\"baz\">blort")
       `(*TOP* (foo (@ (bar "baz")) "blort")))
 (test (html->xexp "<foo bar='baz'>blort")
       `(*TOP* (foo (@ (bar "baz")) "blort")))
 (test (html->xexp "<foo bar=\"baz'>blort")
       `(*TOP* (foo (@ (bar "baz'>blort")))))
 (test (html->xexp "<foo bar='baz\">blort")
       `(*TOP* (foo (@ (bar "baz\">blort")))))

 (test (html->xexp (string-append "<p>A</p>"
                                  "<script>line0 <" "\n"
                                  "line1" "\n"
                                  "<line2></script>"
                                  "<p>B</p>"))
       `(*TOP* (p "A")
               (script ,(string-append "line0 <" "\n")
                       ,(string-append "line1"   "\n")
                       "<line2>")
               (p "B")))

 (test (html->xexp "<xmp>a<b>c</XMP>d")
       `(*TOP* (xmp "a<b>c") "d"))
 (test (html->xexp "<XMP>a<b>c</xmp>d")
       `(*TOP* (xmp "a<b>c") "d"))
 (test (html->xexp "<xmp>a<b>c</foo:xmp>d")
       `(*TOP* (xmp "a<b>c") "d"))
 (test (html->xexp "<foo:xmp>a<b>c</xmp>d")
       `(*TOP* (xmp "a<b>c") "d"))
 (test (html->xexp "<foo:xmp>a<b>c</foo:xmp>d")
       `(*TOP* (xmp "a<b>c") "d"))
 (test (html->xexp "<foo:xmp>a<b>c</bar:xmp>d")
       `(*TOP* (xmp "a<b>c") "d"))

 (test (html->xexp "<xmp>a</b>c</xmp>d")
       `(*TOP* (xmp "a</b>c")     "d"))
 (test (html->xexp "<xmp>a</b >c</xmp>d")
       `(*TOP* (xmp "a</b >c")    "d"))
 (test (html->xexp "<xmp>a</ b>c</xmp>d")
       `(*TOP* (xmp "a</ b>c")    "d"))
 (test (html->xexp "<xmp>a</ b >c</xmp>d")
       `(*TOP* (xmp "a</ b >c")   "d"))
 (test (html->xexp "<xmp>a</b:x>c</xmp>d")
       `(*TOP* (xmp "a</b:x>c")   "d"))
 (test (html->xexp "<xmp>a</b::x>c</xmp>d")
       `(*TOP* (xmp "a</b::x>c")  "d"))
 (test (html->xexp "<xmp>a</b:::x>c</xmp>d")
       `(*TOP* (xmp "a</b:::x>c") "d"))
 (test (html->xexp "<xmp>a</b:>c</xmp>d")
       `(*TOP* (xmp "a</b:>c")    "d"))
 (test (html->xexp "<xmp>a</b::>c</xmp>d")
       `(*TOP* (xmp "a</b::>c")   "d"))
 (test (html->xexp "<xmp>a</xmp:b>c</xmp>d")
       `(*TOP* (xmp "a</xmp:b>c") "d"))

 (let ((expected `(*TOP* (p "real1")
                         "\n"
                         (xmp "\n"
                              ,(string-append "alpha"       "\n")
                              ,(string-append "<P>fake</P>" "\n")
                              ,(string-append "bravo"       "\n"))
                         (p "real2"))))

   (test (html->xexp (string-append "<P>real1</P>" "\n"
                                    "<XMP>"        "\n"
                                    "alpha"        "\n"
                                    "<P>fake</P>"  "\n"
                                    "bravo"        "\n"
                                    "</XMP "       "\n"
                                    "<P>real2</P>"))
         expected)

   (test (html->xexp (string-append "<P>real1</P>" "\n"
                                    "<XMP>"        "\n"
                                    "alpha"        "\n"
                                    "<P>fake</P>"  "\n"
                                    "bravo"        "\n"
                                    "</XMP"        "\n"
                                    "<P>real2</P>"))
         expected))

 (test (html->xexp "<xmp>a</xmp>x")
       `(*TOP* (xmp "a")   "x"))
 (test (html->xexp (string-append "<xmp>a" "\n" "</xmp>x"))
       `(*TOP* (xmp ,(string-append "a" "\n")) "x"))
 (test (html->xexp "<xmp></xmp>x")
       `(*TOP* (xmp)       "x"))

 (test (html->xexp "<xmp>a</xmp") `(*TOP* (xmp "a")))
 (test (html->xexp "<xmp>a</xm")  `(*TOP* (xmp "a</xm")))
 (test (html->xexp "<xmp>a</x")   `(*TOP* (xmp "a</x")))
 (test (html->xexp "<xmp>a</")    `(*TOP* (xmp "a</")))
 (test (html->xexp "<xmp>a<")     `(*TOP* (xmp "a<")))
 (test (html->xexp "<xmp>a")      `(*TOP* (xmp "a")))
 (test (html->xexp "<xmp>")       `(*TOP* (xmp)))
 (test (html->xexp "<xmp")        `(*TOP* (xmp)))

 (test (html->xexp "<xmp x=42 ")
       `(*TOP* (xmp (@ (x "42")))))
 (test (html->xexp "<xmp x= ")   `(*TOP* (xmp (@ (x)))))
 (test (html->xexp "<xmp x ")    `(*TOP* (xmp (@ (x)))))
 (test (html->xexp "<xmp x")     `(*TOP* (xmp (@ (x)))))

 (test (html->xexp "<script>xxx")
       `(*TOP* (script "xxx")))
 (test (html->xexp "<script/>xxx")
       `(*TOP* (script) "xxx"))

 (test (html->xexp "<html xml:lang=\"en\" lang=\"en\">")
       `(*TOP* (html (@ (xml:lang "en") (lang "en")))))

 (test (html->xexp "<a href=/foo.html>")
       `(*TOP* (a (@ (href "/foo.html")))))
 (test (html->xexp "<a href=/>foo.html")
       `(*TOP* (a (@ (href "/")) "foo.html")))

 ;; TODO: Add verbatim-pair cases with attributes in the end tag.

 (test (html->xexp "&copy;")
       `(*TOP* (& copy)))
 (test (html->xexp "&rArr;")
       `(*TOP* (& ,(string->symbol "rArr"))))
 (test (html->xexp "&#151;")
       `(*TOP* ,(integer->char 151)))

 (test (html->xexp "&#999;")
       `(*TOP* ,(integer->char 999)))

 (test (html->xexp "xxx<![CDATA[abc]]>yyy")
       `(*TOP* "xxx" "abc" "yyy"))

 (test (html->xexp "xxx<![CDATA[ab]c]]>yyy")
       `(*TOP* "xxx" "ab]c" "yyy"))

 (test (html->xexp "xxx<![CDATA[ab]]c]]>yyy")
       `(*TOP* "xxx" "ab]]c" "yyy"))

 (test (html->xexp "xxx<![CDATA[]]]>yyy")
       `(*TOP* "xxx" "]" "yyy"))

 (test (html->xexp "xxx<![CDATAyyy")
       `(*TOP* "xxx" "<![CDATA" "yyy"))

 (test (html->xexp "<html><div><p>P1</p><p>P2</p></div><p>P3</p>")
       `(*TOP* (html (div (p "P1")
                          (p "P2"))
                     (p "P3")))
       #:id 'parent-constraints-with-div)

 (test (html->xexp "&#151;")
       `(*TOP* ,(integer->char 151))
       #:id 'no-longer-convert-character-references-above-126-to-string)

 (test (html->xexp "<ul><li>a<p>b</p>")
       `(*TOP* (ul (li "a" (p "b"))))
       #:id 'p-element-can-be-child-of-li-element)

 ;; TODO: Document this.
 ;;
 ;; (define html-1 "<myelem myattr=\"&\">")
 ;; (define shtml   (html->xexp html-1))
 ;; shtml
 ;; (define html-2 (shtml->html shtml))
 ;; html-2

 )
