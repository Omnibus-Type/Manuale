#!/bin/sh
set -e


echo "Generating Static fonts"
fontmake -g Manuale.glyphs -i -o ttf --output-dir ../fonts/ttf/
fontmake -g Manuale_Italic.glyphs -i -o ttf --output-dir ../fonts/ttf/
fontmake -g Manuale.glyphs -i -o otf --output-dir ../fonts/otf/
fontmake -g Manuale_Italic.glyphs -i -o otf --output-dir ../fonts/otf/

echo "Generating VFs"
fontmake -g Manuale.glyphs -o variable --output-path ../fonts/vf/Manuale-Roman-VF.ttf
fontmake -g Manuale_Italic.glyphs -o variable --output-path ../fonts/vf/Manuale-Italic-VF.ttf

rm -rf master_ufo/ instance_ufo/


echo "Post processing"
ttfs=$(ls ../fonts/ttf/*.ttf)
for ttf in $ttfs
do
	gftools fix-dsig -f $ttf;
	./ttfautohint-vf $ttf "$ttf.fix";
	mv "$ttf.fix" $ttf;
done

echo "Post processing VFs"
vfs=$(ls ../fonts/vf/*-VF.ttf)
for vf in $vfs
do
	gftools fix-dsig -f $vf;
	./ttfautohint-vf --stem-width-mode nnn $vf "$vf.fix";
	mv "$vf.fix" $vf;
	gftools fix-hinting $vf;
	mv "$vf.fix" $vf;
done


echo "Fixing VF Meta"
gftools fix-vf-meta $vfs;
for vf in $vfs
do
	mv "$vf.fix" $vf;
	ttx -f -x "MVAR" $vf; # Drop MVAR. Table has issue in DW
	rtrip=$(basename -s .ttf $vf)
	new_file=../fonts/vf/$rtrip.ttx;
	rm $vf;
	ttx $new_file
	rm $new_file
done

