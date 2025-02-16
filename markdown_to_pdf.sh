#!/bin/bash

# Répertoire contenant les fichiers Markdown
MARKDOWN_DIR="./"
# Répertoire de sortie pour les fichiers PDF
OUTPUT_DIR="./pdf_files"

# Vérifiez que les répertoires existent
if [ ! -d "$MARKDOWN_DIR" ]; then
  echo "Le répertoire $MARKDOWN_DIR n'existe pas."
  exit 1
fi

if [ ! -d "$OUTPUT_DIR" ]; then
  mkdir -p "$OUTPUT_DIR"
fi

# Parcourez chaque fichier Markdown dans le répertoire
for md_file in "$MARKDOWN_DIR"/*.md; do
  if [ -f "$md_file" ]; then
    filename=$(basename -- "$md_file")
    filename="${filename%.*}"
    output_file="$OUTPUT_DIR/$filename.pdf"

    echo "Conversion de $md_file en $output_file"

    # Utilisez le conteneur Docker pour convertir le fichier Markdown en PDF
    docker run --rm -v "$(pwd)/$MARKDOWN_DIR:/data" -v "$(pwd)/$OUTPUT_DIR:/output" yjpictures/mdpdfinator /data/$(basename "$md_file") --output_file_path /output/$(basename "$output_file")
  fi
done

echo "Conversion terminée."