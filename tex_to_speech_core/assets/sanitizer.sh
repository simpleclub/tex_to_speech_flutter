#!/bin/zsh
# A script that applies a series of sanitization steps to TeX samples input.
# It applies sanitizations such as removing duplicates, custom color commands,
# fixing relations, and replacing underlines without block.
#
# Usage: sanitizer.sh <input_file>
#
FILE_NAME="$1"
readonly FILE_NAME
STEP=0
# remove duplicates
cat $FILE_NAME | sort | uniq > ${FILE_NAME}-step0

# removing custom color commands
perl -pe 's/\\textcolor{[a-zA-Z0-9_]+?}/ /g' ${FILE_NAME}-step0 > ${FILE_NAME}-step1
perl -pe 's/\\col\[[0-9]+\]/ /g' ${FILE_NAME}-step1 > ${FILE_NAME}-step2


# fixing underlines without block
perl -pe 's/\\underline(\s*)\\/\\/g' ${FILE_NAME}-step2 > ${FILE_NAME}-step3

# replace \dfrac with \frac
# perl -pe 's/\\dfrac/\frac/g' ${FILE_NAME}-step5 > ${FILE_NAME}-step6

# replace \middle with \mid,
perl -pe 's/\\middle(\s*)\|/\\mid /g' ${FILE_NAME}-step3 > ${FILE_NAME}-step4

# add space after command
perl -pe 's/\\lt(\S)/\\lt $1/g'  ${FILE_NAME}-step4 | perl -pe 's/\\gt(\S)/\\gt $1/g' > ${FILE_NAME}-step5

# replace \textsf or \textrm with \text
perl -pe 's/\\text(sf|rm)(\s*){([^}]+)}/\\text{$3}/g' ${FILE_NAME}-step5 > ${FILE_NAME}-step6

# expand macros
perl -pe 's/\\e(\W|_)/\\mathrm{e}$1/g' ${FILE_NAME}-step6 | \
perl -pe 's/\\i(\W|_)/\\mathrm{i}$1/g' | \
perl -pe 's/\\d(\W|_)/\\mathrm{d}$1/g' | \
perl -pe 's/\\C(\W|_)/\\mathbb{C}$1/g' | \
perl -pe 's/\\Q(\W|_)/\\mathbb{Q}$1/g' | \
perl -pe 's/\\N(\W|_)/\\mathbb{N}$1/g' | \
perl -pe 's/\\R(\W|_)/\\mathbb{R}$1/g' | \
perl -pe 's/\\lsg(\s*){(.+)}/\\underline{\\underline{$2}}/g' | \
perl -pe 's/\\eqhat/\\overset{\\wedge}{=}/g' > ${FILE_NAME}-step7

# replace \rarr with \rightarrow
perl -pe 's/\\[Rr]arr/\\rightarrow/g' ${FILE_NAME}-step7 > ${FILE_NAME}-step8

perl -pe 's/\\[Ll]arge//g' ${FILE_NAME}-step8 | \
perl -pe 's/\\[Ss]mall//g' | \
perl -pe 's/\\huge//g' > ${FILE_NAME}-step9

perl -pe 's/\\space/\\ /g' ${FILE_NAME}-step9 > ${FILE_NAME}-step10

# replace \bold with \bf
perl -pe 's/\\bold(\W)/\\bf$1/g' ${FILE_NAME}-step10 > ${FILE_NAME}-step11

# remove \boxed
perl -pe 's/\\boxed//g' ${FILE_NAME}-step11 > ${FILE_NAME}-step12
