.SUFFIXES:	.ps .dvi .tex

doc.ps: ref.dvi tut.dvi
	dviconcat -o robot.dvi tut.dvi ref.dvi
	dvips -f robot > robot.ps
	ps2pdf2 robot

tut.dvi:	tut.tex
	pslatex tut
	pslatex tut

ref.dvi:	ref.tex
	pslatex ref
	pslatex ref

clean:
	rm *.dvi *.aux *.log *~ *toc *.ps *.blg
