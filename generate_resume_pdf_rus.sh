#!/bin/bash
# Clean previous build
rm -rf tmp public resources
# Create temporary directory
mkdir -p tmp

# Start merged Markdown file
echo "---" > tmp/merged.md

# Extract front matter from python-backend.md, excluding experience, education, projects
awk '/^---$/{p=!p; if (p==1) print; next} p&&p==1 {if (/^(experience|education|projects):/) {skip=1} else if (skip && /^[^ ]/) {skip=0} if (!skip) print}' \
  content/ru/curriculum/python-backend.md | head -n -1 | tail -n +2 >> tmp/merged.md

# Function to escape LaTeX special characters and quote YAML strings with colons
escape_latex() {
  sed 's/&/\\&/g; s/%/\\%/g; s/–/\\--/g; s/#/\\#/g; s/"/\\"/g; s/:/'"'"'&: '"'"'/g'
}

# Add experience data
echo "experience:" >> tmp/merged.md
# Extract paths using yq
paths=$(yq '.experience[]' content/ru/curriculum/python-backend.md -r 2>/dev/null)
if [ -n "$paths" ]; then
  while IFS= read -r path; do
    file="content/ru/$path.md"
    if [ -f "$file" ]; then
      echo "  - company: $(yq '.company // ""' "$file" -r | escape_latex)" >> tmp/merged.md
      echo "    title: $(yq '.title // ""' "$file" -r | escape_latex)" >> tmp/merged.md
      echo "    city: $(yq '.city // ""' "$file" -r | escape_latex)" >> tmp/merged.md
      echo "    date_str: $(yq '.date_str // ""' "$file" -r | escape_latex)" >> tmp/merged.md
      echo "    desc: $(yq '.desc // ""' "$file" -r | escape_latex)" >> tmp/merged.md
      echo "    responsibilities:" >> tmp/merged.md
      if yq '.responsibilities' "$file" -r | grep -q '[^[:space:]]'; then
        yq '.responsibilities[]' "$file" -r | while IFS= read -r line; do
          if echo "$line" | grep -q ':'; then
            echo "      - \"$line\"" >> tmp/merged.md
          else
            echo "      - $line" >> tmp/merged.md
          fi
        done
      else
        echo "      - None" >> tmp/merged.md
      fi
      echo "    technologies:" >> tmp/merged.md
      if yq '.technologies' "$file" -r | grep -q '[^[:space:]]'; then
        yq '.technologies[]' "$file" -r | while IFS= read -r line; do
          if echo "$line" | grep -q ':'; then
            echo "      - \"$line\"" >> tmp/merged.md
          else
            echo "      - $line" >> tmp/merged.md
          fi
        done
      else
        echo "      - None"
      fi
    else
      echo "Warning: File $file not found" >&2
    fi
  done <<< "$paths"
else
  echo "Warning: No experience paths found in python-backend.md" >&2
fi

# Add education data
echo "education:" >> tmp/merged.md
paths=$(yq '.education[]' content/ru/curriculum/python-backend.md -r 2>/dev/null)
if [ -n "$paths" ]; then
  while IFS= read -r path; do
    file="content/ru/$path.md"
    if [ -f "$file" ]; then
      echo "  - institution: $(yq '.institution // ""' "$file" -r | escape_latex)" >> tmp/merged.md
      echo "    title: $(yq '.title // ""' "$file" -r | escape_latex)" >> tmp/merged.md
      echo "    city: $(yq '.city // ""' "$file" -r | escape_latex)" >> tmp/merged.md
      echo "    date_str: $(yq '.date_str // ""' "$file" -r | escape_latex)" >> tmp/merged.md
      echo "    technologies:" >> tmp/merged.md
      if yq '.technologies' "$file" -r | grep -q '[^[:space:]]'; then
        yq '.technologies[]' "$file" -r | while IFS= read -r line; do
          if echo "$line" | grep -q ':'; then
            echo "      - \"$line\"" >> tmp/merged.md
          else
            echo "      - $line" >> tmp/merged.md
          fi
        done
      else
        echo "      - None" >> tmp/merged.md
      fi
    else
      echo "Warning: File $file not found" >&2
    fi
  done <<< "$paths"
else
  echo "Warning: No education entries found" >&2
fi

# Add projects data
echo "projects:" >> tmp/merged.md
paths=$(yq '.projects[]' content/ru/curriculum/python-backend.md -r 2>/dev/null)
if [ -n "$paths" ]; then
  while IFS= read -r path; do
    file="content/ru/$path.md"
    if [ -f "$file" ]; then
      echo "  - title: $(yq '.title // ""' "$file" -r | escape_latex)" >> tmp/merged.md
      echo "    desc: $(yq '.desc // ""' "$file" -r | escape_latex)" >> tmp/merged.md
      echo "    technologies:" >> tmp/merged.md
      if yq '.technologies' "$file" -r | grep -q '[^[:space:]]'; then
        yq '.technologies[]' "$file" -r | while IFS= read -r line; do
          if echo "$line" | grep -q ':'; then
            echo "      - \"$line\"" >> tmp/merged.md
          else
            echo "      - $line" >> tmp/merged.md
          fi
        done
      else
        echo "      - None" >> tmp/merged.md
      fi
    else
      echo "Warning: File $file not found" >&2
    fi
  done <<< "$paths"
else
  echo "Warning: No project entries found" >&2
fi

echo "---" >> tmp/merged.md

# Debug: Print merged content
echo "Debug: Contents of tmp/merged.md"
cat tmp/merged.md

# Convert merged Markdown to PDF using Pandoc
pandoc -o tmp/resume.pdf \
  tmp/merged.md \
  --template=layouts/partials/resume-pandoc.tex \
  --pdf-engine=latexmk \
  --strip-comments \
  -V lang=ru-RU \
  --quiet 2> tmp/failed.log
# Check if PDF was generated
if [ ! -f tmp/resume.pdf ]; then
  echo "Error: PDF compilation failed. Check tmp/failed.log"
  cat tmp/failed.log
  exit 1
fi
# Move PDF to static
mv tmp/resume.pdf static/sushkov_python.pdf
# Clean up
rm -rf tmp
echo "PDF generated: static/sushkov_python.pdf"