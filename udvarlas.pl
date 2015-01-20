my @f_1 = ("aranyos",
		"kedves",
		"szívdöglesztõ",
		"izgalmas",
		"erotikus kisugárzású",
		"szép szemû",
		"dögös",
		"szexi",
		"imádnivaló",
		"csókos szájú",
		"hihetetlenül kedves");

my @f_2 = ("leányzó",
		"cicababa",
		"vadmacska",
		"bébi",
		"aranybogár",
		"vágyaim netovábbja",
		"szexistennõ",
		"amazon",
		"szerelmi csúcsnimfa",
		"szívcsücsök",
		"tündér",
		"álomlány");

my @f_3 = ("olyan vagy mint",
		"úgy ragyogsz mint",
		"olyan imádnivaló vagy mint",
		"sokkal többet érsz mint");

my @f_4 = ("a legdrágább kincs",
		"az égbolt tengerén tündöklõ Nap",
		"a csillogó csillagok",
		"a hûsítõ nyári zápor",
		"az éjszakát bevilágító telihold",
		"a gyémánt");

my @f_5 = ("ami fénylik",
		"ami gyönyörûséges",
		"ami mindeneknél szebb",
		"ami felvidítja a lelkemet",
		"ami távol van mégis közel");

my @f_6 = ("szeretném",
		"annyira akarnám",
		"annyira imádnám",
		"úgy vágynám",
		"vállalnám én",
		"megpróbálnám",
		"jó lenne",
		"jól esne",
		"írtóra szeretném",
		"nagyon kedvem lenne");

my @f_7 = ("megcsókolni rózsás orcádat",
		"dédelgetni testedet izmos karjaimban",
		"ízlelni eper-vörös ajkaid eper-vörös zamatát",
		"símogatni lágy bõrödet",
		"érezni hajad kókusz-illatát",
		"az érzést elmerülni szemeid tavában",
		"felkorbácsolni érzékeidet",
		"elnyerni szerelmedet",
		"a halált is érted");

my @f_8 = ("csak egy kicsit",
		"egyszer",
		"néha",
		"gyorsan",
		"jókedvemben",
		"hogy érezd amit én",
		"amikor akarod",
		"csak egy pillanatra");

my @f_9 = ("ahol akarod",
		"a csillagok között",
		"valamikor",
		"mindörökké",
		"az idõk végezetéig",
		"tomboló viharban",
		"a tejúj hófehér porán",
		"napfény áztatta réten");

my @f10 = ("a karjaimba",
		"édes ide hozzám",
		"és ölelj",
		"életem értelme",
		"és ölelj át",
		"gyönyörûséges szerelmem");

my @f11 = ("legkedvesebb",
		"álmodozó",
		"romantikus",
		"õrült");

my @f12 = ("lázban égõ",
		"csak Téged imádó",
		"vágytól remegõ",
		"vacsorára hívogató");

my @f13 = ("szerelmesed",
		"izompacsirtád",
		"szexrabszolgád",
		"micimackód",
		"quasimodod",
		"szíved csücske");

my $szoveg = 'Te '. $f_1[int(rand(scalar @f_1))]
			. ' ' . $f_2[int(rand(scalar @f_2))]
			. ', '. $f_3[int(rand(scalar @f_3))]
			. ' ' . $f_4[int(rand(scalar @f_4))]
			. ' ' . $f_5[int(rand(scalar @f_5))]
			. ', '. $f_6[int(rand(scalar @f_6))]
			. ' ' . $f_7[int(rand(scalar @f_7))]
			. ' ' . $f_8[int(rand(scalar @f_8))]
			. ', ' . $f_9[int(rand(scalar @f_9))] . '. '
			. 'Gyere ' . $f10[int(rand(scalar @f10))] . ', '
			. 'Szeretettel és imádattal, teljes szívembõl: a te'
			. ' '  . $f11[int(rand(scalar @f11))]
			. ', ' . $f12[int(rand(scalar @f12))]
			. ' '  . $f13[int(rand(scalar @f13))] . '.';

$out = $szoveg;