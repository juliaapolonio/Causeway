set -euxo pipefail

input=$1

name=${input%%.txt.gz}
echo $name
# Create a variable with the tissue name
keyword=$(echo "$input" | awk -F'-' '{print $4}')
echo $input
echo $keyword
# Decompress the file, add the keyword as a new column, and write to the temporary file
zcat "$input" | awk -v keyword="$keyword" '{print $0 "\t" keyword}' > "$name"_tmp0.txt
# Split snp column, filter columns and add column names
cat "$name"_tmp0.txt  | tr ':' '\t' | tr '_' '\t' | cut -f1,5,8,9,10,15,16,17,19,20,25  > "$name"_tmp.txt
# Create f-stats column
awk 'NR==1{print} NR>1{print $0, $11=$9^2/$10^2}' "$name"_tmp.txt > "$name"_tmp1.txt
# Filter by f-stats
awk -F "\t" '$12<10' "$name"_tmp1.txt  > "$name"_fstats.txt 
# Change header to MR format
var="ensemble\tgenesymbol\tSNP\tA1\tA2\tfreq\tp\tN\tbeta\tse\ttissue\tfstat"
sed -i "1s/.*/$var/" "$name"_fstats.txt
rm *tmp*
# Split by gene name, process by first gene letter and generate one GSMR file for each gene and each tissue. It may take a while to run
cat "$name"_fstats.txt | awk '{print > $2"_"$11".txt"}'

rm *fstats*

for file in ./*.txt; do
	b=${file%%.txt}
	echo $b
	cat $file | awk '{print $3 "\t" $4 "\t" $5 "\t" $6 "\t" $9 "\t" $10 "\t" $7 "\t" $8}' | tr 'e ' 'E' | sed 's/^chr\|%$//g'  \
	| awk '$3!="NA"' |awk '$4!="NA"' | awk '$5!="NA"' | awk '$6!="NA"' | awk '$7!="NA"' | awk '$8!="NA"'   \
	| awk '$9!="NA"' | awk '$7!=0' | awk '$8!=0' | awk '($9 + 0) <1E-5' | tr ' ' '\t' > "$b"_tmp1.txt; done

for file in ./*_tmp1.txt; do
	b=${file%%_tmp1.txt}
	echo -e "SNP\tA1\tA2\tfreq\tb\tse\tp\tN" | cat - $file | cut -d $'\t' -f1-8 | awk '!seen[$1,$2,$3]++' | sed "s/^chr//g" | gzip > "$b"_MR.txt.gz   
done

rm *_tmp1*

