
# Pandoc

## Installation


```bash
 sudo apt install pandoc texlive-xetex
```
## Conversion en PDF

```bash
 sudo apt install pandoc texlive-xetex
```
ou 

```bash
 pandoc README.md -o pdf_files/README.pdf --from markdown --to pdf
```

Exemple pour ajuster les marges :

```bash
pandoc README.md -o pdf_files/README.pdf --from markdown --to pdf --pdf-engine=xelatex -V geometry:margin=1in
```
Ajouter un centrage du titre via LaTeX dans les métadonnées

```bash
pandoc README.md -o pdf_files/README.pdf --from markdown --to pdf --pdf-engine=xelatex -V geometry:margin=1in -V lineheight=1.5 -V title="Ton Titre" -V header-includes="\usepackage{titling}\pretitle{\begin{center}\LARGE} \posttitle{\end{center}}"

```