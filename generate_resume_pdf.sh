#!/bin/bash
# Clean previous build
rm -rf tmp public resources
# Create temporary directory
mkdir -p tmp

# Function to escape LaTeX special characters
escape_latex() {
  sed 's/&/\\&/g; s/%/\\%/g; s/–/\\--/g; s/#/\\#/g'
}

# Function to convert HTML links to Markdown
html_to_markdown() {
  sed -E 's|<a href=['"'"'"]([^'"'"'"]+)['"'"'"]>([^<]+)</a>|\[\2\](\1)|g'
}

# Function to generate resume for a given language
generate_resume() {
  local lang=$1
  local content_dir=$2
  local output_pdf=$3
  local lang_code=$4

  # Start merged Markdown file
  echo "---" > tmp/merged_${lang}.md

  # Extract front matter from python-backend.md, excluding experience, education, projects
  awk '/^---$/{p=!p; if (p==1) print; next} p&&p==1 {if (/^(experience|education|projects):/) {skip=1} else if (skip && /^[^ ]/) {skip=0} if (!skip) print}' \
    "${content_dir}/python-backend.md" | head -n -1 | tail -n +2 >> tmp/merged_${lang}.md

  # Add experience data
  echo "experience:" >> tmp/merged_${lang}.md
  paths=$(yq '.experience[]' "${content_dir}/python-backend.md" -r 2>/dev/null)
  if [ -n "$paths" ]; then
    while IFS= read -r path; do
      # Remove 'curriculum/' prefix from path
      file="${content_dir}/${path#curriculum/}.md"
      echo "Debug: Processing experience file: $file" >&2
      if [ -f "$file" ]; then
        echo "  - company: $(yq '.company // ""' "$file" -r | escape_latex)" >> tmp/merged_${lang}.md
        echo "    title: $(yq '.title // ""' "$file" -r | escape_latex)" >> tmp/merged_${lang}.md
        echo "    city: $(yq '.city // ""' "$file" -r | escape_latex)" >> tmp/merged_${lang}.md
        echo "    date_str: $(yq '.date_str // ""' "$file" -r | escape_latex)" >> tmp/merged_${lang}.md
        echo "    desc: $(yq '.desc // ""' "$file" -r | html_to_markdown | escape_latex)" >> tmp/merged_${lang}.md
        echo "    responsibilities:" >> tmp/merged_${lang}.md
        if yq '.responsibilities' "$file" -r | grep -q '[^[:space:]]'; then
          yq '.responsibilities[]' "$file" -r | while IFS= read -r line; do
            echo "Debug: Processing responsibility: $line" >&2
            transformed_line=$(echo "$line" | html_to_markdown)
            echo "Debug: Transformed responsibility: $transformed_line" >&2
            if echo "$line" | grep -q ':'; then
              echo "      - \"$(echo "$transformed_line" | escape_latex)\"" >> tmp/merged_${lang}.md
            else
              echo "      - $(echo "$transformed_line" | escape_latex)" >> tmp/merged_${lang}.md
            fi
          done
        else
          echo "      - None" >> tmp/merged_${lang}.md
        fi
        echo "    technologies:" >> tmp/merged_${lang}.md
        if yq '.technologies' "$file" -r | grep -q '[^[:space:]]'; then
          yq '.technologies[]' "$file" -r | while IFS= read -r line; do
            if echo "$line" | grep -q ':'; then
              echo "      - \"$line\"" >> tmp/merged_${lang}.md
            else
              echo "      - $line" >> tmp/merged_${lang}.md
            fi
          done
        else
          echo "      - None" >> tmp/merged_${lang}.md
        fi
      else
        echo "Warning: File $file not found" >&2
      fi
    done <<< "$paths"
  else
    echo "Warning: No experience paths found in ${content_dir}/python-backend.md" >&2
  fi

  # Add education data
  echo "education:" >> tmp/merged_${lang}.md
  paths=$(yq '.education[]' "${content_dir}/python-backend.md" -r 2>/dev/null)
  if [ -n "$paths" ]; then
    while IFS= read -r path; do
      # Remove 'curriculum/' prefix from path
      file="${content_dir}/${path#curriculum/}.md"
      echo "Debug: Processing education file: $file" >&2
      if [ -f "$file" ]; then
        echo "  - institution: $(yq '.institution // ""' "$file" -r | escape_latex)" >> tmp/merged_${lang}.md
        echo "    title: $(yq '.title // ""' "$file" -r | escape_latex)" >> tmp/merged_${lang}.md
        echo "    city: $(yq '.city // ""' "$file" -r | escape_latex)" >> tmp/merged_${lang}.md
        echo "    date_str: $(yq '.date_str // ""' "$file" -r | escape_latex)" >> tmp/merged_${lang}.md
        echo "    desc:" >> tmp/merged_${lang}.md
        if yq '.desc' "$file" -r | grep -q '[^[:space:]]'; then
          yq '.desc[]' "$file" -r | while IFS= read -r line; do
            echo "Debug: Processing desc: $line" >&2
            transformed_line=$(echo "$line" | html_to_markdown)
            echo "Debug: Transformed desc: $transformed_line" >&2
            if echo "$line" | grep -q ':'; then
              echo "      - \"$(echo "$transformed_line" | escape_latex)\"" >> tmp/merged_${lang}.md
            else
              echo "      - $(echo "$transformed_line" | escape_latex)" >> tmp/merged_${lang}.md
            fi
          done
        else
          echo "      - None" >> tmp/merged_${lang}.md
        fi
        echo "    technologies:" >> tmp/merged_${lang}.md
        if yq '.technologies' "$file" -r | grep -q '[^[:space:]]'; then
          yq '.technologies[]' "$file" -r | while IFS= read -r line; do
            if echo "$line" | grep -q ':'; then
              echo "      - \"$line\"" >> tmp/merged_${lang}.md
            else
              echo "      - $line" >> tmp/merged_${lang}.md
            fi
          done
        else
          echo "      - None" >> tmp/merged_${lang}.md
        fi
      else
        echo "Warning: File $file not found" >&2
      fi
    done <<< "$paths"
  else
    echo "Warning: No education entries found in ${content_dir}/python-backend.md" >&2
  fi

  # Add projects data
  echo "projects:" >> tmp/merged_${lang}.md
  paths=$(yq '.projects[]' "${content_dir}/python-backend.md" -r 2>/dev/null)
  if [ -n "$paths" ]; then
    while IFS= read -r path; do
      # Remove 'curriculum/' prefix from path
      file="${content_dir}/${path#curriculum/}.md"
      echo "Debug: Processing project file: $file" >&2
      if [ -f "$file" ]; then
        echo "  - title: $(yq '.title // ""' "$file" -r | escape_latex)" >> tmp/merged_${lang}.md
        echo "    desc: $(yq '.desc // ""' "$file" -r | html_to_markdown | escape_latex)" >> tmp/merged_${lang}.md
        echo "    responsibilities:" >> tmp/merged_${lang}.md
        if yq '.responsibilities' "$file" -r | grep -q '[^[:space:]]'; then
          yq '.responsibilities[]' "$file" -r | while IFS= read -r line; do
            echo "Debug: Processing responsibility: $line" >&2
            transformed_line=$(echo "$line" | html_to_markdown)
            echo "Debug: Transformed responsibility: $transformed_line" >&2
            if echo "$line" | grep -q ':'; then
              echo "      - \"$(echo "$transformed_line" | escape_latex)\"" >> tmp/merged_${lang}.md
            else
              echo "      - $(echo "$transformed_line" | escape_latex)" >> tmp/merged_${lang}.md
            fi
          done
        else
          echo "      - None" >> tmp/merged_${lang}.md
        fi
        echo "    technologies:" >> tmp/merged_${lang}.md
        if yq '.technologies' "$file" -r | grep -q '[^[:space:]]'; then
          yq '.technologies[]' "$file" -r | while IFS= read -r line; do
            if echo "$line" | grep -q ':'; then
              echo "      - \"$line\"" >> tmp/merged_${lang}.md
            else
              echo "      - $line" >> tmp/merged_${lang}.md
            fi
          done
        else
          echo "      - None" >> tmp/merged_${lang}.md
        fi
      else
        echo "Warning: File $file not found" >&2
      fi
    done <<< "$paths"
  else
    echo "Warning: No project entries found in ${content_dir}/python-backend.md" >&2
  fi

  echo "---" >> tmp/merged_${lang}.md

  # Debug: Print merged content
  echo "Debug: Contents of tmp/merged_${lang}.md"
  cat tmp/merged_${lang}.md

  # Convert merged Markdown to PDF using Pandoc
  pandoc -o tmp/resume_${lang}.pdf \
    tmp/merged_${lang}.md \
    --template=layouts/resume/resume-pandoc.tex \
    --pdf-engine=latexmk \
    --strip-comments \
    -V lang="${lang_code}" \
    --quiet 2> tmp/failed_${lang}.log
  # Check if PDF was generated
  if [ ! -f tmp/resume_${lang}.pdf ]; then
    echo "Error: PDF compilation failed for ${lang}. Check tmp/failed_${lang}.log"
    cat tmp/failed_${lang}.log
    exit 1
  fi
  # Move PDF to static
  mv tmp/resume_${lang}.pdf static/${output_pdf}
  echo "PDF generated: static/${output_pdf}"
}

# Generate resumes for each language
generate_resume "ru" "content/ru/curriculum" "sushkov_python_ru.pdf" "ru-RU"
generate_resume "en" "content/en/curriculum" "sushkov_python_en.pdf" "en-US"
generate_resume "es" "content/es/curriculum" "sushkov_python_es.pdf" "es-ES"

# Clean up
# rm -rf tmp
echo "All PDFs generated."