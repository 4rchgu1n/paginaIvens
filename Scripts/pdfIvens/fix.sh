#!/bin/bash
pdfname=$1


pages=$(pdfinfo $pdfname | grep "Pages:" | sed 's/Pages:           //g')


baseName=${1:0:-4}
folder=".$baseName"
mkdir $folder

pdfseparate "$pdfname" "$folder/tmpPDF-%d.pdf"

counter=1
for ((i = 1 ; i < $(($pages + 1)) ; i++  )); do
	tmpPDFName="tmpPDF-$i.pdf"

	pdfjam --trim "0pts 297.5pts 421pts 0pts" --fitpaper true "$folder/$tmpPDFName" --outfile "$folder/cropped-$counter.pdf"
       ((counter++))
	pdfjam --trim "421pts 297.5pts 0pts 0pts" --fitpaper true "$folder/$tmpPDFName" --outfile "$folder/cropped-$counter.pdf"
       ((counter++))
	pdfjam --trim "0pts 0pts 421pts 297.5pts" --fitpaper true "$folder/$tmpPDFName" --outfile "$folder/cropped-$counter.pdf"
       ((counter++))
	pdfjam --trim "421pts 0pts 0pts 297.5pts" --fitpaper true "$folder/$tmpPDFName" --outfile "$folder/cropped-$counter.pdf"
	((counter++))
done



totalPDFs=""

for ((i = 1 ; i < $counter ; i++ )) ; do
	totalPDFs+="$folder/cropped-$i.pdf "
done

echo  ---------Merging PDFs--------

mkdir output

pdftk $totalPDFs cat output $folder/$baseName-Fixed.pdf
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress -dNOPAUSE -dQUIET -dBATCH -sOutputFile="output/$baseName.pdf" "$folder/$baseName-Fixed.pdf"

rm $folder/tmpPDF-*
rm $folder/cropped-*
rm -rf $folder
