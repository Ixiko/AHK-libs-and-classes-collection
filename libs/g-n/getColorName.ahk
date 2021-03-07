getColorName(hexRGB := "") {
	static COLORS := {}
		, STIF_SUPPORT_HEX := 0x00000001
		, TYPE := A_AhkVersion < "2" ? "xdigit" : "TYPE_V2"
		, TYPE_V2 := "xdigit"
		, QUOTE := Chr(0x22)
		, INIT := getColorName()


	if !COLORS.Count()
	{
		hModule := DllCall("LoadLibrary", "Str", "Shlwapi.dll", "Ptr")

		fileSelf := FileOpen(A_LineFile, "r")

		while !fileSelf.AtEOF
		{
			line := Trim(fileSelf.ReadLine(), " `t`r`n")

			if (!isParsingSelf && line == "<<<START>>>")
			{
				isParsingSelf := true
				continue
			}

			if (isParsingSelf && line == "<<<END>>>")
				break

			if isParsingSelf
			{
				Temp := StrSplit(line, "|")

				DllCall("Shlwapi.dll\StrToIntEx", "Str", "0x" Temp[1], "UInt", STIF_SUPPORT_HEX, "Int*", R, "Int")
				if !COLORS.HasKey(R)
					COLORS[R] := {}

				DllCall("Shlwapi.dll\StrToIntEx", "Str", "0x" Temp[2], "UInt", STIF_SUPPORT_HEX, "Int*", G, "Int")
				if !COLORS[R].HasKey(G)
					COLORS[R][G] := {}

				DllCall("Shlwapi.dll\StrToIntEx", "Str", "0x" Temp[3], "UInt", STIF_SUPPORT_HEX, "Int*", B, "Int")
				color := Temp[4]
				COLORS[R][G][B] := color
			}
		}

		fileSelf.Close()
		DllCall("FreeLibrary", "Ptr", hModule)
		return
	}

	if hexRGB is %TYPE%
	{
		r := (hexRGB & 0xFF0000) >> 16
		g := (hexRGB & 0x00FF00) >> 8
		b := (hexRGB & 0x0000FF)

		COLORS_GREEN := {}
		for red, GreenComponent in COLORS
		{
			distanceR := Abs(red - r)

			if (A_Index == 1)
			{
				lowestDistanceR := distanceR
				COLORS_GREEN := GreenComponent
				continue
			}

			if (distanceR < lowestDistanceR)
			{
				lowestDistanceR := distanceR
				COLORS_GREEN := GreenComponent
			}
			else
				break
		}

		COLORS_BLUE := {}
		for green, BlueComponent in COLORS_GREEN
		{
			distanceG := Abs(green - g)

			if (A_Index == 1)
			{
				lowestDistanceG := distanceG
				COLORS_BLUE := BlueComponent
				continue
			}

			if (distanceG < lowestDistanceG)
			{
				lowestDistanceG := distanceG
				COLORS_BLUE := BlueComponent
			}
			else
				break
		}

		for blue, colorName in COLORS_BLUE
		{
			distanceB := Abs(blue - b)

			if (A_Index == 1)
			{
				lowestDistanceB := distanceB
				result := colorName
				continue
			}

			if (distanceB < lowestDistanceB)
			{
				lowestDistanceB := distanceB
				result := colorName
			}
			else
				break
		}

		return result
	}
	else
		throw Exception(A_ThisFunc "(" QUOTE hexRGB QUOTE "): Only hexadecimal, numerical RGB colors are supported!", -2)
/*
<<<START>>>
00|00|00|Black
00|00|11|Benthic Black
00|00|22|Hadopelagic Water
00|00|33|Abyssopelagic Water
00|00|44|Endless Galaxy Blue
00|00|55|Alucard's Night
00|00|66|Alone in the Dark
00|00|77|Scotch Blue
00|00|80|Navy Blue
00|00|8b|Dark Blue
00|00|9c|Duke Blue
00|00|aa|Very Blue
00|00|bc|Keese Blue
00|00|cc|Lady of the Sea
00|00|cd|Medium Blue
00|00|dd|Bluealicious
00|00|ee|Blue Overdose
00|00|fc|Graphical 80's Sky
00|00|ff|Blue
00|01|00|Registration Black
00|01|33|Very Dark Blue
00|02|2e|Dark Navy Blue
00|03|5b|Abyssal Blue
00|04|35|Dark Navy
00|07|41|Stratos
00|0b|00|Wet Crow's Wing
00|0f|89|Phthalo Blue
00|11|11|Black Glaze
00|11|22|Kuretake Black Manga
00|11|33|Squid Ink Powder
00|11|44|Wet Latex
00|11|46|Kantor Blue
00|11|55|Interstellar Blue
00|14|40|Cetacean Blue
00|14|a8|Zaffre
00|17|7d|Blue Ranger
00|18|a8|Dark Galaxy
00|1c|3d|Maastricht Blue
00|21|47|Oxford Blue
00|22|00|Rainforest Nights
00|22|11|Clock Chimes Thirteen
00|22|22|Stellar Explorer
00|22|33|Midnight Dreams
00|22|44|Rhapsody In Blue
00|22|aa|City Hunter Blue
00|22|cc|Arcade Glow
00|23|66|Deep Sea Blue
00|23|87|Resolution Blue
00|23|95|Imperial Blue
00|24|00|Tides of Darkness
00|28|68|Old Glory Blue
00|2d|04|Dark Forest Green
00|2d|69|Deep Sea Dream
00|2e|63|Cool Black
00|2f|a6|International Klein Blue
00|2f|a7|International Blue
00|30|8f|US Air Force Blue
00|31|71|Konjō Blue
00|33|00|Serpentine Shadow
00|33|33|Nora's Forest
00|33|66|Prussian Blue
00|33|77|Dark Midnight Blue
00|33|99|Smalt
00|33|aa|UA Blue
00|33|ee|Blue Bouquet
00|33|ff|Blinking Blue
00|34|ab|Blue Hour
00|38|a7|Philippine Blue
00|38|a8|Royal Azure
00|3a|6c|Ateneo Blue
00|3a|ff|C64 Blue
00|40|40|Rich Black
00|40|58|Maniac Mansion
00|41|6a|Dark Imperial Blue
00|41|6c|Indigo Dye
00|42|25|Angel Green
00|42|42|Warm Black
00|44|00|Woodland Grass
00|44|99|Fright Night
00|44|ff|Rare Blue
00|45|77|Macragge Blue
00|47|ab|Soulstone Blue
00|48|ba|Absolute Zero
00|49|4e|Sherpa Blue
00|49|53|Midnight Green
00|4b|49|Deep Jungle Green
00|4b|8d|Lapis Blue
00|4e|00|Malachite Green
00|4f|7d|Snorkel Sea
00|4f|98|USAFA Blue
00|50|7a|Sea Paint
00|50|7f|Cleo's Bath
00|51|76|Pirate's Haven
00|52|43|Tetsu Green
00|52|49|Dark Blue Green
00|52|65|Deep Lagoon
00|52|80|Toy Submarine Blue
00|53|9c|Princess Blue
00|54|77|World Peace
00|54|93|Ocean
00|55|00|Pharmacy Green
00|55|55|Overboard
00|55|5a|Deep Teal
00|55|72|Night Kite
00|55|77|Studer Blue
00|55|99|Standing Waters
00|55|aa|Blue Lobster
00|55|ff|Nīlā Blue
00|56|3f|Sacramento State Green
00|56|4f|Castleton Green
00|57|26|Caliban Green
00|57|6e|Submersible
00|57|6f|Subaqueous
00|57|7e|Real Mccoy
00|57|80|Mykonos Blue
00|57|84|Baby Shoes
00|58|00|Duck Hunt Green
00|58|5e|Shaded Spruce
00|58|6d|Sea Creature
00|58|71|Lyons Blue
00|58|9b|Parachuting
00|58|f8|Megaman Helmet
00|59|61|Entrapment
00|59|86|Sea Cave
00|5a|85|High Profile
00|5b|6a|Captive
00|5b|87|Impulse
00|5c|2b|Dark Angels Green
00|5c|69|Egyptian Enamel
00|5c|77|Prismatic Springs
00|5d|6a|Hero
00|5d|96|Jetski Race
00|5e|59|Tidal Pool
00|5e|7d|Seaport
00|5e|88|Blue Flame
00|5e|8c|Mamala Bay
00|5f|56|Alpine Green
00|5f|5b|Mosque
00|5f|6a|Petrol
00|5f|7a|Deep Turquoise
00|60|4b|Sci-Fi Takeout
00|60|6f|Cool Dive
00|60|8b|Ink Blotch
00|60|8f|Felix
00|60|a6|Peptalk
00|61|31|Dark Elf Green
00|61|69|Turkish Aqua
00|61|75|Ocean Depths
00|61|9d|Rave Regatta
00|61|a3|Directoire Blue
00|62|6f|Blue Lagoon
00|62|84|Blue League
00|62|9a|Atlantic Mystique
00|63|7c|Crystal Teal
00|63|80|Celestial
00|63|83|Harem Silk
00|63|84|Blue Heist
00|63|a0|Brigadier Blue
00|63|ec|Old Gungeon Red
00|64|00|Cucumber
00|64|42|Aotake Bamboo
00|64|74|Green Spool
00|64|77|Atlantis Myth
00|64|a1|Prime Blue
00|65|6b|Deep Lake
00|65|6e|Wakame Green
00|65|85|Bowerbird Blue
00|65|ac|Wing Commander
00|66|00|Pakistan Green
00|66|58|Dancing Dragonfly
00|66|65|Barbados Bay
00|66|66|Sci-fi Petrol
00|66|cc|Royal Navy Blue
00|66|ff|Blue Ribbon
00|67|a5|Medium Persian Blue
00|67|bc|Sapphire Blue
00|68|00|Forest Ride
00|68|65|Quetzal Green
00|68|6d|Tahitian Treat
00|69|40|Celtic Clover
00|69|67|Chinese Garden
00|69|7c|Caribbean Splash
00|69|8b|Turkish Tile
00|69|94|Sea Blue
00|69|95|Hydra Blue
00|6a|4e|Bottle Green
00|6a|4f|Bangladesh Green
00|6a|50|Peacock Green
00|6a|93|Port Au Prince
00|6b|3c|Cadmium Green
00|6b|54|Ultramarine Green
00|6b|7e|Tahitian Tide
00|6c|67|Green Dragon
00|6c|68|Ocean Oasis
00|6c|7f|Shinbashi Azure
00|6c|8d|Copacabana
00|6c|a9|Indigo Bunting
00|6d|70|Fanfare
00|6e|4e|Watercourse
00|6e|51|Lush Meadow
00|6e|5b|Shady Glade
00|6e|62|Deep Pacific
00|6e|7a|Carnival Night
00|6e|89|Private Eye
00|6e|9d|Disarm
00|6e|c7|Indigo Carmine
00|6f|47|So-Sari
00|70|3c|Dartmouth Green
00|70|44|Diisha Green
00|70|62|Falcon Turquoise
00|70|7d|Iridescent Peacock
00|70|b8|Spanish Blue
00|70|ff|Brandeis Blue
00|71|8a|Waterworld
00|71|a0|Cat's Purr
00|72|8d|Align
00|72|90|Fjord Blue
00|72|b5|Cobalt Glaze
00|72|bb|French Blue
00|73|67|Pharaoh's Gem
00|73|6c|Parasailing
00|73|81|Deep Current
00|73|cf|Wizard Blue
00|74|74|Skobeloff
00|74|8e|Rare Turquoise
00|74|8f|Ocean Mirage
00|74|a4|Singing Blue
00|74|a8|Methyl Blue
00|74|b4|Post It
00|75|4b|Gnarls Green
00|75|58|Bosphorus
00|75|5e|Tropical Rainforest
00|75|6a|Hawk Turquoise
00|75|8f|Mosaic Blue
00|75|90|Cleopatra
00|75|af|Cloisonne
00|75|b3|Brilliant Blue
00|76|cc|Science Blue
00|77|00|Moth Green
00|77|55|Victoria Peak
00|77|65|Teal Waters
00|77|a7|Summer Lake
00|77|b3|Blue Aster
00|77|be|Ocean Boat Blue
00|77|ff|Blue Sparkle
00|78|00|Green Hills
00|78|44|Gale of the Wind
00|78|7f|Hypnotic Sea
00|78|9b|Sea Sight
00|78|a7|Hawaiian Surf
00|78|be|Roller Coaster Chariot
00|78|f8|Blue Darknut
00|79|58|Ivy League
00|79|a9|Sixties Blue
00|7a|5e|Emerald Dream
00|7a|73|Hydra Turquoise
00|7a|8e|Enamel Blue
00|7a|91|Bimini Blue
00|7a|a5|CG Blue
00|7b|43|Tokiwa Green
00|7b|75|Emperor Jade
00|7b|77|Surfie Green
00|7b|84|Mediterranean Cove
00|7b|90|By the Bayou
00|7b|a1|Bleu Ciel
00|7b|a7|Celadon Blue
00|7b|aa|Benitoite
00|7b|b2|Diva Blue
00|7b|b8|Star Command Blue
00|7b|bb|Deep Cerulean
00|7c|75|Romantic Isle
00|7c|78|Navajo Turquoise
00|7c|7a|Blue Grass
00|7c|ac|Jacuzzi
00|7c|b7|Ibiza Blue
00|7d|60|Pepper Green
00|7d|69|Greenlake
00|7d|82|Macquarie
00|7d|ac|Neptune
00|7e|6b|Medieval Forest
00|7e|b0|Capstan
00|7e|b1|Swedish Blue
00|7f|1f|Azure Radiance
00|7f|3a|Charmed Green
00|7f|59|Irish Beauty
00|7f|5c|Spanish Viridian
00|7f|66|Generic Viridian
00|7f|87|Go Alpha
00|7f|a2|Kingfisher Sheen
00|7f|bf|Honolulu Blue
00|7f|ff|Azure
00|80|00|Hulk Green
00|80|0c|Ao
00|80|0f|Office Green
00|80|4c|Picture Book Green
00|80|80|Teal
00|81|7f|Belly Flop
00|81|9d|Caribbean Sea
00|82|7f|Pond Bath
00|82|92|Island Lush
00|82|9e|Decore Splash
00|83|4e|Dark Emerald
00|83|81|Deep Peacock Blue
00|83|84|Marine Teal
00|83|89|Precious Blue
00|83|a8|Bird Of Paradise
00|83|c8|Water Raceway
00|84|00|Lucky Clover
00|84|4b|Deep Watercourse
00|84|6b|Viridis
00|84|91|Tile Blue
00|84|9f|Caneel Bay
00|84|a1|Barrier Reef
00|84|bd|Blithe
00|84|ff|Bubble Bobble P2
00|85|43|Philippine Green
00|85|83|Navigate
00|85|95|Painted Sea
00|85|9c|Algiers Blue
00|85|a1|Blue Arc
00|86|84|Green Lapis
00|86|bb|Dresden Blue
00|87|51|Pixel Nature
00|87|63|Golf Green
00|87|78|Alhambra
00|87|94|Tropical Teal
00|87|99|Capri Breeze
00|87|9f|Eastern Blue
00|87|a1|Gogo Blue
00|87|ad|Lyrebird
00|87|b6|Blue Danube
00|87|bd|Forget-Me-Not
00|88|11|Lush Garden
00|88|88|Green Moblin
00|88|ab|Tiny Bubbles
00|88|b0|Stomy Shower
00|88|dc|Blue Cola
00|89|96|Zuni
00|8a|51|Later Gator
00|8a|7d|Go Go Green
00|8a|ad|Corfu Waters
00|8b|6d|Carolina Green
00|8b|8b|Dark Cyan
00|8c|69|Indonesian Jungle
00|8c|8c|Marrs Green
00|8c|8d|Egyptian Teal
00|8c|96|Lake Blue
00|8c|a9|Quintana
00|8c|c1|Malibu Blue
00|8d|b9|Hawaiian Ocean
00|8e|80|Dynasty Green
00|8e|8d|Corfu Shallows
00|8f|00|Clover
00|8f|70|Observatory
00|90|00|Maniac Green
00|90|51|Moss
00|90|94|Christina Brown
00|90|a8|Mediterranean Blue
00|90|ad|Zeftron
00|91|93|Common Teal
00|92|76|Dòu Lǜ Green
00|92|83|Silk Sari
00|92|88|Columbia
00|92|8c|Supermint
00|92|a1|Jaded
00|92|a3|Oasis
00|92|ad|Cape Pond
00|93|37|Pixelated Grass
00|93|8b|Torrid Turquoise
00|93|af|Munsell Blue
00|93|d6|Kahu Blue
00|94|a7|Brilliant
00|94|c8|Pale Indigo
00|95|5e|Green Gloss
00|95|b6|Bondi Blue
00|96|8f|Reef Encounter
00|96|ff|Starfleet Blue
00|98|c8|UV Light
00|99|00|Islamic Green
00|99|11|Green Gardens
00|99|66|Green Cyan
00|99|77|Cadaverous
00|99|99|Regula Barbara Blue
00|99|cc|Tomb Blue
00|99|ee|Pervenche
00|99|ff|Sky of Magritte
00|9a|70|Rainforest
00|9a|9e|Riviera Paradise
00|9b|75|Simply Green
00|9b|7d|Paolo Veronese Green
00|9b|8c|Spectra Green
00|9d|7d|Tropical Kelp
00|9d|94|Caribbean Turquoise
00|9d|ae|Bluebird
00|9d|c4|Ocean Blue
00|9e|60|Shamrock
00|9e|6c|Highlighter Turquoise
00|9e|6d|Deep Mint
00|9e|82|Reptilian Green
00|9f|6b|Surgeon Green
00|a0|93|Teal Trip
00|a0|b0|Breaking Wave
00|a2|8a|Arcadia
00|a2|9e|Aqua Velvet
00|a3|e0|Vanadyl Blue
00|a4|66|Jungle
00|a4|83|Congo Green
00|a4|9b|Grecian Isle
00|a5|50|Green Pigment
00|a6|93|Persian Green
00|a7|76|Blarney
00|a7|8b|Moray Eel
00|a8|00|Aquamentus Green
00|a8|44|Poetic Green
00|a8|6b|Jade
00|a8|70|Sesame Street Green
00|a8|77|Dragon Scale
00|a9|90|Shindig
00|aa|00|Phosphor Green
00|aa|22|Kobra Khan
00|aa|55|Rita Repulsa
00|aa|66|Greedo Green
00|aa|92|Billiard
00|aa|aa|Jade Orchid
00|aa|ee|Vivid Cerulean
00|aa|ff|Protoss Pylon
00|ab|66|Go Green!
00|ab|c0|Scuba Blue
00|ad|43|Poison Ivy
00|af|9d|Pool Green
00|b1|91|Victorian Greenhouse
00|b1|d2|Blue Atoll
00|b6|94|Mint Leaf
00|b7|eb|Cyanite
00|b8|00|Bubble Bobble Green
00|b8|9f|Aare River
00|b9|fb|Blue Bolt
00|bb|00|Green Glimmer
00|bb|55|Pistou Green
00|bb|66|Green Elliott
00|bb|aa|Verditer
00|bb|ff|Hawaii Morning
00|bf|fe|Tractor Beam
00|bf|ff|Capri
00|c0|00|Waystone Green
00|c4|b0|Amazonite
00|c5|cd|Turquoise Surf
00|cc|00|Demeter Green
00|cc|33|Vivid Malachite
00|cc|99|Caribbean Green
00|cc|cc|Robin's Egg Blue
00|cc|ee|Picnic Day Sky
00|cc|ff|Vivid Sky Blue
00|ce|d1|Jade Dust
00|dd|00|Greenalicious
00|dd|cc|Mint Morning
00|e4|36|Lexaloffle Green
00|e8|d8|First Timer Green
00|ee|00|Delightful Green
00|f9|00|Spring
00|fa|92|Ahaetulla Prasina
00|fa|9a|Medium Spring Green
00|fb|b0|Greenish Turquoise
00|fc|fc|Arctic Water
00|fd|ff|Fluorescent Turquoise
00|ff|00|Green
00|ff|55|Cathode Green
00|ff|77|Booger Buster
00|ff|7c|Spring Green
00|ff|7f|Guppie Green
00|ff|99|Green Gas
00|ff|aa|Enthusiasm
00|ff|ee|Master Sword Blue
00|ff|ef|Turquoise Blue
00|ff|fe|Spanish Sky Blue
00|ff|ff|Aqua
01|02|03|Black Hole
01|0b|13|Black Knight
01|0f|cc|True Blue
01|15|3e|Navy
01|19|93|Bright Midnight
01|23|89|Dark Powder Blue
01|24|8f|Neutrino Blue
01|27|31|Daintree
01|32|20|Nightly Woods
01|38|6a|Marine Blue
01|41|82|Darkish Blue
01|44|20|Deep Pond
01|44|21|Broadleaf Forest
01|44|26|Deep Forest Green
01|44|31|UP Forest Green
01|46|00|Racing Green
01|4b|43|Aqua Deep
01|4d|4e|Dark Teal
01|4e|83|Cook's Bay
01|54|82|Deep Lake Blue
01|63|60|Emerald Stone
01|65|fc|Bright Blue
01|66|12|Zelyony Green
01|67|95|Peacock Blue
01|6e|61|Forest Splendor
01|73|71|Dark Aquamarine
01|73|74|Natural Instinct Green
01|74|8e|Amulet Gem
01|79|6f|Pond Moss
01|7a|79|Buzzards Bay
01|7b|92|Jade Shard
01|82|81|Windows 95 Desktop
01|88|9f|Teal Blue
01|93|c2|Surf Rider
01|95|29|Irish Green
01|a0|49|Link Green
01|a3|68|Green Haze
01|ab|fd|Krishna Blue
01|ad|8f|Hobgoblin
01|b4|4c|Praxeti White
01|c0|8d|Cōng Lǜ Green
01|f1|f1|Aqua Cyan
01|f9|c6|Bright Teal
01|ff|01|Venom Dart
01|ff|07|EGA Green
02|00|35|Midnight Blue
02|03|e2|Pure Blue
02|06|6f|Dark Royal Blue
02|1b|f9|Rich Blue
02|47|8e|Congress Blue
02|47|fe|Magic Ink
02|4a|43|Tropical Forest
02|4a|ca|Flying Fish Blue
02|51|7a|Silk Jewel
02|59|0f|Deep Green
02|64|ae|Cobalt Stone
02|6b|5d|Pacific Queen
02|6b|67|Chitin Green
02|70|8c|Teal Tune
02|72|75|Scaly Green
02|73|7a|Scurf Green
02|79|44|Blarney Stone
02|8a|52|English Meadow
02|8f|1e|Emerald
02|93|86|Old Benchmark
02|9d|74|Free Speech Aquamarine
02|ab|2e|Kelley Green
02|c1|4d|Lǜ Sè Green
02|cc|fe|Bright Sky Blue
02|d8|e9|Thousand Sons Blue
03|01|2d|Midnight
03|02|05|Raven's Coat
03|03|03|Armor Wash
03|07|64|D. Darx Blue
03|0a|a7|Cobalt
03|16|02|Oil Slick
03|35|00|Dark Green
03|39|f8|Vibrant Blue
03|43|df|Merchant Marine Blue
03|4a|71|Broadwater Blue
03|4c|67|Fresco Blue
03|4f|7c|China Seas
03|4f|84|Snorkel Blue
03|50|96|Medium Electric Blue
03|54|53|Pacific Storm
03|55|68|Plunge
03|5b|8d|Buccaneer Blue
03|71|9c|Tofino Belue
03|84|87|Milky Aquamarine
03|8c|67|Kabalite Green
03|8e|85|Aqua Experience
03|94|87|Approval Green
03|b4|c8|Iris Blue
03|c0|3c|Dark Pastel Green
04|02|73|Deep Blue
04|03|48|Night Blue
04|11|08|Jedi Night
04|2e|60|Marine
04|33|ff|Nightly Escapade
04|4a|05|Kabocha Green
04|4f|67|Hanada Blue
04|5c|5a|Dark Turquoise
04|5c|61|Enamelled Jewel
04|62|7a|Jamaican Dream
04|63|07|Emerald Green
04|65|0d|Apple II Green
04|74|95|Enchanted Blue
04|74|ad|Reef Escape
04|77|b4|Americana
04|80|bd|Phuket Palette
04|82|43|Jungle Green
04|85|d1|Calgar Blue
04|d8|b2|Channel Marker Green
04|d9|ff|Neon Blue
04|f4|89|Turquoise Green
05|04|aa|Traditional Royal Blue
05|0d|25|Void
05|10|09|Alpine Salamander
05|10|40|Deep Cove
05|39|76|Azure Dragon
05|47|2a|Alaskan Moss
05|48|0d|British Racing Green
05|49|07|Borg Queen
05|4c|8a|Magnetic Blue
05|69|6b|Dark Aqua
05|6e|ee|Níu Zǎi Sè Denim
05|90|33|North Texas Green
05|ff|a6|Yíng Guāng Sè Green
06|00|30|Erebus Blue
06|03|10|Broken Tube
06|03|13|Obsidian Shard
06|06|06|Black Metal
06|10|88|Yearning
06|2a|78|Catalina Blue
06|2e|03|Very Dark Green
06|47|0c|Borg Drone
06|4d|83|Dance Studio
06|52|ff|Blue et une Nuit
06|73|76|Greeny Glaze
06|8e|9e|Coral Coast
06|9a|f3|Fresh Blue of Bel Air
06|b1|c4|Antigua Blue
06|b4|8b|Chromophobia Green
06|c2|ac|Turquoise
07|0d|0d|Almost Black
07|48|63|Stegadon Scale Green
07|6a|7e|Porpoise Place
07|7a|7d|Tobernite
08|04|f9|Primary Blue
08|08|08|Reversed Grey
08|08|13|Narwhale Grey
08|25|67|Dark Sapphire
08|25|99|Deep Sapphire
08|45|7e|Dark Cerulean
08|58|9d|Victoria Blue
08|71|70|Boating Green
08|78|30|La Salle Green
08|78|7f|Deep Aqua
08|81|d1|Electron Blue
08|8d|46|Grass Court
08|92|d0|Rich Electric Blue
08|94|04|True Green
08|e8|de|Bright Turquoise
08|ff|08|Fluorescent Green
09|00|45|Ultramarine Shadow
09|08|07|Accursed Black
09|1f|92|Celestial Indigo
09|22|56|Downriver
09|51|55|Emerald Spring
09|58|59|Deep Sea Green
09|5d|75|Glass Sea
09|68|72|Kingfisher Bright
09|79|88|Biscay Bay
09|f9|11|Free Speech Green
0a|05|02|Liquorice
0a|09|08|Badab Black Wash
0a|0a|0a|Existential Angst
0a|11|95|Cadmium Blue
0a|43|7a|Twilight Blue
0a|48|0d|Dark Fern
0a|48|1e|Pine Green
0a|5f|38|Spruce
0a|6b|92|Cairns
0a|6f|69|Tidepool
0a|7e|8c|Metallic Seaweed
0a|88|8a|Old Truck
0a|91|bf|Swimmer
0a|98|ac|Aquarium Diver
0a|ba|b5|Jade Gravel
0a|dd|08|Vibrant Green
0a|ff|02|Fluro Green
0b|08|5f|Dark Prussian Blue
0b|0b|0b|Darth Vader
0b|40|08|Hunter Green
0b|47|4a|Incubi Darkness
0b|53|69|Ink Blue
0b|55|09|Forest
0b|59|7c|Commandes
0b|69|5b|Bella Vista
0b|8b|87|Greenish Blue
0b|da|51|Malachite
0b|f7|7d|Minty Green
0b|f9|ea|Bright Aqua
0c|06|f7|Strong Blue
0c|0c|0c|Black Wash
0c|0c|1f|Tristesse
0c|17|93|Royal
0c|60|8e|Pontoon
0c|b5|77|Green Teal
0c|bf|e9|Blue Raspberry
0c|dc|73|Tealish Green
0c|ff|0c|Alien Abduction
0d|2e|1c|Bush
0d|44|62|Forest Blues
0d|5e|af|Greek Flag Blue
0d|61|83|Blue Velvet
0d|63|49|Green Paw Paw
0d|75|f8|Deep Sky Blue
0d|78|9f|Mitchell Blue
0d|ac|a7|Teal Me No Lies
0e|3a|53|Sailor Blue
0e|4d|4e|Port Malmesbury
0e|4d|72|Sail Maker
0e|60|71|Nocturnal Sea
0e|69|5f|Evergreen Forest
0e|7c|61|Turquoise Cyan
0e|7f|78|Coelia Greenshade
0e|81|b9|Tall Ships
0e|87|cc|Water Blue
0e|9c|a5|Boy Red
0f|07|07|Knight Rider
0f|08|09|Chyornyi Black
0f|0b|0a|Stout
0f|0f|0f|Chaos Black
0f|10|12|Ruined Smores
0f|38|0f|Gameboy Contrast
0f|3b|57|Blue Opal
0f|46|45|Cyprus
0f|47|8c|Mondrian Blue
0f|4c|81|Classic Blue
0f|4d|92|Yale Blue
0f|4e|67|Moroccan Blue
0f|52|ba|Sapphire
0f|5a|5e|Blue Emerald
0f|5f|9a|Daphne
0f|63|b3|Les Cavaliers Beach
0f|8b|8e|Duvall
0f|9b|8e|Stormy Strait Green
0f|9b|c0|Sea Wonder
0f|9d|76|Holly Green
0f|c0|fc|Spiro Disco Ball
0f|f0|fc|Electric Cyan
0f|f0|fe|Cyan
0f|fe|f9|Kaltes Klares Wasser
10|0c|08|Smoky Black
10|34|a6|Egyptian Blue
10|4a|65|Victorian Peacock
10|4c|77|Seashell Cove
10|56|73|Tardis
10|60|5a|Empress Teal
10|6b|21|Avagddu Green
10|7a|b0|Nice Blue
10|87|80|Porcelain Green
10|a6|74|Bluish Green
11|00|11|Glossy Black
11|00|22|Space Grey
11|00|33|Black Htun
11|00|aa|Groundwater
11|01|01|Dark Matter
11|11|00|Chinese Black
11|11|11|Dreamless Sleep
11|11|22|Corbeau
11|22|00|Yuzu Soy
11|22|11|Nightmare
11|22|22|Dark Charcoal
11|22|33|Fog of War
11|2a|12|Nori Green
11|33|33|Storm Green
11|42|5d|Neptune's Wrath
11|44|77|Inoffensive Blue
11|57|4a|Evergreen
11|5a|82|Whale's Tale
11|63|56|Deep Veridian
11|64|b4|Ephren Blue
11|66|ff|Heroic Blue
11|6f|26|Bogey Green
11|7b|87|Alpine Landing
11|87|5d|Dark Sea Green
11|88|7b|Green Ink
11|99|44|Boogie Blast
11|99|ff|Blue Nebula
11|bb|00|Green Gamora
11|bb|11|Emerald Starling
11|bb|33|Green Goblin
11|cc|55|Battletoad
11|cc|bb|Exquisite Turquoise
11|ee|00|Squeeze Toy Alien
11|ee|55|Mike Wazowski Green
11|ee|ee|Phosphorescent Blue
11|ff|00|Phosphorescent Green
12|0a|8f|Blue Trust
12|12|12|Dark Tone Ink
12|31|20|Méi Hēi Coal
12|34|56|Incremental Blue
12|35|24|Phthalo Green
12|38|50|Gibraltar Sea
12|39|0d|Melancholia
12|39|55|Poseidon
12|40|3c|Botanical Night
12|54|59|Seaworld
12|57|61|Baltic Trench
12|61|80|Blue Sapphire
12|63|66|Caribbean Swim
12|67|4a|Verdant Green
12|72|a3|Quarterdeck
12|73|2b|Clear Green
12|74|53|Green Velvet
12|7e|93|Pagoda
12|9c|8b|Flamboyant
12|e1|93|Aqua Green
13|01|73|Quantum of Light
13|0a|06|Asphalt
13|13|13|Kettle Black
13|45|58|Sultan's Silk
13|59|52|Baltic Prince
13|68|43|Jewel
13|6c|51|Martian Green
13|77|30|Intermediate Green
13|7e|6d|Blue Green
13|88|08|India Green
13|9d|08|Space Invader
13|bb|af|Turquoise Topaz
13|ea|c9|Fake Jade
14|10|0e|Nuln Oil
14|14|14|Sooty
14|15|1d|Kuroi Black
14|20|30|Hēi Sè Black
14|2d|25|Guerrilla Forest
14|57|75|The Broadway
14|6b|47|Caterpillar Green
14|78|a7|Tanzanite
14|a3|c7|Cyan Blue
15|15|15|Matt Black
15|15|1c|Absence of Light
15|2e|ff|Vivid Blue
15|44|06|Forest Green
15|46|47|Prestige Green
15|50|84|Light Navy
15|51|87|Baleine Blue
15|58|43|Billiard Table
15|59|db|Chun-Li Blue
15|5e|60|Emerald Pool
15|60|bd|Amnesia Blue
15|60|fb|Y7K Blue
15|63|3d|Fun Green
15|64|6d|Seamount
15|79|54|Opal Green
15|7e|a0|Bluejay
15|80|78|Autumn Pine Green
15|ab|be|Future
15|b0|1a|Pikkoro Green
15|f2|fd|Lightsaber Blue
16|11|0d|Black Raspberry
16|14|10|King Kong
16|16|0e|Darkness
16|16|16|Pot Black
16|16|1d|Eigengrau
16|18|20|River Styx
16|49|75|Linear
16|5b|31|Crusoe
16|5d|95|Lapis Jewel
16|64|61|Dark Chlorophyll
16|69|8c|Bondi
16|7e|65|Deep Sea
16|83|40|Warpstone Glow
16|9e|c0|Delos Blue
16|a0|a6|Ducati
16|f8|ff|Hey Blue!
17|13|10|Nuln Oil Gloss
17|14|12|Kokushoku Black
17|17|17|Cynical Black
17|18|1c|Aswad Black
17|18|2b|Sambucus
17|18|4b|Tetsu-Kon Blue
17|28|08|Lindworm Green
17|46|2e|Zucchini
17|56|9b|Sonic Blue
17|58|44|Rousseau Green
17|72|45|Dark Spring Green
17|7b|4d|Salem
17|80|6d|Tropical Green
17|91|7f|Miami Jade
17|9f|a6|Will
18|05|db|Ultramarine
18|06|14|Crow Wing
18|18|18|Thamar Black
18|1b|26|Coarse Wool
18|43|43|Tiber
18|45|3b|MSU Green
18|4a|45|Forest Biome
18|51|5d|Genetic Code
18|57|6c|Corsair
18|58|87|Stunning Sapphire
18|6d|b6|Beautiful Blue
18|88|0d|Verse Green
18|8b|c2|Cyan Cornflower Blue
18|90|86|Ocean Liner
18|9f|ac|Riviera
18|d1|7b|Seaweed
19|19|70|20000 Leagues Under the Sea
19|1f|45|Konkikyō Blue
19|22|36|Kon
19|39|25|Deep Fir
19|44|3c|Black Soap
19|50|4c|Lacustral
19|51|55|Deep Sanction
19|51|90|Turkish Sea
19|54|56|Ramsons
19|56|5e|Uncharted
19|59|05|Lincoln Green
19|74|d2|Bright Navy Blue
19|93|be|Spa Dream
19|9e|bd|Ahriman Blue
19|a7|00|Peter Pan
19|b6|b5|Swagger
1a|11|10|Licorice
1a|1b|1c|Gluon Grey
1a|24|21|Dark Jungle Green
1a|25|78|Impression of Obscurity
1a|41|57|Capital Blue
1a|48|76|Bright Midnight Blue
1a|4c|8b|Olympian Blue
1a|50|91|Nautical Blue
1a|58|97|Suddenly Sapphire
1a|6c|76|Teal Fury
1a|7f|8e|Pagoda Blue
1a|95|97|Sea Fantasy
1a|9d|49|Get Up and Go
1a|b3|85|Dark Mountain Meadow
1a|c1|dd|Caribbean Blue
1b|18|11|Nightshade Berries
1b|1b|1b|Eerie Black
1b|24|31|Dark
1b|26|32|Abyssal Anchorfish Blue
1b|29|4b|Rurikon Blue
1b|2b|1b|Kuro Green
1b|34|27|Cardin Green
1b|45|56|Dark Border
1b|46|36|Sherwood Green
1b|4b|35|County Green
1b|4d|3e|Brunswick Green
1b|4d|3f|English Green
1b|53|66|Blue Coral
1b|6f|81|Billabong
1b|75|98|Bateau
1b|7d|8d|Bermuda
1b|81|88|Riviera Sea
1b|8a|6b|Elf Green
1b|a1|69|Biel-Tan Green
1b|fc|06|Highlighter Green
1c|12|08|Crowshead
1c|1b|1a|Siyâh Black
1c|1c|f0|Bluebonnet
1c|28|41|Yankees Blue
1c|30|5c|Ending Navy Blue
1c|33|82|Bavarian Blue
1c|35|2d|Medium Jungle Green
1c|39|bb|Persian Blue
1c|43|74|Assault
1c|50|22|Białowieża Forest
1c|55|44|Bagpiper
1c|57|98|Florentine Lapis
1c|6b|69|Mosaic Tile
1c|70|ad|Planetarium
1c|8a|c9|Newport Blue
1c|a9|c9|Pacific Blue
1c|ac|78|Bright Camouflage
1c|d3|a2|Wild Caribbean Green
1d|02|00|Very Dark Brown
1d|29|51|Space Cadet
1d|2b|53|Pico Void
1d|39|3c|Nordic
1d|47|69|Superstar
1d|4e|8f|Sweat Bee
1d|56|71|Canoe Blue
1d|56|99|Blue Chip
1d|5c|83|Animation
1d|5d|ec|Azul
1d|69|7c|Hanaasagi Blue
1d|78|81|Blue Kelp
1d|78|ab|Larimar Blue
1d|ac|78|Crayola Green
1d|ac|d1|Hú Lán Blue
1d|ac|d4|Battery Charged Blue
1d|ac|d6|Bright Cerulean
1d|b3|94|Aloha
1d|f9|14|Lime Shot
1e|27|2c|Black Pearl
1e|2f|3c|Tangaroa
1e|34|42|Blue Whale
1e|44|69|Lucidity
1e|44|6e|Fish Net Blue
1e|48|8f|Nuit Blanche
1e|4d|2b|Cal Poly Pomona Green
1e|50|a2|Ruri Blue
1e|7e|9a|Blue Mediterranean
1e|7e|ae|Blue Vacation
1e|80|c7|Eye Blue
1e|8c|ab|Mediterranean Sea
1e|8e|a1|Safe Harbour
1e|90|ff|Clear Chill
1e|91|67|Viridian
1e|97|52|Garnish
1e|98|ae|Tropical Lagoon
1e|f8|76|Synthetic Spearmint
1f|09|54|Dark Indigo
1f|0b|1e|Meški Black
1f|26|2a|Dark Gunmetal
1f|34|65|Passionate Blue
1f|3b|4d|Dark Blue Grey
1f|47|88|Indigo Hamlet
1f|49|5b|Legion Blue
1f|54|29|Waaagh! Flesh
1f|56|a7|Altdorf Guard Blue
1f|59|5c|Pacific
1f|5d|a0|Drakenhof Nightshade
1f|63|57|Dark Green Blue
1f|66|80|Saxony Blue
1f|69|54|Celtic Green
1f|6a|7d|Allports
1f|70|73|Marine Wonder
1f|75|fe|Clouded Blue
1f|75|ff|Magic Fountain
1f|7f|76|Geneva Green
1f|a7|74|Cǎo Lǜ Grass
1f|ab|58|Nordic Grass Green
1f|b5|7a|Dark Seafoam
1f|ce|cb|Blue Martina
20|00|6d|Bavarian Gentian
20|00|b1|Deep Sea Exploration
20|12|0e|Bighorn Sheep
20|18|19|Kālā Black
20|34|62|Navy Trim
20|38|38|Kōrainando Green
20|39|2c|Palm Green
20|3b|3d|Ponderosa Pine
20|3c|7f|Surf the Web
20|3e|4a|Reflecting Pond
20|3f|58|Regal Blue
20|41|5d|Sir Edmund
20|4f|54|Immersed
20|57|6e|Navy Teal
20|69|37|Camarone
20|6d|71|Peacock Plume
20|70|6f|Bayou
20|72|6a|Advantageous
20|88|7a|Palm Springs Splash
20|99|bb|Butterfly Blue
20|ae|a7|Tropical Tree
20|b2|aa|Glass Jar Blue
20|b5|62|Future Hair
20|c0|73|Dark Mint Green
20|f9|86|Wintergreen
21|08|37|Middle Red Purple
21|16|40|Prune Plum
21|21|21|Lead
21|26|3a|Midnight Express
21|30|3e|Imperial Primer
21|36|31|Pine Grove
21|36|38|Cruel Sea
21|38|ab|Yuè Guāng Lán Blue
21|40|48|Bay Isle Pointe
21|42|1e|Myrtle
21|42|4d|Winter Waves
21|42|6b|Blue Mosque
21|45|59|Astronaut Blue
21|47|61|Dark Slate Blue
21|4f|c6|New Car
21|53|54|Forbidden Forest
21|53|99|Summer Waters
21|69|87|Sea Goddess
21|6b|d6|Flickr Blue
21|8b|a0|Waikiki
21|a5|be|Maui
21|ab|cd|Ball Blue
21|c3|6f|Algal Fuel
21|c4|0e|Crude Banana
21|fc|0d|Electric Green
22|00|00|Ponzu Brown
22|00|11|Belladonna
22|00|22|Black Sabbath
22|00|33|Coalmine
22|00|55|Crowberry
22|00|99|Blue Beetle
22|08|78|Prunelle
22|11|00|Super Black
22|22|00|Liquorice Root
22|22|11|Deepsea Kraken
22|22|33|Black Velvet
22|33|99|North Star Blue
22|3a|5e|Navy Peony
22|42|c7|Blue Blue
22|43|47|Emerald Forest
22|43|76|Demon
22|43|b6|Denim
22|46|34|Birōdo Green
22|52|58|Hidden Waters
22|58|69|Bright Nautilus
22|5e|64|Gulf Harbour
22|69|ca|Mimesia Blue
22|6c|63|Ivy
22|82|a8|Blue Paisley
22|8b|21|Tropical Forest Green
22|8b|22|Summer Forest Green
22|99|55|Militant Vegan
22|aa|00|Vegetarian
22|ac|ae|Greenland Green
22|bb|55|Vegan Mastermind
22|bb|66|Welsh Onion
22|bb|88|Vegan
22|ff|22|Plastic Veggie
23|17|12|Used Oil
23|19|1e|Kurobeni
23|1f|20|Abaddon Black
23|23|23|Young Night
23|29|7a|St. Patrick's Blue
23|2b|2b|Charleston Green
23|2e|26|Quartzite
23|2f|2c|Ardósia
23|2f|36|Freinacht Black
23|31|2d|Scarab
23|36|58|Estate Blue
23|3e|57|Integrity
23|41|4e|Green Vogue
23|41|62|Alpine Race
23|42|72|Cold Current
23|45|37|Burnham
23|4e|86|Night Mode
23|66|49|Brunswick
23|7f|ac|Blue Bird Day
23|c4|8b|Píng Gǔo Lǜ Green
24|21|24|Raisin Black
24|24|6d|After Work Blue
24|25|2b|Black Russian
24|27|2e|Black Grey
24|2a|2e|Cinder
24|2e|28|Midnight Moss
24|32|56|Boatswain
24|36|40|Elephant
24|3f|6c|Limoges
24|43|43|Metal Deluxe
24|50|56|Paua Shell
24|53|36|Kaitoke Green
24|54|9a|Blue Sail
24|58|78|Sea Hunter
24|64|53|Embracing
24|6b|ce|Celtic Blue
24|73|45|Felt
24|7a|fd|Clear Blue
24|7e|81|Jade Jewel
24|85|91|River Fountain
24|91|48|Paperboy's Lawn
24|a0|ed|Button Blue
24|a4|c8|Celestine Spring
24|bc|a8|Tealish
24|da|91|Reptile Green
25|17|06|Cannon Black
25|23|21|Black Chestnut Oak
25|25|25|Nero
25|25|2c|Closed Shutter
25|2f|2f|Swamp Mosquito
25|34|2b|Holly
25|35|29|Black Leather Jacket
25|36|68|Sodalite Blue
25|3c|48|Tarawera
25|3f|4e|Nile Blue
25|3f|74|Blue Expanse
25|41|5d|Blue Accolade
25|44|45|Sea Moss
25|46|36|Wine Bottle Green
25|48|55|Mallard
25|4a|47|Deep Pine
25|53|67|Juggernaut
25|59|58|Bayberry
25|59|7f|Bahama Blue
25|5b|77|Orient
25|5c|61|Deep Sea Diver
25|97|97|Java
25|99|b2|Pelorus
25|a3|6f|Teal Green
25|b3|87|Jess
25|c4|0d|Apple II Lime
25|e2|cd|Ice Climber
25|ff|29|Hot Green
26|23|35|Cold Steel
26|26|2a|Black Beauty
26|29|34|Sky Captain
26|2b|2f|Blue Charcoal
26|2c|2a|Jet Set
26|30|56|Blue Depths
26|40|66|Elmer's Echo
26|42|8b|Dark Cornflower Blue
26|43|34|Everglade
26|43|48|Japanese Indigo
26|4a|48|June Bug
26|4c|47|Amphibian
26|4d|8e|Unity
26|4e|50|Seagrass Green
26|53|8d|Vegeta Blue
26|60|4f|Evening Sea
26|61|9c|Lapis Lazuli
26|62|3f|Fairway Green
26|62|42|Green Pea
26|62|55|Eden
26|66|91|Deep Water
26|a5|ba|Jamaican Sea
26|a6|be|Minted Blue
26|f7|fd|Bright Light Blue
27|22|1f|Orka Black
27|27|5f|Deep Breath
27|29|3d|Maritime Blue
27|2d|4e|Wahoo
27|2f|38|Chimney Sweep
27|3b|e2|Palatinate Blue
27|3c|5a|Dark Catalina
27|3c|76|Mazarine Blue
27|3e|51|Asurmen Blue Wash
27|3f|4b|Bakos Blue
27|42|34|English Holly
27|42|42|Theatre Dress
27|42|56|Reef Resort
27|42|6b|Nightlife
27|43|57|Majolica Blue
27|43|74|Monaco Blue
27|44|47|Ai Indigo
27|4a|5d|Arapawa
27|4e|55|Atlantic Deep
27|54|6e|Diver Lady
27|66|ac|Barbados Blue
27|68|78|Discovery Bay
27|6a|b3|Mid Blue
27|6b|40|Billiard Ball
27|75|94|Devil Blue
27|92|c3|Porpita Porpita
27|9d|9f|Baltic
28|01|37|Midnight Purple
28|1a|14|Tetsu-Guro Black
28|28|28|Dire Wolf
28|28|2d|Anthracite
28|2a|4a|Royal Curtsy
28|2b|34|Salute
28|2d|3c|Navy Blazer
28|31|4d|Blue Lobelia
28|34|82|Migol Blue
28|3b|4c|Harpoon
28|3c|44|Cool Current
28|4f|bd|Apnea Dive
28|58|9c|Cyan Cobalt Blue
28|59|91|Blue Regent
28|5b|5f|Inner Space
28|63|ad|Rainbow Bright
28|64|92|Starry Night
28|7c|37|Darkish Green
28|9d|be|Horizon Blue
28|a4|cb|Sardinia Beaches
29|0e|05|Root Brew
29|21|7a|Blue Royale
29|29|2f|Jaguar
29|2a|2d|Caviar
29|2c|2c|Blackadder
29|2c|2f|Bunker
29|2d|4f|Lucky Point
29|2e|44|Latin Charm
29|30|4e|Medieval Blue
29|32|86|Ritterlich Blue
29|33|2b|Gordons Green
29|34|32|Aztec
29|36|48|Willow Blue
29|39|47|Adept
29|3b|4a|Craft
29|3b|4d|Moonlit Ocean
29|3f|54|Blue Shade Wash
29|46|5b|Dark Grey Blue
29|49|5c|Deep Dive
29|51|8c|Blue Nude
29|54|68|Wakefield
29|59|8b|Endeavour
29|67|5c|Antique Green
29|68|5f|Galapagos Green
29|6a|9d|Blues
29|6d|93|Blue Oasis
29|76|bb|Bluish
29|7b|76|Elm
29|7c|bf|Amalfi Coast
29|7e|6b|Green Fingers
29|84|8d|Sea Bed
29|90|6d|Leprechaun
29|99|a2|Mediterranean Swirl
29|a9|8b|Niagara
29|ab|87|Herbal
29|ad|ff|Fantasy Console Sky
2a|01|34|Very Dark Purple
2a|24|24|Gold Black
2a|25|51|Paua
2a|27|25|Bokara Grey
2a|29|22|Maire
2a|29|3e|Evening Blue
2a|2a|35|Night Sky
2a|2b|2d|Tap Shoe
2a|2b|41|Valhalla
2a|2c|1f|Aircraft Green
2a|2e|44|Sea Going
2a|2f|23|Pine Tree
2a|31|49|Ahoy
2a|32|44|Dress Blues
2a|40|41|Liquorice Green
2a|40|71|Mystification
2a|48|45|Platoon Green
2a|4b|5f|Deep Ocean
2a|4b|6e|Blue Tang
2a|4b|7c|Galaxy Blue
2a|52|be|Cerulean Blue
2a|54|43|Fresh Mint
2a|54|5c|Deep Emerald
2a|57|74|Sacrifice
2a|5c|6a|Night Shift
2a|60|3b|Midori
2a|62|95|Outer Reef
2a|6a|8b|Faience
2a|72|79|King Tide
2a|7e|19|Tree Green
2a|80|00|Napier Green
2a|81|4d|Bold Irish
2a|8f|bd|Christmas Blue
2a|96|d5|Boyzone
2a|9c|a0|Empress Envy
2a|aa|45|Vitalize
2a|fe|b7|Greenish Cyan
2b|02|02|Sepia Black
2b|20|28|Shikon
2b|27|2b|Black Onyx
2b|2b|2b|Wax
2b|2c|30|Stretch Limo
2b|2e|25|Rangoon Green
2b|2e|26|Marshland
2b|2e|43|Peacoat
2b|2f|41|Atlantic Charter
2b|2f|43|Blue Exult
2b|30|42|Black Iris
2b|32|30|Woodsmoke
2b|34|48|Aeronautic
2b|34|49|Bunting
2b|37|33|Tetsu Black
2b|37|36|Tetsuonando Black
2b|3d|54|Sharp Blue
2b|3e|52|Snap-Shot
2b|3f|36|Celtic
2b|3f|5c|Antarctic Blue
2b|40|57|Blue Tone Ink
2b|4b|40|Te Papa Green
2b|4d|68|Singing the Blues
2b|52|6a|Shimmering Sea
2b|55|3e|Green Stain
2b|5d|34|Pine
2b|62|f4|Retro Blue
2b|64|60|Strong Sage
2b|64|ad|Shukra Blue
2b|65|5f|Alliance
2b|68|67|Magnetic Green
2b|6c|8e|Ocean Call
2b|79|7a|Atoll
2b|7b|66|Pinehurst
2b|88|8d|Turkish Jade
2b|8c|4e|St.Patrick
2b|98|90|Azure Tide
2b|a7|27|Dry Highlighter Green
2b|ae|66|Island Green
2b|af|6a|Jade Powder
2b|b1|79|Salsify Grass
2c|16|08|Zinnwaldite Brown
2c|21|33|Bleached Cedar
2c|2a|33|Deep Well
2c|2a|35|Haiti
2c|2c|32|Bastille
2c|2d|24|Green Waterloo
2c|2d|3c|Black Rock
2c|31|3d|Total Eclipse
2c|32|27|Ebony Wood
2c|35|39|Dracula Orchid
2c|36|41|Anchorman
2c|39|44|Precision
2c|3b|4d|Blue Fantastic
2c|3e|56|Academic Blue
2c|40|53|Blue Wing Teal
2c|46|41|Gable Green
2c|4d|69|Celestial Blue
2c|54|63|Glitch
2c|57|78|Venice Blue
2c|58|5c|Sea Challenge
2c|59|71|Chathams Blue
2c|5c|4f|Old Money
2c|6e|31|San Felix
2c|6f|bb|Matt Blue
2c|b1|eb|Lynx Screen Blue
2c|ba|a3|Capture
2c|fa|1f|Radioactive Green
2d|19|62|Night Fog
2d|25|41|Tolopea
2d|2c|2f|Jet Black
2d|2d|24|Karaka
2d|2f|28|Eternity
2d|30|32|Cod Grey
2d|33|59|Quill Tip
2d|35|44|Pacific Line
2d|38|3a|Far Away Grey
2d|3a|49|Ship's Officer
2d|3c|44|Sea Deep
2d|3c|54|Madison
2d|44|36|Mushiao Green
2d|45|4a|Little Mermaid
2d|49|82|Coastal Surf
2d|4a|4c|Delta Green
2d|4f|83|Assassin
2d|51|7c|Slumber
2d|52|54|Microwave Blue
2d|53|5a|Sea of Atlantis
2d|53|60|Blue Bayberry
2d|53|67|Regatta Bay
2d|53|84|Boat Blue
2d|56|7c|Breonne Blue
2d|59|75|Mountain Lake
2d|5e|22|Bright Nori
2d|62|a3|Nebulas Blue
2d|64|71|Colonial Blue
2d|7f|6c|Green Belt
2d|96|ce|Astrolab Reef
2d|a4|b6|Sparkling Cove
2d|df|c1|Celestial Green
2d|fe|54|Bright Light Green
2e|03|29|Globe Thistle
2e|18|3b|Blackcurrant
2e|21|1b|Kenpōzome Black
2e|22|49|Elderberry
2e|2d|88|Cosmic Cobalt
2e|2f|31|Black Cat
2e|32|22|Rangitoto
2e|32|8f|Ultramarine Highlight
2e|37|2e|Aimiru Brown
2e|37|49|German Liquorice
2e|38|40|Electromagnetic
2e|3d|30|Mountain View
2e|48|46|Black Water
2e|4a|7d|Nautical
2e|4b|3c|Norfolk Green
2e|4c|5b|Celtic Rush
2e|50|8a|Regal Destiny
2e|50|90|YInMn Blue
2e|51|69|Blue Lava
2e|52|6a|Ocean Trapeze
2e|56|86|Royal Consort
2e|57|67|Deep Loch
2e|58|94|B'dazzled Blue
2e|5a|50|Holly Leaf
2e|5a|88|Light Navy Blue
2e|5c|58|Lacrosse
2e|5f|60|Calypso Green
2e|64|69|Deep Marine
2e|71|76|Whaling Waters
2e|7b|52|Canadian Pine
2e|8b|57|Lake Green
2e|a7|85|Gumdrop Green
2e|e8|bb|Aquamarine
2f|2d|30|Moonless Night
2f|2f|48|Black Blueberry
2f|2f|4a|Wild Iris
2f|38|44|Royal Battle
2f|39|46|Biro Blue
2f|3c|53|Biscay
2f|3e|55|Insignia Blue
2f|3f|53|Waterhen Back
2f|48|4e|Dad's Coupe
2f|4f|4f|Dark Slate Grey
2f|56|84|Mordian Blue
2f|5d|50|Velvet Green
2f|66|79|San Gabriel Blue
2f|75|32|Japanese Laurel
2f|7a|92|Turkish Stone
2f|83|51|Greener Grass
2f|84|7c|Celadon Green
2f|bd|a1|First Post
2f|ef|10|Vivid Green
30|26|21|Wood Bark
30|28|33|Black Safflower
30|30|48|Blue Regal
30|36|3c|Blue Plaza
30|37|42|Prestige Blue
30|3b|4c|Dark Spell
30|3d|3c|Darkest Spruce
30|3e|55|Winter Sea
30|44|71|Bona Fide
30|4e|63|Sovereignty
30|51|44|Highland Green
30|52|5b|Encore Teal
30|54|51|Hidden Depths
30|59|4b|Federal Fund
30|5a|4a|Billiard Green
30|5c|71|Blumine
30|5d|35|Parsley
30|60|30|Mughal Green
30|62|30|Gameboy Shade
30|62|a0|Perfect Ocean
30|65|8e|Vallarta Blue
30|6f|73|Lakelike
30|7d|67|Transtasman
30|8e|a0|Scooter
30|94|9d|Aqua Lake
30|a2|99|Sea Kale
30|ba|8f|Mountain Meadow
30|bf|bf|Maximum Blue Green
30|d5|c8|Turquoise Panic
31|27|60|Paris M
31|2a|29|Livid Brown
31|30|48|Plum Fuzz
31|32|48|Deep Velvet
31|33|30|Oil
31|33|37|Ebony
31|33|90|Perfect Dark
31|36|41|Supernatural
31|37|39|Japanese Sable
31|37|3f|School Ink
31|37|40|Night Wizard
31|44|59|Pickled Bluewood
31|45|3b|Bracken Fern
31|46|43|Firefly
31|4a|49|Frontier
31|4a|76|Dragonfly
31|4d|67|Blueberry Pie
31|59|55|Enchanting Ivy
31|63|9c|Caledor Sky
31|64|6e|Pedigree
31|66|7d|Byron Place
31|66|8a|Drake’s Neck
31|67|45|Thousand Years Green
31|6c|6b|North Sea
31|6e|a0|Lochmara
31|75|89|Thousand Herb
31|78|73|Myrtle Green
31|79|6d|Genoa
31|81|81|Nero's Green
31|83|a0|Navagio Bay
31|8c|e7|Bleu De France
31|91|77|Illuminating Emerald
31|94|ce|Splish Splash
31|a2|f2|Rockman Blue
31|a6|d1|Modal
31|aa|74|Beanstalk
32|12|7a|Persian Indigo
32|14|14|Seal Brown
32|17|4d|Russian Violet
32|2c|2b|Diesel
32|31|37|Blue Graphite
32|32|35|Stiletto
32|34|38|Ebony Clay
32|34|41|Parisian Night
32|39|39|Tàn Hēi Soot
32|3f|75|Blackberry Pie
32|42|41|Green Gables
32|43|36|Timber Green
32|46|80|Indigo Night
32|49|3e|Government Green
32|4a|b2|Blue Violet
32|54|5e|Cold Sea Currents
32|54|82|St Tropez
32|57|5d|Mediterranea
32|58|4c|Hypnotism
32|5b|51|Posy Green
32|5f|8a|Bay Site
32|63|95|Teeny Bikini
32|6a|b1|Dover Straits
32|72|af|Campánula
32|7a|68|Census
32|7a|88|Panorama
32|97|60|Eucalyptus
32|a7|b5|Green Buoy
32|be|cc|Blue Curacao
32|bf|84|Greenish Teal
32|cd|32|Warboss Green
33|00|00|Old Brown Crayon
33|00|11|Ilvaite Black
33|00|33|Exquisite Eggplant
33|00|66|Deep Violet
33|00|99|Violet Hickey
33|11|00|Chocolate Melange
33|11|11|Black Rooster
33|11|44|Purple Door
33|11|66|Candied Blueberry
33|22|00|Black Swan
33|22|11|Black Slug
33|22|22|Hornblende
33|2c|22|Melon Seed
33|2e|2e|Night Rider
33|31|2d|Dryad Bark
33|33|00|Wasabi Nori
33|33|11|Olivenite
33|33|22|Fuchsia Berries
33|33|33|Carbon
33|33|99|Bluebell
33|3c|76|Good Karma
33|40|46|Big Stone
33|41|59|Passionate Blueberry
33|4b|58|Sailor's Coat
33|4d|41|Pine Needle
33|4f|7b|High Altar
33|50|83|Fun Blue
33|55|7f|Overtake
33|55|88|Glimpse of Void
33|56|5e|Green Moonstone
33|61|6a|After the Storm
33|61|72|Atlantis
33|66|ff|Gentian Flower
33|74|6b|Imperial Dynasty
33|77|a2|Taiwan Blue Magpie
33|78|9c|Fun and Games
33|7b|35|Mermaid's Tail
33|7f|86|Sea Swimmer
33|8d|ae|Carol
33|98|ce|Sorcerer
33|99|ff|Brilliant Azure
33|9a|8d|Temple Guard Blue
33|a3|b3|Marine Tinge
33|ab|b2|Tempo
33|b8|64|Cool Green
33|bb|88|Aztec Jade
33|cc|99|Dark Shamrock
34|01|3f|Dark Violet
34|15|15|Tamarind
34|1c|02|Dark Brown
34|29|2a|Ganache
34|29|31|Melanzane
34|34|2c|Black Powder
34|34|34|Jet
34|34|45|Pauper
34|34|50|Tiě Hēi Metal
34|34|67|Deep Koamaru
34|36|3a|Hawk’s Eye
34|37|3c|Metalise
34|38|37|Charcoal
34|3b|4e|Old Mill
34|3c|4c|North Sea Blue
34|3e|54|Black River Falls
34|3f|5c|Gulf Blue
34|41|4e|Midnight Navy
34|46|6c|Alaskan Cruise
34|49|89|Truth
34|4d|56|Iron Head
34|53|3d|Goblin
34|53|62|Wentworth
34|54|6d|America's Cup
34|5c|61|Deep Arctic
34|6c|b0|Palace Blue
34|76|99|Male Betta
34|78|8c|Adventure
34|9b|82|Green Jelly
34|ac|b1|Pluto
34|b2|33|Wageningen Green
34|b3|34|American Green
34|c2|a7|Jade Mountain
35|06|3e|Dark Purple
35|1e|1c|Black Kite
35|1f|19|Scorched
35|22|35|Fat Tuesday
35|28|1e|Cocoa Brown
35|29|25|Betel Nut Dye
35|31|2c|Acadia
35|32|35|Black Tortoise
35|34|3f|Witches Cauldron
35|35|42|Sceptre Blue
35|38|38|Wet Concrete
35|38|39|Onyx Heart
35|38|3f|Antarctic Deep
35|3a|4c|Mood Indigo
35|3c|3d|Old School
35|3d|75|Torea Bay
35|3e|4f|Burka Black
35|3e|64|Bay of Many
35|3f|51|Dark & Stormy
35|43|5a|Sargasso Sea
35|46|5e|Dark Denim
35|49|5a|Dilly Blue
35|4a|55|Sea Kelp
35|4e|4b|Silk Crepe Grey
35|4f|58|Aircraft Blue
35|50|48|Trekking Green
35|51|4f|Blue Dianne
35|52|4a|Deep Mooring
35|53|0a|Navy Green
35|53|76|Aerostatics
35|53|7c|Bunting Blue
35|58|59|Depth Charge
35|58|73|Water Chi
35|59|78|Tidal Wave
35|5d|51|Holly Bush
35|5d|83|Pelagic
35|5e|3b|Verde Garrafa
35|5e|4b|Deep Moss Green
35|63|7c|Blueprint
35|65|4d|Poker Green
35|6b|6f|Aquarium
35|6f|ad|Nocturne Shade
35|75|67|Nominee
35|80|82|Green Blue Slate
35|8d|52|Shamrock Field
35|9e|6b|Bulma Hair
35|ad|6b|Seaweed Green
35|fa|00|Plutonium
36|01|3f|Deep Purple
36|0c|cc|Interdimensional Blue
36|2d|26|Coffee Bean
36|31|51|Astral Aura
36|36|2d|Rosin
36|37|37|Dark Grey
36|37|56|Patriot Blue
36|38|38|Pirate Black
36|38|3c|Vulcan
36|3b|48|Blue Nights
36|3b|7c|Clematis Blue
36|3e|1d|Turtle Skin
36|41|41|Dying Light
36|45|4f|Azul Petróleo
36|48|2f|Palm Leaf
36|4d|70|Airforce
36|51|94|Chinese Blue
36|57|6a|Summer Night
36|57|71|Winner's Circle
36|59|55|Crystal Ball
36|5c|7d|Matisse
36|5d|73|Brigade
36|6c|4e|Jungle Book Green
36|71|6f|Deep Jungle
36|75|88|Clear Viridian
36|7d|83|Sea Urchin
36|86|a0|Blue Moon
36|b1|4e|Spandex Green
36|ff|9a|Eva Green
37|25|28|Aubergine
37|29|0e|Brown Tumbleweed
37|2d|52|Cherry Pie
37|33|32|Gondola
37|36|3f|Revolver
37|3b|40|Crypt
37|3d|31|USMC Green
37|3e|02|Dark Olive
37|3e|41|Mine Shaft
37|3f|43|Mirage
37|41|2a|Deep Seaweed
37|41|3a|Deep Forest
37|42|31|Sensaimidori Green
37|47|55|Surf'n'dive
37|48|74|Daring Indigo
37|4a|5a|Odyssey
37|4e|88|Tory Blue
37|4f|6b|Police Blue
37|50|3d|Angry Gremlin
37|56|73|Blue Earth
37|59|78|Bluey
37|5d|4f|Spectra
37|62|98|Blue Regatta
37|62|a5|International
37|66|98|Summerday Blue
37|6d|03|Tatzelwurm Green
37|6d|64|Statue of Liberty
37|6f|89|Astral
37|76|ab|Python Blue
37|78|bf|Windows Blue
37|86|61|Chrysocolla Green
37|91|90|Latigo Bay
37|b5|75|Buddha Green
38|02|82|Marionberry
38|08|35|Cured Eggplant
38|21|61|Christalle
38|2c|38|Valentino Nero
38|2e|2d|Chocolate Torte
38|34|28|Graphite
38|34|3e|Persian Prince
38|37|40|Black Marlin
38|39|3f|After Midnight
38|3e|44|Ferry
38|3e|5d|Mangosteen
38|43|51|Starlit Eve
38|44|f4|Bright Greek
38|45|43|Refined Green
38|48|83|Deep Ultramarine
38|4a|66|Annapolis Blue
38|4c|67|Ensign Blue
38|4e|47|Amphitrite
38|4e|49|Black Green
38|50|a0|Dazzling Blue
38|54|6e|Albeit
38|5d|8d|Bright Cobalt
38|61|4c|Moss Vale
38|61|92|Star Sapphire
38|67|82|Naval Passage
38|6b|7d|Kimberley Sea
38|73|8b|Bengal Blue
38|7a|be|Mykonos
38|7b|54|Amazon
38|80|04|Dark Grass Green
38|88|7f|Copper Turquoise
38|8d|95|Aqueous
38|91|4a|Wild Forest
38|a1|db|Dayflower
38|a3|cc|Skydome
38|af|cd|River Blue
38|b0|de|Summer Sky
38|b4|8b|Hisui Kingfisher
38|c6|a1|Jadeite
39|12|85|Pixie Powder
39|18|02|American Bronze
39|28|52|Parachute Purple
39|2d|2b|Mole
39|31|21|Agrax Earthshade
39|32|27|Creole
39|34|32|Indigo Ink Brown
39|35|40|Professor Plum
39|37|3b|Avocado Peel
39|39|2c|El Paso
39|39|39|Boltgun Metal
39|3b|3c|Montana
39|3d|2a|Green Kelp
39|3e|4f|Kachi Indigo
39|3f|4c|Indigo Iron
39|40|34|Duffel Bag
39|40|43|Charade
39|48|51|Limed Spruce
39|4d|60|Blue Hue
39|4d|78|Noble Knight
39|4e|65|Blue Bottle
39|50|5c|Stargazer
39|53|6c|Plaudit
39|55|49|Leprechaun Green
39|55|51|Bistro Green
39|55|55|Oracle
39|56|43|O'Neal Green
39|56|48|Shadow Leaf
39|7c|80|Blue Venus
39|84|67|Mythical Forest
39|94|af|Water Welt
39|9f|86|Gossamer
39|a7|8e|Zomp
39|a8|45|Classic Green
39|ad|48|Matt Green
39|ff|14|Neon Green
3a|18|1a|Rustic Red
3a|18|b1|Indigo Blue
3a|24|3b|Kokimurasaki Purple
3a|2e|fe|Light Royal Blue
3a|35|32|Kilimanjaro
3a|36|3b|Shiny Rubber
3a|3b|5b|Magic Night
3a|3f|41|Seaplane Grey
3a|40|32|Kombu Green
3a|40|3b|Dark Al-Amira
3a|40|5a|Victory Blue
3a|44|5d|Diplomatic
3a|45|31|Mallardish
3a|4a|62|Evening Glory
3a|4b|61|Master
3a|4e|5f|Cello
3a|51|4d|Heavy Black Green
3a|51|61|Sailing Safari
3a|53|3d|Highlander
3a|5b|52|Iridescent
3a|5c|6e|Mallard Blue
3a|5f|7d|Chinese Porcelain
3a|69|60|Seiheki Green
3a|72|5f|Fir
3a|79|68|Green Moray
3a|79|7e|Diver's Eden
3a|7a|9b|Blue Dart Frog
3a|92|34|Putting Green
3a|a2|78|Ming Green
3a|a8|c1|Moonstone
3a|af|dc|Highlighter Blue
3a|b0|a2|Waterfall
3a|e5|7f|Weird Green
3b|28|20|Tree House
3b|2b|2c|Havana
3b|2e|25|Sambuca
3b|2f|2f|Smoked Black Coffee
3b|30|2f|Black Coffee
3b|33|1c|Pullman Green
3b|34|29|Sensaicha brown
3b|35|49|Plush
3b|3a|3a|Dead Pixel
3b|3b|6d|American Blue
3b|3c|36|Black Olive
3b|3c|38|Zeus
3b|3c|3c|Yin Mist
3b|3f|42|Dark Gunship Grey
3b|3f|66|Raven Night
3b|42|4c|Astrogranite Debris
3b|42|71|Space Angel
3b|43|6c|Port Gore
3b|44|4b|Arsenic
3b|48|4f|Midnight Hour
3b|49|56|Voltage
3b|4a|6c|Jazz Age Blues
3b|50|6f|Blue Flag
3b|51|50|Dark Reaper
3b|52|57|Mountain Pine
3b|57|60|Great Void
3b|58|61|Autumn Night
3b|59|3a|Ficus
3b|5b|92|Lambent Lagoon
3b|5e|68|Freedom
3b|5e|8d|Antilles Blue
3b|5f|78|Blue Ashes
3b|63|8c|Mississippi River
3b|69|5f|Dignified
3b|6c|3f|Arcala Green
3b|71|9f|Muted Blue
3b|79|60|Scouring Rush
3b|7a|5f|Liquid Green Stuff
3b|b0|8f|Walk in the Woods
3b|b7|73|Ceramic Green
3b|de|39|Green Juice
3c|00|08|Dark Maroon
3c|14|14|Dark Sienna
3c|14|21|Chocolate Kiss
3c|20|05|Dark Ebony
3c|21|26|Temptress
3c|24|1b|Brown Pod
3c|2d|2e|Chocolate Plum
3c|2f|23|Cola
3c|30|24|Cola Bubble
3c|34|1f|Lebanon Cedar
3c|34|3d|Zeus Palace
3c|35|1f|LeChuck's Beard
3c|35|23|Devlan Mud Wash
3c|35|35|After Dark
3c|37|48|Martinique
3c|39|10|Camouflage
3c|3b|3c|Shisha Coal
3c|3d|3e|Baltic Sea
3c|3f|4a|Indian Ink
3c|3f|52|Knighthood
3c|3f|b1|Early Spring Night
3c|41|42|Cannon barrel
3c|41|51|Lava Stone
3c|41|73|Jewel Cave
3c|43|54|Blue Zodiac
3c|43|78|Little Blue Heron
3c|4a|56|Pacific Spirit
3c|4c|5d|Man Friday
3c|4d|03|Dark Olive Green
3c|4d|85|Dive In
3c|4f|4e|Night Watch
3c|57|4e|Midnight Clover
3c|58|6b|Indian Teal
3c|5f|9b|Raftsman
3c|66|3e|Jurassic Park
3c|73|a8|Flat Blue
3c|76|8a|English River
3c|7a|c2|Celestial Plum
3c|7d|90|Larkspur
3c|82|4e|Medium Green
3c|85|be|King Triton
3c|8d|0d|Christmas Green
3c|94|c1|Opalescent
3c|99|92|Sea
3c|ad|d4|Aquarius
3c|b3|71|Medium Sea Green
3c|bc|fc|Megaman
3c|d0|70|UFO Green
3d|07|34|Greek Aubergine
3d|0c|02|Red Bean
3d|1c|02|90% Cocoa
3d|2b|1f|Bistre
3d|32|5d|Jakarta Skyline
3d|33|54|Naggaroth Night
3d|34|3f|Wolf's Bane
3d|34|a5|Purple cabbage
3d|3c|7c|Spectrum Blue
3d|3f|7d|Jacksons Purple
3d|40|31|Scrub
3d|40|35|Sunday Niqab
3d|46|52|Boeing Blue
3d|46|53|Rhino
3d|46|55|Blue Rhapsody
3d|47|4b|Lights Out
3d|49|6d|Egyptian Violet
3d|4b|4d|Mechanicus Standard Grey
3d|4b|52|Atomic
3d|4c|51|Kimono Grey
3d|4e|67|Calico Dress
3d|5d|42|Horsetail
3d|5d|64|Jimbaran Bay
3d|5e|8c|Delft
3d|66|95|Too Blue
3d|6c|54|Toad King
3d|71|88|Calypso
3d|79|7c|Atlantic Wave
3d|7a|fd|Lightish Blue
3d|84|81|Emu Egg
3d|85|b8|Curious Blue
3d|87|bb|Walker Lake
3d|8e|d0|Magical Merlin
3d|99|73|Ocean Green
3d|a3|ae|Teal Essence
3d|b9|b2|Green Grapple
3d|cf|c2|Bianchi Green
3e|00|07|Charred Brown
3e|26|31|Toledo
3e|28|5c|Violet Indigo
3e|2b|23|English Walnut
3e|32|67|Minsk
3e|35|42|Royal Coronation
3e|35|4d|Caddies Silk
3e|3a|44|Ship Grey
3e|3d|29|Green 383
3e|3f|41|Dark Engine
3e|42|65|Chronicle
3e|43|55|Marshal Blue
3e|43|64|Genie
3e|46|52|Bank Blue
3e|4b|69|Buster
3e|4d|50|Rocky Creek
3e|4d|59|Presidential
3e|4f|5c|Orion Blue
3e|50|5f|Midnight Haze
3e|52|4b|Garden Topiary
3e|53|61|Dark Secret
3e|57|55|Orkhide Shade
3e|59|4c|Plantation
3e|60|58|Emerson
3e|62|57|Smoke Pine
3e|62|ad|Kakitsubata Blue
3e|63|34|Greenhouse
3e|64|90|Blue Ribbon Beauty
3e|66|76|Barbados
3e|6a|6b|Moat
3e|6f|58|Foliage Green
3e|6f|87|Crashing Waves
3e|72|9b|Phenomenon
3e|79|84|Sea Quest
3e|7a|85|Mysterious Blue
3e|7f|a5|Cendre Blue
3e|80|27|Bilbao
3e|82|fc|Dodger Blue
3e|88|96|Seachange
3e|8b|aa|Magic Blue
3e|8f|bc|Quiet Night
3e|9e|ac|Glacier Green
3e|a3|80|Funk
3e|af|76|Dark Seafoam Green
3e|b3|70|Midori Green
3e|b4|89|Mint
3f|00|0f|Berry Chocolate
3f|00|ff|Electric Ultramarine
3f|01|2c|Dark Plum
3f|2a|47|Blackberry Cordial
3f|2e|4c|Jagger
3f|31|2b|Chinese Ink
3f|31|3a|Disappearing Purple
3f|35|2f|Delicioso
3f|35|4f|Maharaja
3f|36|23|Mikado
3f|36|3d|Treasure Seeker
3f|37|26|Birch
3f|39|25|Magic Metal
3f|39|39|Eclipse
3f|41|4c|Intellectual
3f|42|50|Madonna
3f|42|58|Attorney
3f|42|5a|Amphystine
3f|45|51|Deep Storm
3f|48|55|Whispered Secret
3f|49|48|Green Valley
3f|49|52|Medium Gunship Grey
3f|4c|5a|Cavalry
3f|52|77|True Navy
3f|54|5a|Casal
3f|59|48|Royal Hunter Green
3f|67|82|Good Samaritan
3f|6c|8f|Rainy Lake
3f|6e|8e|Big Sur Blue Jade
3f|70|74|Peabody
3f|74|a3|Decoration Blue
3f|82|9d|Dirty Blue
3f|95|bf|Galleon Blue
3f|9b|0b|Grass Green
3f|9d|a9|Caribbean Cruise
3f|a4|9b|Bahaman Bliss
3f|af|cf|Summer Air
3f|ba|bd|Montego Bay
3f|bb|b2|Magnetic Magic
3f|ff|00|Harlequin
40|33|30|Blackest Brown
40|34|2b|Demitasse
40|35|47|Royal Decree
40|3c|39|Desert Shadow
40|3c|40|Midnight Escape
40|40|34|I R Dark Green
40|40|48|Volcanic Sand
40|41|49|Napoleon
40|44|66|Deep Cobalt
40|44|6c|Wooed
40|46|5d|Bella Sera
40|48|54|Soft Steel
40|49|56|Blue Sou'wester
40|4d|49|Corduroy
40|4e|61|Admiralty
40|53|3d|Okroshka
40|53|5d|Slate Wall
40|58|52|Concealment
40|59|78|Carter's Scroll
40|5b|50|Woodlawn Green
40|5d|73|Real Teal
40|5e|5c|Rosemary
40|5e|95|Integra
40|63|56|Stromboli
40|63|8e|Blue Beret
40|75|77|Ming
40|76|b4|Petrel
40|7a|52|Rokushō Green
40|82|6d|Shǔi Cǎo Lǜ Green
40|8e|7c|Perky
40|8f|90|Blue Chill
40|a3|68|Greenish
40|a4|8e|Marine Green
40|a6|ac|Modal Blue
40|e0|d0|Fresh Turquoise
40|fd|14|Poison Green
41|00|56|Ripe Plum
41|02|00|Deep Brown
41|19|00|Chocolate Brown
41|20|10|Deep Oak
41|2a|7a|Clear Purple
41|33|2f|Deep Leather
41|34|31|Bloodstone
41|35|4d|Purple Velvet
41|36|28|Jacko Bean
41|36|3a|Monastery Mantle
41|3d|4b|Italian Grape
41|40|40|Scarabaeus Sacer
41|43|4e|MacKintosh Midnight
41|45|49|Stargazing
41|46|54|Blue Ash
41|48|33|Rifle Green
41|49|58|Pit Stop
41|49|5d|Sapphire Stone
41|4a|4c|Outer Space
41|4d|62|Luna Pier
41|50|53|Lunar Eclipse
41|52|41|Pine Forest
41|54|5c|Sea Blithe
41|56|c5|Free Speech Blue
41|57|64|Alien
41|58|62|Steiglitz Fog
41|5a|09|Lustrian Undergrowth
41|5d|66|Hypothalamus Grey
41|60|82|Alexis Blue
41|63|8a|Winter Palace
41|66|59|Earhart Emerald
41|66|f5|Secret of Mana
41|69|86|Team Spirit
41|69|e1|Royal Blue
41|70|74|Thunderhawk Blue
41|72|9f|Naval
41|74|91|Harbour Blue
41|78|8a|Blue Catch
41|7d|c1|Tufts Blue
41|8d|84|Royal Palm
41|9a|7d|Greenway
41|9c|03|Grassy Green
41|9f|59|Chateau Green
41|a0|b4|Aquatic Cool
41|a1|aa|Marlin Green
41|a9|4f|Leapfrog
41|b0|d0|Santorini
41|b4|5c|Artificial Turf
41|bf|b5|Tint of Turquoise
41|fd|fe|Bright Cyan
42|03|03|Burnt Maroon
42|31|4b|Acai Berry
42|34|2b|Slugger
42|34|50|Devil's Plum
42|39|21|Lisbon Brown
42|3d|27|Scorched Metal
42|42|42|Black Panther
42|42|4d|Flint Purple
42|42|6f|Overcast Night
42|47|53|Midnight Sky
42|4d|60|Breakaway Blue
42|4f|5f|Deep Reservoir
42|51|66|Navy Damask
42|54|4c|Moss Cottage
42|63|9f|Mariner
42|65|79|Noshime Flower
42|69|72|Hydro
42|71|31|Druid Green
42|75|73|Surf Green
42|79|77|Faded Jade
42|82|c6|Worn Denim
42|89|29|La Palma
42|93|95|Catalan
42|b3|95|Green Blue
43|00|05|Dirty Leather
43|05|41|Eggplant
43|18|2f|Blackberry
43|1c|53|American Purple
43|24|2a|Nisemurasaki Purple
43|2c|47|Purple Pennant
43|30|2e|Old Burgundy
43|31|20|Iroko
43|34|30|Bruno Brown
43|35|4f|Velvet Violet
43|37|48|Wineshade
43|39|37|Mulch
43|3d|3c|Binrouji Black
43|42|37|Forest Night
43|43|40|Balsamic Reduction
43|44|52|Odyssey Grey
43|46|4b|Steel Grey
43|48|54|Ombre Blue
43|4b|4f|Dead Forest
43|4c|28|Bronze Tone
43|50|5e|Blue Quarry
43|53|5e|Nightfall
43|54|4b|Cilantro
43|5d|8b|Anchor Point
43|61|74|The Fang Grey
43|62|8b|Federal Blue
43|6b|95|Queen Blue
43|6b|ad|Waterline Blue
43|7b|48|Kemp Kelly
43|8e|ac|Boston Blue
43|b3|ae|Verdigris
44|00|00|Eyelids
44|00|44|Jacarta
44|11|00|Black Chocolate
44|11|dd|Blue Copper Ore
44|22|00|Blackened Brown
44|22|11|Duqqa Brown
44|22|ee|Violet Glow
44|23|2f|Castro
44|28|bc|Blue Depression
44|2d|21|Morocco Brown
44|31|2e|Benikeshinezumi Purple
44|32|40|Voodoo
44|33|ff|Ultra Indigo
44|36|2d|Tobago
44|36|3d|Fireworks
44|37|24|Brown 383
44|37|36|Cowboy
44|38|2b|Bear Brown
44|3f|6f|Deep Wisteria
44|40|3d|Scorched Earth
44|41|3c|Black Ink
44|42|51|Smoked Purple
44|44|44|Goshawk Grey
44|49|40|Nightly Ivy
44|4d|56|Deepest Sea
44|50|55|Obsidian
44|50|56|High Salute
44|51|72|Astronaut
44|53|97|Crushed Velvet
44|55|00|Highlands Moss
44|55|44|Greene & Greene
44|55|6b|Inkjet
44|55|99|Nuthatch Back
44|55|cc|Gorgonzola Blue
44|55|ff|Hooloovoo Blue
44|57|61|San Juan
44|59|56|Mariana Trench
44|5a|79|Newburyport
44|66|88|French Mirage Blue
44|66|ee|The Rainbow Fish
44|66|ff|Blue Titmouse
44|6c|cf|Han Blue
44|6d|46|Jungle Adventure
44|70|b0|Pacific Blues
44|76|4a|Maidenhair Fern
44|77|aa|Field Blue
44|77|dd|Andrea Blue
44|79|8e|Jelly Bean
44|88|11|Kelp Forest
44|88|3c|Online Lime
44|88|99|Turquesa
44|88|ff|Bleuchâtel Blue
44|89|1a|Chlorophyll
44|8e|e4|Dark Sky Blue
44|99|dd|Flax Flower Blue
45|2e|39|Barossa
45|34|30|Rebel
45|36|2b|Dark Rum
45|36|3a|Rapt
45|40|2b|Woodrush
45|41|29|Strong Tone Wash
45|41|51|Loom of Fate
45|45|45|Machine Gun Metal
45|46|42|Tuatara
45|49|4d|Salem Black
45|4c|56|Thunderbolt Blue
45|4d|32|Matsuba Green
45|52|3a|Green Shade Wash
45|54|40|Castellan Green
45|54|54|All Nighter
45|55|59|Asagi Koi
45|57|65|Tetsu Iron
45|58|59|Sabionando Grey
45|60|74|Eclipse Blue
45|62|52|Mission Jewel
45|67|89|A Hint of Incremental Blue
45|69|8c|Snake River
45|6f|6e|Farrago
45|74|7e|Flip
45|75|ad|Sail On
45|79|73|Sea Pea
45|79|ac|Sleep
45|7e|87|For the Love of Hue
45|86|7c|Carlisle
45|86|8b|Sea Caller
45|86|c7|Casting Sea
45|ab|ca|Dragonfly Blue
45|be|76|Esmeralda
45|c3|ad|Melbourne Cup
45|ce|a2|Mint Jelly
45|dc|ff|Berta Blue
46|26|39|Potent Purple
46|29|5a|Acai
46|2c|77|Windsor
46|34|30|Cedar
46|35|4b|Purple Verbena
46|36|23|Clinker
46|36|29|Woodburn
46|37|32|Americano
46|37|3f|Priceless Purple
46|39|4b|Mysterioso
46|3b|3a|Zin Cluster
46|3d|2b|Typhus Corrosion
46|3d|2f|Bold Eagle
46|3d|3e|Black Truffle
46|3f|3c|Wild Truffle
46|41|96|Blueberry
46|43|4a|Nine Iron
46|44|4c|Kala Namak
46|45|44|Onyx
46|46|46|Wood Charcoal
46|46|47|Black Tie
46|47|3e|Heavy Metal
46|48|3c|Deep Depths
46|48|3e|Parkview
46|49|4e|Tuna
46|49|60|Chinaberry
46|4b|65|Crown Blue
46|4b|6a|Royal Hyacinth
46|4e|4d|Urban Chic
46|50|48|Park Avenue
46|53|52|Dark Slate
46|53|83|Blue Jewel
46|55|4c|Huntington Woods
46|56|5f|Good Night!
46|59|45|Grey Asparagus
46|5f|9e|Bio Blue
46|60|82|Climate Control
46|61|74|Deepest Water
46|64|7e|Stellar
46|64|a5|Starstruck
46|6b|82|Eames for Blue
46|6f|97|Postwar Boom
46|75|b7|Sinatra
46|82|b4|Steel Blue
46|82|bf|Blue Azure
46|9b|a7|Sea Sparkle
46|9f|4e|Fervent Green
46|a7|95|Jewel Weed
46|c2|99|Macau
46|cb|18|Harlequin Green
47|24|3b|Winter Bloom
47|34|30|Pawn Broker
47|34|42|Red Onion
47|37|39|Judah Silk
47|38|54|Purple Plumeria
47|39|51|Gothic Grape
47|3b|3b|Humpback Whale
47|3e|23|Madras
47|3f|2d|Flirtatious Indigo Tea
47|41|3b|Skavenblight Dinge
47|45|7a|Orient Blue
47|47|49|Wrought Iron Gate
47|49|3b|Treasure Island
47|4a|4d|Indigo Ink
47|4a|4e|Black Bay
47|4c|4d|Black Lead
47|4c|50|Witchcraft
47|4c|55|Asphalt Blue
47|4f|43|Charcoal Smoke
47|52|6e|East Bay
47|55|3c|Green Tone Ink
47|56|2f|Trefoil
47|57|42|Catachan Green
47|58|77|Chambray
47|5c|62|Blue Tapestry
47|5f|94|Last Light Blue
47|61|3c|Lady Luck
47|64|4b|Vizcaya Palm
47|6a|30|Tree Shade
47|70|50|Fairway
47|72|66|Christmas Ivy
47|78|8a|Sotek Green
47|7f|4a|Tarmac Green
47|88|5e|Onion Seedling
47|88|65|Mallard Green
47|97|84|Algen Gerne
47|a3|c6|Oasis Spring
47|ab|cc|Maximum Blue
47|ba|87|Aragon Green
47|c6|ac|Disc Jockey
48|06|07|Bulgarian Rose
48|06|56|Clairvoyant
48|08|40|Pion Purple
48|24|00|Ibex Brown
48|24|27|New Bulgarian Rose
48|2d|54|Crown Jewel
48|37|43|Vincotto
48|3c|32|Dark Lava
48|3c|3c|Dark Taupe
48|3c|41|Pitch Black
48|3d|8b|Nauseous Blue
48|3f|39|Turkish Coffee
48|41|2b|Onion
48|43|35|Cannon Ball
48|44|50|Ishtar
48|45|2b|Tin Bitz
48|46|4a|Forged Iron
48|47|53|Gun Powder
48|48|48|Pig Iron
48|4a|46|Armadillo
48|4a|72|Skipper Blue
48|4b|5a|Black Flame
48|4b|62|Blue Suede Shoes
48|53|1a|Verdun Green
48|57|69|Rainmaker
48|63|58|Pine Haven
48|65|31|Dell
48|6b|67|Pond Newt
48|6c|7a|Bismarck
48|76|78|Cool Waters
48|7a|7b|Lucky Shamrock
48|7a|b7|Regatta
48|80|84|Paradiso
48|90|84|Lochinvar
48|92|9b|Asagi Blue
48|a8|d0|Mystic Blue
48|c0|72|Dark Mint
48|d1|cc|Medium Turquoise
49|02|06|Dark Chocolate
49|06|48|Alien Purple
49|1e|3c|Rabbit-Ear Iris
49|2a|34|Wine Tasting
49|2b|00|Stirland Mud
49|33|38|Fudge
49|34|35|Rhinox Hide
49|35|4e|Oregon Grape
49|3c|2b|Harpy Brown
49|3c|62|Mulberry Purple
49|45|4b|Blackheath
49|49|4d|Grey Pinstripe
49|4a|41|Sensai Brown
49|4c|55|Deep Night
49|4c|59|Deep Mystery
49|4d|55|Isolation
49|4d|58|Blue Sash
49|4d|8b|Beaded Blue
49|4e|4f|Cover of Night
49|4f|62|Tried & True Blue
49|51|6d|Blue Indigo
49|54|5a|Country Sky
49|54|5c|Winter Solstice
49|55|6c|Snoop
49|58|3e|Heavy Green
49|5a|44|Cayman Green
49|5a|4c|Greener Pastures
49|5d|39|Stinging Nettle
49|5e|35|Garden Green
49|5e|7b|Stream
49|60|a8|Amparo Blue
49|62|67|Smalt Blue
49|65|69|Tax Break
49|6a|76|Planet Green
49|71|6d|Sinkhole
49|75|9c|Dull Blue
49|76|4f|Killarney
49|78|a9|Co Pilot
49|79|6b|Hooker's Green
49|84|b8|Cool Blue
49|88|9a|Hippie Blue
49|97|d0|Blue Tourmaline
49|99|a1|Water Carrier
49|b3|a5|Sacred Turquoise
4a|01|00|Old Mahogany
4a|2c|2a|Brown Coffee
4a|2d|57|Scarlet Gum
4a|2e|32|Cab Sav
4a|34|2e|Chicory Coffee
4a|37|3e|Spell Caster
4a|38|32|Brown Beauty
4a|3b|6a|Meteorite
4a|3c|4a|Funkie Friday
4a|3c|50|Preserve
4a|3f|37|Brown Bear
4a|3f|41|Shale
4a|40|ad|Megadrive Screen
4a|41|39|Wren
4a|43|54|Serendibite Black
4a|46|5a|Oath
4a|48|43|Beluga
4a|4a|43|Natural Pumice
4a|4b|46|Gravel
4a|4b|4d|Dark Shadow
4a|4e|5c|Receding Night
4a|4f|52|Eshin Grey
4a|4f|55|Lamp Post
4a|4f|5a|Extinct Volcano
4a|51|5f|Senate
4a|53|35|Chive
4a|55|6b|Vintage Indigo
4a|57|77|Steadfast
4a|5a|6f|Bluster Blue
4a|5b|51|Dark Green Velvet
4a|5c|69|Shot Over
4a|5c|6a|Seven Seas
4a|5c|94|Blue Dude
4a|5d|23|Dark Moss Green
4a|5e|6c|Ragtime Blues
4a|62|3b|Plasticine
4a|63|8d|Dutch Blue
4a|64|6c|Deep Space Sparkle
4a|65|46|Backwoods
4a|65|58|Jasper Park
4a|65|7a|Gloomy Sea
4a|68|71|Azalea Leaf
4a|72|a3|Great Serpent
4a|75|4a|Spring Juniper
4a|76|6e|Dark Green Copper
4a|79|ba|Ashton Blue
4a|7d|82|Submerge
4a|87|91|Flounce
4a|87|cb|Blue Sonki
4a|93|4e|Discover Deco
4a|99|76|Smaragdine
4a|9c|95|Majorca Blue
4a|ac|72|Glen
4a|ae|97|Hole In One
4a|bb|d5|Bachelor Button
4a|ff|00|Chlorophyll Green
4b|00|6e|Royal Purple
4b|00|82|Indigo
4b|01|01|Dried Blood
4b|2d|72|Blue Diamond
4b|36|21|Café Noir
4b|37|3a|Vibrant Vine
4b|37|3c|Jube
4b|38|41|Royal Silk
4b|38|4c|Prince
4b|3b|4f|Sweet Grape
4b|3c|39|Dobunezumi Brown
4b|3c|8e|Blue Gem
4b|3d|33|Slate Black
4b|3f|69|Geode
4b|43|3b|Space Shuttle
4b|44|41|Phantom Mist
4b|49|2d|Tinny Tin
4b|4b|4b|Shadowed Steel
4b|4c|fc|Saturated Sky
4b|53|20|Army Green
4b|53|38|Broccoli Green
4b|53|5c|Evening Cityscape
4b|55|39|Banksia Leaf
4b|56|67|Property
4b|57|db|Warm Blue
4b|5a|62|Fiord
4b|5b|40|Knarloc Green
4b|5b|6e|Bering Sea
4b|5d|16|Kyuri Green
4b|5d|46|Muddy Olive
4b|5f|56|Cloudy Viridian
4b|61|13|Camouflage Green
4b|6d|41|Artichoke Green
4b|6e|3b|Gully Green
4b|70|79|Winter Storm
4b|73|78|Vining Ivy
4b|77|94|Sea Drifter
4b|78|9b|Blue Antarctic
4b|81|af|Seabrook
4b|8e|b0|Atlantic Gull
4b|90|99|Adrift
4b|9b|69|Greenbrier
4b|a3|51|Fruit Salad
4b|a4|a9|Blue Racer
4b|c3|a8|Eucalipto
4b|c7|cf|Sea Serpent
4c|10|50|Shani Purple
4c|1c|24|Vino Tinto
4c|22|1b|Tobi Brown
4c|28|82|Spanish Violet
4c|2f|27|Acajou
4c|33|47|Loulou
4c|34|30|Lineage
4c|39|38|Blackberry Burgundy
4c|3d|30|Simmered Seaweed
4c|3d|4e|Bossa Nova
4c|49|76|Purple Pool
4c|4a|74|Purple Berry
4c|4d|ff|Siniy Blue
4c|4e|31|Waiouru
4c|4f|56|Abbey
4c|51|6d|Independence
4c|53|56|Trout
4c|55|44|Cabbage Pont
4c|57|52|Black Spruce
4c|61|77|Night Market
4c|69|69|Sea Pine
4c|6a|68|Deep Rift
4c|6a|92|Riverside
4c|6b|88|Wedgewood
4c|6c|b3|Azraq Blue
4c|72|6b|Smoky Emerald
4c|73|af|Ramjet
4c|77|a4|Billycart Blue
4c|78|5c|Como
4c|79|3c|Nereus
4c|7a|9d|Tech Wave
4c|7e|86|Brittany Blue
4c|8c|72|Aegean Green
4c|90|85|Dusty Teal
4c|91|41|May Green
4c|95|9d|Sea Current
4c|98|c2|Mountain Bluebird
4c|a5|c7|Norse Blue
4c|a8|e0|High Blue
4c|a9|73|Sēn Lín Lǜ Forest
4c|bb|17|Luigi Green
4d|00|01|Scorched Brown
4d|00|82|Pigment Indigo
4d|08|4b|Christmas Purple
4d|14|0b|Hull Red
4d|23|3d|Pickled Beet
4d|31|13|Bavarian Sweet Mustard
4d|32|46|Blackberry Wine
4d|3b|3c|Burnt Bamboo
4d|3c|2d|Abbot
4d|3e|3c|Crater Brown
4d|44|56|Violet Intense
4d|44|69|Evening Lavender
4d|44|8a|Liberty
4d|47|3d|Seaweed Wrap
4d|48|60|Violet Shadow
4d|49|5b|House Stark Grey
4d|49|70|Evening Fizz
4d|4a|4a|Bastion Grey
4d|4a|6f|Intense Purple
4d|4b|3a|Sooty Willow Bamboo
4d|4b|4f|Magnet
4d|4b|50|Blackened Pearl
4d|4d|41|Ruskin Bronze
4d|4d|4b|Thunder
4d|4d|58|Churchill
4d|4d|ff|Lán Sè Blue
4d|4e|5c|Squid's Ink
4d|50|3c|Kelp
4d|50|4b|Iron River
4d|50|51|Black Ice
4d|50|62|Voyager
4d|51|6c|Intergalactic
4d|51|7f|Roman Violet
4d|56|59|Urbanite
4d|57|78|Alpha Centauri
4d|58|7a|Nyctophobia Blue
4d|5a|6b|Yankee Doodle
4d|5a|af|Chinese Bellflower
4d|5b|88|Wizard
4d|5d|53|Feldgrau
4d|5e|42|Luftwaffe Ca. Green
4d|64|6c|Masuhana Blue
4d|66|3e|Mountain Forest
4d|69|68|Hancock
4d|6a|77|Before the Storm
4d|6b|53|Medium Grey Green
4d|6e|b0|Bluebonnet Frost
4d|78|6c|Double Jeopardy
4d|7f|aa|Neapolitan Blue
4d|86|81|Jericho Jade
4d|8a|a1|Cossack Dancer
4d|8b|72|Molly Robins
4d|8c|57|Middle Green
4d|8f|ac|Sora Sky
4d|91|c6|Azure Blue
4d|93|9a|Sea Star
4d|9e|9a|Lagoon
4d|a4|09|Lawn Green
4d|b1|c8|Viking
4d|b5|60|Samphire Green
4e|05|50|Beaten Purple
4e|16|09|French Puce
4e|27|28|Volcano
4e|2e|53|Purple Shade
4e|31|2d|Espresso
4e|33|4e|Shadow Purple
4e|3f|44|Requiem
4e|40|3b|Brown Pepper
4e|42|60|Royal Indigo
4e|43|4d|Black Dahlia
4e|4b|35|Olive Leaf
4e|4b|4a|Black Bean
4e|4d|2f|Umber Shade Wash
4e|4d|59|Tyrian
4e|4e|4c|Ash to Ash
4e|4e|63|Legendary Purple
4e|4f|48|Aceto Balsamico
4e|4f|4e|Black Oak
4e|50|55|Iron Gate
4e|51|80|Purple Navy
4e|51|8b|Twilight
4e|53|68|Nightshadow Blue
4e|53|6b|Harbourmaster
4e|54|5b|Turbulence
4e|54|81|Dusk
4e|55|41|Lunar Green
4e|55|52|Cape Cod
4e|58|78|Blue Review
4e|5a|6d|Midnight Sun
4e|5d|4e|Nandor
4e|5e|7f|Bijou Blue
4e|63|2c|Twist of Lime
4e|63|41|Cub Scout
4e|64|82|Blue Horizon
4e|66|65|Angry Ocean
4e|68|66|Silverpine
4e|6c|9d|San Marino
4e|6e|81|Aegean Blue
4e|74|96|Hammerhead Shark
4e|77|a3|Pacifica
4e|7f|ff|C64 NTSC
4e|82|b4|Cyan Azure
4e|83|bd|Blue Vault
4e|9a|a8|Acapulco Cliffs
4e|fd|54|Light Neon Green
4f|15|07|Earth Brown
4f|28|4b|Murasaki
4f|2a|2c|Heath
4f|2d|54|Grape Royale
4f|30|1f|Dark Wood Grain
4f|34|66|Petunia
4f|36|50|Chive Bloom
4f|38|35|Cocoa Bean
4f|3a|32|Button Eyes
4f|3a|3c|Dark Puce
4f|40|37|Paco
4f|43|37|Peppercorn Rent
4f|43|52|Nightshade
4f|44|3f|Dark Granite
4f|45|54|Black Magic
4f|46|7e|Fresh Eggplant
4f|47|44|Espresso Macchiato
4f|49|44|Oubliette
4f|49|69|Darlak
4f|4d|32|Dark Camouflage Green
4f|4e|48|Merlin
4f|4f|5e|Night Night
4f|51|56|Water Ouzel
4f|55|52|Black Pool
4f|56|6c|Heavy Violet
4f|58|45|Albert Green
4f|58|55|Capri Isle
4f|5a|4c|Deep Sea Shadow
4f|5a|51|Hidden Forest
4f|5b|93|Dark PHP Purple
4f|63|48|Tom Thumb
4f|63|64|Wellington
4f|64|46|Thraka Green Wash
4f|66|6a|Sumatra Chicken
4f|69|97|Blue Odyssey
4f|6d|82|Oceanic
4f|6d|8e|Berry Pie
4f|73|8e|Metallic Blue
4f|79|42|Mana Tree Green
4f|7c|a4|Parisian Blue
4f|81|ff|Flickery C64
4f|84|af|Ship's Harbour
4f|84|c4|Marina
4f|8f|00|Pistachio Flour
4f|91|53|Light Forest Green
4f|92|97|Bluebound
4f|97|85|Crisp Lettuce
4f|9e|81|Wintergreen Shadow
4f|a1|83|Inspiration Peak
4f|a1|c0|Brig
4f|aa|6c|Fresh Oregano
4f|b3|a9|Emerald Wave
4f|b3|b3|Crystalsong Blue
4f|b9|ce|Glimpse
50|2b|33|Port Royale
50|2d|86|Sick Blue
50|30|00|Kyoto House
50|31|4c|Dark Beetroot
50|3b|53|Navy Cosmos
50|3d|4d|Dark Energy
50|40|4d|Purple Taupe
50|41|39|Oxford Brown
50|48|4a|Black Elegance
50|49|3c|Wet Suit
50|49|4a|Emperor
50|4d|4c|Charadon Granite
50|4e|47|Renwick Brown
50|53|38|Amazon Depths
50|55|55|Mako
50|57|4c|Thyme
50|58|38|Dark Rainforest
50|59|4f|Evergreen Boughs
50|5a|39|Green Goanna
50|5a|92|Whale Skin
50|5c|3a|Shallot Leaf
50|5d|7e|Coastal Fjord
50|63|55|Mineral Green
50|64|7f|Admiral Blue
50|67|6b|Iron Creek
50|67|70|Sultry Sea
50|68|86|Moonlight Blue
50|6e|82|Happy Days
50|70|2d|Loren Forest
50|70|69|Par Four
50|72|a9|Plunder
50|75|9e|Secrecy
50|7b|49|Autumn Fern
50|7b|9a|Stormy Ridge
50|7b|9c|Storm Blue
50|7d|2a|Master Chief Green
50|7e|a4|Pale Flower Field
50|81|8b|Cape Lee
50|8f|a2|Aegean Sea
50|a4|00|Prairie Green
50|a7|47|Mid Green
50|a7|d9|Blue Astro
50|c8|78|Emerald Reflection
50|c8|7c|Paris Green
51|0a|c9|Violet Blue
51|28|88|KSU Purple
51|2c|31|Purple Kite
51|30|4e|Plum Skin
51|32|35|Decadent Chocolate
51|34|39|Nectar of the Gods
51|38|43|Peacock Purple
51|39|38|Warm Port
51|3d|3c|Magenta Ink
51|41|00|Dark Bronze Coin
51|41|2d|Deep Bronze
51|48|4f|Smoky Quartz
51|4b|40|Arrowhead
51|4b|80|Spirit Dance
51|4e|5c|Salvation
51|4f|4a|Dune
51|50|4d|Blackjack
51|51|31|Warplock Bronze
51|51|53|Celluloid
51|52|52|Cavernous
51|55|9b|Governor Bay
51|57|4f|Sunken Battleship
51|57|6f|Hormagaunt Purple
51|5b|62|Novelty Navy
51|5b|87|Marlin
51|61|72|Da Blues
51|65|72|Slate
51|66|78|Dark Electric Blue
51|6a|62|Green Beret
51|6b|84|Copen Blue
51|6f|a0|Chesty Bond
51|70|d7|Cornflower
51|7b|78|Breaker Bay
51|82|b9|Fisher King
51|87|a0|Raging Tide
51|8f|d1|Blue Dart
51|9d|76|Sea Cabbage
51|9e|a1|Rockpool
51|b7|3b|Skirret Green
52|02|00|Umbral Umber
52|0c|17|Maroon Oak
52|18|fa|Han Purple
52|24|26|Lonestar
52|2c|35|Japanese Wineberry
52|2d|80|Regalia
52|35|2f|American Mahogany
52|38|39|Deep Persian
52|38|3d|Blackcurrant Conserve
52|39|36|Van Cleef
52|3b|2c|Bonanza
52|3b|35|Royal Brown
52|41|44|Raisin
52|47|65|Roman Purple
52|4a|46|Périgord Truffle
52|4b|2a|Codium Fragile
52|4b|4b|Matterhorn
52|4b|4c|Dark Liver
52|4b|50|Noblesse
52|4d|50|Pavement
52|4d|5b|Mulled Wine
52|4e|4d|Keshizumi Cinder
52|57|46|Castle Stone
52|59|3b|Blue Black Crayfish
52|5e|68|Wizard Grey
52|5f|48|Mossy Bronze
52|65|25|Tabbouleh Green
52|67|71|Silent Night
52|67|7b|Periscope
52|6b|2d|Green Leaf
52|70|65|Bridgewater
52|70|6c|Stone Bridge
52|74|98|Trustee
52|75|85|San Miguel Blue
52|7e|6d|Gremolata
52|8b|ab|Cosmopolitan
52|8d|3c|Fiji Palm
52|9d|6e|Basil Pesto
52|a2|b4|Maui Blue
52|a7|86|Laurel Wreath
52|b4|ca|Blue Bobbin
52|b4|d3|Blue Martini
52|b7|c6|Cave Lake
52|b9|63|Forest Maid
53|1b|93|Eggplant Tint
53|29|34|Black Rose
53|2d|3b|Fig
53|31|46|Italian Plum
53|33|1e|Brown Bramble
53|35|7d|Prism Violet
53|38|44|Ritual Experience
53|3b|32|Bright Brown
53|3c|c6|Blue With A Hint Of Purple
53|3d|47|Indulgence
53|43|3e|Spiced Hot Chocolate
53|46|5d|Petal Purple
53|47|78|Grand Purple
53|49|31|Punga
53|4a|32|Rikan Brown
53|4a|77|Red Cabbage
53|4b|4f|Liver
53|50|40|Olive Night
53|50|4e|German Grey
53|52|66|Inky Storm
53|58|72|Nightshade Purple
53|5a|61|Blue Steel
53|5e|63|Mysterious
53|62|67|Gunmetal
53|62|6e|Lithic Sand
53|64|37|Interior Green
53|66|5a|Deep in the Jungle
53|66|5c|Duck Green
53|67|62|Armada
53|68|61|Collard Green
53|68|71|Light Payne's Grey
53|68|72|Cadet
53|68|78|Payne's Grey
53|68|95|UCLA Blue
53|6a|79|Turbulent Sea
53|6b|1f|Bowser Shell
53|6d|70|North Atlantic
53|73|4c|Irish Clover
53|73|6f|William
53|77|83|Ocean Current
53|77|8f|Melancholic Sea
53|78|6a|Wishard
53|83|c3|Pale Ultramarine
53|86|b7|Hideout
53|8b|89|Evora
53|8f|94|Coastal Calm
53|97|b7|Hush-A-Bye
53|98|3c|Enviable
53|9c|cc|Blue Iguana
53|a3|91|Golf Blazer
53|b0|ae|Blue Turquoise
53|fc|a1|Sea Green
53|fe|5c|Light Bright Green
54|2c|5d|Imperial Purple
54|2d|24|Momoshio Brown
54|35|3b|Sassafras
54|38|39|Blood Mahogany
54|38|3b|Port Glow
54|39|2d|Potting Soil
54|39|38|Royal Maroon
54|3b|35|Shaved Chocolate
54|3d|37|Horse Liver
54|3f|32|Kenpō Brown
54|41|73|Raw Amethyst
54|42|75|Gentian Violet
54|43|33|Old Treasure Chest
54|45|40|Railroad Ties
54|45|63|Vibrant Hue
54|4a|42|Brown Fox
54|4e|03|Scorzonera Brown
54|4e|31|Thatch Green
54|4f|3a|Panda
54|4f|66|Magic Spell
54|51|44|Grape Leaf
54|53|4d|Fuscous Grey
54|55|62|Black Dragon's Caldron
54|58|5e|Edge of Black
54|5a|2c|Soldier Green
54|5a|3e|Cypress
54|5b|62|Titanium Grey
54|5e|4f|Brierwood Green
54|5e|6a|Blue Planet
54|62|6f|Black Coral
54|64|5c|Obligation
54|64|77|China Blue
54|69|77|Sky Lodge
54|6b|75|Ruskin Blue
54|6b|78|Morro Bay
54|6c|46|Graceland Grass
54|70|53|Elm Green
54|74|97|Yawl
54|75|88|Russ Grey
54|80|ac|Pacific Coast
54|82|c2|Sea Note
54|88|c0|Blueberry Popover
54|8d|44|Fern
54|8f|6f|Green Weed
54|90|19|Vida Loca
54|a6|c2|Pottery Blue
54|ac|68|Algae
54|c3|c1|Port Hope
54|c5|89|Enamelled Dragon
55|00|00|Soooo Bloody
55|00|22|Fig Balsamic
55|00|55|Cloak and Dagger
55|00|aa|Aubergine Perl
55|00|ff|Aladdin's Feather
55|11|99|Amarklor Violet
55|1b|8c|American Violet
55|1f|2f|Light Chocolate Cosmos
55|22|00|Conker Brown
55|22|11|Peaty Brown
55|22|88|Kalish Violet
55|29|5b|Kuwanomi Purple
55|2c|1c|Boson Brown
55|33|cc|Grape Hyacinth
55|33|ff|Meteor Shower
55|35|92|Blue Magenta Violet
55|39|cc|Blurple
55|3b|39|Deep Mahogany
55|3b|3d|Charred Chocolate
55|3b|50|Hortensia
55|3f|2d|Antique Brown
55|43|48|Purple Prose
55|44|00|Sugarloaf Brown
55|45|45|Wood Brown
55|45|5a|Parma Violet
55|47|38|Kuri Black
55|47|47|Chinotto
55|4a|3c|Metallic Bronze
55|4b|4f|Subtle Night Sky
55|4d|42|Mondo
55|4d|44|Barnwood
55|51|42|Forest Floor
55|53|37|Avocado Pear
55|53|56|Fingerprint
55|54|70|Sombre Grey
55|55|00|Douro
55|55|55|Davy's Grey
55|55|70|Majestic Magic
55|55|aa|Brandywine Raspberry
55|55|ff|Shady Neon Blue
55|58|4c|Beetle
55|5a|4c|Sherwood Forest
55|5a|90|Berry Mix
55|5b|2c|Saratoga
55|5b|53|Midnight Spruce
55|5d|50|Light Ebony
55|5e|5f|Soot
55|60|61|Riverbed
55|64|3b|Daisy Leaf
55|66|82|Stained Glass
55|66|cc|Borage Blue
55|66|ff|Blue Heath Butterfly
55|69|62|Dark Forest
55|6b|2f|Deep Spring Bud
55|6d|88|Electronic
55|70|7f|Lily Pond Blue
55|70|88|Captains Blue
55|77|aa|Flax Flower
55|83|67|Deep Grass Green
55|84|84|Rainier Blue
55|88|00|Pesto Alla Genovese
55|88|aa|Safe Haven
55|88|ab|Blueberry Muffin
55|88|cc|Berlin Blue
55|88|dd|Blue Jay
55|89|61|Spring Garden
55|8f|91|Bristol Blue
55|8f|93|Half Baked
55|99|33|Hubert's Truck Green
55|a7|b6|Blue Calypso
55|a8|60|Exploration Green
55|a9|d6|Cousteau
55|aa|00|Yoshi's Green
55|aa|55|Harā Green
55|aa|aa|Emerald Succulent
55|aa|bb|Verditter Blue
55|aa|ff|Joust Blue
55|b4|92|Electra
55|b4|de|Sail Away
55|bb|aa|Green Fluorite
55|c6|a9|Biscay Green
55|ff|00|Hyper Green
55|ff|55|Puyo Blob Green
55|ff|aa|Hanuman Green
55|ff|ff|Electric Sheep
56|03|19|Dark Scarlet
56|2f|7e|Amethyst Purple
56|34|74|Tillandsia Purple
56|35|2d|Chocolate Fondant
56|39|48|Purple Sphinx
56|3c|0d|Pineapple
56|3c|5c|Old Heliotrope
56|3d|2d|Real Brown
56|3d|5d|English Violet
56|3e|31|Lounge Leather
56|41|4d|Punchit Purple
56|45|6b|Purple Reign
56|47|86|Gigas
56|49|85|Victoria
56|4a|33|Hóng Zōng Brown
56|50|42|Jungle Cover
56|50|51|Mortar
56|52|66|Freefall
56|53|50|Heavy Charcoal
56|56|4b|Shell Brown
56|59|7c|Blue Glaze
56|5b|58|Carbon Dating
56|5b|8d|Midnight Sea
56|60|62|Yacht Club
56|62|6e|Intermediate Blue
56|69|77|Blue Insignia
56|6e|57|Green Bayou
56|70|63|High Tea Green
56|73|6f|Evening Emerald
56|74|5f|Painted Turtle
56|75|72|Sagebrush Green
56|82|03|Avocado
56|84|ae|Off Blue
56|88|7d|Wintergreen Dream
56|8e|88|Sea Garden
56|92|b2|Vanity
56|ac|ca|Frozen Wave
56|ae|57|Chlorella Green
56|b3|c3|Aqua Verde
56|be|ab|Florida Keys
56|fc|a2|Light Green Blue
56|ff|ff|CGA Blue
57|29|ce|Blue Purple
57|39|35|Intergalactic Ray
57|3b|2a|Tuk Tuk
57|3d|37|Vixen
57|40|38|Roasted Kona
57|40|57|Bella
57|46|5d|Conspiracy Velvet
57|4a|47|Molasses
57|4b|50|Kona
57|4d|35|Tǔ Hēi Black
57|53|4b|Masala
57|56|54|Jet Fuel
57|59|3f|Pinetop
57|59|5d|Summer Concrete
57|5a|44|Lone Pine
57|5b|93|Persian Plush
57|5c|3a|Base Camp
57|5e|5f|Mostly Metal
57|5f|6a|Blue Sabre
57|60|49|Grape Leaves
57|66|48|Jalapeno Poppers
57|66|64|Balsam Green
57|67|80|Dana
57|6a|7d|Fern Flower
57|6b|6b|Blue Ballet
57|6d|8e|Kashmir Blue
57|6e|6a|Aventurine
57|6f|44|Asparagus Sprig
57|70|63|Palmerin
57|71|90|Boathouse
57|72|84|Blue Stone
57|72|b0|Prefect
57|73|96|Clean Slate
57|78|a7|Vinca
57|7a|6c|Stately Stems
57|7e|88|La Pineta
57|7f|ae|Blue Fin
57|82|70|Frosty Spruce
57|83|63|Soylent Green
57|84|c1|Havelock Blue
57|86|b4|Blue Smart
57|87|58|Emerald Ring
57|89|a5|Kuta Surf
57|96|a1|Star City
57|9d|ab|Flood Out
57|a1|a0|Teal Bayou
57|a9|d4|Hoeth Blue
57|b7|c5|Aqualogic
57|b8|dc|Nancy
58|0f|41|Plum Purple
58|11|1a|Chocolate Cosmos
58|21|24|Burnt Crimson
58|2b|36|Windsor Wine
58|2f|2b|Dark Mochaccino
58|34|32|Rum Raisin
58|35|80|Kingfisher Daisy
58|36|3d|Vineyard Wine
58|38|22|Kuro Brown
58|3a|39|Smoked Claret
58|3d|37|Rich Loam
58|41|65|When Blue Met Red
58|42|3f|French Roast
58|42|4c|Grapes of Wrath
58|42|7c|Cyber Grape
58|47|69|Woad Purple
58|4b|4e|Wizard's Spell
58|4c|25|Bronze Olive
58|51|6e|Exotic Evening
58|54|42|Ivy Green
58|54|52|Tundora
58|55|38|Bronze Icon
58|56|42|Second Nature
58|56|73|The Fang
58|59|60|Midnight Badger
58|5d|4e|Nottingham Forest
58|5e|6a|Evening East
58|5e|6f|Grisaille
58|64|6d|Stormy Weather
58|68|ae|Evening Lagoon
58|6a|7d|Scholarship
58|6e|75|Moody Blues
58|71|4a|Climbing Ivy
58|79|a2|Montreux Blue
58|7a|65|Dark Sorrel
58|7d|79|Green Hour
58|8c|3a|Indica
58|8f|a0|Sail Cover
58|93|6d|DaVanzo Green
58|9f|7e|Green Spruce
58|a0|bc|Dupain
58|a8|3b|Ballyhoo
58|ac|8f|O'grady Green
58|ba|c2|Sussie
58|bc|08|Frog Green
58|c1|cd|Baharroth Blue
58|c8|b6|Cockatoo
58|c9|d4|Blue Radiance
58|d3|32|Download Progress
58|d8|54|Koopa Green Shell
58|f8|98|Thallium Flame
59|27|20|Caput Mortuum
59|29|2c|Kuwazome Red
59|2b|1f|Kōrozen
59|35|5e|Passion Razz
59|37|61|Majesty
59|39|4c|Dulcet Violet
59|3a|27|Weathered Bamboo
59|3c|39|Brown Stone
59|3c|50|Purple Cort
59|45|37|Brown Derby
59|46|70|Purple Feather
59|46|b2|Swiss Plum
59|4e|40|Afternoon Tea
59|4f|40|Mama Racoon
59|50|4c|Weathered Brown
59|54|38|Batu Cave
59|55|39|Danger Ridge
59|56|46|Fern Gully
59|56|48|Millbrook
59|56|52|Pure Black
59|58|57|Sumi Ink
59|59|ab|Yuè Guāng Lán Moonlight
59|5a|5c|Zombie
59|5d|45|Tree of Life
59|60|62|Anchor Grey
59|64|42|Gretna Green
59|64|72|Fuel Town
59|65|6d|Slate Grey
59|68|5f|Hockham Green
59|6c|3c|Spring Onion
59|71|75|Porch Swing
59|71|91|French Diamond
59|72|8e|Coronet Blue
59|75|4d|Willow Bough
59|77|66|Mt Burleigh
59|7f|b9|Woad Blue
59|80|69|Holenso
59|84|b0|Splash Palace
59|85|56|Magic Sage
59|87|84|Cretan Green
59|9c|89|Derby Green
59|9c|99|Caulerpa Lentillifera
59|9f|99|Agate Green
59|a6|cf|First Landing
59|b6|d9|Aquella
59|b9|c6|Shinbashi
59|b9|cc|High Dive
59|ba|a3|Puerto Rico
59|bb|c2|Pharaoh's Seas
59|c8|a5|Mermaid's Kiss
5a|06|ef|Wèi Lán Azure
5a|19|91|Banafš Violet
5a|2f|43|Grape Wine
5a|39|5b|Purple Wineberry
5a|3d|3f|Deep Prunus
5a|3e|36|Rocky Road
5a|43|51|Smoked Amethyst
5a|44|58|Polka Dot Plum
5a|46|32|Desert Palm
5a|47|43|Shopping Bag
5a|47|69|Loganberry
5a|48|4b|Carob Chip
5a|4c|42|Cork
5a|4d|39|Beggar
5a|4d|41|Rock
5a|4d|55|Purple Empire
5a|4e|88|Bright Eggplant
5a|4e|8f|Purple Corallite
5a|4f|51|Don Juan
5a|4f|74|Benikakehana Purple
5a|4f|cf|Iris
5a|53|48|Tarmac
5a|57|3f|Devlan Mud
5a|5b|9f|Blue Iris
5a|5e|6a|Blue Linen
5a|5f|68|Blue Slate
5a|62|72|Speedwell
5a|63|70|Blue Metal
5a|64|57|Wet Aloeswood
5a|65|3a|Marsh Mix
5a|66|47|Olympia Ivy
5a|66|5c|Spirulina
5a|68|68|Wing Man
5a|6a|43|Silverbeet
5a|6a|8c|Allegiance
5a|6d|77|Rolling Sea
5a|6e|41|Chalet Green
5a|6e|9c|Moonshade
5a|72|47|Kale
5a|77|a8|Blue Yonder
5a|78|9a|Quiet Harbour
5a|79|ba|Pale Flower Cherry Blossom
5a|7d|7a|Trumpet Teal
5a|7d|9a|Hint of Steel Blue
5a|80|9e|Blue Beads
5a|86|ad|Sand Shark
5a|95|89|Fiddler
5a|9e|4b|Golf Course
5a|a7|a0|Paradise Island
5a|b5|cb|Water Baby
5a|b9|a4|Shylock
5a|ca|a4|Diroset
5b|30|82|Deep Amethyst
5b|32|56|Japanese Violet
5b|34|2e|Redwood
5b|35|30|Library Red
5b|36|44|Mauve Wine
5b|3a|24|Carnaby Tan
5b|3d|27|Bracken
5b|3e|90|Daisy Bush
5b|41|48|Bruised Burgundy
5b|43|49|Huckleberry
5b|47|63|Purple People Eater
5b|4a|44|Bear in Mind
5b|4c|44|Sarsaparilla
5b|4d|54|Purple Prince
5b|4e|4b|Black Sand
5b|4f|3b|Beech
5b|51|49|Major Brown
5b|5a|41|Winter Moss
5b|5a|4d|Osiris
5b|5c|5a|Zinc Dust
5b|5d|56|Chicago
5b|5e|61|Glazed Granite
5b|60|9e|Iris Bloom
5b|63|56|Willow Sooty Bamboo
5b|66|76|Blue Zephyr
5b|68|6f|Made of Steel
5b|6a|7c|Spinning Blue
5b|6d|84|Boundless
5b|6e|74|Superstition
5b|6e|91|Waikawa Grey
5b|6f|55|Cactus
5b|6f|61|Army Canvas
5b|70|85|Silver Blueberry
5b|77|63|Dark Ivy
5b|79|61|Comfrey
5b|7a|9c|Blue Plate
5b|7c|99|Slate Blue
5b|7e|98|Blue Heaven
5b|89|30|Fresh Onion
5b|89|c0|Danube
5b|8d|6b|Murdoch
5b|92|e5|United Nations Blue
5b|97|6a|Endless
5b|a0|d0|Picton Blue
5b|a8|ff|Âbi Blue
5b|ac|c3|Blue Mist
5b|b4|d7|Disembark
5c|05|36|Mulberry Wood
5c|29|35|Zinfandel
5c|33|17|Baker's Chocolate
5c|33|57|Spanish Plum
5c|38|39|Warmed Wine
5c|39|37|Taxite
5c|3a|4d|Prune Purple
5c|3c|0d|Hippogriff Brown
5c|3c|6d|Honey Flower
5c|3e|35|Chocolate Lab
5c|40|33|Pitch Mary Brown
5c|44|50|Purple Basil
5c|46|71|Blue Tulip
5c|48|27|Nightingale
5c|49|39|Dark Earth
5c|4f|6a|Blackcurrant Elixir
5c|50|3a|Arrow Shaft
5c|50|42|Star Anise
5c|51|2f|West Coast
5c|53|37|Marsh
5c|54|4e|Mousy Indigo
5c|54|51|Wolf's Fur
5c|54|6e|Arraign
5c|56|38|Maze
5c|56|44|Walnut Grove
5c|56|58|Foggy London
5c|59|54|Stormvermin Fur
5c|5d|5d|Knight's Armor
5c|5f|4b|Fresh Basil
5c|61|41|Tank
5c|61|9d|Violet Storm
5c|62|72|Confederate
5c|62|74|Pencil Lead
5c|67|30|Deathworld Forest
5c|6b|65|Artistic Stone
5c|6d|7c|Blue Mirage
5c|79|8e|Provincial Blue
5c|81|73|Cutty Sark
5c|89|9b|Adriatic Blue
5c|8b|15|Sap Green
5c|9f|59|Vivid Imagination
5c|a6|ce|Ethereal Blue
5c|a9|04|Leaf Green
5c|ac|2d|Grass
5c|ac|ce|Blue Grotto
5c|b2|00|Kermit Green
5c|bf|ce|Skink Blue
5c|cd|97|Vegetation
5d|06|e9|Gonzo Violet
5d|14|51|Grape Purple
5d|19|16|Philippine Brown
5d|1f|1e|Red Oxide
5d|21|d0|Nasu Purple
5d|2b|2c|Christmas Brown
5d|34|1a|Bock
5d|39|54|Dark Byzantium
5d|3a|1a|Earthtone
5d|3a|47|Enchantress
5d|3b|2e|Cioccolato
5d|3c|43|Catawba Grape
5d|3f|6a|Kikyō Purple
5d|42|36|Fondue Fudge
5d|42|50|Majestic
5d|47|3a|Carafe
5d|4a|61|Plush Purple
5d|4e|46|Saddle
5d|4e|50|Jacqueline
5d|4f|39|Oak Plank
5d|51|53|Sophisticated Plum
5d|52|42|Walnut Hull
5d|53|46|Judge Grey
5d|58|3e|Tuscan Olive
5d|5b|56|Charcoal Sketch
5d|5b|5b|Iron Fixture
5d|62|5c|Charcoal Briquette
5d|66|aa|Bellflower
5d|67|32|Gretchin Green
5d|69|5a|Pinebrook
5d|6b|75|Big Daddy Blue
5d|6e|3b|Crisp Capsicum
5d|6f|80|Glide Time
5d|71|a9|Dormitory
5d|76|cb|Indigo Light
5d|77|59|Seaweed Tea
5d|7b|89|Night Owl
5d|81|bb|Granada Sky
5d|83|ab|Navigator
5d|84|b1|Shrinking Violet
5d|89|b3|Lichen Blue
5d|8a|9b|Durban Sky
5d|8a|a8|Air Force Blue
5d|8a|aa|Rackley
5d|8c|ae|Gunjō Blue
5d|96|bc|Heritage Blue
5d|98|b3|Pass Time Blue
5d|a4|64|Endo
5d|a4|93|Polished Pine
5d|a9|9f|Dragon Bay
5d|ad|ec|Blue Jeans
5d|af|ce|Crystal Seas
5d|b0|be|Finnish Fiord
5d|b1|c5|Gondolier
5d|b3|ff|Tiān Lán Sky
5d|bd|cb|Faded Jeans
5e|00|92|SQL Injection Purple
5e|28|24|Ebicha Brown
5e|3a|39|Pa Red
5e|42|35|Daniel Boon
5e|46|3c|Northern Territory
5e|4a|47|Mustang
5e|4f|46|Black Walnut
5e|4f|50|Spell
5e|52|39|Men Brown
5e|52|41|Friar's Brown
5e|53|47|Canteen
5e|53|49|Cabin Fever
5e|54|40|Hiking Boots
5e|55|45|Iwaicha Brown
5e|57|49|Deep Sea Turtle
5e|58|96|Old Nan Yarn
5e|5a|59|Waza Bear
5e|5b|4d|Moss Rock
5e|5b|60|Tornado Cloud
5e|5e|5e|Iron
5e|60|63|Sheet Metal
5e|61|5b|Pompeii Ruins
5e|62|4a|Botanical Garden
5e|62|77|Presumption
5e|63|54|Black Forest
5e|64|4f|Oitake Green
5e|67|37|Cedar Green
5e|67|5a|Deep Bottlebrush
5e|68|41|Golfer Green
5e|68|6d|Lava Grey
5e|6a|34|Heavy Khaki
5e|6b|44|Bonza Green
5e|6c|62|Windrock
5e|6d|6e|Brooding Storm
5e|77|4a|Jolly Green
5e|7c|ac|Deck Crew
5e|7e|7d|Edward
5e|7f|b5|Prompt
5e|81|9d|Greyish Blue
5e|81|c1|Bodega Bay
5e|8b|3d|Hidden Paradise
5e|8c|31|Maximum Green
5e|8e|82|Chlorite
5e|8e|91|Tort
5e|97|a9|Deep Diving
5e|99|48|Bredon Green
5e|9b|8a|Grey Teal
5e|9c|a1|Hydroport
5e|9d|47|Calm Balm
5e|ab|81|Green Tourmaline
5e|b2|aa|Artesian Well
5e|b6|8d|Crazy Eyes
5e|ca|ae|Tropical Tide
5e|dc|1f|Green Apple
5f|19|33|Brown Chocolate
5f|2c|2f|Jazz
5f|34|e7|Blue Magenta
5f|38|3c|Red Vine
5f|3b|36|Hereford Bull
5f|3d|32|Painted Bark
5f|3e|3e|Wine Brown
5f|3e|41|Cajun Brown
5f|3e|42|Vulcan Burgundy
5f|40|53|Amaranthine
5f|45|61|Pansy Petal
5f|47|37|Woodland Brown
5f|48|71|Gengiana
5f|49|47|Aged Chocolate
5f|4c|40|Rain Drum
5f|4d|50|Vicarious Violet
5f|4e|72|Mystical
5f|4f|42|Turf
5f|53|4e|Spirit Rock
5f|55|37|Olive Bark
5f|55|47|Rub Elbows
5f|56|3f|Buzzard
5f|57|4f|Dark LUA Console
5f|57|55|Thunderstruck
5f|57|5c|Rabbit
5f|58|54|Bark
5f|58|55|Lahar
5f|58|79|Taylor
5f|5b|4c|Kalamata
5f|5d|48|Olive Court
5f|5d|50|Hayden Valley
5f|5e|62|Castlerock
5f|5f|6e|Mid Grey
5f|60|6e|Venus Mist
5f|61|71|Deep Caribbean
5f|62|55|Sweet Tooth
5f|63|56|Palo Verde
5f|65|3b|Scots Pine
5f|65|5a|Woohringa
5f|66|72|British Shorthair
5f|68|6f|King Creek Falls
5f|68|82|Spaceman
5f|69|57|Italian Basil
5f|6c|3c|Globe Artichoke
5f|6c|74|Midnight Pearl
5f|6d|36|Russian Uniform WW2
5f|6d|b0|Loch Ness
5f|72|78|Goblin Blue
5f|73|55|Vineyard Green
5f|75|8f|Columbus
5f|77|97|Rushing River
5f|79|63|Swanndri
5f|7c|47|Homeopathic
5f|81|51|Glade Green
5f|81|a4|Revival
5f|87|48|Beatnik
5f|8a|8b|Steel Teal
5f|92|28|Pont Moss
5f|93|70|Skarsnik Green
5f|97|27|Limeade
5f|9e|8f|Dull Teal
5f|9e|a0|Cadet Blue
5f|a0|52|Muted Green
5f|a7|77|Aqua Forest
5f|a7|78|Shiny Shamrock
5f|b6|9c|Keppel
5f|b6|bf|Spearfish
5f|c9|bf|Bayside
5f|d1|ba|Sweet Garden
60|1e|f9|Akihabara Arcade
60|28|1e|Chestnut Leather
60|2f|6b|Imperial
60|35|35|Andorra
60|37|2e|Rusted Crimson
60|37|3d|Red Mahogany
60|39|4d|Violet Posy
60|3b|41|Stag Beetle
60|3e|53|Dark Potion
60|40|46|Red Gooseberry
60|40|6d|Grape Popsicle
60|42|41|Fruit Yard
60|46|0f|Mud Brown
60|49|38|Beauty Spot
60|4a|3f|Fudge Truffle
60|4b|42|Little Bear
60|4d|47|Lynx
60|4e|42|Ground Bean
60|4e|7a|Imperial Palace
60|4f|5a|Wishing Star
60|50|4b|Chocolate Pretzel
60|50|dc|Majorelle Blue
60|51|3a|Longboat
60|52|58|Pinot Noir
60|54|3f|Crossbow
60|54|67|Purple Stone
60|55|47|Tea Chest
60|56|4c|Beaver Pelt
60|56|55|Rix
60|56|9a|Purple Opulence
60|58|4b|Mud Room
60|5a|67|Mobster
60|5c|58|Stone's Throw
60|5d|6b|Smoky
60|60|5e|Charcoal Smudge
60|60|61|Kettleman
60|60|6f|Prince Royal
60|62|56|English Forest
60|66|02|Mud Green
60|67|88|Champion Blue
60|68|65|Dark Pewter
60|68|8d|Velvet Morning
60|69|72|Feather Falls
60|6a|88|Grape Haze
60|6b|77|Press Agent
60|6b|8e|Justice
60|70|38|Venom Wyrm
60|73|74|Castaway Lagoon
60|78|79|Becker Blue
60|7b|8e|Canyon Blue
60|7c|3d|Mangrove Leaf
60|7c|47|Dingley
60|7c|8e|Whale Shark
60|82|b6|Glaucous
60|85|7a|Greenella
60|8a|5a|Hippie Green
60|8b|a6|Sea Crystal
60|94|9b|Clear Brook
60|97|95|Loch Blue
60|9a|b8|Shakespeare
60|9d|91|Treasure Isle
60|a0|a3|Meadowbrook
60|a4|48|Zatar Leaf
60|b3|bc|Aqueduct
60|b8|92|Jade Cream
60|b8|be|Dickie Bird
60|b9|22|Field Green
60|c7|c2|Chinese Lacquer
61|00|23|Baal Red Wash
61|22|4a|Plum Caspia
61|2e|35|Chocolate Truffle
61|3a|57|Gypsy Jewels
61|3e|3d|Night Bloom
61|40|51|Old Eggplant
61|40|ef|Purplish Blue
61|42|51|Meranda's Spike
61|44|54|Deep Exquisite
61|47|3b|Pine Cone
61|49|6e|Your Majesty
61|4a|7b|Royal Robe
61|4e|6e|Futaai Indigo
61|51|3d|Corral
61|54|52|Nighthawk
61|55|43|Sandalwood
61|55|44|Light Roast
61|57|53|Pure Zeal
61|58|4f|Metropolis
61|5c|60|Volcanic Glass
61|5d|58|Deep Walnut
61|5e|5f|Granite Grey
61|63|3f|Wood's Creek
61|66|52|Old Army Helmet
61|66|6b|Shuttle Grey
61|6c|44|Pandanus
61|6c|51|Hinterland
61|6f|65|Seraphinite
61|73|6f|Drifting Downstream
61|75|5b|Finlandia
61|81|a3|Blue Boater
61|84|5b|English Ivy
61|8b|97|Bell Blue
61|8b|b9|Silver Lake Blue
61|98|ae|Delphinium Blue
61|9a|d6|Blue Bay
61|a9|a5|Veranda
61|aa|b1|Aquarelle
61|ba|85|Green Garter
61|bd|dc|Sea Capture
61|c9|c1|Nile Stone
61|de|2a|Toxic Green
61|e1|60|Lightish Green
62|2e|5a|Gloxinia
62|39|41|Velvet Cape
62|3d|3d|Cuba Brown
62|40|76|Plum Jam
62|41|33|Teak Wood
62|41|c7|Dragonlord Purple
62|42|2b|Irish Coffee
62|44|35|Thai Teak
62|49|3b|Ship Steering Wheel
62|4f|59|Prophetic Purple
62|53|4f|Grapevine Canyon
62|56|65|Fedora
62|58|c4|Circumorbital Ring
62|59|81|Psychic
62|5a|42|Pinyon Pine
62|5b|5c|Plum Kitten
62|5c|58|Caveman
62|5c|91|Colossus
62|5d|2a|Costa Del Sol
62|5d|5d|Dark Gull Grey
62|60|3e|Verdigris Foncé
62|61|7e|Heron
62|64|dc|Exodus Fruit
62|67|46|Woodland
62|68|79|Folkstone Grey
62|69|6b|Equinox
62|6d|5b|Wimbledon
62|6e|71|American River
62|6f|5d|Bracken Green
62|70|99|Blueberry Patch
62|71|88|Blue Cloud
62|74|ab|King's Robe
62|77|7e|Blue Bayoux
62|7e|75|Penzance
62|80|26|Straken Green
62|8d|aa|Blue Fjord
62|8f|b0|Alpha Tango
62|90|91|Tranquil Seashore
62|91|91|Pauley
62|97|63|Abundance
62|9a|31|Thyme and Salt
62|9d|a6|Echo One
62|a5|df|Windjammer
62|ae|9e|Green Crush
62|ae|ba|Ocean Trip
62|b4|c0|Glacier Lake
63|0f|0f|Blood Organ
63|2a|60|Charisma
63|2d|e9|Yíng Guāng Sè Purple
63|35|28|Hairy Heath
63|3f|2e|Grilled
63|3f|33|Cappuccino
63|40|3a|American Milking Devon
63|40|41|Federation Brown
63|42|35|Tiramisu
63|42|4b|Budōnezumi Grape
63|43|33|Worn Wooden
63|48|75|Presley Purple
63|48|78|Picasso Lily
63|49|3e|Choco Death
63|49|50|Gǔ Tóng Hēi Copper
63|4e|43|Dark Tavern
63|4f|62|Vintage Violet
63|51|47|Gobo Brown
63|55|4b|Ground Coffee
63|56|3b|Military Olive
63|58|4c|Monkey Madness
63|59|40|Puff Dragon
63|59|51|Intrigue
63|5a|4f|Downing to Earth
63|5c|53|Boycott
63|5c|59|Solid Empire
63|5d|63|Wonder Wine
63|61|53|Bull Kelp
63|63|40|Glossy Olive
63|63|73|Comet
63|64|7e|Purple Daze
63|66|53|Winning Ticket
63|68|69|Stone Hearth
63|6c|77|Mirage Blue
63|6d|70|Pale Sky
63|6f|22|Fiji Green
63|6f|46|Grass Blade
63|70|57|Midnight Garden
63|71|95|Ocean Night
63|77|5a|Wild Axolotl
63|77|5b|Salamander
63|79|83|Blue Monday
63|7d|74|Salal Leaves
63|84|96|Granite Falls
63|84|b8|Marine Ink
63|8b|27|Moss Green
63|8f|7b|Sheffield
63|92|83|Patina
63|92|b7|Scuba
63|95|bf|Kentucky
63|9b|95|Soft Touch
63|a9|50|Shiso Green
63|b3|65|Boring Green
63|b5|21|Chasm Green
63|b7|6c|Forest Fern
63|f7|b4|Light Greenish Blue
64|00|5e|Clear Plum
64|01|25|Spring Lobster
64|24|2e|Dark Carmine
64|35|30|War God
64|39|49|High Priest
64|3a|48|Tawny Port
64|3a|4c|Crushed Violets
64|3b|46|Wine Goblet
64|3e|65|Purple Odyssey
64|41|17|Pullman Brown
64|49|82|Violet Majesty
64|4b|41|Chaps
64|50|59|Sinful
64|54|03|Olive Brown
64|54|52|Wenge
64|54|53|High Rank
64|55|30|Uguisu Brown
64|56|71|Rich Texture
64|5a|8b|Idol
64|5d|41|Shagbark Olive
64|5d|5e|Phantom Hue
64|60|49|Burnt Olive
64|60|93|Corsican Blue
64|61|7b|Blue Potato
64|62|55|Marble Garden
64|63|56|Dusty Olive
64|67|56|Strong Olive
64|67|62|Castor Grey
64|67|67|Pointed Rock
64|69|44|Hellebore
64|6a|45|Olive Branch
64|6b|59|Shire
64|6b|77|Noctis
64|6c|64|Gunmetal Grey
64|6f|9b|Bleached Denim
64|79|83|Scatman Blue
64|7b|72|Stockleaf
64|7d|86|Hoki
64|7d|8e|Pier 17 Steel
64|7e|9c|Blue Oar
64|85|89|Arctic
64|88|94|Horizon
64|88|ea|Soft Blue
64|8f|a4|Salt Box Blue
64|95|ed|Guilliman Blue
64|9b|9e|Dusty Turquoise
64|a2|81|Plumosa
64|a5|ad|Nirvana Jewel
64|ac|b5|Experience
64|b3|d3|Shimmering Brook
64|be|9f|Peppermint Fresh
64|bf|a4|Spearmint
64|bf|dc|Magnesia Bay
64|d1|be|Jamaican Jade
64|e9|86|Very Light Malachite Green
65|00|0b|Rosewood
65|00|21|Merguez
65|1a|14|Cherrywood
65|1c|26|Pohutukawa
65|2d|c1|Purple Spot
65|31|8e|True Purple
65|34|4e|Vintage Wine
65|37|00|Brown
65|3b|66|Wine Tour
65|3d|7c|Dark Pansy
65|41|61|Royal Plum
65|43|20|Otter Brown
65|43|21|Satoimo Brown
65|43|4d|Misty Grape
65|46|36|Copra
65|47|41|Gorthor Brown
65|48|46|Outer Boundary
65|4d|49|Congo Brown
65|4f|4f|Robeson Rose
65|50|46|Mayan Chocolate
65|57|77|Regal Gown
65|58|56|Louisiana Mud
65|5f|50|Twisted Vine
65|62|55|Rikyūnezumi Brown
65|62|71|Spike
65|63|44|Capulet Olive
65|64|57|Plunge Pool
65|64|5f|Storm Dust
65|64|66|Smoked Pearl
65|64|70|Eventide
65|65|79|Eggplant Ash
65|66|3f|Mayfly
65|68|74|Alley Cat
65|6b|78|Magic
65|6d|63|Velvet Clover
65|6e|72|Batman
65|70|7e|Buoyant
65|72|20|Fern Frond
65|73|7e|Wharf View
65|74|32|Muddy Green
65|75|8f|Niche
65|76|82|Freedom Found
65|76|9a|Colony Blue
65|78|8c|Enterprise
65|84|77|Lorna
65|84|98|Tambua Bay
65|84|99|Blowout
65|86|9b|Seal Pup
65|8b|38|Gǎn Lǎn Lǜ Green
65|8c|7b|Sea Monster
65|8c|88|Oil Blue
65|8c|bb|Faded Blue
65|8d|6d|Slate Green
65|8d|c6|Provence
65|8e|64|Succulent Leaves
65|8e|67|Stone Green
65|8f|7c|Stanford Green
65|94|bc|Blue Marble
65|97|cc|Quiet Bay
65|99|a4|Princess Kate
65|9f|b5|Dolphin Daze
65|a5|d5|Water Spirit
65|ab|7c|Green Tea Candy
65|ad|b2|Fountain Blue
65|ce|95|Van Gogh Green
65|dc|d6|Hammam Blue
65|fe|08|Bright Lime Green
66|00|00|Red Blood
66|00|66|Purple Dreamer
66|00|77|Zeus Purple
66|00|88|Peaceful Purple
66|00|99|Indigo Purple
66|00|ff|Electric Indigo
66|02|3c|Tyrian Purple
66|03|3c|Spanish Purple
66|11|00|Cowpeas
66|11|88|Extraviolet
66|1a|ee|Purple Blue
66|22|00|Raw Chocolate
66|22|66|Blackest Berry
66|22|77|Berry Blackmail
66|22|88|Sapphire Siren
66|2a|2c|Devil's Lip
66|32|71|Purple Magic
66|33|00|Beasty Brown
66|33|11|Meatloaf
66|33|36|Port
66|33|99|Rebecca Purple
66|35|2b|Cherry Mahogany
66|38|54|Halayà Úbe
66|3b|3a|Bogong Moth
66|3c|55|Primitive Plum
66|3f|3f|Mecca Red
66|42|28|Van Dyke Brown
66|42|38|Brunette
66|42|4d|Deep Tuscan Red
66|43|48|Shaded Fuchsia
66|49|42|Spiced Wine
66|4a|2d|Dallas
66|52|61|Purple Trinket
66|53|43|Rokō Brown
66|55|37|Cartwheel
66|5a|38|Beach Casuarina
66|5a|48|Grand Avenue
66|5c|46|Stone Pine
66|5d|59|Oswego Tea
66|5d|63|Moired Satin
66|5d|9e|Giant Onion
66|5f|d1|Dark Periwinkle
66|64|8b|Twilight Purple
66|65|56|Nevergreen
66|66|00|Earthy Khaki Green
66|66|55|Dark Seagreen
66|66|77|London Grey
66|66|99|Dark Horizon
66|66|bb|Bluish Purple Anemone
66|66|ee|Blue Hepatica
66|66|ff|Blue Genie
66|67|5a|Greenish Grey Bark
66|67|6d|Quiet Shade
66|6a|60|Nature's Gate
66|6a|6d|Midnight Grey
66|6a|76|Blue Sari
66|6e|7f|Shutter Blue
66|6f|6f|Nevada
66|6f|b4|Chetwode Blue
66|70|28|Forest Spirit
66|77|44|Ghoul Skin
66|78|7e|Night Rendezvous
66|78|9a|Chicory Flower
66|79|60|Mildura
66|7c|3e|Military Green
66|7c|71|Cypress Garden
66|7e|2c|Dirty Green
66|80|bb|Amazing Smoke
66|82|9a|Blue Shadow
66|88|cc|Livid
66|92|64|Arizona Tree Frog
66|99|99|Desaturated Cyan
66|99|aa|Cloudy Sea
66|99|cc|Lothern Blue
66|9c|7d|Dying Moss
66|a3|c3|Scott Base
66|a6|d9|Baja Blue
66|a9|b0|Timid Sea
66|a9|b1|Summer Sea
66|a9|d3|Salem Blue
66|aa|00|Appetizing Asparagus
66|b0|32|Yule Tree
66|b2|e4|Sanctuary Spa
66|b3|48|Sour Candy
66|b7|e1|Malibu
66|b8|9c|Sainsbury
66|b9|d6|Baby Tears
66|bc|91|Katydid
66|c3|d0|Arctic Ocean
66|cd|aa|Aquarium Blue
66|d0|c0|Green Patina
66|dd|aa|Medium Aquamarine
66|dd|ff|Athena Blue
66|ee|ee|Poseidon Jr.
66|fc|00|Fertility Green
66|ff|00|Bright Green
66|ff|11|Poisoning Green
66|ff|22|Venomous Green
66|ff|66|Screamin' Green
67|08|0b|Blood God
67|24|22|Azuki Red
67|31|45|Wine Dregs
67|31|47|Old Mauve
67|3a|3f|Purple Brown
67|41|96|Sweet Flag
67|42|2d|Triassic
67|42|3b|Autumn Fall
67|42|44|Smoked Flamingo
67|42|47|Jazzberry Jam
67|44|03|Violin Brown
67|45|50|Plum Wine
67|48|34|Jambalaya
67|48|46|Rose Ebony
67|48|48|Chocolate Eclair
67|48|76|Neon Violet
67|4c|47|Medium Taupe
67|56|57|Plum Truffle
67|57|54|Nocturnal Flight
67|59|2a|Fir Green
67|5a|74|Mulled Grape
67|5c|49|City Bench
67|5d|62|Vintage Plum
67|61|68|Excalibur
67|66|62|Wire Wool
67|66|7c|Swollen Sky
67|69|57|Green Gate
67|69|65|Fade to Black
67|6b|55|Bijoux Green
67|6c|58|All About Olive
67|6e|7a|Hong Kong Skyline
67|70|6d|York River Green
67|70|7d|Purebred
67|72|83|Flintstone
67|74|4a|Dill Pickle
67|77|8a|Charcoal Blue
67|78|6e|Camping Trip
67|7a|04|Olive Green
67|7f|70|Ecological
67|87|79|Aloe Vera
67|92|67|Russian Green
67|95|91|Green Turquoise
67|97|a2|Shore Water
67|9b|6a|Leafy
67|a1|59|Astroturf
67|a1|81|Sea Lettuce
67|a1|95|Colony
67|a6|ac|Blue Mercury
67|ad|83|Sea Grass
67|ae|d0|Imrik Blue
67|bc|b3|Pool Blue
67|be|90|Silver Tree
68|00|18|Claret
68|0c|08|Beastly Flesh
68|28|60|Palatinate Purple
68|29|61|Grape Juice
68|32|e3|Burple
68|33|32|Dried Plum
68|36|00|Nutmeg Wood Finish
68|39|3b|Forest Fruit Pink
68|3b|39|Hot Chocolate
68|3d|62|Purple Passion
68|3f|36|Sekkasshoku Brown
68|41|41|Folklore
68|44|fc|Pink OCD
68|45|7a|Palace Purple
68|48|32|Emperador
68|49|76|Clary
68|4b|40|Spanish Mustang
68|55|3a|Graveyard Earth
68|57|8c|Butterfly Bush
68|5a|4e|Chocolate Chip
68|5c|53|Morel
68|5c|61|Mauve Mystery
68|5e|4f|Spooky Graveyard
68|5e|5b|Bessie
68|67|67|Shadow Gargoyle
68|68|58|Double Duty
68|69|59|Jungle Cloak
68|6b|50|Siam
68|6b|93|Wild Wisteria
68|6c|7b|Wind Cave
68|6d|6c|Sedona Sage
68|6e|43|Gulf Weed
68|75|5d|Bean Counter
68|75|7e|Long Lake
68|76|6e|Sirocco
68|7b|92|Blue Suede
68|80|49|Beyond the Pines
68|84|6a|Christmas Holly
68|85|5a|Tee Off
68|88|fc|Punch Out Glove
68|8d|8a|Ebbing Tide
68|96|63|Milpa
68|9d|b7|Lake Lucerne
68|a0|b0|Crystal Blue
68|b0|82|Elf Shoe
68|bd|56|Range Land
68|be|8d|Young Bamboo
68|e5|2f|Shire Green
69|00|5f|Divine Purple
69|04|5f|Amygdala Purple
69|27|46|Witch Soup
69|29|3b|Siren
69|32|6e|Seance
69|35|9c|Purple Heart
69|44|4f|Wine Stain
69|45|54|Finn
69|47|5a|Magos
69|48|78|Perfectly Purple
69|49|77|Benevolence
69|4e|52|Flamboyant Plum
69|55|6d|Medicine Man
69|56|45|Buffalo Dance
69|56|49|Wild Mustang
69|59|5c|Sparrow
69|5a|82|Concord Jam
69|5d|87|Kimberly
69|5e|4b|Capers
69|5f|4f|Lemur
69|5f|50|Makara
69|60|06|Green Brown
69|60|5a|Brood
69|61|12|Greenish Brown
69|61|56|Bungee Cord
69|62|68|Blackwater Park
69|63|74|Purple Punch
69|65|6a|Cracked Slate
69|66|7c|Unexplained
69|66|84|Daemonette Hide
69|67|3a|Deep Reed
69|68|45|Eat Your Greens
69|68|4b|Hemlock
69|69|69|Dim Grey
69|69|87|Luscious Lavender
69|6b|a0|Dusted Peri
69|6f|a5|Kimberlite
69|70|78|Dapper Greyhound
69|75|5c|Willow Grove
69|7a|7e|Trooper
69|7d|4c|Leaf Tea
69|7d|89|Lynch
69|7f|8e|Cascade Tour
69|80|4b|Woodland Nymph
69|83|39|Swamp Moss
69|85|89|Thundercloud
69|86|5b|Thicket
69|88|90|Gothic
69|8a|ab|Pale Flower
69|8e|b3|Genteel Blue
69|90|5b|Irish Charm
69|91|3d|Mary's Garden
69|91|58|Fluorite Green
69|91|6e|Prickly Pear Cactus
69|9d|4c|Flat Green
69|a4|b9|Pacific Palisade
69|ac|58|Techno Green
69|b0|76|Pale Green
69|b2|cf|Charter
69|d8|4f|Fresh Green
6a|00|01|Khorne Red
6a|00|02|Arcavia Red
6a|1f|44|Pompadour
6a|28|2c|Syrah
6a|2e|2a|Fired Brick
6a|31|ca|Sagat Purple
6a|33|31|Madder Brown
6a|39|39|Plum Sauce
6a|39|7b|Amaranth Purple
6a|3c|3a|Victoria Red
6a|3d|36|Burnished Bark
6a|43|2d|Aloeswood
6a|43|45|Dark Mushroom
6a|49|28|Cafe Royale
6a|51|3b|Coffee Liqueur
6a|52|87|Zimidar
6a|54|45|Quincy
6a|55|36|Ancient Olive
6a|56|37|Chieftain
6a|58|7e|Grape Expectations
6a|5a|cd|Ameixa
6a|5b|b1|Blue Marguerite
6a|5d|53|Sausalito Ridge
6a|62|83|Purple Gumball
6a|64|66|Scorpion
6a|64|72|Silverado
6a|68|73|Deep Sea Dolphin
6a|69|5a|Duck Willow
6a|6b|65|Armory
6a|6b|67|Iron-ic
6a|6e|09|Brownish Green
6a|6f|34|Calla Green
6a|75|ad|Midnight Violet
6a|79|78|Trade Secret
6a|79|f7|Byzantine Night Blue
6a|7b|6b|Cricket Green
6a|7d|4e|Mint Leaves
6a|7e|5f|Emerald City
6a|7f|7a|Sabiasagi Blue
6a|7f|7d|Dark Lagoon
6a|7f|b4|Marvellous
6a|80|8f|Blue Prince
6a|81|9e|Bay View
6a|83|89|Puddle Jumper
6a|84|72|Ranger Green
6a|85|61|Bladerunner
6a|89|88|Overgrown Trellis
6a|8b|98|Spirit Mountain
6a|8d|88|Aspen Hush
6a|92|66|Blade Green
6a|9a|8e|Little League
6a|b2|ca|Delicate Girl Blue
6a|b4|17|Extra Life
6a|b4|e0|Xavier Blue
6a|b5|4b|Pure Apple
6a|dc|99|Aurora Green
6b|25|2c|Monarch
6b|26|4b|Magenta Purple
6b|39|00|Bestial Brown
6b|3c|39|Murray Red
6b|3f|a0|Poppy Pompadour
6b|42|26|Semi Sweet Chocolate
6b|42|47|Purplish Brown
6b|44|23|Kobicha
6b|44|24|Flattery
6b|44|3d|Sunken Ship
6b|47|30|Axe Handle
6b|47|5d|Annis
6b|48|36|Satin Soil
6b|49|47|Painite
6b|4c|37|Guitar
6b|51|40|Buckingham Palace
6b|51|5f|Exclusively
6b|57|4a|Chocolate Chunk
6b|58|76|Grape Compote
6b|59|3c|Gun Corps Brown
6b|5a|5a|Zambezi
6b|5e|5d|Moroccan Dusk
6b|5f|68|Fiji Coral
6b|60|48|Overgrown
6b|60|5a|Velvet Umber
6b|60|5b|Bull Ring
6b|69|65|Volcanic Rock
6b|6a|6c|Scarpa Flow
6b|6a|74|Warpfiend Grey
6b|6d|4e|Rustling Leaves
6b|6d|85|Great Grape
6b|6f|59|Iwai Brown
6b|70|61|Moss Beach
6b|71|69|Agave Green
6b|76|80|Sheffield Grey
6b|7b|a7|Night Thistle
6b|7c|85|Astronomicon Grey
6b|7f|81|Blue Blood
6b|83|72|Wild Beet Leaf
6b|88|85|Classic Calm
6b|8b|75|Juniper Oil
6b|8b|8b|Sealegs
6b|8b|a2|Bermuda Grey
6b|8b|a4|Stormy Strait Grey
6b|8c|23|Italian Buckthorn
6b|8e|23|Scallion
6b|93|62|Wakatake Green
6b|97|7a|Club Moss
6b|a0|bf|Fate
6b|a3|53|Off Green
6b|a5|a9|Fairstar
6b|aa|ae|Aqua Sea
6b|b1|b4|Dexter
6b|c2|71|Bermudagrass
6c|2c|2f|Spring Lobster Brown
6c|2e|1f|Hereford Cow Brown
6c|32|2e|Kenyan Copper
6c|34|61|Grape
6c|37|36|Sanguine Brown
6c|38|3c|Rubine
6c|40|3e|Burgundy Wine
6c|45|22|Bunni Brown
6c|46|1f|Antique Brass
6c|46|2d|Pumpernickel Brown
6c|48|3a|Birdhouse Brown
6c|4e|79|Patrician Purple
6c|4f|3f|Spice
6c|54|1e|Field Drab
6c|56|54|Bourbon Truffle
6c|56|56|Peppercorn
6c|57|65|Black Plum
6c|59|71|Montana Grape
6c|5b|4c|Domino
6c|5b|4d|Coffee House
6c|5e|53|Kabul
6c|60|68|Vibrant Vision
6c|63|58|Carriage
6c|64|59|Ploughed Earth
6c|65|41|Ocean Weed
6c|65|56|Shaker Grey
6c|68|68|Dotted Dove
6c|69|56|Aged Jade
6c|6a|43|Fossil Green
6c|6b|6a|Boat Anchor
6c|6d|7a|Space Station
6c|6e|7e|Mountain Haze
6c|6f|78|Granite Canyon
6c|70|5e|Shutters
6c|70|68|Queen Valley
6c|70|a9|Jacaranda Jazz
6c|71|79|Draw Your Sword
6c|71|86|Rockabilly
6c|75|7d|Pompeii Ash
6c|76|5c|Lush Hosta
6c|77|79|Pike Lake
6c|7a|0e|Murky Green
6c|7c|6d|Brussels
6c|80|96|Grey Blueberry
6c|84|8d|Indigo Mouse
6c|84|9b|Lakeville
6c|90|b2|Grant Village
6c|91|9f|Wave Jumper
6c|94|cd|Zeus'Temple
6c|a0|dc|Little Boy Blue
6c|a1|78|Growth
6c|b0|37|Starbur
6c|ba|e7|Norfolk Sky
6c|c1|bb|Tropic Tide
6c|c4|da|Squeaky
6c|cc|7b|Snow Pea
6c|da|e7|Turquoise Sea
6d|10|08|Chestnut Brown
6d|24|00|Centipede Brown
6d|2b|50|Ebizome Purple
6d|34|45|Cabernet Craving
6d|3b|24|New Amber
6d|3c|32|Chestnut Peel
6d|3d|2a|Red Mane
6d|40|52|Chilled Wine
6d|43|4e|Cryptic Light
6d|44|44|Moroccan Leather
6d|46|60|Wizard Time
6d|47|41|Warm Mahogany
6d|47|73|Spiced Plum
6d|49|76|Hyssop
6d|50|44|Calthan Brown
6d|51|60|Dynamic
6d|56|2c|Horses Neck
6d|56|98|Passion Flower
6d|58|37|Bulrush
6d|58|43|Tobacco Brown
6d|5a|cf|Light Indigo
6d|5c|7b|Princely Violet
6d|60|53|Introspective
6d|61|66|Grape Grey
6d|62|40|Bronze Medal
6d|63|53|Harold
6d|69|5e|Secret Passageway
6d|69|a1|Inner Journey
6d|6c|5f|Knit Cardigan
6d|6c|6c|Dove Grey
6d|6e|7b|Prediction
6d|6f|4f|Toy Tank Green
6d|70|58|Flinders Green
6d|72|44|Oakmoss
6d|75|3b|Swamp Shrub
6d|75|8f|Legal Eagle
6d|76|5b|Dark Sage
6d|78|76|Rolling Stone
6d|7a|6a|Remote Control
6d|83|bb|Orbital
6d|86|87|Hammock
6d|86|b6|Kimono
6d|89|94|Jeans Indigo
6d|8a|74|Capsella
6d|8e|44|Athonian Camoshade
6d|91|85|Pine Ridge
6d|91|92|Mineral Blue
6d|92|88|Nephrite
6d|98|c4|Windstorm
6d|9a|78|Oxley
6d|9a|79|Precious Oxley
6d|9a|9b|Palmetto
6d|9b|c3|Cerulean Frost
6d|9e|7a|Holiday Camp
6d|a2|9e|Canton
6d|a8|93|Peacock Silk
6d|a9|d2|Alaskan Blue
6d|ae|81|Morning Forest
6d|af|a7|Tradewind
6d|ba|c0|Castaway
6d|ce|87|Spring Bouquet
6d|ed|fd|Robin's Egg
6e|00|60|Hexed Lichen
6e|10|05|Reddy Brown
6e|22|33|Squid Hat
6e|33|26|Pueblo
6e|35|30|Henna Red
6e|36|2c|Smoked Paprika
6e|39|74|Eminence
6e|3a|07|Philippine Bronze
6e|3d|34|Metallic Copper
6e|40|3c|Sable
6e|45|34|Brisket
6e|48|26|Pickled Bean
6e|49|3a|Friar Brown
6e|49|3d|Dancing Dogs
6e|4c|4b|Marron
6e|4f|3a|Bison
6e|51|50|Buccaneer
6e|51|60|Dark Olive Paste
6e|56|4a|Caramelized Walnut
6e|57|55|Purple Statement
6e|5a|5b|Falcon
6e|5c|4b|Cub
6e|5d|3e|Uniform Brown
6e|5f|56|Dorado
6e|5f|57|Sunezumi Brown
6e|60|64|Duomo
6e|64|55|Never Cry Wolf
6e|66|54|Bronze Fig
6e|69|70|Purple Comet
6e|6a|3b|Robinhood
6e|6a|44|Deep Aloe Vera
6e|6a|51|Spruce Woods
6e|6c|5b|Coastline Trail
6e|6e|30|Aged Mustard Green
6e|6e|5c|Deep Lichen Green
6e|6f|56|Green Illude
6e|6f|82|Old Mill Blue
6e|70|6d|Up In Smoke
6e|71|53|Loden Green
6e|73|76|Improbable
6e|75|0e|Spinach Soup
6e|79|55|Kariyasu Green
6e|79|7b|Phantom
6e|79|9b|Quantum Blue
6e|7e|99|Infinity
6e|7f|80|AuroMetalSaurus
6e|80|82|Stormy Sea
6e|81|be|Persian Jewel
6e|82|6e|Hibiscus Leaf
6e|8d|71|Laurel
6e|93|77|Watercress
6e|99|d1|Sea Loch
6e|b4|78|Appleton
6e|cb|3c|Bitter Dandelion
6f|00|fe|Bright Indigo
6f|30|28|Cypress Bark Red
6f|37|2d|Strong Mocha
6f|39|42|Ripening Grape
6f|42|32|Heart Wood
6f|43|4a|Legal Ribbon
6f|45|6e|Sunset Purple
6f|46|85|Purple Sapphire
6f|4b|3e|Burned Brown
6f|4c|37|Tuscan Brown
6f|4d|3f|Arabic Coffee
6f|4e|37|Coffee
6f|51|4c|Susu-Take Bamboo
6f|57|49|Mournfang Brown
6f|59|37|Bali Batik
6f|59|44|Baby Bear
6f|59|65|Ephemera
6f|5a|48|Mexican Chocolate
6f|5d|57|Missing Link
6f|60|66|Catnip Wood
6f|61|38|Rationality
6f|63|4b|Soya Bean
6f|63|a0|Scampi
6f|66|65|Chocolate Pudding
6f|67|5c|Grouchy Badger
6f|6a|52|Mysterious Moss
6f|6a|68|Gibraltar Grey
6f|6c|0a|Worn Olive
6f|6d|56|Secluded Green
6f|6e|d1|C64 Purple
6f|74|76|Battleship Grey
6f|74|7b|Raven
6f|76|32|Olive Drab
6f|76|78|Volcanic Ash
6f|77|55|Dill
6f|7c|00|Topiary Garden
6f|7d|6d|Garden Hedge
6f|82|8a|Polished Steel
6f|8c|69|Turf Green
6f|8c|9f|Bermuda Triangle
6f|8d|6a|Kashmir
6f|8d|af|Distant Sky
6f|95|87|Up North
6f|95|c1|Blue Tuna
6f|9f|a9|Reef Waters
6f|9f|b9|Adventure Isle
6f|a7|7a|Primavera
6f|ab|92|Dublin Jack
6f|b0|be|Water Music
6f|c0|b1|Fiesta Blue
6f|c1|af|T-Bird Turquoise
6f|c2|76|Soft Green
6f|c2|88|Clover Mist
6f|c3|91|Felt Green
6f|d2|be|Downy
6f|e7|db|Turquoise Chalk
6f|ea|3e|Miyazaki Verdant
6f|ff|ff|Aggressive Baby Blue
70|19|1f|Surya Red
70|1c|11|Prune
70|1c|1c|Persian Plum
70|1f|28|Red Berry
70|29|63|Byzantium
70|36|42|Catawba
70|39|3f|Griffon Brown
70|3b|e7|Bluish Purple
70|3f|00|Bloodtracker Brown
70|40|3d|Wine Cellar
70|42|14|Sepia
70|42|41|Deep Coffee
70|43|41|Roast Coffee
70|48|22|Monks Robe
70|4a|07|Antique Bronze
70|4f|37|Dachshund
70|50|46|Buffalo Herd
70|54|3e|Mud
70|54|46|Dark Highlight
70|55|36|Rustic Cabin
70|56|76|Trixter
70|58|a3|Sumire Violet
70|5a|46|Log Cabin
70|5a|56|Taupe Night
70|5f|63|Impromptu
70|60|48|Midnight Brown
70|62|5c|Fozzie Bear
70|68|42|Swinging Vine
70|69|50|Crocodile
70|69|86|Aromatic
70|6c|11|Brown Green
70|6d|5e|King's Court
70|6e|66|Ironside Grey
70|75|6e|Dawnstone
70|76|51|Ranger Station
70|76|7b|Rhythm & Blues
70|78|9b|Blue Ice
70|7a|68|Sedge Green
70|7b|71|Boxwood
70|7b|b4|Iolite
70|7c|78|Grey Monument
70|7e|84|Taliesin Blue
70|80|4d|Creamed Avocado
70|80|90|Chain Gang Grey
70|82|8f|Mica Creek
70|85|5e|Equatorial Forest
70|8d|6c|Forest Path
70|8e|95|Baritone
70|93|9e|Silk Khimar
70|9d|3d|Pea Case
70|a3|8d|Quilotoa Green
70|a4|b0|Stillwater
70|a5|b7|Estuary Blue
70|b2|3f|Nasty Green
70|b2|cc|Aspara
70|b8|d0|Blue Brocade
70|ba|9f|Arboretum
70|c1|e0|Mizu
70|cb|ce|Tropical Splash
70|d4|fb|Heisenberg Blue
71|1a|00|Cedar Wood Finish
71|2f|2c|Auburn
71|38|4b|Grapeshot
71|38|4c|Venusian
71|42|4a|Pirat's Wine
71|46|36|Santana Soul
71|4a|41|Root Beer
71|50|55|Night Romance
71|51|45|Bigfoot
71|56|36|Oak Barrel
71|5a|8d|Emperor Jewel
71|5d|3d|Muddy River
71|60|63|Plum Crush
71|61|40|US Field Drab
71|62|46|Kelp Brown
71|63|5a|Leroy
71|64|3e|Lizard
71|65|63|Sultry Spell
71|66|75|Rum
71|67|48|Nessie
71|69|70|Pirate's Trinket
71|6a|4d|Olive Grove
71|6b|63|Shot-Put
71|6e|61|Flint
71|70|6e|Dark Silver
71|71|4e|Gratefully Grass
71|73|88|Blue Granite
71|74|62|Magic Mountain
71|74|74|Sandpiper Cove
71|74|86|Storm Grey
71|77|7e|Bilberry
71|78|67|Burdock
71|7e|6f|Devon Rex
71|7f|9b|Country Blue
71|81|8c|Oyster Bay
71|81|a4|English Manor
71|84|7d|Dwarf Spruce
71|89|81|Misty Moor
71|89|8d|Twilight Stroll
71|8b|9a|China Clay
71|8f|8a|Gumbo
71|96|a6|Smoky Blue
71|97|cb|Razee
71|98|c0|Pinafore Blue
71|9e|8a|Peahen
71|9f|91|Greyish Teal
71|a6|a1|Steel Pan Mallet
71|a6|d2|Polar Ice
71|a9|1d|Christi
71|aa|34|Leaf
71|ba|b4|Earth Eclipse
71|bc|77|Iguana Green
71|bc|78|Young Fern
71|d9|e2|Aquamarine Blue
72|00|58|Rich Purple
72|0b|98|Chinese Purple
72|1f|37|Rocking Chair
72|2b|3f|Rhododendron
72|2f|37|Red Wine Vinegar
72|39|3f|Antique Rosewood
72|45|3a|Volcanic Brick
72|49|1e|XV-88
72|4a|a1|Studio
72|54|40|Moose Fur
72|56|71|Cembra Blossom
72|5f|69|Moonscape
72|61|38|Morass
72|62|50|Reed Mace Brown
72|62|59|Tea Bag
72|64|49|Covered Wagon
72|66|47|Russian Olive
72|67|47|Back To Basics
72|67|51|Cold Brew Coffee
72|68|54|Treasure Chest
72|69|6f|Lythrum
72|6a|60|Pony Express
72|6d|40|Trough Shell
72|6e|68|Charcoal Light
72|6e|69|Homebush
72|6e|9b|Thirsty Thursday
72|6f|7e|Paisley
72|71|71|Dull
72|76|64|Mouse Tail
72|7a|60|Desert Chaparral
72|7a|7c|Rhinoceros
72|84|78|Calabash Clash
72|86|39|Khaki Green
72|89|7e|Sea Palm
72|8f|02|Canopy
72|8f|66|Villandry
72|90|67|Moss Ring
72|91|83|Hawkesbury
72|91|b4|Allure
72|95|c9|Cool Touch
72|99|88|Silent Sage
72|9c|c2|Blue Promise
72|a0|c1|Air Superiority Blue
72|a3|55|Greengrass
72|a4|9f|Catalina
72|a7|e1|Greek Sea
72|a8|ba|Milky Blue
72|a8|d1|Chronus Blue
72|c8|b8|Shockwave
72|d7|b7|Peppy
73|00|39|Merlot
73|00|61|Liche Purple
73|01|13|Cinnabar
73|33|80|Maximum Purple
73|34|3a|Aged Merlot
73|36|2a|Brandy Brown
73|36|35|Garnet
73|37|2d|Beaten Copper
73|38|3c|Cuba Libre
73|3d|1f|Peruvian Soil
73|48|6b|Old Fashioned Purple
73|4a|12|Hairy Brown
73|4a|33|Taj
73|4a|35|Riding Boots
73|4a|45|Dark Ruby
73|4a|65|Dirty Purple
73|4b|42|Minotaur Red
73|4f|96|Parfait d'Amour
73|50|3b|Old Copper
73|50|54|Plumberry
73|51|53|Sheringa Rose
73|58|48|Heavy Siena
73|5b|3b|Bee Master
73|5b|6a|Arctic Dusk
73|5c|12|Hot Mustard
73|5e|56|Raccoon Tail
73|61|57|Poppy Pods
73|62|4a|Heavy Brown
73|62|53|Shiitake Mushroom
73|62|6f|Purple Kasbah
73|63|30|Himalaya
73|63|3e|Yellow Metal
73|63|54|Kā Fēi Sè Brown
73|66|65|Eagle Eye
73|66|7b|Decadence
73|66|bd|Ultra Violet
73|69|4b|Shady Oak
73|69|67|Warm Haze
73|69|93|Purple Grapes
73|6a|86|Beets
73|70|00|Bronze Yellow
73|70|54|Secret Path
73|70|6f|Brushed Nickel
73|77|6e|Sugar Pine
73|7b|6c|Thyme Green
73|7d|6a|Greenland
73|85|95|New Steel
73|86|78|Xanadu
73|8f|50|Forest Bound
73|8f|5d|Four Leaf Clover
73|90|72|Shale Green
73|95|b8|Bluebird's Belly
73|99|57|Meadow Green
73|9b|d0|Ice Blue
73|a2|63|Bulbasaur
73|a3|d0|Overcast
73|a4|c6|Wandering River
73|a9|c2|Moonstone Blue
73|b7|a5|Turtle Lake
73|c2|fb|Maya Blue
73|c4|d7|Thredbo
73|c9|d9|Betsy
73|fa|79|Flora
73|fc|d6|Spindrift
73|fd|ff|Deep Ice
74|06|00|Chaotic Red
74|28|02|Chestnut
74|33|32|Russet Brown
74|3b|39|Oxford Brick
74|40|42|Tosca
74|42|c8|Purple Rain
74|46|2d|Broomstick
74|50|85|Affair
74|53|42|Rich Mocha
74|54|43|Briar
74|56|3d|Black Jasmine Rice
74|59|37|Shingle Fawn
74|5b|49|Moderne Class
74|5e|6f|Banished Brown
74|60|62|Nasake
74|62|6d|Chimera
74|64|0d|Spicy Mustard
74|65|50|Ancient Earth
74|65|65|Paradise Grape
74|67|6c|Rhapsody Rap
74|6a|51|Hip Waders
74|6a|5e|Granite
74|6c|57|Dusky Green
74|6c|8f|Bureaucracy
74|6c|c0|Toolbox
74|6f|5c|Momentum
74|6f|67|Artillery
74|70|28|Olivetone
74|72|61|Organic
74|77|69|Armored Steel
74|78|80|Grey Cloud
74|7d|5a|Variegated Frond
74|7d|63|Limed Ash
74|7f|89|Bay Wharf
74|80|9a|Stonewash
74|82|8f|Battle Blue
74|85|00|Swamp Green
74|85|7f|Armor
74|86|97|Apollo Bay
74|87|c6|Violets Are Blue
74|89|95|Citadel
74|8b|97|Bluish Grey
74|8c|69|Watercress Spice
74|8d|70|Toad
74|91|8e|Juniper
74|95|51|Drab Green
74|98|bd|Blue Ballad
74|98|bf|Blue Beauty
74|9f|8d|Mizuasagi Green
74|a6|62|Dull Green
74|ac|8d|Melon Green
74|ae|ba|Watson Lake
74|af|54|Fluoro Green
74|b2|a8|Gulf Stream
74|b5|60|Palm Tree
74|b8|de|Tranquil Bay
74|bb|fb|Very Light Azure
74|c3|65|Mantis
74|c6|d3|Salt Lake
75|08|51|Velvet
75|19|73|Darkish Purple
75|21|00|Shaku-Do Copper
75|23|29|Sun Dried Tomato
75|2b|2f|Tamarillo
75|2e|23|Hihada Brown
75|3a|58|Passionate Plum
75|40|6a|Wood Violet
75|44|2b|Bull Shot
75|46|00|Flat Brown
75|47|34|Tortoise Shell
75|48|2f|Cape Palliser
75|49|5e|Bewitching
75|51|39|Toffee
75|54|68|Hothouse Orchid
75|55|3f|Cellar Door
75|58|3d|Moroccan Blunt
75|5d|5b|Dove Feather
75|5f|4a|Woodward Park
75|60|3d|High Chaparral
75|62|44|Olive Wood
75|62|5e|Burnt Grape
75|65|56|European Pine
75|66|3e|Nutria
75|68|58|Ceylonese
75|69|3d|Sphagnum Moss
75|69|47|Old Willow Leaf
75|69|7e|Purple Sage
75|6a|43|Fossilized Leaf
75|6d|44|Trim
75|6e|60|Randall
75|6f|54|Priory
75|6f|6b|Anchovy
75|6f|6d|Newsprint
75|72|61|Salt Island Green
75|72|66|Viking Castle
75|73|74|Bank Vault
75|74|61|Mangrove
75|75|75|Sonic Silver
75|76|79|Astrogranite
75|78|5a|Finch
75|79|4a|Verdant Views
75|7a|4e|Calliste Green
75|7c|ae|Bright Zenith
75|7d|43|Old Four Leaf Clover
75|7d|75|Harbour Rat
75|80|00|Verde Tropa
75|80|67|Beech Fern
75|82|69|Bladed Grass
75|87|6e|Chlorosis
75|8b|a4|Starsilt
75|8d|a3|Blue Grey
75|8f|9a|Sheltered Bay
75|91|80|Rainford
75|94|65|Van Gogh Olives
75|95|ab|American Anthem
75|96|b8|Cotton Cardigan
75|97|8f|Yucca
75|9d|be|Blue Mountain
75|a1|4f|Unakite
75|a7|ad|Water Cooler
75|aa|94|Acapulco
75|b7|90|Water Fern
75|b8|4f|Turtle Green
75|bb|fd|Green Darner Tail
75|bf|0a|Monstera Deliciosa
75|bf|d2|Cologne
75|c7|e0|Hawaiian Breeze
75|db|c1|Star Grass
75|fd|63|Lighter Green
76|35|68|Ayame Iris
76|39|2e|Capsicum Red
76|3b|42|Garnet Evening
76|3c|33|Crown of Thorns
76|3d|35|Ducal
76|3f|3d|Sequoia Redwood
76|40|31|Lava Core
76|42|4e|Brownish Purple
76|44|3e|Rocky Mountain Red
76|46|63|Scintillating Violet
76|4f|82|Meadow Violet
76|52|69|Berry Conserve
76|59|52|Red Wattle Hog
76|5c|52|Picador
76|60|4e|Chocolate Ripple
76|66|4c|Khemri Brown
76|67|9e|Reign Over Me
76|68|59|Curlew
76|69|80|Fujinezumi
76|6a|5f|Cocoa Powder
76|6d|52|Peat
76|6d|7c|Mamba
76|70|81|Ritual
76|71|94|Rhythm
76|72|75|Steel Armor
76|74|5d|Positively Palm
76|76|94|Iris Eyes
76|79|62|Northampton Trees
76|79|9e|Blue Dove
76|7a|49|Tara's Drapes
76|7b|a5|Lavender Violet
76|7c|6b|Wild Pigeon
76|7c|9e|Bossa Nova Blue
76|83|71|Lottery Winnings
76|85|6a|Wreath
76|85|7b|Limerick
76|8a|75|Hedge Green
76|91|64|Old Bamboo
76|93|58|Piquant Green
76|99|58|Dry Moss
76|9d|a6|Cameo Blue
76|a0|af|Bosco Blue
76|a4|a6|Sightful
76|a4|a7|Spartacus
76|a5|5b|Grassy Meadow
76|a9|73|Dusty Green
76|af|b6|Water Glitter
76|b5|83|Absinthe Green
76|c1|e1|Bright Spark
76|c4|d1|Twisted Blue
76|c5|e7|Spritzig
76|c6|d3|Lagoona Teal
76|cd|26|Apple Green
76|d6|ff|Sky
76|fd|a8|Light Bluish Green
76|ff|7a|Goblin Green
76|ff|7b|Light Green
77|00|00|Gochujang Red
77|00|01|Blood
77|00|11|Blood Brother
77|0f|05|Dark Burgundy
77|11|00|Sang de Boeuf
77|11|11|Blood Pact
77|19|08|Dark Fleshtone
77|20|2f|Rhubarb
77|21|2e|Biking Red
77|22|00|Bloodstain
77|22|44|Caviar Couture
77|22|aa|Nebula Fuchsia
77|33|00|Bay Brown
77|33|11|Beer Glazed Bacon
77|33|22|Mocha Glow
77|33|3b|Ruby Wine
77|33|55|Possessed Plum
77|33|76|Sparkling Grape
77|33|99|Skeletor's Cape
77|36|44|Deep Garnet
77|3b|2e|Brass Scorpion
77|3b|38|Belly Fire
77|3c|30|Ebi Brown
77|3c|31|Red Hot Jazz
77|3c|a7|Shiner
77|3f|1a|Walnut
77|40|41|Ripasso
77|42|2c|Copper Canyon
77|42|4e|Berry Bush
77|44|00|Dusky Flesh
77|44|33|Clay Play
77|45|48|Musk Memory
77|4d|8e|Royal Lilac
77|50|20|Trojan Horse Brown
77|51|5a|Stravinsky Pink
77|54|96|Juneberry
77|55|ff|Venetian Nights
77|5d|38|Nut Oil
77|60|22|Brassy Brass
77|60|3f|Brick Brown
77|61|ab|Genestealer Purple
77|62|3a|Twig Basket
77|67|5b|Braid
77|67|5c|Sea Elephant
77|69|59|Congo Capture
77|69|85|Amethyst Gem
77|6a|3c|Racoon Eyes
77|6c|76|Purposeful
77|71|2b|Crete
77|76|48|Gunmetal Green
77|76|61|Gully
77|76|72|Dry Mud
77|77|00|Mongolian Plateau
77|77|77|Steel Wool
77|77|cc|Kickstart Purple
77|77|ee|Hera Blue
77|77|ff|Stargate Shimmer
77|78|72|Coal Miner
77|7c|b0|Ontario Violet
77|7e|65|Expanse
77|80|70|Ellis Mist
77|80|71|Harbour Mist Grey
77|81|20|Pacifika
77|82|4a|Grasshopper
77|82|90|Link
77|88|99|Light Slate Grey
77|8b|a5|Shadow Blue
77|90|80|Cyanara
77|91|3b|Fresh Herb
77|92|6f|Chá Lǜ Green
77|92|af|Wink
77|94|c0|King Neptune
77|95|c1|Denver River
77|97|81|Mid Cypress
77|99|bb|Eiger Nordwand
77|9e|cb|Dark Pastel Blue
77|9f|b9|Blue Nile
77|a1|35|Carol's Purr
77|a1|b5|Grey Blue
77|a2|76|Jadesheen
77|a8|ab|Pompeius Blue
77|aa|ff|Fennel Flower
77|ab|56|Asparagus
77|ab|ab|Solution
77|ac|c7|Air Blue
77|ad|3b|Mamba Green
77|b5|fe|French Sky Blue
77|b7|d0|Blue Chrysocolla
77|b9|db|Pacific Harbour
77|bc|b6|Polished Aqua
77|c3|b4|Pale Jade
77|ca|bd|Hawaiian Vacation
77|cc|00|Delicious Dill
77|dd|77|Pastel Green
77|dd|e7|Turkish Turquoise
77|ff|66|Poisonous Dart
77|ff|77|Astro Arcade Green
78|01|09|Japanese Maple
78|18|4a|Pansy Purple
78|2a|39|Tibetan Red
78|2e|2c|Strong Envy
78|34|2f|Auburn Lights
78|39|37|Spiced Apple
78|3b|38|Red Velvet
78|3b|3c|Marrakesh Red
78|3c|1d|Kara Cha Brown
78|43|84|Nightly Violet
78|44|30|Old Cumin
78|48|48|Cocobolo
78|4d|4c|False Morel
78|51|a9|Royal Lavender
78|57|36|Deep Tan
78|58|7d|Dr Who
78|5e|49|Namakabe Brown
78|61|5c|Raisin in the Sun
78|69|47|Shaded Fern
78|6a|4a|Amazon Green
78|6c|57|Irrigation
78|6c|75|Lavender Elegance
78|6d|5e|Sleeping Giant
78|6d|5f|Wet Sandstone
78|6d|72|Pineal Pink
78|6e|38|Garden Weed
78|6e|4c|Go Ben
78|6e|97|Arabian Silk
78|73|76|Storm Front
78|73|8b|Plum Shade
78|74|89|Flying Carpet
78|77|9b|Benimidori Purple
78|79|76|Legendary Grey
78|7b|54|Bonsai
78|7e|93|Your Shadow
78|85|7a|Cigar Smoke
78|86|6b|Olive Leaf Tea
78|86|aa|Enchanting Sky
78|87|88|Shadow Effect
78|88|78|Bleached Grey
78|88|79|Brassica
78|8f|74|Loden Frost
78|90|ac|Identity
78|94|5a|Vegetarian Veteran
78|95|cc|Pannikin
78|96|ba|Ocean City
78|9b|73|Horenso Green
78|9b|b6|Walden Pond
78|a3|c2|Afloat
78|a4|86|Corporate Green
78|a7|c3|Serene Sea
78|ae|48|Parakeet
78|b1|bf|Glacier
78|bd|d4|Blue Topaz
78|bf|b2|Mintage
78|cf|86|Jube Green
78|d1|b6|Seafoam Blue
78|db|e2|Deep Aquamarine
79|37|21|Bootstrap Leather
79|40|29|Burnished Russet
79|44|31|Medium Tuscan Red
79|44|3b|Bole
79|48|40|Texas Sweet Tea
79|4d|60|Red Endive
79|50|88|Cleopatra's Gown
79|53|65|Passive Royal
79|54|35|Pheasant Brown
79|57|45|Wild Bill Brown
79|5d|34|Breen
79|63|59|Bear Hug
79|66|60|Bold Brandy
79|68|78|Old Lavender
79|6a|4e|Wood Stain Brown
79|6c|70|Realm
79|6e|54|Conservation
79|72|87|Early Dawn
79|74|47|Fern Shade
79|79|79|Steel
79|7b|80|Tarnished Silver
79|7e|65|Pine Garland
79|7e|b5|Astro Zinger
79|7f|63|Koi Pond
79|83|7f|Enchanted Eve
79|83|9b|Tempest
79|84|88|Regent Grey
79|85|3c|Laird
79|88|ab|Ship Cove
79|8e|a4|Faded Denim
79|97|81|Sea Radish
79|9b|96|Avalon
79|a2|bd|Ocean Surf
79|aa|87|Green Globe
79|af|ad|Galaxy Green
79|b0|b6|Buoyancy
79|b4|65|Bud Green
79|b4|c9|Pearl Blue
79|be|58|Green Pear
79|c0|cc|Meltwater
79|c7|53|Green Flash
79|c9|d1|Valonia
79|cc|b3|Puppeteers
79|d0|a7|Crystal Gem
7a|1f|3d|Beet Red
7a|2e|4d|Flirt
7a|41|34|Aged Teak
7a|41|71|Spring Lobster Dye
7a|44|34|Peanut
7a|45|49|Bold Sangria
7a|46|3a|1975 Earth Red
7a|4b|56|Nocturne
7a|54|7f|Crushed Grape
7a|55|46|Roxy Brown
7a|58|c1|Fuchsia Blue
7a|59|01|Blackfire Earth
7a|59|6f|Purple Gumdrop
7a|63|4d|Fig Branches
7a|64|3f|Rawhide Canoe
7a|68|7f|Purplish Grey
7a|6a|4f|Greyish Brown
7a|6a|75|Mystical Trip
7a|6d|44|Crease
7a|6e|70|Imagery
7a|6f|66|Shadow Cliff
7a|70|a8|Purple Mountain Majesty
7a|71|5c|Pablo
7a|72|29|Wood Garlic
7a|73|63|Palm Lane
7a|74|4d|Steel Legion Drab
7a|76|79|Monsoon
7a|77|78|Submarine
7a|7a|60|La Grange
7a|7b|75|Stone Mason
7a|7c|76|Gunsmoke
7a|7e|66|Moss Covered
7a|7f|3f|Thai Basil
7a|80|8d|Blue Mood
7a|81|ff|Orchid
7a|86|87|Rough Ride
7a|88|98|Spartan Blue
7a|89|b8|Wild Blue Yonder
7a|8c|a6|Gladeye
7a|92|91|Castaway Cove
7a|94|2e|Siskin Sprout
7a|94|61|Highland
7a|96|82|Fish Camp Woods
7a|97|03|Mossy Woods
7a|97|3b|Antique Moss
7a|99|9c|Cathedral Glass
7a|99|ad|Post Boy
7a|9c|58|Leek Soup
7a|9d|cb|Della Robbia Blue
7a|a5|c9|Seaborne
7a|aa|e0|Jordy Blue
7a|ab|55|Kiwi
7a|ac|21|Lima Sombrio
7a|ac|80|Summer Garden
7a|c3|4f|Conceptual
7a|c5|b4|Monte Carlo
7a|ca|d0|Aqua Belt
7a|cc|b8|Beveled Glass
7a|f9|ab|Lime Soap
7b|00|2c|Bordeaux
7b|03|23|Wine Red
7b|11|13|UP Maroon
7b|35|39|Red Pear
7b|38|01|Red Beech
7b|3b|3a|Kokiake Brown
7b|3f|00|Hazelnut Chocolate
7b|43|68|Grape Kiss
7b|45|3e|Sweet Spiceberry
7b|58|04|Qahvei Brown
7b|58|47|Burns Cave
7b|59|86|Champion
7b|5f|46|Frontier Shingle
7b|60|65|Pretty Puce
7b|66|23|Brazen Brass
7b|66|60|Deep Taupe
7b|68|ee|Medium Slate Blue
7b|6c|74|Zoom
7b|6c|7c|Goose Bill
7b|6c|8e|Nymph's Delight
7b|6f|60|Village Square
7b|6f|a0|Queen's
7b|73|6b|Deconstruction
7b|73|7b|Chain Mail
7b|78|5a|Kokoda
7b|7c|7d|Namara Grey
7b|7c|94|Waterloo
7b|7d|69|Dried Chive
7b|7f|32|Woodbine
7b|7f|56|Frond
7b|80|8b|Carbon Footprint
7b|82|65|Flax Smoke
7b|83|93|Stowaway
7b|85|88|Garrison Grey
7b|85|c6|Twilight Twinkle
7b|88|67|Swedish Clover
7b|89|76|Spanish Green
7b|8b|5d|Sage Leaves
7b|8c|a8|Evening Hush
7b|8d|42|Komatsuna Green
7b|8e|b0|Ashton Skies
7b|8f|99|Sidewalk Grey
7b|90|93|Weathered Blue
7b|94|59|Peas in a Pod
7b|94|8c|Granny Smith
7b|9a|6d|Money
7b|9a|ad|Bay's Water
7b|9c|b3|Frozen Lake
7b|9f|82|Aquadulce
7b|a0|5b|Frankenstein
7b|a0|c0|Dusk Blue
7b|a5|70|Ready Lawn
7b|b0|ba|Flotation
7b|b1|8d|Mate Tea
7b|b2|74|Faded Green
7b|b3|69|Drying Grass Green
7b|b5|a3|Dusty Jade Green
7b|b5|ae|Melodious
7b|bd|c7|Aqua Vitale
7b|c4|c4|Aqua Sky
7b|c8|b2|Meridian Star
7b|c8|f6|Nirvana Nevermind
7b|d9|ad|Fresco Green
7b|f2|da|Tiffany Blue
7b|fd|c7|Light Aquamarine
7c|00|87|Aunt Violet
7c|0a|02|Demonic Presence
7c|1c|05|New Kenyan Copper
7c|1e|08|Doombull Brown
7c|24|39|Rumba Red
7c|29|46|Red Plum
7c|2d|37|Paprika
7c|36|51|Rich Red Violet
7c|38|3e|Rose Pink Villa
7c|38|3f|Carmen
7c|42|3c|Henna
7c|48|48|Tuscan Red
7c|4a|33|Witch Wood
7c|4c|53|Wild Ginger
7c|4f|3a|Leather Satchel
7c|50|3f|Nougat Brown
7c|53|79|Concord Grape
7c|64|4a|Bonnie's Bench
7c|64|4b|Old Boot
7c|68|41|Mud Bath
7c|69|42|Middle Ditch
7c|6b|6f|Gothic Spire
7c|6b|76|Purple Dusk
7c|6d|61|Namibia
7c|6e|4f|Gothic Olive
7c|6e|6d|Hickory Cliff
7c|71|73|Empress
7c|72|5f|Backcountry
7c|72|6c|Moroccan Brown
7c|74|69|Aumbry
7c|7a|3a|Evening Green
7c|7b|6a|Mount Tam
7c|7c|65|Tangle
7c|7c|72|Tapa
7c|7d|57|Tambo Tank
7c|7e|6a|Rolling Hills
7c|81|7c|Boulder
7c|82|86|Adeptus Battlegrey
7c|83|bc|Deep Periwinkle
7c|84|47|Fresh Artichoke
7c|87|83|Thunderbolt
7c|8c|87|Chinois Green
7c|8e|a6|Cabaret Charm
7c|91|6e|New Life
7c|94|b2|Accolade
7c|97|93|Green Granite
7c|98|ab|Weldon Blue
7c|9f|2f|Sushi
7c|a1|4e|Tree Frog Green
7c|a7|cb|Madam Butterfly
7c|aa|cf|Calm Day
7c|af|e1|Lucea
7c|b0|83|Zephyr Green
7c|b2|6e|Stalk
7c|b3|86|Irish Hedge
7c|b6|8e|Light Grass Green
7c|b7|7b|Color Me Green
7c|b9|e8|Aero
7c|bc|6c|Primo
7c|bd|85|Flashman
7c|ca|6b|Energise
7c|d8|d6|Aqua Zing
7c|fc|00|Nuclear Waste
7d|00|61|Xereus Purple
7d|20|27|Red Dahlia
7d|21|2a|Seattle Red
7d|41|38|Red Robin
7d|46|38|Armadillo Egg
7d|49|61|Princely
7d|4e|2d|Kinsusutake Brown
7d|4e|38|Cigar
7d|5d|99|Chive Blossom
7d|5f|53|Choco Loco
7d|60|44|Coconut Husk
7d|65|5c|Betalain Red
7d|66|5f|Plumburn
7d|67|57|Roman Coffee
7d|67|5d|Cocoa Milk
7d|68|48|Essential Brown
7d|68|5b|Warrior
7d|6a|58|Downtown Benny Brown
7d|6d|39|Musket
7d|6d|70|Dusky Cyclamen
7d|71|03|Sunlit Kelp Green
7d|71|6e|Mauve Mole
7d|71|70|Sophomore
7d|74|a8|Aster Purple
7d|75|6d|Bearsuit
7d|77|5d|Denali Green
7d|77|71|Tadpole
7d|7f|7c|Medium Grey
7d|80|6e|Kakadu Trail
7d|85|74|Wolfram
7d|86|7c|Stone Craft
7d|86|97|Salon Bleu
7d|87|74|Dollar
7d|93|a2|Clouded Sky
7d|94|c6|Steel Blue Eyes
7d|95|6d|Green Eyes
7d|9c|9d|Salt Blue
7d|9d|72|Amulet
7d|9e|a2|Gould Blue
7d|a2|70|Frog Hollow
7d|ae|e1|Pool Floor
7d|c4|cd|Wavelet
7d|c7|34|Niblet Green
7d|ed|17|Slimy Green
7d|f9|ff|Electric Blue
7e|1e|9c|Noble Cause Purple
7e|25|30|Scarlet Shade
7e|25|53|Pico Eggplant
7e|26|39|Suō
7e|37|4c|Velvet Rose
7e|39|2f|Burnt Henna
7e|39|40|Burnt Russet
7e|39|47|Ripe Rhubarb
7e|3a|3c|Wild Berry
7e|40|71|Bruise
7e|43|37|Country Sleigh
7e|4a|3b|Nutmeg
7e|51|46|Red Rooster
7e|5b|58|Musk Deer
7e|5c|52|Wild West
7e|5e|52|Acorn
7e|5e|8d|Plum Power
7e|60|72|Chicha Morada
7e|60|99|Jubilee
7e|61|3f|Berkeley Hills
7e|63|3f|Trinket Box
7e|66|7f|Grape Jelly
7e|68|84|Matriarch
7e|6b|43|Cork Bark
7e|6c|44|Mossy Shade
7e|6e|ac|Dahlia Purple
7e|6f|4f|Muskrat
7e|70|5e|River Bank
7e|71|50|Burgundy Snail
7e|72|6d|Kombu
7e|73|6d|Dark Sting
7e|74|66|Bat Wing
7e|74|68|Jasmine Hollow
7e|75|67|Hammered Pewter
7e|75|74|Soft Fur
7e|76|68|Smoky Topaz
7e|7a|75|Caps
7e|7d|78|Not My Fault
7e|7d|88|Silver Surfer
7e|82|70|Battle Dress
7e|84|24|Trendy Green
7e|8d|60|Moss Point Green
7e|8d|9f|Lucid Blue
7e|8e|90|Harrow's Gate
7e|8f|69|Saladin
7e|92|85|Green Bay
7e|97|6d|Apple Day
7e|98|9d|Soul Quenching
7e|9b|76|Aspen Green
7e|9c|6f|Wild Thyme
7e|9e|c2|Alaskan Ice
7e|a0|7a|Green Grey
7e|a3|d2|Boudoir Blue
7e|b2|c5|Heavenly
7e|b3|94|Padua
7e|b4|d1|Blue Cuddle
7e|b6|d0|Harbour Sky
7e|b6|ff|Parakeet Blue
7e|b7|bf|Waterway
7e|bb|c2|Warm Waters
7e|bd|01|Dark Lime Green
7e|be|a5|Celadon Porcelain
7e|c8|45|Jasmine Green
7e|cd|dd|Spray
7e|d4|e6|Middle Blue
7e|f4|cc|Light Turquoise
7e|fb|b3|Light Blue Green
7f|00|ff|Violent Violet
7f|01|fe|Poison Purple
7f|2b|0a|Reddish Brown
7f|3e|98|Cadmium Violet
7f|43|30|Coppery Orange
7f|47|74|Magic Magenta
7f|4e|1e|Milk Chocolate
7f|4e|47|Revival Red
7f|51|12|Medium Brown
7f|51|53|Deep Rhubarb
7f|54|00|Intense Brown
7f|55|6f|Magnificence
7f|5d|3b|Japanese Iris
7f|5e|00|Hè Sè Brown
7f|5e|46|Rodeo
7f|5f|00|Gédéon Brown
7f|64|73|Cabal
7f|66|40|Seasoned Acorn
7f|67|4f|Otter
7f|68|4e|Anthill
7f|69|44|Lizard Legs
7f|69|68|Deep Serenity
7f|6b|5d|Lye Tinted
7f|6c|24|Tarnished Brass
7f|6c|6e|Twisted Time
7f|70|53|Grey Brown
7f|72|5c|Colusa Wetlands
7f|72|6b|Flipper
7f|74|52|Olive Sapling
7f|75|5f|Swamp
7f|76|67|Rattlesnake
7f|77|93|Kinlock
7f|77|9a|Grape Jam
7f|78|60|String Deep
7f|79|5f|Rainforest Zipline
7f|7b|60|Thurman
7f|7b|73|Bushland Grey
7f|7c|81|Silver Filigree
7f|80|9c|Blue Intrigue
7f|81|62|Spores
7f|81|81|Mt. Rushmore
7f|82|85|Pebble Beach
7f|83|53|Oregano
7f|84|88|Great Coat Grey
7f|85|96|Stand Out
7f|86|88|Distant Thunder
7f|87|93|Sea Lion
7f|88|66|Green Bush
7f|8f|4e|Camo
7f|90|9d|London Square
7f|95|a5|Storm Petrel
7f|97|b5|Denim Tradition
7f|99|7d|Dinosaur
7f|9d|af|Quilotoa Blue
7f|a7|71|Garden of Eden
7f|aa|4b|Tree Palm
7f|ab|60|Jealousy
7f|b3|77|Joshua Tree
7f|b3|83|Verde
7f|b6|a4|Key Largo
7f|bb|9e|Neptune Green
7f|bb|c2|Cuttlefish
7f|c1|5c|Fierce Mantis
7f|c6|cc|Pearl Bay
7f|cc|e2|Blue Limewash
7f|f2|17|Fresh Granny Smith
7f|f2|3e|Lush Greenery
7f|ff|00|Radium
7f|ff|d4|Hiroshima Aquamarine
80|00|00|Maroon
80|00|08|Laura Potato
80|00|20|Oxblood
80|00|70|Patriarch
80|00|80|Purple
80|01|3f|Wine
80|18|18|Falu Red
80|20|ff|Szöllősi Grape
80|2a|50|Raspberry Radiance
80|2c|3a|Bicyclette
80|30|4c|Beaujolais
80|37|90|Dull Violet
80|38|5c|Pleasure
80|3a|4b|Camelot
80|40|40|American Brown
80|44|4c|Dark Strawberry
80|46|1b|Russet
80|46|65|Vivacious Violet
80|48|39|Sequoia
80|4a|00|Dark Bronze
80|4b|81|Vibrant Orchid
80|4e|2c|Korma
80|4f|5a|Crushed Berry
80|54|66|Tulipwood
80|55|57|Lampoon
80|56|5b|Rose Branch
80|5b|48|Spiced Cinnamon
80|5b|87|Muted Purple
80|5d|24|Tapenade
80|5d|80|Trendy Pink
80|65|68|Amazing Amethyst
80|68|43|Birchy Woods
80|68|52|Stock Horse
80|6b|5d|Bannister Brown
80|6d|95|Ornate
80|6e|7c|Splendiferous
80|6f|63|Fossil
80|70|70|Noble Robe
80|73|6a|Tattletail
80|73|88|Hyacinth Dream
80|73|96|Purple Haze
80|75|32|Spanish Bistre
80|75|48|Peppered Moss
80|76|5f|Covert Green
80|76|61|Stonewall
80|76|69|Fallen Rock
80|76|97|Grape Harvest
80|79|43|Tribal
80|79|6e|Cathedral Stone
80|7a|6c|Rogue
80|7b|76|Cool Charcoal
80|7d|6f|Vetiver
80|7d|7f|Titanium
80|7e|79|Friar Grey
80|7f|7e|Platinum Granite
80|80|00|Heart Gold
80|80|10|Olive
80|80|5d|Wild Ginseng
80|80|80|Grey
80|80|ff|Zürich Blue
80|82|83|Storm Cloud
80|85|6d|Oil Green
80|88|4e|Field Maple
80|8c|8c|Dark Compass Ghost Grey
80|92|bc|Soothsayer
80|93|91|Scarborough
80|98|7a|Eat Your Peas
80|a1|b0|Lake Winnipeg
80|a4|b1|Lagoon Blue
80|a7|c1|Stormfang
80|aa|95|Catnip
80|ae|a4|Green Room
80|b9|c0|Coastal Fringe
80|c1|e2|Horizon Haze
80|c4|a9|Green Balloon
80|d4|d0|Water Wonder
80|d7|cf|Isle Royale
80|d9|cc|Mintos
80|da|eb|Medium Sky Blue
80|db|eb|Faded Poster
80|f9|ad|Esper's Fungus Green
81|00|7f|Philippine Violet
81|14|53|French Plum
81|23|08|Mahogany Brown
81|3e|45|Ruby Lips
81|4d|50|Tibetan Temple
81|59|89|Purple Mystery
81|5b|28|Hot Curry
81|5b|37|Rubber
81|60|45|Man Cave
81|61|3c|Coyote Brown
81|65|75|Opera
81|6a|38|By Gum
81|6b|56|Salted Pretzel
81|6c|5b|Nut Cracker
81|6d|5e|Caribou
81|6e|54|Bancroft Village
81|6e|5c|Donkey Brown
81|6f|6b|Granite Boulder
81|6f|7a|Lively Lavender
81|76|65|Dry Dock
81|77|7f|Chainmail
81|7a|60|Aloe
81|7a|65|Mermaid
81|7a|69|Center Ridge
81|7b|69|Willow Grey
81|7c|74|Ricochet
81|7c|85|Magic Dust
81|7c|87|Dark Topaz
81|7d|68|Smoky Forest
81|7e|6d|Bare
81|7f|6d|Serpent
81|7f|6e|Bridge Troll Grey
81|80|68|Ivy Garden
81|80|81|Pound Sterling
81|81|81|Trolley Grey
81|84|55|Iguana
81|87|6f|Shebang
81|89|88|Pirate Silver
81|8a|40|Sea Turtle
81|8b|9c|Prophetic Sea
81|8c|72|Canaletto
81|8d|b3|Skysail Blue
81|8e|b1|Luxury
81|8f|84|Lily Pad
81|9a|aa|Beach Umbrella
81|9a|b1|Polished Metal
81|9a|c1|Bel Air Blue
81|9c|8b|Seiji Green
81|9d|aa|Serene Stream
81|9e|84|Vineyard
81|a1|9b|Gnome
81|a6|aa|Ziggurat
81|a7|9e|Scenario
81|b3|9c|Mid-century Gem
81|b6|bc|Lifeboat Blue
81|bc|a8|Peppermint Bar
81|c3|b4|Holiday
81|d7|d0|Island Sea
81|d7|d3|Aruba Blue
82|00|00|Deep Maroon
82|07|47|Renanthera Orchid
82|32|70|Hollyhock
82|3c|3d|Zangief's Chest
82|49|5a|Mahogany Cherry
82|4b|2e|Pookie Bear
82|4b|35|Sencha Brown
82|4e|4a|Cherokee Red
82|57|36|Football
82|5c|43|Coffee Bar
82|5e|2f|Bronze Brown
82|5e|61|Tarsier
82|5f|87|Dusty Purple
82|61|67|Celine
82|66|44|Bright Umber
82|66|63|Pharlap
82|6a|21|Yukon Gold
82|6a|6c|Speakeasy
82|6b|58|Rikyū Brown
82|6c|68|African Mud
82|6d|8c|Grey Purple
82|6f|7a|Mysteria
82|70|58|Jarrah
82|70|64|Pine Bark
82|71|4d|Outrigger
82|72|a4|Deluge
82|73|fd|Bainganī
82|75|63|Dinosaur Bone
82|75|66|Cool Camo
82|77|6b|Brindle
82|78|ad|Purple Rhapsody
82|7a|67|Arrowtown
82|7a|6d|Paw Print
82|7b|77|Mule
82|7e|7c|Steeple Grey
82|7f|79|Concord
82|83|44|Drab
82|83|88|Victorian Pewter
82|85|6d|Simpson Surprise
82|85|96|Blue Jasmine
82|86|8a|Heavy Grey
82|88|9c|Top Shelf
82|8b|8e|Necron Compound
82|8e|74|Dolphin Grey
82|8e|84|Mummy's Tomb
82|8f|72|Battleship Green
82|90|a6|Blueberry Soda
82|9b|a0|Miles
82|9c|a5|Stone Blue
82|9f|96|Japanese Bonsai
82|a2|be|Old Faithful
82|a6|7d|Greyish Green
82|aa|dc|Swift
82|ac|c4|Arabella
82|b1|85|Peapod
82|c2|c7|Tibetan Stone
82|c2|db|Blue Charm
82|ca|fc|Chromis Damsel Blue
82|cb|b2|Pale Teal
82|cd|e5|Sky of Ocean
82|db|cc|Candy Green
83|36|33|Heirloom Tomato
83|3d|3e|Kopi Luwak
83|45|5d|Wild Plum
83|48|31|Hammered Copper
83|4c|4b|Red Maple Leaf
83|4f|3d|Brown Patina
83|4f|44|Beauty Patch
83|59|95|Purple Tanzanite
83|5e|81|Chinese Violet
83|62|68|Blueberry Blush
83|65|39|Dirt Brown
83|69|53|Pastel Brown
83|69|6e|Deep Hydrangea
83|6b|4f|Ermine
83|6e|59|Deep Bamboo
83|70|50|Shadow
83|75|6c|Clayton
83|76|9c|Voxatron Purple
83|77|52|Olive Ochre
83|78|71|Palomino Pony
83|78|c7|Moody Blue
83|7a|64|Mendocino Hills
83|7e|74|Metal Fringe
83|7e|87|Soft Savvy
83|7f|7f|Cloudburst
83|82|54|Dark Cavern
83|82|6d|Olive Paste
83|82|98|Soft Charcoal
83|84|87|Sharkskin
83|84|92|Modest Mauve
83|84|93|Clairvoyance
83|87|82|Metal Flake
83|89|96|Roman Silver
83|8b|a4|Violet Aura
83|94|c5|Blue Hyacinth
83|98|8c|Paradise Found
83|98|ca|Grapemist
83|9b|5c|Pine Leaves
83|a9|b3|Equanimity
83|ab|d2|Cotton Wool Blue
83|ac|d3|Skydiver
83|c2|cd|Antiqua Sand
83|c5|cd|Angel Blue
83|c7|df|Winter Chime
83|cc|d2|White Ultramarine
83|d1|a9|Pharaoh's Jade
84|00|00|Dark Red
84|08|04|Proton Red
84|1b|2d|Antique Ruby
84|28|33|Shiraz
84|29|94|Druchii Violet
84|2c|48|Anemone
84|3d|38|Kilauea Lava
84|3e|83|Dahlia
84|3f|5b|Deep Ruby
84|4b|4d|Apple Butter
84|4c|44|Partridge
84|54|69|Private Tone
84|55|44|Red Hook
84|56|3c|Chocolate Stain
84|59|7e|Dull Purple
84|59|98|Purple Squid
84|5c|00|Soil Of Avagddu
84|5c|40|Potters Pot
84|5e|40|Artisan Tile
84|61|3d|Loose Leather
84|62|3e|Barricade
84|6c|76|Velvet Slipper
84|70|ff|Light Slate Blue
84|71|46|Mud House
84|74|51|Woodbridge
84|75|67|Wicker Basket
84|75|92|Vintage
84|79|86|Grey Ridge
84|7a|59|Dried Herb
84|7e|54|Xena
84|7e|b1|Murex
84|81|6f|Tortuga
84|81|82|Chert
84|82|83|Frost Grey
84|84|6f|Mudstone
84|84|72|Hanover Pewter
84|84|81|Tank Grey
84|84|82|Old Silver
84|85|85|Dover Grey
84|87|89|Aluminium
84|89|7f|Turtle Bay
84|89|8c|Monument
84|89|99|Yin Hūi Silver
84|8b|71|Aloe Vera Tea
84|8b|80|Appalachian Forest
84|91|37|Wasabi Nuts
84|91|61|Epsom
84|91|c3|Safflowerish Sky
84|94|57|Pretty Maiden
84|9b|63|Dead Flesh
84|9b|cc|Hydrangea
84|9c|8d|Mother Earth
84|9c|a9|Bali Hai
84|a2|7b|Rivergrass
84|a2|d4|Wisteria Blue
84|a5|dc|Blue Cue
84|a7|ce|Windfall
84|ad|db|Buoyant Blue
84|b7|01|Dark Lime
84|c3|aa|Gauss Blaster Green
84|c9|e1|Budgie Blue
84|de|02|Alien Armpit
85|01|01|Sacrifice Altar
85|0e|04|Indian Red
85|2e|19|Chestnut Plum
85|35|34|Tall Poppy
85|44|3f|Spiced Berry
85|4c|65|Damson
85|51|41|Rustic Brown
85|56|9c|Highlighter Lavender
85|5c|4c|Carob Brown
85|5e|42|Dark Wood
85|5f|43|Vaquero Boots
85|63|63|Light Wood
85|67|7b|Port Wine Stain
85|67|98|Dark Lavender
85|6b|71|Punctuate
85|6d|4d|French Bistre
85|6d|70|Emotive Ring
85|71|39|Mustard Magic
85|71|58|Tantanmen Brown
85|71|65|Pipe
85|73|49|Mossy
85|77|67|Grange Hall
85|79|46|Green Moss
85|79|47|Swamp Mud
85|7a|64|Mission Trail
85|7e|86|Lavender Mosaic
85|83|65|Green Scene
85|88|85|Stack
85|89|61|Mosstone
85|8f|94|Common Feldspar
85|8f|b1|Purple Impression
85|94|75|Catalina Green
85|96|d2|Mystic Iris
85|99|a8|Silver Storm
85|9c|9b|Shaded Hammock
85|9d|66|Green Sky
85|9d|95|Sutherland
85|9e|94|Padded Leaf
85|a3|b2|Grauzone
85|a6|99|Beckett
85|ac|9d|Corsican
85|b2|a1|Le Max
85|bb|65|Dollar Bill
85|c0|cd|Aftercare
85|c1|c4|Celestine
85|c7|a1|Foul Green
85|c7|a6|Aqua Eden
85|ca|87|De York
85|ce|d1|Aqua Splash
86|01|11|Red Devil
86|01|af|Shade of Violet
86|01|bf|Violet Poison
86|28|08|Red Shade Wash
86|28|2e|Flame Red
86|3b|2c|Grill Master
86|42|3e|Strawberry Jam
86|47|64|Grand Poobah
86|49|3f|Spice of Life
86|4a|36|Brickhouse
86|4b|36|Paarl
86|4c|24|Caramel Cafe
86|4f|3e|Antler Moth
86|50|40|Ironstone
86|55|60|Renaissance Rose
86|5e|49|Rawhide
86|60|8e|Swiss Lilac
86|61|80|Pink-N-Purple
86|69|5e|Nut Brown
86|6b|8d|Beauty
86|6c|5e|Ruskie
86|6d|4c|Wine Cork
86|6f|5a|Baton
86|6f|85|Purple Grey
86|73|54|Leather Loafers
86|73|6e|Cave of the Winds
86|75|78|Choo Choo
86|76|65|Dune Shadow
86|77|5f|Brownish Grey
86|79|3d|Bay Leaf
86|7b|a9|Aster
86|7c|83|Honed Steel
86|7e|36|Old Moss Green
86|7e|85|Trumpet
86|83|7a|Grey Porcelain
86|8b|53|Special Ops
86|8e|65|Green Coconut
86|94|9f|Supreme Grey
86|99|ab|Ashley Blue
86|9b|af|Tsunami
86|9f|49|Nasturtium Shoot
86|9f|69|Jack Bone
86|9f|98|Meek Moss Green
86|a1|7d|Grey Green
86|a1|a9|Tourmaline
86|a9|6f|Wyvern Green
86|ab|a5|Lake Water
86|af|38|Young Bud
86|ba|4a|Spring Sprout
86|bb|9d|Grand Gusto
86|c4|da|Dolphin
86|c8|ed|Fish Pond
86|cd|ab|Marooned
86|d2|c1|Blue Frosting
87|16|46|Akuma's Fury
87|1f|78|Noble Plum
87|26|57|Dark Raspberry
87|32|60|Boysenberry
87|38|2f|Crabapple
87|3d|30|Boxcar
87|41|3f|Aged Brandy
87|4c|62|Dark Mauve
87|4e|3c|Wiener Dog
87|56|e4|Gloomy Purple
87|59|42|Hope Chest
87|5f|42|Cocoa
87|5f|9a|Wisteria Purple
87|60|8e|Pomp and Power
87|61|55|Clove
87|65|7e|Blackberry Jam
87|6a|68|Ferra
87|6b|4b|Chester Brown
87|6d|5e|Wandering Road
87|6e|4b|Dull Brown
87|6e|52|Appaloosa Spots
87|6e|59|Mill Creek
87|6f|a3|Babiana
87|71|5f|Dark Mink
87|72|52|Favorite Fudge
87|75|a1|Smashed Grape
87|79|66|Flood Mud
87|7a|64|Pie Safe
87|7d|83|Shadow Dance
87|7f|95|Dusky Grape
87|84|66|Bandicoot
87|85|73|Medieval Cobblestone
87|85|7c|Subway
87|87|6f|Schist
87|87|85|Jumbo
87|87|87|Mithril
87|8d|91|Oslo Grey
87|94|73|Royal Oakleaf
87|98|77|Backyard
87|9b|a3|Arona
87|9f|6c|Purslane
87|9f|84|Basil
87|a1|b1|Silver Skate
87|a9|22|Avocado Green
87|a9|6b|Peeled Asparagus
87|ae|73|Sage
87|b2|c9|Batch Blue
87|b3|69|Nasturtium Leaf
87|b5|50|Savoy
87|bd|e3|Blue Eyed Boy
87|be|a3|Baby Cake
87|c2|d4|Petit Four
87|c5|ae|Hellion Green
87|cd|ed|Below Zero
87|ce|ca|Surf Wash
87|ce|eb|Afternoon Sky
87|ce|fa|Light Sky Blue
87|d3|f8|Pale Cyan
87|d6|dd|VIC 20 Sky
87|d7|be|Cabbage
87|d8|c3|Ice Green
87|e0|cf|Sea Foam
87|fd|05|Bright Lime
87|ff|2a|Spring Frost
88|00|00|Glass Bull
88|00|11|Bloodthirsty
88|00|44|Midnight Merlot
88|00|85|Mardi Gras
88|06|ce|French Violet
88|11|00|Sangoire Red
88|11|88|Violaceous Greti
88|11|ff|Punk Rock Pink
88|14|00|Red Leever
88|22|00|Bloodline
88|2c|17|Dark Cow
88|2d|17|Kobe
88|33|00|Coffee Addiction
88|33|77|Violet Vixen
88|36|36|Tuskgor Fur
88|3c|32|Prairie Sand
88|3f|11|Gryphonne Sepia Wash
88|43|32|Arabian Spice
88|43|44|Cowhide
88|44|00|Chocolate Pancakes
88|44|44|Fired Clay
88|47|36|Burning Brier
88|48|98|Murasaki Purple
88|49|67|Noble Tone
88|4c|5e|Hawthorn Rose
88|4f|40|Mule Fawn
88|51|32|Charred Clay
88|51|57|Roan Rouge
88|55|00|Spear Shaft
88|58|18|Grizzly
88|5d|62|Rabbit Paws
88|5f|01|Rat Brown
88|60|37|Quiver
88|61|50|How Now
88|62|21|Kumera
88|65|4e|Dark Brown Tangelo
88|66|ff|Purple Anemone
88|67|93|Mirabella
88|68|06|Muddy Brown
88|69|71|Grape Shake
88|6a|3f|Shaker Peg
88|6e|54|Big Stone Beach
88|71|91|Greyish Purple
88|72|4d|Paddle Wheel
88|76|47|Pickled Okra
88|78|9b|Relic
88|78|c3|Ube
88|79|38|Baikō Brown
88|79|6d|Mocha Magic
88|7b|6e|Ghost Ship
88|7c|ab|Parmentier
88|7d|79|Eastlake Lavender
88|7f|7a|Susu Green
88|7f|85|Ironbreaker
88|80|64|Olive Haze
88|83|87|Suva Grey
88|87|86|Looking Glass
88|88|66|Green Savage
88|88|73|Paris Creek
88|88|88|Argent
88|89|6c|Bitter
88|89|a0|Mandrake
88|8a|8e|Russian Unif.
88|8d|8f|Leadbelcher Metal
88|8e|7e|Tea Leaf Mouse
88|8f|4f|Vintage Vibe
88|92|bf|PHP Purple
88|92|c1|Sweet William
88|95|c5|Pale Iris
88|97|17|Snakes in the Grass
88|99|44|Café de Paris
88|99|99|Aged Pewter
88|a3|c2|Windy City
88|a4|96|Poppy Leaf
88|a9|5b|Chelsea Cucumber
88|aa|aa|Harbor Mist
88|ac|e0|Light Cobalt Blue
88|b0|4b|Greenery
88|b3|78|Hakusai Green
88|b5|c4|Crystal Lake
88|b6|9f|Grey Aqua
88|bb|95|Forest Frolic
88|be|69|Lima Bean Green
88|c1|d8|Sky Babe
88|c7|e9|Shimmer
88|c9|a6|Park Green Flat
88|cc|ff|Platonic Blue
88|d8|c0|Pearl Aqua
88|d9|d8|Island Oasis
88|dd|bb|Āsmānī Sky
88|ff|cc|A State of Mint
88|ff|dd|Tibetan Plateau
88|ff|ff|Glitter Shower
89|2d|4f|Disco
89|3f|45|Cordovan
89|45|85|Light Eggplant
89|4c|3b|Cherry Cola
89|4e|45|Rudraksha Beads
89|53|60|Berry Smoothie
89|55|6e|Merlin's Cloak
89|5b|7b|Dusky Purple
89|5b|8a|Ancient Murasaki Purple
89|5c|79|Argyle Purple
89|62|6d|Glazed Ringlet
89|67|57|Suede Leather
89|68|7d|Imaginary Mauve
89|69|56|Art and Craft
89|6c|39|Kimirucha Brown
89|70|58|Braun
89|72|9e|Fuji Purple
89|73|4b|Desert Willow
89|75|60|Sepia Tint
89|75|65|Towering Cliffs
89|76|70|Soft Bark
89|77|6e|Deep Clay
89|78|70|Wet River Rock
89|7a|68|Guy
89|7a|69|Mudskipper
89|7b|66|Home Brew
89|7e|59|Clay Creek
89|7f|79|Vulcan Mud
89|7f|98|Grey Dusk
89|80|76|Crust
89|80|78|Purri Sticks
89|80|c1|Faraway Sky
89|81|a0|Daybreak
89|82|53|Aged Eucalyptus
89|86|96|Miracle
89|8a|74|Sabiseiji Grey
89|8a|86|Downpour
89|8c|4a|Enough Is Enough
89|8c|a3|Violet Verbena
89|8e|58|Crocodile Smile
89|92|8a|Grey Heron
89|93|c3|Corfu Sky
89|97|8e|Deco Grey
89|98|88|Manifest
89|9a|8b|Birch Forest
89|9b|b8|Forever Blue
89|9f|b9|Astro Bound
89|a0|6b|Tendril
89|a0|a6|Symphony of Blue
89|a0|b0|Qiān Hūi Grey
89|a2|03|Vomit Green
89|a3|ae|Blue Alps
89|a4|cd|Anode
89|a5|72|Putrid Green
89|ab|98|Pale Willow
89|ac|27|German Hop
89|ac|ac|Aquifer
89|ac|da|Birdie Num Num
89|b3|86|Chatty Cricket
89|ba|b2|Morning Green
89|c3|eb|Wasurenagusa Blue
89|c8|c3|Mercury Mist
89|ce|e0|Bayshore
89|cf|db|Bluish Water
89|cf|f0|Pool Tiles
89|d1|78|Fluorescence
89|d9|c8|Riptide
89|fe|05|Radioactive
8a|03|03|Blood Omen
8a|22|32|Rio Red
8a|2b|e2|Bright Blue Violet
8a|2d|52|Rosebud Cherry
8a|33|19|Red Rust
8a|33|24|Burnt Umber
8a|33|35|Old Brick
8a|3a|3c|Bacchanalia Red
8a|3c|38|Red Blooded
8a|3e|34|Strong Strawberry
8a|49|6b|Twilight Lavender
8a|53|4e|Saddlebag
8a|57|73|Indian Silk
8a|5d|55|Raspberry Truffle
8a|69|3f|Eagles Nest
8a|6c|42|Ground Cumin
8a|6e|45|Tiki Hut
8a|6f|45|Wild Seaweed
8a|6f|48|Dull Gold
8a|72|65|Derby Brown
8a|75|61|Mink
8a|77|9a|Pale Eggplant
8a|79|5d|Shadow Woods
8a|79|63|Lead Grey
8a|7d|69|Clay Bath
8a|7d|6b|Patches
8a|7d|72|Silt
8a|7e|5c|Canyon Verde
8a|7e|61|Fingerpaint
8a|7f|80|Rocket Metallic
8a|80|6b|Army Issue
8a|82|87|Natural Steel
8a|84|3b|Apeland
8a|8d|aa|Non Skid Grey
8a|96|6a|Bullfrog
8a|99|92|Green Milieu
8a|99|a3|Thundercat
8a|99|a4|Hamilton Blue
8a|9a|9a|Silver Blue
8a|9b|76|Sweet Florence
8a|a2|77|Antilles Garden
8a|a2|82|Mistletoe
8a|a5|6e|Virtual Forest
8a|a7|75|Rotting Flesh
8a|a7|86|Mermaid's Cove
8a|a7|cc|Polo Blue
8a|aa|d6|Reform
8a|ad|cf|Mini Bay
8a|ae|7c|Cressida
8a|ae|a4|Sea Nymph
8a|b8|fe|Carolina Blue
8a|bd|7b|Baby Grass
8a|c4|79|Applegate
8a|c7|bb|Tranquil Teal
8a|d3|70|Green Lacewing
8a|f1|fe|Robin Egg Blue
8b|00|00|Scab Red
8b|00|8b|Dark Magenta
8b|2a|98|Leviathan Purple Wash
8b|2e|08|Red Tone Ink
8b|2e|16|Sugar-Candied Peanuts
8b|31|03|Rust Brown
8b|34|39|Bindi Dot
8b|35|2d|Kiriume Red
8b|40|44|Barn Red
8b|45|13|Saddle Brown
8b|49|63|Violet Quartz
8b|50|4b|Lotus
8b|51|31|Oriental Spice
8b|57|76|Queen's Honour
8b|59|3e|Argan Oil
8b|59|87|Dewberry
8b|5f|4d|Spicy Mix
8b|69|47|Texas Boots
8b|69|4d|Neutral Valley
8b|69|62|Creamed Muscat
8b|6a|4f|Centaur Brown
8b|6b|47|Castle Moat
8b|6f|70|Twilight Mauve
8b|71|4b|Molasses Cookie
8b|71|4c|Schindler Brown
8b|71|80|Wiped Out
8b|71|81|Who-Dun-It
8b|72|be|Middle Blue Purple
8b|75|74|Plum Haze
8b|77|53|Burlap
8b|78|5c|Rock'n Oak
8b|79|5f|Rain Barrel
8b|79|b1|Paisley Purple
8b|7d|3a|Koke Moss
8b|7d|82|Ganymede
8b|7e|77|Hurricane
8b|7f|78|Bleached Bark
8b|7f|7a|Pre-Raphaelite
8b|7f|7b|Tsar
8b|81|74|Nile Clay
8b|81|8c|Asian Violet
8b|82|65|Granite Green
8b|82|74|Bogart
8b|82|83|Pewter Mug
8b|84|6d|Antique
8b|84|7c|So Sublime
8b|85|89|Taupe Grey
8b|86|6b|Tidal Thicket
8b|86|80|Natural Grey
8b|86|85|Detective Coat
8b|88|f8|Lavender Blue Shadow
8b|8c|40|Vegetable Garden
8b|8c|6b|Playing Hooky
8b|8c|89|Wild Dove
8b|8d|63|Woodland Walk
8b|8d|98|Flannel Pajamas
8b|94|c7|Fast Velvet
8b|95|a2|Ozone
8b|97|4e|Apple Jack
8b|98|d8|Portage
8b|9c|ac|Settler
8b|a4|94|Wintessa
8b|a5|8f|Envy
8b|a6|73|Salad
8b|a8|ae|Stone Silver
8b|a8|b7|Pewter Blue
8b|ab|68|Celuce
8b|ac|0f|Gameboy Screen
8b|b6|b8|Summit
8b|b6|c6|Pond Blue
8b|b9|dd|Goluboy Blue
8b|ba|94|Meadow
8b|be|1b|Dark Lemon Lime
8b|c2|8c|Greengage
8b|c3|e1|Club Cruise
8b|c7|e6|Deluxe Days
8b|cb|ab|Sybarite Green
8b|d0|dd|Aqua Clear
8b|d2|e2|Piccolo
8b|d2|e3|July
8b|d3|c6|Green Daze
8b|e0|ba|Sprig of Mint
8c|00|0f|Crimson
8c|00|34|Red Wine
8c|05|5e|Cardinal Pink
8c|2c|24|Borscht
8c|35|73|Purple Wine
8c|47|36|Suzumecha Brown
8c|47|4b|Rhubarb Smoothie
8c|4a|2f|Gingerbread
8c|4f|42|Earth Crust
8c|54|3a|Mocha Bisque
8c|59|39|Brushwood
8c|63|38|McKenzie
8c|63|3c|Cambridge Leather
8c|64|50|Gaboon Viper
8c|66|5c|Baby Burro
8c|66|7a|Sweet Violet
8c|6c|6f|Chocolate Sparkle
8c|6e|54|Caravel Brown
8c|6e|67|Eclectic Plum
8c|70|42|Rokou Brown
8c|72|4f|Tobacco Leaf
8c|75|44|Reservation
8c|75|91|Self Powered
8c|7b|6c|Inca Temple
8c|7c|61|Elmwood
8c|7d|88|Medieval Wine
8c|7e|49|Ovoid Fruit
8c|7f|3c|Peas Please
8c|81|85|Viennese
8c|81|88|Mauvey Pink
8c|84|49|Frog's Legs
8c|84|75|Dark Ash
8c|85|78|Roller Coaster
8c|85|89|Plate Mail Metal
8c|86|70|Stratford Sage
8c|87|98|Purple Ragwort
8c|8d|91|Aluminum Silver
8c|8e|65|Paid In Full
8c|8e|b2|Persian Violet
8c|92|ac|Sephiroth Grey
8c|93|ad|Cool Grey
8c|97|a3|Roman Bath
8c|9c|76|Usuao Blue
8c|9c|92|Iceberg Green
8c|9c|9c|Boredom
8c|9c|c1|Lavender Lustre
8c|9d|8f|Mossleaf
8c|9d|ad|Dusty Blue
8c|9e|5e|Yanagizome Green
8c|9f|a0|Aqua Smoke
8c|9f|a1|White Scar
8c|a4|68|Scarpetta
8c|a8|a0|Tropical Cascade
8c|a8|c6|Dresden Doll
8c|aa|95|Peaslake
8c|ad|cd|Ocean Bubble
8c|ad|d3|Placid Blue
8c|ae|a3|Donnegal
8c|ae|ac|Shallow Water
8c|b0|cb|Windy Day
8c|b2|93|Monarch's Cocoon
8c|b2|95|Morris Artichoke
8c|b2|99|Holly Fern
8c|bc|9e|Summertown
8c|be|d6|High Elf Blue
8c|c3|c3|Aqua Fiesta
8c|ce|ea|Anakiwa
8c|d4|df|Plunging Waterfall
8c|d6|12|Frogger
8c|d9|a1|Patrice
8c|fd|7e|Easter Green
8c|ff|9e|Baby Green
8c|ff|db|Light Aqua
8d|3f|2d|Picante
8d|43|62|Putnam Plum
8d|45|12|Korichnewyi Brown
8d|46|87|Hyacinth Violet
8d|4e|85|Razzmic Berry
8d|51|4c|Ragin' Cajun
8d|5c|74|Grape Nectar
8d|5e|b7|Deep Lavender
8d|5f|2c|Rusty Nail
8d|60|8c|Hashita Purple
8d|64|49|Goulash
8d|67|37|Beagle Brown
8d|67|47|Wild Horses
8d|6a|4a|Slippery Stone
8d|6b|4b|Cowboy Trails
8d|70|2a|Corn Harvest
8d|72|5a|Cocoa Delight
8d|73|6c|Brown Rose
8d|74|48|Turned Leaf
8d|79|4f|Rustic Ranch
8d|79|60|Petrified Oak
8d|7d|68|Eagle's Meadow
8d|7d|77|Cinnamon Toast
8d|7e|71|Desert Taupe
8d|7f|64|Hidden Cottage
8d|80|70|Timber Wolf
8d|82|8c|Lusty Lavender
8d|84|68|Brown Grey
8d|84|78|Schooner
8d|84|7f|Mecha Grey
8d|84|85|Purpura
8d|87|52|Bronze Green
8d|87|6d|Western Reserve
8d|89|4a|Warm Wetlands
8d|8a|a0|Antiquate
8d|8b|55|Green Olive
8d|8d|40|Cute Pixie
8d|8d|8d|More Than A Week
8d|8f|8e|Stieglitz Silver
8d|8f|8f|Griffin
8d|90|a1|Manatee
8d|95|aa|Silverfish
8d|99|9e|By The Sea
8d|9a|9e|Grey Flannel
8d|9c|a7|Lost At Sea
8d|a3|99|Morning Blue
8d|a8|be|Kaleidoscope
8d|a9|8d|Alga Moss
8d|ac|a0|Rare Happening
8d|ac|cc|Northern Sky
8d|b0|51|Parrot Green
8d|b0|ad|Jitterbug Lure
8d|b2|55|Usumoegi Green
8d|b6|00|Seasoned Apple Green
8d|b6|b7|Eyefull
8d|bb|d1|Bonnie Blue
8d|ce|65|Bright Lettuce
8d|d9|cc|Middle Blue Green
8e|23|23|Old Mandarin
8e|35|37|Well Read
8e|36|43|Raspberry Fool
8e|3a|59|Quinacridone Magenta
8e|3b|2f|Gatsby Brick
8e|3c|36|Chili Oil
8e|3c|3f|Royal Red Flush
8e|44|83|Willowherb
8e|45|85|Plum Pie
8e|47|85|Pickled Plum
8e|4d|45|Matrix
8e|51|64|Cannon Pink
8e|59|3c|Rope
8e|59|59|Barn Door
8e|5b|68|Cabernet
8e|5e|5e|Antique Garnet
8e|5e|65|Cherry Cocoa
8e|60|3c|African Ambush
8e|60|4b|Tamarind Tart
8e|62|68|Grenache
8e|62|78|Victorian Plum
8e|6c|39|Mango Squash
8e|6c|94|Rhinestone
8e|6e|74|Pink Poppy
8e|6f|73|Tetrarose
8e|6f|76|Myself
8e|72|82|Magic Gem
8e|72|c7|True V
8e|74|6c|Woodchuck
8e|76|18|Jīn Zōng Gold
8e|7a|a1|Pickled Purple
8e|7b|58|Woven Basket
8e|7d|5d|Prairie Grove
8e|7e|67|Barrel Stove
8e|80|62|Hindu Lotus
8e|82|4a|Shaded Glen
8e|82|fe|Periwinkle
8e|85|5f|Boa
8e|85|83|Mine Rock
8e|8c|97|Alaitoc Blue
8e|8e|6e|Rowntree
8e|90|74|Mesmerize
8e|90|8d|T-Rex Fossil
8e|90|b4|Fresh Lavender
8e|91|8f|Neutral Grey
8e|95|98|Grey Russian
8e|96|55|Topiary
8e|96|9e|Dusky Grouse
8e|97|7e|Veranda Green
8e|99|85|Linden Spear
8e|9a|21|Limetta
8e|9b|88|Farm Fresh
8e|9b|96|Tranquility
8e|a5|97|Tree Lined
8e|a7|b9|Dresden Dream
8e|aa|bd|Sky Eyes
8e|ab|12|Pea Green
8e|b8|ce|Moon Jellyfish
8e|bc|bd|Lorian
8e|c1|c0|Cabana Bay
8e|c2|e7|Astral Spirit
8e|c3|9e|Delltone
8e|c5|b6|Ocean Wave
8e|cb|9e|Frost Gum
8e|ce|d8|Winter Chill
8e|cf|d0|Fling Green
8e|cf|e8|Light Mizu
8e|da|cc|Bambino
8e|e5|3f|Kiwi Green
8e|ef|15|Scorpy Green
8e|fa|00|Mochito
8f|00|f1|Electric Violet
8f|00|ff|Amethyst Ganzstar
8f|14|02|Brick Red
8f|1d|21|Shinshu
8f|2e|14|Bengala Red
8f|3f|2a|Fire
8f|41|55|Umemurasaki Purple
8f|42|3d|Deep Crimson
8f|4b|41|Red Clay
8f|4c|3a|Burled Redwood
8f|4e|45|El Salva
8f|50|9d|Vicious Violet
8f|58|3c|Chōjicha Brown
8f|59|73|Blackberry Tint
8f|66|6a|Deadlock
8f|68|4b|Webcap Brown
8f|6a|50|Warm Nutmeg
8f|6d|6b|Moss Rose
8f|6e|4b|Tanned Wood
8f|71|6e|Oakwood Brown
8f|71|91|Wine Stroll
8f|72|65|Milk Brownie Dough
8f|73|03|Vermin Brown
8f|75|5b|Cargo
8f|77|5d|Hat Box Brown
8f|77|77|Bazaar
8f|79|74|Venus Deva
8f|7b|51|Safari Trail
8f|7d|6b|Squirrel
8f|7d|a5|Chalk Violet
8f|7f|85|Mighty Mauve
8f|81|77|Fungi
8f|81|8b|Lavendaire
8f|83|95|Purple Ash
8f|84|61|Grant Drab
8f|86|67|Tea Leaf
8f|87|6b|Rattan Palm
8f|88|6c|Wilderness
8f|89|82|Elephant Skin
8f|8a|70|Executive Course
8f|8c|79|Meander
8f|8c|e7|Perrywinkle
8f|91|7c|Farmer's Market
8f|91|83|Stone Creek
8f|94|82|Eyre
8f|97|79|Artichoke
8f|97|a5|Trance
8f|98|05|Devil's Flower Mantis
8f|98|9d|Pachyderm
8f|99|fb|Periwinkle Blue
8f|9a|88|Ramona
8f|9a|a4|Canadian Lake
8f|9c|ac|Atom Blue
8f|9e|9d|Abyss
8f|9f|97|Marble Green
8f|a0|a7|Symmetry
8f|a1|74|Lady Fern
8f|a4|d2|Rip Van Periwinkle
8f|a6|c1|Frills
8f|aa|ca|Bachelor Blue
8f|ab|bd|Pool Bar
8f|ae|22|Icky Green
8f|b6|7b|Flavoparmelia Caperata
8f|b6|9c|Summer Green
8f|ba|bc|Watchet
8f|bc|8f|Tiki Monster
8f|bc|c4|Kingston Aqua
8f|bf|bd|Chinese Tzu
8f|c1|d2|Eastern Sky
8f|cb|c0|Deco-Rate
8f|cb|dc|Baby Motive
8f|cd|b0|Vile Green
8f|cd|c7|Tropical Holiday
8f|d4|00|Sheen Green
8f|e0|c6|Clean Green
8f|fe|09|Acid Green
8f|ff|9f|Barium Green
90|00|20|Burgundy
90|09|10|Stizza
90|09|1f|Old Wine
90|30|5d|Pink Horror
90|3e|2f|Carmen Miranda
90|3f|45|Apple-A-Day
90|3f|75|Deep Orchid
90|4f|ef|Pericallis Hybrida
90|52|84|Grape Candy
90|5d|36|Dark Rye
90|5d|5d|Rose Taupe
90|5e|26|Afghan Carpet
90|61|4a|Weathered Leather
90|67|3f|Centaur
90|68|6c|Mauve-a-Lish
90|6a|54|Leather
90|70|47|Gold Spike
90|76|6e|Cadian Fleshtone
90|79|ad|Gentian
90|7a|6e|Miami Spice
90|7b|aa|Trumpeter
90|81|86|Mauve Jazz
90|82|79|Cherry Bark
90|83|5e|Wood Chi
90|89|82|Gunmetal Beige
90|8a|78|Cricket's Cross
90|8b|85|Excelsior
90|8b|8e|Shining Armor
90|8d|39|Sycamore
90|90|62|Nick's Nook
90|90|a2|Cotton Flannel
90|92|6f|Desert Sage
90|93|73|Dry Hemlock
90|97|7a|Acanthus Leaf
90|98|a1|Thunderstorm
90|99|89|Dark Sky
90|9b|4c|Spinach Green
90|a2|b7|Sell Out
90|a5|8a|Sonoma Sage
90|a8|a4|Blue Surf
90|a9|6e|Green Tea Mochi
90|ab|d9|Black Drop
90|b1|34|Avocado Toast
90|b1|ae|Undersea
90|b3|c2|Bright Bluebonnet
90|c0|c9|Witness
90|cb|aa|Hint of Peppermint
90|d1|dd|Foaming Surf
90|e4|c1|Light Teal
90|ee|90|Ulva Lactuca Green
90|f2|15|Flickery CRT Green
90|fd|a9|Foam Green
91|09|51|Reddish Purple
91|32|25|Bengara Red
91|32|28|Red Kite
91|38|32|Red Ochre
91|43|3e|Red Craft
91|49|3e|Cedar Staff
91|4b|13|Parasite Brown
91|4e|75|Sugar Plum
91|55|2b|Glazed Ginger
91|5a|7f|Thor's Thunder
91|5b|41|Spiced Cider
91|5c|83|Antique Fuchsia
91|5d|88|Plum Savor
91|5f|6c|Raspberry Glace
91|5f|6d|Mauve Taupe
91|62|38|Oregon Hazel
91|6d|5d|Wild Cattail
91|6e|52|Leather Bound
91|6e|99|Faded Purple
91|6f|5e|Redwood Forest
91|73|47|Fallen Leaves
91|77|47|Wool Tweed
91|77|98|Sweet Potato Peel
91|78|8c|Muted Berry
91|7a|56|Coconut Shell
91|7a|75|Porcupine Needles
91|7b|53|Old Ruin
91|7c|6f|Motto
91|81|51|Dark Tan
91|82|78|Mocha Wisp
91|85|79|Roasted Cashew
91|85|7c|Wild Wilderness
91|86|76|Stacked Stone
91|87|54|Trough Shell Brown
91|87|6b|Open Range
91|8c|7e|Laurel Oak
91|8c|86|Rocky Ridge
91|8c|8f|Gull
91|8e|8a|Bygone
91|8e|8c|Antique Silver
91|90|ba|Purple Amethyst
91|91|6d|Extra Mile
91|91|91|Tin
91|92|3a|Bean Shoot
91|95|85|Tarzan Green
91|97|a3|Classic Cloud
91|97|a4|Memorize
91|98|9d|Wolverine
91|9b|c9|Easter Egg
91|9f|a1|Rain Cloud
91|a0|85|Fresh Sod
91|a0|92|Pewter
91|a0|b7|Anita
91|a1|b5|Canary Wharf
91|a2|a6|Cape Cod Blue
91|a3|b0|Cadet Grey
91|a4|9d|Spruce Shade
91|a6|73|Luscious Lime
91|a8|d0|Serenity
91|ac|80|Forest Shade
91|af|88|Pear Cactus
91|b6|ac|Treetop
91|b9|c2|Mallard Lake
91|c1|c6|Chuff Blue
91|c3|bd|Focus Point
91|cb|7d|Fresh Cut Grass
91|dc|e8|Tanager Turquoise
92|00|0a|Chokecherry
92|0a|4e|Mulberry
92|1d|0f|Uluru Red
92|27|24|Vivid Auburn
92|2a|31|Ancient Red
92|2b|05|Brown Red
92|2b|9c|Pale Grey Shade Wash
92|2e|4a|Scarlet Apple
92|31|6f|Wild Aster
92|35|3a|Fire Chi
92|38|30|Thunderbird
92|55|5b|Mesa Red
92|65|3f|Topaz Mountain
92|6a|25|Armageddon Dunes
92|6a|a6|Amethyst Orchid
92|6b|43|Antique Bourbon
92|6c|ac|Knight Elf
92|6d|9d|Court Jester
92|6e|ae|Violet Frog
92|6f|5b|Beaver
92|71|a7|Ce Soir
92|72|47|Cuban Cigar
92|72|57|Arrow Creek
92|72|88|Very Grape
92|77|4c|Beaumont Brown
92|78|6a|Grapple
92|7a|71|Heavy Skintone
92|7b|3c|Ecru Olive
92|7b|97|Violet Persuasion
92|7d|6c|Spiced Nutmeg
92|7d|7b|Warplock Bronze Metal
92|7f|76|Carmel Mission
92|80|83|Venetian
92|84|75|Marmot
92|89|8a|Zinc
92|8a|98|Tin Lizzie
92|8c|36|Uguisu Green
92|8c|3c|Highball
92|90|00|Old Asparagus
92|90|90|Wet Weather
92|91|78|Paseo Verde
92|92|64|Hula Girl
92|92|92|Nickel
92|94|9b|Sleet
92|95|91|Lost Soul Grey
92|97|52|Salvia Divinorum
92|98|7d|Cavern Moss
92|99|01|Pea Soup
92|9b|ac|Numbers
92|a1|cf|Ceil
92|a7|72|Lettuce Mound
92|ab|d8|Victory Lake
92|ac|b4|Botticelli
92|af|88|Fair Green
92|b3|00|Grasping Grass
92|b6|cf|Sea Mark
92|b6|d5|Oxygen Blue
92|c6|d7|Blue Glint
92|cb|f1|Light Azure
92|d2|ed|Light Spritzig
92|d5|99|May Apple
93|37|09|Citrine Brown
93|3d|41|Nelson's Milk Snake
93|3e|49|Banana Blossom
93|43|37|Persimmon Juice
93|52|42|Ruskin Red
93|54|44|Prairie Clay
93|55|29|Sugar Almond
93|59|2b|Roasted Pecan
93|5f|43|Cinnamon Spice
93|60|64|Velveteen Crush
93|62|5b|Canyon Stone
93|66|47|Copper Pot
93|6a|5b|Badlands Sunset
93|6a|6d|San Francisco Mauve
93|6a|98|Lavender Crystal
93|6b|4f|Thrush
93|6c|a7|Hyacinth
93|70|67|Prairie Dog
93|70|db|Matt Purple
93|76|5c|Spanish Style
93|78|74|Astro Sunset
93|78|99|Vestige
93|7a|62|Carved Wood
93|7b|56|Tweed
93|7b|6a|Portabella
93|7c|00|Moscow Papyrus
93|7f|6d|Baneblade Brown
93|80|7f|California Dreamin'
93|82|6a|Empire Ranch
93|85|65|Deep Marsh
93|85|86|Exotica
93|86|73|Light Leather
93|89|88|Storm Break
93|8a|43|Cider Mill
93|8b|4b|Negishi Green
93|8b|78|Silver Sage
93|8c|83|Young Colt
93|8e|a9|Orchilla
93|8f|8a|Mole Grey
93|91|7f|Sandgrass Green
93|91|a0|Grey Suit
93|92|ab|Cosmic Energy
93|94|98|Aircraft Exterior Grey
93|95|81|Restoration
93|97|17|Turtle Moss
93|97|7f|Fair Spring
93|97|89|Smoke & Ash
93|97|a3|Time Warp
93|9a|89|Green Tea Leaf
93|9c|ab|Blue Heeler
93|9c|c9|Hair Ribbon
93|9f|a9|Frilled Shark
93|a2|72|Ivy Enchantment
93|a2|ba|Rock Blue
93|a3|c1|Wild Clary
93|a8|a7|Mythical Blue
93|aa|b9|Nepal
93|b8|81|Willow Dyed
93|b9|df|Lightning Bolt Blue
93|bc|bb|Turner's Light
93|bd|e7|Blue Shutters
93|c3|b1|Bella Green
93|c4|60|Cabbage Patch
93|c5|72|Pistachio
93|c9|d0|Bathing
93|cc|e7|Thresher Shark
93|cc|ea|Light Cornflower Blue
93|d4|c0|Pop Shop
93|d6|bf|Apple II Blue
93|d8|c2|Chloride
93|df|b8|Algae Green
93|ef|10|Fresh Leaf
94|00|08|Carnage Red
94|00|84|Batman's NES Cape
94|00|d3|Violet Ink
94|11|00|Cayenne
94|17|51|Wine Grape
94|21|93|Acai Juice
94|33|2f|Redbox
94|37|ff|Sugar Grape
94|4e|87|Striking Purple
94|52|00|Mochaccino
94|56|8c|Àn Zǐ Purple
94|57|59|Baca Berry
94|57|eb|Lavender Indigo
94|5c|54|Copper Mining
94|69|85|Fruit Of Passion
94|69|a2|Figue
94|6a|81|Strikemaster
94|6c|74|Wistful Mauve
94|6e|5c|Monterey Brown
94|70|c4|Lilac Bush
94|77|06|Bhūrā Brown
94|77|54|Lonely Road
94|77|64|Burro
94|79|af|Fairy Wren
94|7c|ae|Captivated
94|7e|68|Gazelle
94|7e|74|Tallarn Flesh
94|7e|94|Lepidolite Purple
94|81|65|Rich Biscuit
94|82|63|Charlie Horse
94|84|91|Quixotic
94|85|93|Femme Fatale
94|86|75|Country Club
94|87|76|On the Avenue
94|88|be|Magic Carpet
94|89|5f|Enchanted Wood
94|8a|7a|Winter Twig
94|8b|76|Sage Advice
94|8c|7e|Laminated Wood
94|8d|99|Minimal Grey
94|8f|54|Amazon Queen
94|8f|82|Stony Creek
94|90|89|Champignon
94|90|8b|Mourning Dove
94|90|b2|Extinct
94|93|81|Water Scrub
94|94|86|Venetian Wall
94|97|b3|Charcoal Dust
94|99|bb|Thistle Down
94|9e|a2|Soft Pumice
94|a0|89|Triamble
94|a1|35|Pickled Cucumber
94|a2|93|Mountain Moss
94|a4|b9|Blue Blouse
94|a6|17|Pea Soup Green
94|a8|d3|Foresight
94|a9|b7|Ashen Wind
94|ac|02|Barf Green
94|ad|b0|Beach Cottage
94|b1|a9|Ninja Turtle
94|b2|1c|Sickly Green
94|b4|4c|Venus Flytrap
94|b4|91|Mountain Fern
94|b9|b4|Teal Tree
94|bb|da|Manakin
94|be|7f|Sago Garden
94|c0|cc|Blue Chalk
94|c8|d2|Idyllic Isle
94|d0|e9|Light Bright Spark
94|d1|df|Washed Blue
94|d2|bf|Wintermint
94|d8|ac|Peaceful Pastures
94|e0|89|VIC 20 Green
95|2e|31|Guardsman Red
95|2e|8f|Warm Purple
95|36|40|Polished Garnet
95|3d|55|Ancient Magenta
95|42|4e|Earth Red
95|47|38|Mischief Maker
95|48|3f|Kite Brown
95|4e|2a|Khaki Brown
95|4e|2c|Alert Tan
95|52|4c|Copper Rust
95|52|64|Vin Rouge
95|53|2f|Chelsea Gem
95|56|eb|Navy Purple
95|58|43|Seville Scarlet
95|69|a3|Allium
95|6a|66|Clay Ridge
95|6f|29|Mulberry Brown
95|6f|3f|Golden Pilsner
95|6f|7b|Heritage Taffeta
95|70|46|Tavern Creek
95|74|3f|California Gold Rush
95|77|47|Antique Penny
95|78|40|Manticore Brown
95|78|6c|Buffalo Soldier
95|7a|76|Antler
95|7b|38|Cardueline Finch
95|7d|6f|Peppered Pecan
95|7e|68|Lover's Leap
95|80|4a|Yellow Nile
95|85|9c|Hatoba Pigeon
95|86|3c|Eden Prairie
95|87|9c|Amethyst Smoke
95|89|6c|Knapsack
95|8b|84|Moon Rock
95|91|8c|Elephant Grey
95|92|72|Inness Sage
95|92|8d|Winter Park
95|94|86|Dapple Grey
95|96|51|Ancient Maze
95|98|6b|Guacamole
95|98|89|Deep Seagrass
95|98|a1|Light Campers Ghost Grey
95|99|84|Gundaroo Green
95|99|88|California Sagebrush
95|9e|8f|Sycamore Stand
95|9e|b7|Skyline
95|a2|63|Banana Palm
95|a3|a6|Dusty Sky
95|a6|9f|Galago
95|a7|a4|Galway Bay
95|ae|d0|Dockside
95|b3|88|Foliage
95|b6|b5|Baroque Blue
95|b9|d6|Blue Pointer
95|bb|d8|Salt Water
95|bc|c5|Squirt
95|be|76|Leticiaz
95|c0|cb|Porcelain Blue
95|c5|77|Lime Parfait
95|ca|d0|Jellyfish Blue
95|cd|d8|Blue Stream
95|d0|fc|Long Island Sound
95|d6|dc|Arctic Blue
95|de|e3|Island Paradise
95|e3|c0|Green Gum
96|00|18|Flame Hawkfish
96|00|56|Strong Cerise
96|01|17|Heidelberg Red[2]
96|01|45|Rose Garnet
96|2c|54|Figue Pulp
96|2d|49|Red Bud
96|46|3f|Rooster Comb
96|46|6a|Satsuma Imo Red
96|49|6d|Befitting
96|4b|00|Brownie
96|4e|02|Warm Brown
96|4f|4c|Marsala
96|50|36|Japanese Cypress
96|51|2a|Rusty
96|51|4d|Azuki Bean
96|58|49|Russet Leather
96|5a|3e|Coconut
96|65|44|Mud Ball
96|6e|bd|Viola
96|6f|d6|Dark Pastel Purple
96|71|11|Sandy Taupe
96|71|17|Bistre Brown
96|71|1c|Puma
96|71|1f|Mode Beige
96|72|17|Glazed Chestnut
96|74|8a|Hidden Mask
96|78|59|Cocoa Cupcake
96|78|b6|Purple Mountains Majesty
96|7b|5d|Cocoa Pecan
96|7b|b6|Lavender Purple
96|83|79|Ranch Mink
96|83|7d|Wine Crush
96|84|28|Lemon Ginger
96|84|7a|Deep Mushroom
96|86|78|Toffee Fingers
96|87|72|Shipwreck
96|87|75|Bedbox
96|8a|9f|Eccentricity
96|8f|5f|Nile Reed
96|95|65|Rhind Papyrus
96|95|82|Forest Canopy
96|97|83|Elemental Green
96|98|a3|Light Compass Ghost Grey
96|9e|86|Herbalist
96|a3|c7|Blue Heron
96|a6|9f|Farmers Green
96|a7|82|Huntington Garden
96|a7|93|Mantle
96|ac|b8|Pacific Bliss
96|ae|8d|Greenish Grey
96|af|54|Asparagus Cream
96|af|b7|Mountain Stream
96|b3|b3|Cool
96|b4|03|Salty Thyme
96|b5|76|Florence
96|b9|57|Happy Tune
96|bc|4a|Early Spring
96|bf|83|Hearty Hosta
96|bf|b7|Envisage
96|c6|cd|Adriatic Haze
96|c8|a2|Eton Blue
96|cc|d1|Pentagon
96|ce|d5|Peppermint Twist
96|d3|d8|Aqua Bloom
96|d7|db|Mini Blue
96|d9|df|Exotic Escape
96|de|d1|Pale Robin Egg Blue
96|df|ce|Beach Glass
96|f9|7b|Radar Blip Green
96|ff|00|Mango Green
97|34|43|Deep Claret
97|38|2c|Red Stop
97|3a|36|Vermillion Seabass
97|3c|6c|Baton Rouge
97|42|2d|Tia Maria
97|46|3c|Mojo
97|54|37|Tonocha
97|57|2b|Leather Brown
97|63|52|Majolica Earthenware
97|63|5f|Roulette
97|64|5a|Umenezumi Plum
97|65|3c|Ginger Dy
97|65|3f|Ambit
97|69|4f|Old Driftwood
97|6c|60|Safari Brown
97|6e|9a|Tatarian Aster
97|6f|3c|Half Orc Highlight
97|6f|4c|Chocolate Milk
97|70|42|Cane Toad
97|70|43|Chewy Caramel
97|72|5f|Tangara
97|75|47|Medal Bronze
97|75|4c|Dijon
97|77|4d|Weathered Wicker
97|7b|4d|Alluring Umber
97|7c|61|Tiger's Eye
97|7d|70|Ginger Snap
97|86|7c|Ginnezumi
97|87|bb|Sunlit Allium
97|88|88|Rising Ash
97|8a|84|Warm Grey
97|8b|71|Tawny Owl
97|8c|59|In A Pickle
97|8d|71|Courtyard Green
97|90|8e|Mani
97|90|a4|Pale Mouse
97|91|47|Delta Break
97|92|8b|Lazy Afternoon
97|93|81|Sylvan
97|94|3b|Plantain
97|96|9a|Formal Grey
97|97|6f|Silk Road
97|98|7f|Canyon Falls
97|99|a6|Angry Gargoyle
97|9a|aa|Bright Manatee
97|9d|9a|Gun Barrel
97|9f|bf|Midnight Blush
97|a2|a0|Dusty Dream
97|a3|da|Dalmatian Sage
97|a4|9a|Olive Soap
97|a9|8b|Zucchini Cream
97|ae|af|Sliding
97|b2|b1|Smooth-Hound Shark
97|b9|e0|Sacred Blue
97|bb|e1|Fleck
97|bc|62|Green Pepper
97|be|e2|Viva La Bleu
97|c5|da|Bobby Blue
97|d5|b3|Vista Blue
97|d5|ea|Light Blue Booties
97|ea|10|Scorpion Venom
98|00|01|Crimson Red
98|00|02|Blood Red
98|00|36|Pink Raspberry
98|33|3a|Queen of Hearts
98|3f|4a|Egyptian Red
98|3f|b2|Akebi Purple
98|44|27|Fluorescent Fire
98|45|b0|Moonshadow
98|49|61|Cadillac
98|51|4a|Thy Flesh Consumed
98|55|38|Polished Brown
98|56|29|Ethiopian Wolf
98|56|72|Pink Tulip
98|56|8d|Purplish
98|59|4b|Chutney
98|5c|41|Sierra
98|5e|2b|Chili Con Carne
98|5f|68|Deco Rose
98|62|3c|Ash Brown
98|68|7e|Arcane
98|69|60|Dark Chestnut
98|6a|79|Wild Geranium
98|6e|6e|Homestead Red
98|73|87|Artiste
98|74|56|Liver Chestnut
98|76|54|Guinea Pig Brown
98|77|44|Warm Spice
98|78|f8|Forgotten Purple
98|79|a2|Diffused Orchid
98|7b|71|Soft Cocoa
98|7d|73|Hemp
98|7e|7e|Opium
98|80|88|Toadstool Soup
98|81|71|Locomotion
98|81|7b|Cinereous
98|82|66|Knot
98|82|86|Maud
98|84|b9|Bougainvillea
98|86|8c|Quail
98|87|8c|Purple Dove
98|88|70|Limbert Leather
98|8c|75|Peat Swamp Forest
98|8e|b4|Purple Agate
98|91|71|Gurkha
98|92|a8|Jazz Tune
98|92|b8|Indifferent
98|94|93|Flint Rock
98|95|c5|Litmus
98|96|a4|Lilac Grey
98|97|9a|Alloy
98|98|98|Spanish Grey
98|99|a7|Acanthus
98|99|b0|Bay Fog
98|9a|87|Green Fog
98|9a|98|Dark Limestone
98|9b|9e|Harrison Grey
98|9e|a7|Shining Knight
98|9f|7a|Renkon Beige
98|9f|a3|Ufo
98|a0|a5|Quarry
98|a0|b8|Silver Star
98|ab|8c|Banyan Serenity
98|b4|89|Mistletoe Kiss
98|bd|3c|Funky Frog
98|bd|dd|Sleeping Easy
98|be|3c|Green Caterpillar
98|bf|ca|Sea Angel
98|c6|cb|Continental Waters
98|cb|ba|Mint Twist
98|cd|b5|Mint Ice Cream
98|d2|d9|Maya Green
98|d9|8e|Leek
98|da|2c|Effervescent Lime
98|dc|ff|Gas Giant
98|dd|c5|Almost Aqua
98|dd|de|Limpet Shell
98|de|d9|Pale Beryl
98|ef|f9|Permafrost
98|f6|b0|Light Sea Green
98|fb|98|Toxic Frog
98|ff|98|Bright Mint
99|00|00|OU Crimson Red
99|00|03|Cavalry Brown
99|00|10|USC Cardinal
99|00|11|Strawberry Cough
99|00|20|Xmas Candy
99|00|44|Rum Riche
99|00|66|8Bit Eggplant
99|00|fa|Vivid Purple
99|01|47|Purple Red
99|0f|4b|Berry
99|11|00|Dramatical Red
99|11|15|Clotted Red
99|11|99|Violet Eggplant
99|1b|07|Totem Pole
99|22|00|Smoking Red
99|22|44|Berry Rossi
99|32|cc|Dark Orchid
99|33|00|Chocoholic
99|33|11|Choco Chic
99|33|22|Chocolate Lust
99|33|33|Poisonous Apple
99|33|66|Scarlet Flame
99|3c|7c|Vivid Viola
99|42|40|Attar of Rose
99|44|44|Ashen Brown
99|52|2b|Ancient Chest
99|52|2c|Hawaiian Coconut
99|55|00|Charlie Brown
99|55|22|Mammoth Wool
99|55|bb|Deep Lilac
99|55|ff|Irrigo Purple
99|59|15|Sepia Wash
99|5e|39|Toffee Crunch
99|63|78|Mellow Mauve
99|64|2c|Cathay Spice
99|65|15|Cobre
99|65|6c|Soft Bromeliad
99|66|00|Gamboge Brown
99|66|11|Embarrassed Frog
99|66|33|Woodgrain
99|66|44|Oiled Up Kardashian
99|66|66|Copper Rose
99|66|cc|Amethyst
99|68|72|Nouveau Rose
99|6e|5a|Prairie Fire
99|6e|74|Stravinsky
99|71|65|Antique Rose
99|75|70|Reddish Grey
99|76|51|Summerville Brown
99|78|67|Beaver Fur
99|7a|8d|Mountbatten Pink
99|7b|38|Dried Tobacco
99|80|69|Chocolate Moment
99|81|88|Ordain
99|83|71|Even Evan
99|84|56|Fennel Seed
99|88|11|Quagmire Green
99|8d|a8|Futuristic
99|8e|83|Eiffel Tower
99|91|7e|Stonegate
99|94|c0|Lavender Bonnet
99|95|9d|Emperor's Robe
99|96|b3|Tusi Grey
99|98|a7|Lavender Ash
99|99|88|Concrete Jungle
99|99|99|Basalt Grey
99|99|cc|Bluebell Frost
99|99|ff|Cobalite
99|9a|86|Lemon Grass
99|9b|95|Delta
99|9b|9b|Walrus
99|9b|a8|Dame Dignity
99|9e|98|Wrought Iron
99|9e|b0|Screen Test
99|a2|8c|Medicine Wheel
99|a4|56|Do Not Disturb
99|a7|ab|Celestra Grey
99|a8|c9|Sapphire Fog
99|aa|aa|Oily Steel
99|aa|bb|Lead Ore
99|aa|c8|Scorpion Grass Blue
99|ac|4b|Persian Belt
99|ae|ae|Grey Mist
99|af|73|Rural Eyes
99|b0|90|Cloistered Garden
99|ba|dd|Blues White Shoes
99|bb|00|Matcha Picchu
99|bb|33|Machu Picchu Gardens
99|bb|44|Paddy Field
99|bb|ff|Truesky Gloxym
99|bd|91|Milly Green
99|c1|cc|Aquatic
99|c1|d6|Sky Bus
99|c1|dc|January Frost
99|c3|f0|Sail to the Sea
99|c5|c4|Pastel Turquoise
99|cc|00|Viric Green
99|cc|04|Waywatcher Green
99|cc|ff|Apocyan
99|d0|e7|Light Whimsy
99|db|fe|Shiva Blue
99|de|ad|Dead 99
99|e6|b3|Teal Deer
99|ee|aa|Mint Tonic
99|ff|00|Greenday
99|ff|ff|Glitchy Shader Blue
9a|02|00|Deep Red
9a|0e|ea|Violet
9a|11|15|Mephiston Red
9a|2c|a0|Purple Ink
9a|30|01|Chocolate Fondue
9a|38|2d|Ketchup
9a|46|3d|Mature Cognac
9a|49|3f|Safflower Kite
9a|4e|ae|Purpureus
9a|56|33|Seared Earth
9a|5f|3f|Harrison Rust
9a|60|51|Copper Brown
9a|62|00|Raw Sienna
9a|71|82|Dusky Orchid
9a|72|76|March Pink
9a|7a|a0|Divine
9a|7d|61|Ginger Pie
9a|7f|28|Spruced Up
9a|80|3a|Amber Green
9a|84|5e|Twisted Tail
9a|85|57|Spacious Plain
9a|86|78|Almond Frost
9a|8b|4f|Willow
9a|8d|3f|Jalapeno
9a|91|86|Vintage Khaki
9a|92|7f|Seneca Rock
9a|93|7f|Voysey Grey
9a|97|38|Golden Lime
9a|9b|c1|Sweet Lavender
9a|9e|80|Fennelly
9a|9e|88|Flagstone Quartzite
9a|9e|b3|Aleutian
9a|a0|97|Trellised Ivy
9a|a0|99|Native Flora
9a|a0|a3|Prehistoric Stone
9a|a2|2b|Forest Lichen
9a|a7|7c|Forester
9a|ae|07|Elysia Chlorotica
9a|ae|8c|Cardoon
9a|b2|a9|Silver Drop
9a|b3|8d|Light Leaf
9a|b8|c2|Shallow Sea
9a|b9|73|Olivine
9a|bc|dc|Blue Grouse
9a|bf|8d|Olive Sand
9a|c0|b6|Shadow Green
9a|ca|d3|Surfside
9a|cd|32|Dark Yellow Green
9a|cd|a9|Heath Green
9a|d4|d8|Dulcet
9a|d6|e5|Oceano
9a|de|db|Pale Pastel
9a|f7|64|Stadium Lawn
9b|11|1e|Ruby Red
9b|1b|30|Chili Pepper
9b|20|02|Garden Gnome Red
9b|23|3b|Valentine Red
9b|35|1b|Deep Dumpling
9b|3d|3d|Mexican Red
9b|40|40|Sweet Lychee
9b|42|3f|Autumn Ridge
9b|47|03|Oregon
9b|47|22|Cinnamon Stick
9b|4b|80|Plum Passion
9b|53|3f|Sōdenkaracha Brown
9b|55|5d|Cuban Rhythm
9b|59|53|Walleye
9b|5b|55|Rhode Island Red
9b|5f|c0|Trunks Hair
9b|65|75|Jellybean Pink
9b|66|63|Cedar Ridge
9b|69|57|Muscovado Sugar
9b|69|59|Western Red
9b|71|6b|Burlwood
9b|74|48|Sahara Splendor
9b|75|3d|Heavy Ochre
9b|76|53|Dirt
9b|76|97|Rebel Rouser
9b|78|56|Treasure Casket
9b|7a|01|Yellowish Brown
9b|7a|78|Neapolitan
9b|7e|4e|Bronzed Brass
9b|87|0c|Captain Kirk Uniform
9b|8a|44|Plantation Island
9b|8c|7b|German Cam. Beige WWII
9b|8e|54|Serpentine
9b|8e|8e|Grey Violet
9b|8f|22|Nurgle's Rot
9b|8f|55|Dark Khaki
9b|8f|a6|Smoky Grape
9b|8f|b0|Greek Lavender
9b|90|92|Ashen Plum
9b|94|c2|Vision Quest
9b|95|9c|Lunar Light
9b|95|a9|Purple Surf
9b|98|3d|Be Yourself
9b|a0|ef|Cold Lips
9b|a5|91|Coronado Moss
9b|a8|8d|Tsurubami Green
9b|a9|ab|Mission Bay Blue
9b|a9|ca|Brunnera Blue
9b|ab|bb|Blue Fog
9b|ad|be|Soaring Eagle
9b|af|ad|5-Masted Preußen
9b|b1|39|Munchkin
9b|b2|aa|Tiamo
9b|b3|bc|Blue Shell
9b|b5|3c|Booger
9b|b5|3e|Macaw Green
9b|b9|ae|Moncur
9b|b9|e1|His Eyes
9b|bc|0f|Gameboy Light
9b|bc|c3|Bel Esprit
9b|bc|e4|Gallery Blue
9b|be|a9|Greyed Jade
9b|c2|b1|Lichen
9b|c2|b4|Stanley
9b|c2|bd|Pitter Patter
9b|c4|d4|June
9b|c4|e2|Pale Cerulean
9b|c7|ea|Sweet Dreams
9b|ca|47|Wicked Green
9b|cb|96|Kettle Drum
9b|d7|e9|Light Blue Limewash
9b|dc|96|Retro
9b|dc|b9|Birthday King
9b|dd|ff|Columbia Blue
9b|e3|d7|Sharbah Fizz
9b|e5|10|Quithayran Green
9b|e5|aa|Hospital Green
9b|ee|c1|Nightly Aurora
9c|00|4a|Celestial Pink
9c|25|42|Big Dip O’Ruby
9c|2d|5d|Dragon's Fire
9c|2e|33|Ruby Slippers
9c|4a|62|Baby Berries
9c|4a|7d|Orchid Lei
9c|51|b6|Purple Plum
9c|52|21|Ancient Bronze
9c|56|42|Baked Clay
9c|5b|34|Indochine
9c|5e|33|Gingerbread Crumble
9c|67|57|Apple Brown Betty
9c|69|89|Garden Aroma
9c|6b|08|Balor Brown
9c|6d|57|Brownish
9c|6d|a5|Dark Lilac
9c|73|51|Cigar Box
9c|76|47|Sugar Maple
9c|7c|38|Metallic Sunburst
9c|7e|41|Bronze Mist
9c|7f|5a|Howling Coyote
9c|86|7b|Antique Bear
9c|88|55|Wasteland
9c|88|66|Iced Cappuccino
9c|8a|4d|Yanagicha
9c|8a|52|Tibetan Silk
9c|8a|53|Goldbrown
9c|8a|a4|Amethyst Paint
9c|8d|72|Pale Oyster
9c|8e|74|Rustic Hacienda
9c|8e|7b|Chinchilla
9c|8f|60|Pineapple Sage
9c|90|9c|Out of Plumb
9c|92|73|Mossy Gold
9c|93|69|Cactus Sand
9c|94|63|Green Lentils
9c|94|6e|Sweet Annie
9c|94|80|Barnfloor
9c|94|9b|Hidcote
9c|95|84|Calico Rock
9c|96|80|Union Springs
9c|9a|40|Split Pea
9c|9a|99|Polished Pewter
9c|9b|98|Ghost Grey
9c|9b|a7|Colorado Peak
9c|9c|4b|Lazy Lizard
9c|9c|6e|Domain
9c|9c|82|Battle Harbor
9c|9c|9b|Metal Chi
9c|9c|9c|Codex Grey
9c|9f|75|Pine Trail
9c|a0|a6|Grey Wolf
9c|a3|89|Edamame
9c|a4|8a|Frozen Edamame
9c|a6|64|Green Smoke
9c|a6|87|Glade
9c|a9|aa|Horizon Grey
9c|a9|ad|Seryi Grey
9c|ac|a5|Tower Grey
9c|ad|60|Herbal Garden
9c|b3|b5|Powder Mill
9c|bb|04|Bright Olive
9c|bb|e2|Aegean Mist
9c|c2|bf|Bleu Nattier
9c|c2|c5|Canal Blue
9c|ce|9e|Mover & Shaker
9c|d0|3b|Green Lantern
9c|d0|e4|Light Blue Charm
9c|d3|3c|Blanka Green
9c|d4|cf|Fountain City
9c|d4|e1|Ocean Cruise
9c|d5|72|Tropical Light
9c|e5|d6|Neverland
9c|ef|43|Kiwi Pulp
9d|02|16|Carmine
9d|07|59|Dark Fuchsia
9d|20|2f|Scarlet Sage
9d|29|33|Cochineal Red/Rouge
9d|2b|22|Red Birch
9d|44|2d|Rock Spray
9d|44|6e|Magenta Haze
9d|45|31|Burnt Earth
9d|45|42|Lumberjack
9d|54|32|Piper
9d|57|83|Light Plum
9d|5a|8f|Bermuda Onion
9d|5b|8b|Kyo Purple
9d|5c|75|Rose Wine
9d|5f|46|Vintage Copper
9d|60|16|Soft Tone Ink
9d|69|84|Penelope Pink
9d|6f|46|Autumn Bark
9d|70|2e|Buttered Rum
9d|71|47|Aged Whisky
9d|74|46|Bone Brown
9d|76|51|Mocha
9d|77|7c|Bohemian Jazz
9d|79|38|Sneezy
9d|7a|ac|Cloudy Plum
9d|7b|74|Wild Hemp
9d|7b|b0|English Lavender
9d|7e|b7|Lush Lilac
9d|7f|4c|Heart of Gold
9d|7f|61|Sorrell Brown
9d|80|5d|Corkboard
9d|81|64|Teddy Bear
9d|81|ba|Purple Mountains’ Majesty
9d|85|7f|Pigeon Pink
9d|86|5c|Good Luck Charm
9d|88|61|Ridgecrest
9d|88|88|Mauverine
9d|89|6c|Nurude Brown
9d|8a|bf|Cold Purple
9d|8d|66|Autumn Laurel
9d|90|7e|Kommando Khaki
9d|91|3c|Gecko
9d|92|8a|Portobello Mushroom
9d|92|8f|Neutral Buff
9d|93|99|Lavender Elan
9d|95|88|Mud Pack
9d|95|8b|Mud Puddle
9d|96|b2|Heirloom Lilac
9d|98|80|Pebble
9d|9c|7e|Fairbank Green
9d|9c|b4|Logan
9d|9d|9d|Waiting
9d|9e|b4|Purple Balance
9d|a0|73|Dill Powder
9d|a2|86|Zebra Grass
9d|a2|8e|Meadowood
9d|a6|93|Lichen Green
9d|a7|a0|Casting Shadow
9d|a7|cf|Bright Bluebell
9d|a9|4b|Ogryn Camo
9d|aa|4d|Kiwi Fruit
9d|ac|b5|Irogon Blue
9d|ac|b7|Urban Pigeon
9d|b0|b9|Electric Slide
9d|b4|aa|Skeptic
9d|b7|a5|Silver Leaf
9d|b8|ab|Chrysanthemum Leaf
9d|b9|2c|Sick Green
9d|bc|d4|Light Grey Blue
9d|bf|b1|Diorite
9d|c1|00|Snot Green
9d|c2|09|New Limerick
9d|d1|96|Elfin Games
9d|d3|a8|Chinook
9d|d6|d4|Shallow Shoal
9d|d8|db|Lake Reflection
9d|e0|93|Granny Smith Apple
9d|ff|00|Bright Yellow Green
9e|00|3a|Cranberry
9e|01|68|Red Violet
9e|02|00|Dragon Red
9e|10|30|Jester Red
9e|12|12|Heavy Red
9e|13|16|Spartan Crimson
9e|2c|6a|Festival Fuchsia
9e|33|32|Milano Red
9e|36|23|Brownish Red
9e|36|41|Vintage Red
9e|3d|3f|Sappanwood
9e|43|a2|Medium Purple
9e|5b|40|Bitter Chocolate
9e|66|54|Warm Up
9e|67|59|Au Chico
9e|6b|4a|Brown Eyes
9e|6b|89|Pink Jazz
9e|7a|58|Stetson
9e|7b|5c|Barite
9e|7c|5e|Sandpit
9e|7c|60|Cowgirl Boots
9e|7e|53|Muesli
9e|7e|54|Grecian Gold
9e|80|22|Hacienda
9e|81|85|Plumville
9e|82|6a|Yardbird
9e|82|95|Berry Bliss
9e|83|52|Aztec Brick
9e|84|51|Wheatmeal
9e|87|79|Cobblestone Path
9e|8b|8e|Hatoba-Nezumi Grey
9e|8f|66|Willow Tree
9e|91|5c|G. Cam.Beige
9e|91|81|Northpointe
9e|91|c3|Violet Tulip
9e|92|8f|Mouse Catcher
9e|94|78|Lye
9e|95|89|Barnwood Grey
9e|95|8a|Saudi Sand
9e|9c|ab|Adhesion
9e|9e|7c|Bonsai Garden
9e|a1|a3|Suzu Grey
9e|a2|6b|Dry Grass
9e|a2|aa|Rough Stone
9e|a5|c3|Wild Phlox
9e|a6|cf|Venus Flower
9e|af|c2|Sterling Silver
9e|b1|ae|Easy Breezy Blue
9e|b3|7b|Death Guard
9e|b4|d3|Chambray Blue
9e|b6|b8|Ether
9e|b6|d0|Blue Satin
9e|b6|d8|Mont Blanc
9e|b7|88|Green Snow
9e|bb|cd|Anchors Away
9e|bc|97|Quiet Green
9e|bd|d6|Blue Crab Escape
9e|c1|cc|Stratosphere
9e|cc|a7|Potted Plant
9e|cf|d9|Tenzing
9e|d1|d3|Morning Glory
9e|d1|e3|Light Delphin
9e|d6|86|Celery Sprig
9e|d6|e8|Light Budgie Blue
9f|00|00|Cacodemon Red
9f|00|c5|Foxy Fuchsia
9f|00|ff|Vivid Violet
9f|0f|ef|Zǐ Lúo Lán Sè Violet
9f|1d|35|Vivid Burgundy
9f|23|05|Burnt Red
9f|28|32|Japanese Carmine
9f|2b|68|Amaranth Deep Purple
9f|2d|47|Crimson Strawberry
9f|36|45|Bright Lady
9f|41|4b|Charleston Cherry
9f|44|40|Tandoori Spice
9f|4d|65|Cherry Berry
9f|4e|3e|Boynton Canyon
9f|50|69|Malaga
9f|51|30|Bombay Brown
9f|52|33|Taisha Red
9f|54|3e|Ancient Copper
9f|55|2d|Warmth
9f|55|6c|Mulberry Mix
9f|56|3a|Persimmon Varnish
9f|5c|42|Sepia Skin
9f|5f|9f|Heath Spotted Orchid
9f|69|49|Foxfire Brown
9f|6d|66|Terra Rose
9f|6f|55|Whetstone Brown
9f|6f|62|Discretion
9f|70|60|Indian Reed
9f|71|5f|Toast
9f|72|50|Cinnamon Twist
9f|74|62|Kurumizome Brown
9f|78|a9|Karma Chameleon
9f|7a|93|Valerian
9f|7b|3e|Ochre Brown
9f|7b|a9|Virtuous
9f|7d|4f|Pyramid
9f|7e|53|Fantan
9f|80|46|Golden Harmony
9f|81|70|Beaver Kit
9f|83|03|Diarrhea
9f|84|6b|Toscana
9f|86|72|Amphora
9f|86|aa|Rhapsody
9f|88|63|Earthly Pleasures
9f|88|98|Merlin's Choice
9f|8d|57|Fallow Deer
9f|8d|7c|Silver Mink
9f|8d|89|Satellite
9f|8f|55|Green Ochre
9f|90|49|Off the Grid
9f|90|6e|Saddle Soap
9f|90|c1|Sand Verbena
9f|91|80|Bison Beige
9f|92|91|Tassel Taupe
9f|93|69|Chapter
9f|94|7d|Weather Board
9f|94|84|Stone Grey
9f|99|aa|Lavender Aura
9f|9b|84|Knock On Wood
9f|9b|9d|Shady Lady
9f|9c|99|Paloma
9f|9d|91|Dawn
9f|9f|9f|Cold Grey
9f|a0|9f|Hugh's Hue
9f|a0|a0|Su-Nezumi Grey
9f|a0|b1|Santas Grey
9f|a3|6c|Cocktail Olive
9f|a3|a7|Grey Chateau
9f|a9|be|Zen Blue
9f|ab|af|Heavy Blue Grey
9f|ab|b6|Scribe
9f|ad|b7|Shower
9f|af|6c|Necrotic Flesh
9f|b2|89|Easy Green
9f|b3|2e|Tree Frog
9f|b6|c6|Country Air
9f|b7|0a|Citrus
9f|b9|e2|Sky Blue
9f|ba|df|Pylon
9f|bb|da|Baltic Bream
9f|bd|ad|White Spruce
9f|c0|9c|Spruce Stone
9f|c3|ac|Catnap
9f|c8|b2|Lobaria Lichen
9f|c9|e4|Windsor Way
9f|d3|85|Gossip
9f|d9|d7|Blue Tint
9f|e0|10|Bryopsida Green
9f|e2|bf|Bright Sea Green
9f|e4|aa|Weekend Gardener
9f|fe|b0|Synthetic Mint
a0|02|5c|Deep Magenta
a0|04|98|Barney Purple
a0|20|f0|Singapore Orchid
a0|20|ff|Veronica
a0|25|2a|Haute Couture
a0|27|12|Tabasco
a0|36|23|Brick
a0|40|3e|Burning Bush
a0|45|0e|Powdered Coffee
a0|52|2d|Texas Ranger Brown
a0|58|22|Bright Bronze
a0|5c|17|Pumpkin Spice
a0|61|65|Pizza Pie
a0|63|a1|Royal Pretender
a0|68|56|J's Big Heart
a0|72|54|Ayrshire
a0|78|5a|Chamoisee
a0|82|8a|Tropical Orchid
a0|84|75|Wood Lake
a0|84|8a|Wallflower
a0|85|5c|Timber Beam
a0|8b|76|Mud-Dell
a0|8d|71|Tuscan Mosaic
a0|8d|a7|Nana
a0|8f|6f|Stonecrop
a0|90|b8|Wizard's Brew
a0|91|b7|Lush Mauve
a0|92|8b|Talavera
a0|94|84|Stone Terrace
a0|95|74|California Roll
a0|98|7c|Slate Brown
a0|9b|c6|Cosmo Purple
a0|9c|98|Flint Grey
a0|9e|c6|Opulent Violet
a0|9f|9c|Mountain Mist
a0|9f|cc|Indigo Child
a0|a0|82|Rigby Ridge
a0|a0|aa|Amethyst Haze
a0|a1|60|Gothic Revival Green
a0|a1|97|Riding Star
a0|a6|67|Always Apple
a0|ac|4f|Dark Citron
a0|ae|ad|Polaris
a0|ae|b8|How Handsome
a0|af|9d|Drizzle
a0|b0|a4|Powdered Gum
a0|b1|ae|Conch
a0|b7|a8|Leamington Spa
a0|b7|ad|Pistachio Ice Cream
a0|b7|ba|Blue By You
a0|bc|a7|Reeds
a0|bc|d0|Bush Viper
a0|bd|d9|Sky City
a0|be|da|Ice Cave
a0|bf|16|Gross Green
a0|c0|bf|Frosty Glade
a0|c9|cb|Aqua Mist
a0|cd|d9|Regent St Blue
a0|d4|04|Matcha Powder
a0|d6|b4|Nihilakh Oxide
a0|d8|ef|Sora Blue
a0|da|a9|Green Ash
a0|e6|ff|Winter Wizard
a0|fe|bf|Light Sea-Foam
a1|00|47|Cherry Plum
a1|17|29|Haute Red
a1|39|05|Carmim
a1|3d|2d|Edocha
a1|3f|49|Eternal Flame
a1|47|43|Roof Terracotta
a1|4c|3f|Arabian Red
a1|4d|3a|Burnt Brick
a1|53|25|Autumnal
a1|55|89|Purple Zergling
a1|5f|3b|Desert Soil
a1|61|4c|Deer Tracks
a1|65|5b|Cedar Wood
a1|67|17|Syhar Soil
a1|69|54|Verminlord Hide
a1|6c|94|Flowering Raspberry
a1|71|35|Hearth Gold
a1|72|49|Brown Sugar
a1|73|08|Barbarian Leather
a1|75|9c|Long Forgotten Purple
a1|77|91|Angel Heart
a1|79|17|Nataneyu Gold
a1|7a|74|Burnished Brown
a1|7a|83|Port Wine
a1|7b|4d|Caramelized Pecan
a1|7c|59|Agrellan Earth
a1|81|62|Mulled Cider
a1|83|8b|Evening Shadow
a1|88|99|Lively Light
a1|8b|5d|Shank
a1|8d|71|Arava
a1|93|61|Abura Green
a1|93|bf|Chive Flower
a1|95|83|Ironwood
a1|96|5e|Terran Khaki
a1|96|76|Artichoke Dip
a1|96|8c|Rock Slide
a1|96|9b|Artist's Shadow
a1|98|8b|Grey By Me
a1|98|a2|Lavender Lake
a1|99|86|Nomad
a1|9a|7f|Grey Olive
a1|9a|bd|Grape Gatsby
a1|9f|a5|Silver Sconce
a1|a0|b7|Royal Mile
a1|a1|4a|Reed Green
a1|a1|8f|Smoky Slate
a1|a2|bd|Blue Buzz
a1|a4|6d|Willow Leaf
a1|a5|8c|Solid Snake
a1|a5|a8|Baby Seal
a1|a6|a9|Ironbreaker Metal
a1|a8|67|Spanish Olive
a1|a8|d5|Whipped Violet
a1|a9|a8|Shiny Armor
a1|ad|92|Reseda
a1|ad|b5|Hit Grey
a1|af|a0|Grass Sands
a1|b0|be|Sensitivity
a1|b8|41|Clipped Grass
a1|b8|d2|Elizabeth Blue
a1|bc|a9|Attica
a1|bc|d8|Monologue
a1|bd|bf|Colonial Aqua
a1|bd|e0|Blair
a1|be|d9|Everlasting
a1|c4|a8|Aroma Garden
a1|c8|db|Piezo Blue
a1|ca|7b|Jade Lime
a1|ca|f1|Baby Blue Eyes
a1|cc|b1|Calculus
a1|cd|bf|Tareyton
a1|d0|e2|Light Sky Babe
a1|d4|cf|Touch of Turquoise
a1|d5|f1|Light Fish Pond
a1|d7|c9|Yucca Cream
a1|da|d7|Aqua Island
a1|dd|d4|Vidalia
a2|20|42|True Crimson
a2|24|2f|Samba
a2|24|52|Cherries Jubilee
a2|2d|a4|Purple Tone Ink
a2|34|5c|Bōtan
a2|3c|26|Rooibos Tea
a2|3d|54|Night Shadz
a2|48|57|Light Maroon
a2|4f|46|Sappanwood Incense
a2|57|4b|Etruscan Red
a2|57|68|Light Sappanwood
a2|5d|4c|Remington Rust
a2|64|6f|Dark Sakura
a2|65|3e|Earth
a2|66|66|Withered Rose
a2|72|53|Red Rock Falls
a2|74|b5|Purple Pride
a2|75|47|Red-Tailed-Hawk
a2|7c|4f|Crackled Leather
a2|7d|66|New Penny
a2|80|6f|Tattered Teddy
a2|81|6e|Red Earth
a2|84|40|Arrow Rock
a2|85|57|Banner Gold
a2|85|66|Water Wheel
a2|87|44|Yellow Sand
a2|87|61|Mother Lode
a2|87|76|Chanterelle Sauce
a2|8a|67|Sierra Foothills
a2|8b|36|Autumn Festival
a2|8b|7e|Soft Impala
a2|8c|82|Portobello
a2|91|71|Natural Bridge
a2|91|9b|Nirvana
a2|92|59|Desert Yellow
a2|93|71|Gristmill
a2|94|c9|Distinct Purple
a2|95|89|Zorba
a2|98|a2|Regal Violet
a2|99|9a|Sugar Tree
a2|99|9f|Sugilite
a2|9a|6a|Stilted Stalks
a2|9d|ad|Indolence
a2|9e|92|London Fog
a2|9e|cd|Wistful
a2|9f|46|Poplar
a2|a1|ac|Spun Pearl
a2|a2|a2|Grey Of Darkness
a2|a4|15|Fistfull of Green
a2|a5|7b|Dill Grass
a2|a5|80|Locust
a2|aa|b3|Chateau de Chillon
a2|ac|86|Cucumber Crush
a2|ad|b1|Pale Blue Grey
a2|ad|d0|Mild Blue Yonder
a2|af|70|Umbrella Green
a2|b0|a8|Life Aquatic
a2|b2|bd|Peace
a2|b6|b9|Cloud Blue
a2|b7|b5|Holly Glen
a2|b7|cf|Misted Eve
a2|b8|ce|Blue Garter
a2|b9|c2|Sterling Blue
a2|ba|cb|Always Blue
a2|ba|d2|Blue Horror
a2|ba|d4|Sky Pilot
a2|bf|fe|Pastel Blue
a2|c2|b0|Green Silk
a2|c2|d0|Airborne
a2|c3|48|Aerobic Fix
a2|c3|db|Metal Gear
a2|c6|d3|Blue Dam
a2|c7|a3|French Market
a2|cd|d2|Watermark
a2|cf|fe|Baby Blue
a2|d4|bd|Flowering Cactus
a2|d5|d3|Smooth Satin
a2|db|10|Moot Green
a2|eb|d8|Oasis Stream
a3|08|00|Gory Red
a3|17|13|Mechrite Red
a3|26|38|Alabama Crimson
a3|28|57|Vivacious
a3|28|b3|Pink Spyro
a3|4f|66|Raspberry Patch
a3|50|46|BBQ
a3|57|32|Very Terracotta
a3|5d|31|Copper Creek
a3|62|3b|Wet Adobe
a3|67|36|Hot Ginger
a3|6a|6d|Delhi Spice
a3|6e|51|Pecan Brown
a3|71|11|Golden Hind
a3|71|3f|Splinter
a3|72|98|Drama Queen
a3|73|36|Digger's Gold
a3|75|4c|Leather Chair
a3|75|5d|Tan Wagon
a3|75|8b|Upper Crust
a3|7d|5a|Cinnamon Crunch
a3|81|3f|Tausept Ochre
a3|87|6a|Sandal
a3|87|ac|Violet Eclipse
a3|89|61|Mukluks
a3|8b|93|Gothic Amethyst
a3|8c|6c|Desert Tan
a3|8d|6d|Tan 686A
a3|8e|6f|Maple Brown Sugar
a3|90|7e|Zinc Blend
a3|92|81|Rapid Rock
a3|99|77|Tallow
a3|9a|61|Zandri Dust
a3|9a|87|Napa
a3|a0|b3|Lazy Lavender
a3|a2|a1|Shadow of the Colossus
a3|a3|a2|Pale Chinese Ink
a3|a9|69|Sweet Pea
a3|a9|a6|Belgian Block
a3|ab|b8|Atelier
a3|b5|a6|Frosty Green
a3|b6|a4|Bamboo Shoot
a3|b8|ce|Flight Time
a3|b9|cd|Northern Pond
a3|ba|e3|Teclis Blue
a3|bb|cd|Heavenly Blue
a3|bb|da|Clear Lake Trail
a3|bc|3a|In the Tropics
a3|bc|db|Valor
a3|bd|9c|Spring Rain
a3|bd|d3|Angel Falls
a3|bf|cb|Frozen Tundra
a3|c1|ad|Cambridge Blue
a3|c5|7d|Opaline Green
a3|c5|db|Mr Frosty
a3|c8|93|Arcadian Green
a3|cc|c9|Eggshell Blue
a3|ce|27|Pêra Rocha
a3|d1|e8|Light Club Cruise
a3|d1|eb|Songbird
a3|d4|ef|Light Shimmer
a3|e2|dd|Spinnaker
a3|e3|ed|Blizzard Blue
a4|00|00|Dark Candy Apple Red
a4|12|47|Cerise
a4|13|13|Animal Blood
a4|29|2e|Pompeian Red
a4|33|4a|Scarlet Ribbons
a4|34|5d|Tree Peony
a4|42|a0|Aged Purple
a4|49|3d|Rusty Sword
a4|4a|56|Black Pudding
a4|64|22|Cockatrice Brown
a4|6f|44|Meerkat
a4|71|49|Cashew
a4|72|5a|Chic Brick
a4|75|52|Balthasar Gold
a4|75|b1|Bell Heather
a4|77|7e|Nostalgia Rose
a4|78|64|Mocha Mousse
a4|7b|ac|Design Delight
a4|7c|53|Burnt Butter
a4|7d|43|Wood Thrush
a4|80|3f|Gold Dust
a4|84|54|Leather Tan
a4|84|ac|Heather
a4|88|84|Attitude
a4|89|6a|Cortez Chocolate
a4|89|a3|Plum Perfume
a4|8a|80|Earthbound
a4|8b|73|Whole Wheat
a4|91|86|Casket
a4|94|3a|Shimmering Glade
a4|94|91|Fall Heliotrope
a4|95|93|Roman Snail
a4|96|88|Sorrel Felt
a4|96|90|Wet Clay
a4|96|91|Gustav
a4|97|75|Sponge
a4|98|87|Crockery
a4|9a|79|Wheat Tortilla
a4|9d|70|Westcar Papyrus
a4|9e|93|Smoky Day
a4|9e|97|Warm Granite
a4|9e|9e|Opal Grey
a4|9f|80|Wetland Stone
a4|9f|9f|Equilibrium
a4|a1|91|Little Valley
a4|a2|98|Tin Man
a4|a5|82|Dark Envy
a4|a7|a4|Stepping Stone
a4|a8|4d|Olive Reserve
a4|ab|bf|Lilac Time
a4|ad|b0|Gull Grey
a4|ae|77|Tarragon
a4|af|9e|Tranquil Green
a4|af|cd|Echo Blue
a4|b0|c4|Innuendo
a4|b8|8f|Norway
a4|ba|8a|Forest Tapestry
a4|be|5c|Light Olive Green
a4|bf|20|Pea
a4|bf|ce|Sea Breeze
a4|c1|61|Jungle Juice
a4|c3|d7|Blue Bows
a4|c4|8e|Cos
a4|c6|39|Android Green
a4|c7|c8|Twin Cities
a4|cd|cc|Mystery
a4|d2|e0|French Pass
a4|d4|ec|Light Deluxe Days
a4|db|e4|Light Bluish Water
a4|dc|e6|Charlotte
a4|dd|e9|Light Piccolo
a4|dd|ed|Non-Photo Blue
a4|e3|b3|Overtone
a4|e4|fc|Ganon Blue
a4|f4|f9|Waterspout
a5|00|55|Violet Red
a5|0b|5e|Banafsaji Purple
a5|23|50|Granita
a5|29|39|Dòu Shā Sè Red
a5|2a|24|Fresh Auburn
a5|2a|2a|Harissa Red
a5|2a|2f|Red Brown
a5|37|56|Cranberry Sauce
a5|3b|3d|Scarlet Past
a5|40|49|Floriography
a5|4e|37|Texas Heatwave
a5|52|e6|Lightish Purple
a5|5a|f4|Lighter Purple
a5|64|7e|Strawberry Mousse
a5|65|31|Mai Tai
a5|65|4e|Ruddy Oak
a5|69|4f|Hot Cacao
a5|6e|75|Turkish Rose
a5|71|64|Blast-Off Bronze
a5|7c|5b|Café Au Lait
a5|7e|52|False Puce
a5|82|3d|Indian Brass
a5|84|59|Cumin
a5|88|7e|Magic Malt
a5|8b|34|Sullen Gold
a5|8b|6f|Mongoose
a5|8d|7f|Stucco
a5|8e|61|Rattan
a5|8f|73|Snuggle Pie
a5|8f|85|Tanglewood
a5|93|44|18th Century Green
a5|95|64|Tea Leaf Brown
a5|95|8f|Etherea
a5|96|9c|Lavender Lily
a5|97|5b|Faded Khaki
a5|97|84|Malta
a5|97|88|Tuffet
a5|98|88|Time Capsule
a5|98|a0|Mystique
a5|98|c7|Grape Arbor
a5|99|7c|Harvest Dance
a5|9a|59|Iyanden Darksun
a5|9c|8d|Sacred Vortex
a5|9c|9b|Boiling Mud
a5|a1|92|Wooster Smoke
a5|a3|91|Cement
a5|a4|95|Whale Watching
a5|a5|02|Jīn Sè Gold
a5|a5|42|Camo Green
a5|a5|a5|Rainy Grey
a5|a7|96|Sunset Meadow
a5|a8|8f|Bud
a5|a9|43|Delightful Camouflage
a5|a9|9a|Alpine Summer
a5|a9|b2|Mischka
a5|ab|b6|Dutch Jug
a5|ac|b7|Transformer
a5|ad|44|Sphagnales Moss
a5|ad|bd|Snub
a5|ae|9f|Moonwort
a5|b1|45|Elysian Green
a5|b2|a9|Dreamcatcher
a5|b2|aa|Aqua Grey
a5|b2|b7|Special Delivery
a5|b2|c7|Silk Sox
a5|b3|cc|Kentucky Blue
a5|b4|b6|Marine Layer
a5|b4|c6|Posey Blue
a5|b5|46|Azeitona
a5|b6|cf|Minuet
a5|b8|c5|Hazy Daze
a5|b8|d0|Cashmere Blue
a5|ba|93|Byakuroku Green
a5|be|8f|Praying Mantis
a5|c1|b6|Folk Tales
a5|c5|d9|Frozen Blue
a5|c7|df|Sea Cliff
a5|c9|70|Alverda
a5|ca|d1|Sky Chase
a5|cb|66|Be Spontaneous
a5|cd|e1|Blue Calico
a5|ce|d5|Wave
a5|ce|e8|Cielo
a5|ce|ec|Sail
a5|cf|d5|Plume
a5|d0|af|Merrylyn
a5|d0|c6|Phosphorus
a5|d6|10|Sabz Green
a5|d7|85|Feijoa
a5|d7|b2|Frugal
a5|d8|cd|Whirlpool
a5|db|e3|Ice Pack
a5|db|e5|Light Aqua Clear
a5|dd|ea|Light July
a5|fb|d5|Pale Turquoise
a6|00|44|Rondo of Blood
a6|0e|46|Grated Beet
a6|2e|30|Drive-In Cherry
a6|38|64|Valentine's Day
a6|3a|79|Maximum Red Purple
a6|41|37|Cherry Race
a6|4f|82|Dahlia Mauve
a6|50|52|Red Rock
a6|56|48|Crail
a6|66|46|Amber Brown
a6|6c|47|Vintage Pottery
a6|6e|49|Slick Mud
a6|6e|4a|Bran
a6|6e|68|Warm Wassail
a6|6e|7a|Black Elder
a6|6f|b5|Soft Purple
a6|72|83|Never Forget
a6|75|fe|Purple Illusionist
a6|7a|45|Driftwood
a6|7b|50|French Beige
a6|7b|5b|Tuscan Soil
a6|7c|08|Hornet Yellow
a6|7e|4b|Look At Me!
a6|80|64|Medium Wood
a6|81|4c|Hamster Fur
a6|84|7b|South Rim Trail
a6|89|3a|Peanut Brittle
a6|89|66|Coffee With Cream
a6|8a|6d|Tannin
a6|8e|6d|Rodeo Roundup
a6|92|7f|Lap Dog
a6|93|7d|Clippership Twill
a6|94|25|Rapeseed Oil
a6|97|8a|Earl Grey
a6|97|9a|Laura
a6|97|a7|Windsor Haze
a6|99|7a|Olive Chutney
a6|9a|5c|Loveliest Leaves
a6|9f|8d|Apple Hill
a6|a1|9b|Missouri Mud
a6|a1|d7|Simply Violet
a6|a2|3f|Machine Green
a6|a6|60|Rickrack
a6|a6|a6|Quicksilver
a6|a8|65|Elf Slippers
a6|a8|97|Wandering Willow
a6|ab|9b|Moorland
a6|ae|aa|Silver Screen
a6|ae|bb|Berry Chalk
a6|b2|9a|Banksia
a6|b2|a4|Montezuma Hills
a6|b4|c5|Suds
a6|ba|d1|Seascape Blue
a6|ba|df|Lavender Phlox
a6|bc|e2|Blue Lips
a6|be|a6|Bryophyte
a6|be|e1|Artesian Pool
a6|c8|75|Light Moss Green
a6|c8|c7|Zenith Heights
a6|c9|e3|Template
a6|cd|91|Chenille
a6|d2|92|Nature's Delight
a6|d5|d0|Sinbad
a6|d6|08|Vivid Lime Green
a6|d6|c3|Southern Belle
a6|da|d0|Lolly Ice
a6|e7|ff|Fresh Air
a6|fb|b2|Light Mint Green
a7|32|11|Enfield Brown
a7|33|40|American Beauty
a7|38|36|Lobster Brown
a7|39|40|Jules
a7|54|29|Garfield
a7|55|02|Windsor Brown
a7|59|49|Bruschetta
a7|5a|4c|Santa Fe Sunset
a7|5c|3d|Brick-A-Brack
a7|5d|67|Mauvewood
a7|5e|09|Raw Umber
a7|67|a2|Iris Orchid
a7|6b|cf|Rich Lavender
a7|6f|1f|Buckthorn Brown
a7|75|2c|Hot Toddy
a7|75|72|Dusky Haze
a7|76|93|Poise
a7|7c|53|Apple Seed
a7|81|99|Bouquet
a7|84|90|Lacy Mist
a7|86|58|Chicory
a7|8a|50|Graceful Gazelle
a7|8a|59|Fall Harvest
a7|8b|71|Mesa Tan
a7|8c|8b|Delicate Brown
a7|8f|af|Revered
a7|90|69|Rattan Basket
a7|97|81|Bronco
a7|98|c2|Ode to Purple
a7|99|54|Gremlin
a7|99|94|Twilight Taupe
a7|9b|5e|Tallarn Sand
a7|9b|82|Twill
a7|9b|83|Windmill Park
a7|9b|8a|City Loft
a7|9c|81|Buffhide
a7|9c|8e|Foggy Night
a7|9d|8d|Stonehenge Greige
a7|9f|5c|Sulfuric Yellow
a7|9f|92|Abbey Road
a7|a0|7e|Hillary
a7|a0|9f|Ghostly
a7|a1|9e|Pewter Grey
a7|a3|bb|Awaken
a7|a4|9f|Ashlite
a7|a6|9d|Foggy Grey
a7|a6|a3|Actor's Star
a7|a7|99|Backdrop
a7|ae|9e|Mountain Lichen
a7|ae|a5|Light Drizzle
a7|b0|cc|Lovely Lilac
a7|b0|d5|Calm Interlude
a7|b1|91|Family Tree
a7|b3|b5|Winter Morning Mist
a7|b3|b7|Yreka!
a7|b7|ca|Uniform
a7|b8|c4|Overcast Sky
a7|c2|eb|Sky High
a7|c5|ce|Salt Spray
a7|c7|96|Nile Green
a7|c9|eb|Island Light
a7|ca|c9|Impressionist Blue
a7|cf|cb|Blue Angora
a7|d3|b7|Glenwood Green
a7|d7|ff|Malmö FF
a7|d8|de|Crystal
a7|d8|e4|Light Baby Motive
a7|db|ed|Hint of Mizu
a7|e0|c2|Mountain Mint
a7|e1|42|Dynamic Green
a7|e8|d3|Sweet Aqua
a7|f4|32|Green Lizard
a7|fc|00|Spring Bud
a7|ff|b5|Light Seafoam Green
a8|00|20|Castlevania Heart
a8|0e|00|Natural Leather
a8|10|00|Kid Icarus
a8|10|2a|Hong Kong Taxi
a8|1c|07|Rufous
a8|2a|70|Carroburg Crimson
a8|37|31|Sweet Brown
a8|3c|09|Rust
a8|3e|4c|Red Licorice
a8|3e|6c|Cactus Flower
a8|41|5b|Light Burgundy
a8|45|3b|Red Revival
a8|47|34|Barbarossa
a8|4a|49|Pasadena Rose
a8|51|43|Indian Summer
a8|51|6e|China Rose
a8|53|35|Orange Roughy
a8|55|33|Vesuvius
a8|62|17|Honey Ginger
a8|69|65|Sappanwood Perfume
a8|71|5a|Hazelnut
a8|76|78|Handmade Red
a8|79|00|Bronze
a8|7c|a0|Usu Pink
a8|7d|c2|Wisteria
a8|7f|5f|S'mores
a8|85|b5|Purple Statice
a8|89|05|Dark Mustard
a8|8b|66|Old Leather
a8|8e|8b|Ash Hollow
a8|8f|59|Dark Sand
a8|94|6b|Sweet Sparrow
a8|98|87|Kiln Dried
a8|98|9b|Sahara Dust
a8|99|83|Wooden Peg
a8|99|e6|Dull Lavender
a8|9a|8e|Cobblestone
a8|9a|91|Goat
a8|9b|9c|Violet Dawn
a8|9c|94|Atmosphere
a8|9d|ac|Goose Wing Grey
a8|a4|95|Greyish
a8|a4|98|Paving Stone
a8|a4|a1|Caboose
a8|a7|98|Silver Lustre
a8|a8|a8|Uniform Grey
a8|a9|a8|Dark Medium Grey
a8|a9|ad|Chrome Aluminum
a8|ac|b7|Jacaranda Light
a8|b0|ae|Puritan Grey
a8|b0|b2|Mirror Mirror
a8|b4|53|Green Banana
a8|b5|04|Mustard Green
a8|b5|9e|Salvia
a8|b9|89|Grant Wood Ivy
a8|bb|a2|Smoke Green
a8|bb|ba|Blue Willow
a8|bf|8b|Ground Cover
a8|bf|93|Japanese Horseradish
a8|bf|cc|Peace River
a8|c0|bb|Harbour Grey
a8|c0|ce|Graceful
a8|c3|aa|Spring Leaves
a8|c3|bc|Yān Hūi Smoke
a8|c7|4d|Acid Candy
a8|d2|75|Livery Green
a8|d3|e1|Light Blue Glint
a8|d4|b0|Goddess of Dawn
a8|e4|a0|Grape Green
a8|ff|04|Wolf Lichen
a9|03|08|Darkish Red
a9|20|3e|Deep Carmine
a9|40|64|Rouge Like
a9|52|49|Maine-Anjou Cattle
a9|56|1e|Sienna
a9|56|8c|Meadow Mauve
a9|58|6c|Splatter
a9|5c|3e|Gladiator Leather
a9|5c|68|Deep Puce
a9|62|32|Clove Dye
a9|6a|50|Cedar Plank Salmon
a9|71|64|Tangier
a9|76|5d|Clay Court
a9|76|73|Cinnamon Diamonds
a9|78|98|Wonder Wish
a9|84|4f|Muddy Waters
a9|87|5b|Partridge Knoll
a9|87|6a|Caramel Sundae
a9|89|81|Pink Moroccan
a9|89|8d|Coffee Rose
a9|8a|6b|Confidence
a9|8b|af|Regal Orchid
a9|8c|a1|Mauve Musk
a9|8d|36|Reef Gold
a9|90|58|Golden Griffon
a9|94|7a|Cornstalk
a9|95|92|Cortex
a9|98|91|Putty Pearl
a9|99|8c|Porcelain Figurines
a9|9a|86|Grullo
a9|9a|89|Diversion
a9|9a|8a|Parador Inn
a9|9b|a7|Lavender Illusion
a9|9b|a9|Seeress
a9|9d|9d|Nobel
a9|9e|54|Organic Matter
a9|9f|96|Simmering Smoke
a9|9f|97|Winter Nap
a9|9f|ba|Fragrant Satchel
a9|a0|a9|Aluminium Powder
a9|a4|50|Desert Locust
a9|a4|82|Eastlake Olive
a9|a4|91|Olive Pit
a9|a5|c2|Fife
a9|a6|94|Lich Grey
a9|a7|97|Amazing Boulder
a9|a8|a8|Nosferatu
a9|aa|ab|Quartz Sand
a9|ad|c2|Icelandic Blue
a9|af|99|Green Spring
a9|af|aa|Pigeon
a9|b0|b4|Brilliant Silver
a9|b4|9a|Mow the Lawn
a9|b9|b5|Bidwell Blue
a9|ba|9d|Laurel Green
a9|ba|dd|Wisp
a9|bd|b1|Silt Green
a9|bd|bf|Grey Grain
a9|be|70|Tan Green
a9|c0|1c|Bahia
a9|c0|8a|Shrubbery
a9|c0|cb|Winter Sky
a9|c1|c0|Glacier Blue
a9|c4|a6|Green Bark
a9|c4|c4|Blende Blue
a9|ca|da|Corydalis Blue
a9|cc|db|Rain Dance
a9|ce|aa|Mint Circle
a9|d1|71|Bilious Green
a9|d1|d7|Aqua Frost
a9|d3|9e|Pistachio Green
a9|f9|71|Lima
aa|00|00|Heartbeat
aa|00|11|Chorizo
aa|00|22|Incarnadine
aa|00|33|Hot Lava
aa|00|55|Shy Guy Red
aa|00|aa|Purple Potion
aa|00|bb|Heliotrope Magenta
aa|00|cc|Ferocious Fuchsia
aa|00|ff|Digital Violets
aa|0a|27|Barbados Cherry
aa|11|00|Cave Painting
aa|11|11|Büchel Cherry
aa|11|22|Ecstatic Red
aa|11|55|Plum Perfect
aa|11|66|Plum Paradise
aa|11|88|Blissful Berry
aa|18|2b|Salsa
aa|23|ff|Cool Purple
aa|27|04|Rust Red
aa|33|33|Raging Raisin
aa|33|44|Toasted Truffle
aa|36|46|Roses are Red
aa|38|1e|Chinese Night
aa|40|69|Medium Ruby
aa|42|3a|Rum Punch
aa|44|00|Pepperoni
aa|44|33|Chipolata
aa|44|88|Romantic Rose
aa|44|dd|Magenta Affair
aa|4c|8f|Plum Dust
aa|4f|37|Suzume Brown
aa|4f|44|Squig Orange
aa|55|00|Tijolo
aa|55|33|Flat Earth
aa|55|55|Bretzel Brown
aa|55|aa|Orchid Dottyback
aa|55|ff|Vega Violet
aa|5e|5a|Tuscan Clay
aa|66|00|Butter Fudge
aa|66|11|Ancient Brandy
aa|66|44|Amazonian
aa|67|72|Berry Crush
aa|68|64|Melon Twist
aa|69|88|Cure All
aa|76|91|Cipher
aa|77|11|Falafel
aa|77|33|Buff Leather
aa|77|66|Sawshark
aa|79|82|Mauve Madness
aa|7d|89|Silken Raspberry
aa|83|44|Walnut Shell
aa|83|8b|Natural Spring
aa|85|4a|Kiss Candy
aa|87|36|Pale Fallen Leaves
aa|88|05|Golden Palm
aa|88|22|Super Gold
aa|88|33|Rich Gold
aa|88|80|Bedford Brown
aa|8c|bc|East Side
aa|8f|7a|Cocoloco
aa|90|76|Pioneer Village
aa|90|7d|Natural
aa|91|ae|Knight's Tale
aa|94|99|Persian Pastel
aa|97|93|Smoky Sunrise
aa|98|55|Burnished Gold
aa|98|a9|Pink Orthoclase
aa|99|11|Vegan Villain
aa|9c|8b|Light Truffle
aa|9f|96|String
aa|9f|b2|Grapeade
aa|a3|80|Inglenook Olive
aa|a3|88|Northgate Green
aa|a4|92|Aldabra
aa|a5|83|Neutral Green
aa|a6|62|Wholemeal Cookie
aa|aa|00|Honey and Thyme
aa|aa|55|Spinach Banana Smoothie
aa|aa|aa|Dhūsar Grey
aa|aa|c4|Cosmic Sky
aa|aa|ff|Shy Moment
aa|ae|9a|Desert Pear
aa|af|bd|Eclectic
aa|b5|b7|Nautical Star
aa|b5|b8|Casper
aa|bb|99|Ash Tree
aa|bb|aa|Rockfall
aa|bb|cc|Wood Pigeon
aa|be|49|Money Banks
aa|c0|ad|Young Gecko
aa|c2|a1|Pale Mint
aa|c4|d4|Thunder Chi
aa|c7|c1|Peppermint Pie
aa|cc|b9|Bird's Egg Green
aa|cc|bb|Greywacke
aa|ce|bc|Mist Green
aa|cf|53|Young Green Onion
aa|d0|ba|Taffy Twist
aa|d5|d9|Pool Side
aa|d5|db|Clear Water
aa|dc|cd|Prism
aa|dd|00|Slimer Green
aa|e1|ce|Meristem
aa|f0|d1|Magic Mint
aa|ff|00|Lime Candy Pearl
aa|ff|32|Lime
aa|ff|55|Irradiated Green
aa|ff|aa|Creamy Mint
aa|ff|ee|Blister Pearl
aa|ff|ff|Affen Turquoise
ab|00|40|Screamer Pink
ab|12|39|Rouge
ab|34|75|Fuchsia Red
ab|38|1f|Chinese Brown
ab|42|10|Donkey Kong
ab|44|6b|Fuchsia Flock
ab|48|5b|Pink Quince
ab|49|5c|Hippie Pink
ab|4b|52|English Red
ab|4c|3d|Wilted Brown
ab|4d|50|Red Leather
ab|4e|52|Young Redwood
ab|4e|5f|Rose Vale
ab|4f|41|Hot Sauce
ab|52|36|Pico Earth
ab|60|57|Dried Tomatoes
ab|61|34|Corn Snake
ab|68|19|Thai Curry
ab|69|53|Soho Red
ab|6e|67|Coral Tree
ab|6f|60|Amaretto
ab|6f|73|Pomegranate Tea
ab|71|00|Cookie Dough
ab|7e|4c|Tan Brown
ab|7f|5b|Roman Brick
ab|82|74|Hickory Branch
ab|85|08|Chestnut Gold
ab|85|6f|Tawny Brown
ab|86|59|Bread Basket
ab|87|8d|Mask
ab|89|53|Teak
ab|8a|68|Earthly Delight
ab|8c|72|Roasted Coconut
ab|8d|3f|Luxor Gold
ab|8f|55|Gathering Field
ab|90|04|Bark Sawdust
ab|92|7a|Saddle Up
ab|92|b3|Glossy Grape
ab|93|68|Sweet Earth
ab|93|78|Sauteed Mushroom
ab|96|73|Quail Valley
ab|96|7b|Night Tan
ab|97|69|Village Crier
ab|98|95|Sphinx
ab|98|a9|Heliotrope Grey
ab|9a|1c|Lucky
ab|9a|6e|Sunbaked Adobe
ab|9b|9c|Coffee Custard
ab|9b|a5|Laylock
ab|9b|bc|Purple Springs
ab|9d|89|Creek Bay
ab|9d|9c|Stellar Mist
ab|9f|89|The Blarney Stone
ab|a4|4d|Lentil Sprout
ab|a7|98|Abbey Stone
ab|a8|9e|Hot Stone
ab|a9|d2|Monastic
ab|aa|97|Amazon Vine
ab|af|ae|Mirage Grey
ab|b3|9e|Gargoyle
ab|b5|c4|Bluebeard
ab|b6|d7|Lilac Sachet
ab|b7|90|Casa Verde
ab|b9|d7|Conclave
ab|be|c0|Alpine Haze
ab|be|d0|Rendezvous
ab|c0|bb|Garden Gazebo
ab|c1|a0|Saxon
ab|c8|d8|Sonata
ab|ca|ea|Baby Bunting
ab|cd|ee|Pale Cornflower Blue
ab|cd|ef|Alphabet Blue
ab|ce|d8|Hisoku Blue
ab|d3|5d|Lime Lizard
ab|d3|db|Iced Aqua
ab|d5|dc|Light Bathing
ab|d6|de|Light Sea Spray
ab|dc|ee|Spring Shower
ab|dd|f1|Hint of Spritzig
ab|de|e4|Vandermint
ab|df|8f|Stem Green
ab|e3|c9|Fabulous Find
ab|e3|de|Silent Ripple
ac|0c|20|Gaharā Lāl
ac|0e|2e|Tango Red
ac|1d|b8|Barney
ac|1e|44|French Wine
ac|32|35|Red Ink
ac|3a|3e|Red Gumball
ac|3e|5f|Heart's Desire
ac|49|5c|Cherry On Top
ac|4b|55|Garnet Rose
ac|4f|06|Cinnamon Bun
ac|51|2d|Rose of Sharon
ac|54|5e|Grenadine
ac|5e|3a|Fragrant Cloves
ac|66|7b|Apple II Rose
ac|6b|29|Sudan Brown
ac|72|af|Berry Burst
ac|74|34|Deer Leather
ac|7c|00|Brown Butter
ac|7e|04|Mustard Brown
ac|80|44|Rare Find
ac|81|81|Jupiter Brown
ac|82|62|Sylvaneth Bark
ac|86|74|Homestead
ac|86|a8|Dusty Lavender
ac|87|60|Dark Sepia
ac|8a|56|Limed Oak
ac|8c|8c|Mauve Day
ac|8d|74|Cantankerous Coyote
ac|91|b5|Superstitious
ac|93|62|Dark Beige
ac|98|77|Croque Monsieur
ac|98|84|Quicksand
ac|98|9c|Pincushion
ac|9a|7e|Smallmouth Bass
ac|9b|9b|Powdered Brick
ac|9d|64|Whispering Grasslands
ac|a0|8d|Dried Grass
ac|a4|95|Mercer Charcoal
ac|a4|9a|Warm Grey Flannel
ac|a6|90|Lodgepole Pines
ac|a8|cd|Violet Mix
ac|ac|e6|Maximum Blue Purple
ac|ad|ad|Flagstone
ac|ae|a9|Silver Chalice
ac|af|95|Olive Sprig
ac|b3|c7|Perseverance
ac|b4|ab|Southern Pine
ac|b5|97|Norwich Green
ac|b6|b2|Periglacial Blue
ac|b7|5f|Gooseberry Fool
ac|b7|8e|Autumn Meadow
ac|b7|a8|Graceful Green
ac|b7|b0|Cyprus Spring
ac|b8|c1|Glen Falls
ac|b9|9f|Winter Squash
ac|b9|e8|Perano
ac|ba|8d|Gardening
ac|bb|0d|Snot
ac|bd|a1|Pale Sage
ac|bd|b1|Rainsong
ac|bf|60|Middle Green Yellow
ac|bf|69|Light Olive
ac|c2|d9|Cloudy Blue
ac|c7|e5|Water Wash
ac|c9|b2|Gum Leaf
ac|d6|db|Light Jellyfish Blue
ac|d7|c8|Scud
ac|dc|e7|Light Washed Blue
ac|dc|ee|Hint of Bright Spark
ac|dd|af|Big Spender
ac|df|ad|Vers de Terre
ac|df|dd|Blue Light
ac|e1|af|Celadon
ac|e5|ee|Uranus
ac|ff|fc|Frostbite
ad|03|de|Vibrant Purple
ad|0a|fd|Bright Violet
ad|14|00|Red Gore
ad|2a|2d|Cross My Heart
ad|43|79|Mystic Maroon
ad|4b|53|Carmine Carnation
ad|4d|8c|Purple Orchid
ad|4e|1a|Island Monkey
ad|52|2e|Red Stage
ad|54|6e|Pink Parakeet
ad|5d|5d|Italian Villa
ad|5e|99|Radiant Orchid
ad|62|42|Mars Brown
ad|6d|68|Light Mahogany
ad|6d|7f|Heather Rose
ad|6e|a0|Mulberry Bush
ad|6f|69|Copper Penny
ad|71|71|Horizon Glow
ad|73|5a|Arizona Clay
ad|78|5c|Tobey Rattan
ad|7c|35|Billet
ad|7d|40|Kaolin
ad|7d|76|Ferris Wheel
ad|80|47|Bungalow Gold
ad|80|68|Cuddlepot
ad|84|58|Cool Copper
ad|8a|3b|Alpine
ad|8b|75|Praline
ad|90|0d|Manure
ad|91|6c|Armagnac
ad|93|5b|Wheatacre
ad|94|66|Gathering Place
ad|94|7b|Bungalow Brown
ad|96|9d|Legendary Lilac
ad|97|69|Osso Bucco
ad|97|73|Jute
ad|9a|5d|Katmandu
ad|9e|4b|Queen Palm
ad|9e|87|Sheepskin Gloves
ad|9f|93|Simply Taupe
ad|a2|ce|Puturple
ad|a3|96|Pure Cashmere
ad|a3|bb|Decanter
ad|a5|87|Stone
ad|a5|a3|Maculata Bark
ad|a7|c8|Instigate
ad|aa|b1|Sylph
ad|ac|7c|Stuffed Olive
ad|ac|84|New Bamboo
ad|ad|ad|Pale Dull
ad|af|9c|Still
ad|af|af|Aluminum Sky
ad|af|ba|Pantomime
ad|af|bd|Polar Mist
ad|b0|b4|Silver Charm
ad|b1|c1|Fragrant Wand
ad|b6|b9|Smoke Cloud
ad|b8|64|Beach Bag
ad|ba|e3|French Lilac Blue
ad|be|d3|Skyway
ad|bf|c8|Bright Chambray
ad|c0|d6|Blue Thistle
ad|c3|b4|Aqua Foam
ad|c5|c9|Blue Spruce
ad|c6|d3|Twinkle
ad|c8|c0|Copenhagen
ad|c9|79|Sour Face
ad|cf|43|Lyceum (Was Lycra Strip)
ad|d0|e0|Flemish Blue
ad|d2|e3|Light Bobby Blue
ad|d8|e1|Light Blue Stream
ad|d8|e6|Light Blue
ad|d9|d1|Scandal
ad|de|e5|Sky Cloud
ad|df|ad|Frozen Moss Green
ad|ea|ce|Martian Haze
ad|f8|02|Lemon Green
ad|ff|2f|Chestnut Shell
ae|0c|00|Mordant Red 19
ae|20|29|Upsdell Red
ae|2f|48|Amore
ae|3d|3b|Eye Of Newt
ae|49|30|Red Terra
ae|58|83|Guppy Violet
ae|5a|2c|Stirland Battlemire
ae|6a|a1|Victorian Valentine
ae|6c|37|Tanooki Suit Brown
ae|70|4f|Autumn Umber
ae|71|81|Shade of Mauve
ae|72|50|Hazel
ae|75|43|Exotic Life
ae|75|79|Vindaloo
ae|7c|4f|Loquat Brown
ae|85|6c|Tawny Birch
ae|87|74|Café Renversé
ae|8b|0c|Yellow Brown
ae|8b|64|Dubbin
ae|8c|8e|Woodrose
ae|8d|7b|Magnitude
ae|8e|2c|Green Sulphur
ae|8e|5f|Alpha Gold
ae|8f|60|Wet Sand
ae|90|41|Turmeric
ae|92|74|Buffalo Bill
ae|93|5d|Sconce
ae|94|a6|Grape Soda
ae|94|ab|London Hue
ae|95|50|Obsession
ae|95|7c|Hutchins Plaza
ae|97|69|Gold Canyon
ae|98|aa|Lilac Luster
ae|99|6b|Cool Camel
ae|99|d2|Biloba Flower
ae|a1|32|Martian
ae|a2|6e|Autumn Sage
ae|a2|95|Natural Stone
ae|a3|93|Plaza Taupe
ae|a4|c1|Fairy Wand
ae|a6|92|Spray Green
ae|ab|9a|Olive It
ae|ab|a5|City Tower
ae|ac|a1|Pussywillow Grey
ae|ac|ac|Duct Tape Grey
ae|ad|5b|Palm Frond
ae|ad|93|Applegate Park
ae|ad|96|Photo Grey
ae|ad|ad|Industrial Age
ae|ae|ad|Bombay
ae|ae|ae|Smoke Screen
ae|ae|b7|Love-Struck Chinchilla
ae|af|bb|Canyon Cloud
ae|b2|b5|High Rise
ae|b5|c7|Spacious Sky
ae|b9|bc|Lake Placid
ae|bb|c1|Blue Heather
ae|bb|d0|Sailor Boy
ae|bd|a8|Fresh Thyme
ae|c2|a5|Nymph Green
ae|c5|71|Old Lime
ae|c6|cf|Roquefort Blue
ae|c9|ea|Breezy
ae|c9|eb|Tropical Blue
ae|ca|c8|Seaport Steam
ae|cb|e5|Blue Veil
ae|d0|c9|Cassiopeia
ae|d4|d8|Light Imagine
ae|d7|ea|Ariel
ae|dd|d3|Jaded Clouds
ae|e0|e4|Opal
ae|fd|6c|Light Lime
ae|ff|6e|Key Lime
af|2f|0d|Rusty Red
af|40|35|Medium Carmine
af|40|3c|Pale Carmine
af|41|3b|Glitzy Red
af|45|44|Redtail
af|59|3e|Brown Rust
af|59|41|Glowing Firelight
af|5b|46|Iron Ore
af|6c|3e|Bourbon
af|6c|67|Canyon Rose
af|6f|09|Caramel
af|7b|57|Dark Brown Sugar
af|87|51|Camel Spider
af|88|4a|Havana Cigar
af|8a|5b|It Works
af|8b|a8|Voila!
af|8e|a5|Palisade Orchid
af|92|94|Deauville Mauve
af|92|bd|Lavender Earl
af|93|7d|Sandrift
af|94|68|Imagine
af|94|83|Warm Taupe
af|96|90|Rose Mauve
af|98|41|Golden Olive
af|98|94|Lavenbrun
af|99|68|Veranda Gold
af|9a|73|Toasted Sesame
af|9a|7e|Incense
af|9a|91|Quarry Quartz
af|a4|90|Bay Area
af|a7|8d|Olive Grey
af|a8|8b|Bland
af|a8|92|Elder Creek
af|a8|a9|Smoky Mountain
af|a8|ae|Angel Aura
af|a9|7d|Thimbleberry Leaf
af|a9|84|Green Grey Mist
af|a9|af|Iced Tulip
af|ab|97|Moss Grey
af|ab|a0|Big Band
af|af|5e|Palm
af|b1|b4|Harbour Fog
af|b2|a7|Pebble Walk
af|b2|c4|Timeless Lilac
af|b4|b6|Astroscopus Grey
af|bb|42|Hopscotch
af|bd|d9|Pigeon Post
af|c0|9e|Garden Pond
af|c1|82|Caper
af|c1|95|Harmonious
af|c1|bf|Sea Glass
af|c3|bc|Droplet
af|c4|d9|Ballet Blue
af|c7|bf|Crystal Oasis
af|c9|c0|Nadia
af|cb|e5|Featherbed
af|cf|e0|Light Sky Bus
af|d1|c4|Lester
af|d5|d8|Light Continental Waters
af|d7|7f|Wasabi
af|da|df|Daly Waters
af|dd|cc|Brook Green
af|e0|ef|Hint of Blue Booties
af|e3|d6|Ice Cube
af|eb|de|Waterwings
af|ee|e1|Mint Tea
af|ee|ee|Mint Macaron
af|ff|01|Lime Acid
b0|00|3c|Bindi Red
b0|01|49|Raspberry
b0|05|4b|Purplish Red
b0|1b|2e|Christmas Red
b0|30|60|Blood Thorn
b0|30|6a|Rich Maroon
b0|4e|0f|Skrag Brown
b0|5c|52|Giant's Club
b0|61|44|Georgia Clay
b0|64|55|Aragon
b0|65|00|Ginger
b0|68|80|Crushed Raspberry
b0|6a|40|Ebony Lips
b0|70|5d|Clovedust
b0|70|69|Brick Dust
b0|72|4a|Burnt Almond
b0|74|26|Hamtaro Brown
b0|79|39|Durian
b0|79|a7|Victorian Violet
b0|80|7a|Night Rose
b0|82|72|Pink Earth
b0|85|b7|African Violet
b0|86|93|Keepsake Rose
b0|87|9b|Orchid Haze
b0|88|43|Butterscotch Ripple
b0|88|5a|Apple Cinnamon
b0|8a|61|Caramel Kiss
b0|8d|57|Bronze Treasure
b0|8e|08|Cobra Leather
b0|8e|51|Mustard Gold
b0|8f|42|Pirate's Hook
b0|8f|7f|Coyote Tracks
b0|90|7c|Mazzone
b0|90|80|Roebuck
b0|90|c7|Fleur-De-Lis
b0|92|7a|Rikyūshira Brown
b0|97|37|Mana
b0|97|6d|Emperor's Gold
b0|98|70|Bodhi Tree
b0|99|94|Tricycle Taupe
b0|9a|4f|Spanish Gold
b0|9a|77|Dry Starfish
b0|9d|7f|Sand Pebble
b0|9f|84|Gnu Tan
b0|9f|8f|Cuppa Coffee
b0|9f|ca|Purple Rose
b0|a5|82|Woolen Vest
b0|a5|96|Tranquil Taupe
b0|a6|76|Windy Meadow
b0|a6|7e|Sedia
b0|a8|95|Linseed
b0|a8|ad|Stamina
b0|a9|99|Greige
b0|a9|9f|Cloudy Desert
b0|ab|80|Water Reed
b0|ac|94|Eagle
b0|ad|96|Reed Bed
b0|af|8a|Daddy-O
b0|b0|8e|That's Atomic
b0|b1|ac|Plymouth Grey
b0|b4|54|Green Oasis
b0|b4|87|Winter Pear
b0|b4|9b|White Cabbage
b0|b7|be|Pearl Grey
b0|b7|c6|Brother Blue
b0|b9|9c|Foille
b0|b9|c1|Adirondack
b0|bc|c3|Stormy
b0|be|c5|Ocean Drive
b0|bf|1a|The Killing Joke
b0|c4|c4|Jungle Mist
b0|c4|de|Light Steel Blue?
b0|c5|df|Summer Storm
b0|c6|9a|Sheer Green
b0|c6|df|Cumulus Cloud
b0|c8|6f|Young Leaf
b0|c9|65|Green Glow
b0|ce|c2|Watershed
b0|d3|d1|Icy Morn
b0|dc|ed|Hint of Whimsy
b0|dd|16|Yellowish Green
b0|de|c8|Shallow Shore
b0|df|a4|Green Gooseberry
b0|e0|e6|Powder Blue
b0|e0|f6|Azure Sky
b0|e0|f7|Fairy Sparkles
b0|e3|13|Akhdhar Green
b0|e5|c9|Coastal Foam
b0|e6|e3|Cool Crayon
b0|ee|e2|East Cape
b0|ff|9d|Lens Flare Green
b1|45|66|Sangria
b1|4a|30|Kabacha Brown
b1|4b|38|Spiced Up
b1|59|2f|Fiery Orange
b1|60|02|Orange Brown
b1|61|0b|Pumpkin Skin
b1|63|5e|Sienna Red
b1|68|40|Khardic Flesh
b1|6b|40|African Safari
b1|6d|52|Santa Fe
b1|6d|90|Purple Starburst
b1|71|5a|Copper Beech
b1|72|61|Pinkish Brown
b1|73|04|Philippine Gold
b1|81|40|Amber Romance
b1|82|76|Sauvignon Blanc
b1|83|2f|Chai Tea
b1|8e|aa|Lavender Herb
b1|8f|6a|Iced Coffee
b1|90|5e|Pirate Plunder
b1|91|6e|Pale Brown
b1|92|8c|Plush Suede
b1|93|38|Balsam Pear
b1|94|66|Tangled Twine
b1|94|8f|Thatch
b1|94|a6|Grapevine
b1|95|76|Coffee Kiss
b1|96|64|Antelope
b1|97|78|Cookie Crumb
b1|9b|b0|Veiled Violet
b1|9c|86|Weathered Wood
b1|9c|8f|Bidwell Brown
b1|9c|d9|Light Pastel Purple
b1|a6|85|Crocker Grove
b1|a9|9f|Pale Earth
b1|aa|9c|Bright Sepia
b1|aa|9d|Calf Skin
b1|aa|b3|Endless Slumber
b1|ab|96|Oyster Linen
b1|b0|9f|Agate Grey
b1|b2|c4|Filtered Light
b1|b3|be|Glistening Grey
b1|b3|cb|Spring Lilac
b1|b6|a3|Fennel Stem
b1|b7|a1|Mellow Mood
b1|b9|d9|Frosted Iris
b1|bb|c5|Oxford
b1|c4|cb|Yín Sè Silver
b1|c6|c7|Blue Agave
b1|cd|ac|Spinach Dip
b1|cf|5d|Juicy Lime
b1|cf|c7|Steamy Spring
b1|d1|fc|Ice Cold Stare
b1|d2|7b|Pale Olive Green
b1|d2|df|Light June
b1|d3|e3|Spotted Snake Eel
b1|d8|db|Timeless
b1|da|c6|Celadon Sorbet
b1|db|aa|Fizz
b1|dd|52|Conifer
b1|e2|ee|Crystal River
b1|e5|aa|Appetite
b1|ea|e8|Spearmint Water
b1|fc|99|Pale Light Green
b1|ff|65|Pale Lime Green
b2|10|3c|Jalapeno Red
b2|18|07|Tomato Sauce
b2|1b|00|Wazdakka Red
b2|22|22|Firebrick
b2|5f|03|Orangish Brown
b2|64|00|Umber
b2|6e|33|Reno Sand
b2|71|3d|Clay Brown
b2|75|4d|Baked Bean
b2|7a|01|Golden Brown
b2|7d|50|Cowboy Hat
b2|86|5d|Sacred Ground
b2|89|59|Allegro
b2|89|6c|Mangy Moose
b2|8e|a8|Soft Impact
b2|8e|bc|Young Prince
b2|91|55|Golden Egg
b2|97|00|Sunken Gold
b2|97|05|Banana Puree
b2|99|4b|Husk
b2|99|6e|Dust
b2|9a|a7|On the Nile
b2|9d|8a|Easily Suede
b2|9e|9d|Red Rock Panorama
b2|9e|9e|Subtle Violet
b2|9e|ad|Symbolic
b2|a1|88|Whitney Oaks
b2|a4|84|Karma
b2|a5|d3|Ariel's Delight
b2|a7|cc|Wisteria-Wise
b2|a8|a1|Aura
b2|aa|7a|Even Growth
b2|aa|aa|Silver Service
b2|ab|94|Canterbury Cathedral
b2|ab|a1|Dreyfus
b2|ab|a7|Autumn Grey
b2|ac|88|Underhive Ash
b2|ac|a2|Greyhound
b2|ad|bf|Wisteria Trellis
b2|b0|ac|Bashful Emu
b2|b0|bd|Veiled Delight
b2|b2|6c|Rodham
b2|b2|9c|Ballie Scott Sage
b2|b5|5f|Green Me
b2|b6|ac|Mineral Grey
b2|b7|d1|Old World
b2|b9|a5|Matt Sage
b2|ba|db|Lilac Flare
b2|bb|c6|Spirit
b2|be|b5|Wet Ash
b2|c3|46|Rainforest Glow
b2|c6|b1|Zanah
b2|c7|e1|Newman's Eye
b2|c8|bd|Misty Morning
b2|c8|dd|Ridge Light
b2|ce|d2|Dewpoint
b2|cf|be|Gossamer Green
b2|d4|dd|Blue Glow
b2|d5|8c|Fresh Lettuce
b2|dc|ef|Soap Bubble
b2|e1|ee|Hint of Blue Limewash
b2|e7|9f|Paradise Green
b2|ec|5d|Inchworm
b2|ee|d3|Faint Clover
b2|fb|a5|Light Pastel Green
b2|fc|ff|Italian Sky Blue
b2|ff|ff|Celeste
b3|00|b3|Energic Eggplant
b3|1a|38|Vinho do Porto
b3|1b|11|Cornell Red
b3|1b|1b|Carnelian
b3|1c|45|Carmoisine
b3|21|34|American Red
b3|32|34|Red Contrast
b3|43|6c|Raspberry Rose
b3|44|6c|Irresistible
b3|46|46|Baked Apple
b3|4b|47|Lady in Red
b3|54|57|Mineral Red
b3|57|3f|Autumn Glaze
b3|59|66|Hot Flamingo
b3|5a|66|Baroque Rose
b3|5c|44|Karacha Red
b3|5e|97|Spruce Tree Flower
b3|66|63|Lasting Impression
b3|68|53|Deathclaw Brown
b3|6f|f6|Light Urple
b3|70|84|Tapestry
b3|72|56|Sunburn
b3|73|7f|Raspberry Whip
b3|80|70|Brick Fence
b3|83|3b|Weissbier
b3|83|80|Rose Dawn
b3|84|91|Fireweed
b3|8b|6d|Light Taupe
b3|8b|71|Macaroon
b3|93|55|Antique Honey
b3|93|c0|Quibble
b3|95|6c|Creamy Caramel
b3|98|7d|Woodbridge Trail
b3|98|97|Hazy Rose
b3|99|53|Viva Las Vegas
b3|99|97|Tawny Mushroom
b3|9a|a0|Decorum
b3|9b|94|Iris Mauve
b3|9e|b5|Pastel Purple
b3|9f|8d|Gilded Beige
b3|a0|c9|Lilac Breeze
b3|a6|a5|Cool Lavender
b3|a7|4b|Pickled
b3|a7|a6|Centennial Rose
b3|a9|8c|Prairie Sage
b3|a9|a3|Muted Mauve
b3|ab|98|Shaggy Barked
b3|ab|b6|Chatelle
b3|ad|a7|Dove
b3|ae|87|Lively Ivy
b3|b1|7b|Weeping Willow
b3|b5|af|Church Mouse
b3|b6|b0|Fitzgerald Smoke
b3|bb|b7|Loblolly
b3|be|98|Pale Spring
b3|be|c4|Soothing Breeze
b3|c1|b1|Rainee
b3|c4|ba|Aquamarine Dream
b3|c4|d5|Time Travel
b3|c4|d8|Spindle
b3|c5|cc|Crackling Lake
b3|c6|b9|Pine Whisper
b3|ca|dc|Big Sur
b3|cd|ac|Spring Fields
b3|cd|bf|Tyrol
b3|d1|57|Citrus Leaf
b3|d5|c0|Ginninderra
b3|d6|c3|Chlorophyll Cream
b3|d8|e5|Glacier Point
b3|d9|f3|Blue Rice
b3|da|e2|Light Tenzing
b3|db|ea|Hint of Blue Charm
b3|e1|e8|Across the Bay
b3|eb|e0|Gentle Giant
b4|02|3d|M. Bison Red
b4|26|2a|Aura Orange
b4|49|40|Teaberry Blossom
b4|49|6c|Lickedy Lick
b4|4c|97|Safflower Purple
b4|4e|5d|Holly Berry
b4|54|22|Gold Flame
b4|58|65|Slate Rose
b4|5f|56|Redwood City
b4|65|5c|Pineapple Blossom
b4|67|4d|Brown Wood
b4|74|63|Vin Cuit
b4|77|56|Apricot Mix
b4|7b|27|Weapon Bronze
b4|83|5b|Choco Biscuit
b4|83|95|Nuisette
b4|89|7d|Cappuccino Bombe
b4|89|93|Rose Tea
b4|8a|76|Plum Blossom Dye
b4|8a|c2|Creeping Bellflower
b4|8c|60|Crown Gold
b4|8c|a3|Lover's Tryst
b4|91|61|Maple View
b4|93|75|Colorado Trail
b4|95|a4|Ashberry
b4|98|9f|Deep South
b4|99|a1|Pink Discord
b4|a0|7a|Paper Sack
b4|a3|bb|Emanation
b4|a5|4b|Moss Stone
b4|a6|c6|Pixieland
b4|ab|af|Pinch Purple
b4|ad|a9|Slate Pebble
b4|ae|cc|Lavender Dream
b4|b4|98|Milton
b4|b6|ad|Old Grey Mare
b4|b6|da|Wild Orchid Blue
b4|b7|80|Fancy Flirt
b4|bb|31|Golden Passionfruit
b4|bb|85|Nile
b4|bc|bf|Crestline
b4|c0|4c|Celery
b4|c0|af|Coastal Crush
b4|c2|b6|Mossa
b4|c7|9c|Wasabi Peanut
b4|c7|db|Blue Ballerina
b4|c8|b6|Aida
b4|c8|c2|Surf Spray
b4|cb|d4|April Tears
b4|cb|e3|Melt Ice
b4|cc|bd|Mint Mousse
b4|cd|e5|Morality
b4|d0|d9|Midsummer's Dream
b4|d5|d5|Dante Peak
b4|df|ed|Hint of Budgie Blue
b4|e1|bb|Fringy Flower
b4|e2|d5|Cruise
b4|e5|ec|Winter Escape
b5|00|38|Warlock Purple
b5|33|2e|Molten Lava
b5|33|89|Fandango
b5|48|5d|Dark Rose
b5|4b|73|Royal Heath
b5|50|67|Exaggerated Blush
b5|52|33|Renga Brick
b5|62|57|Electric Brown
b5|65|1d|Light Brown
b5|65|1e|Dirty Brown
b5|6a|4c|Autumn Leaf
b5|6c|60|Water Persimmon
b5|6e|dc|Lavender
b5|72|81|Kerr's Pink Potato
b5|74|5c|Weathered Saddle
b5|77|70|Earth Rose
b5|7b|2e|Mandalay
b5|7e|dc|Lavender Blossom
b5|81|41|Tiffany Amber
b5|81|7d|Ash Rose
b5|82|99|Mauve Orchid
b5|83|38|Paler Pumpkin
b5|8e|8b|Brandy Snaps
b5|90|5a|Tan Your Hide
b5|94|10|Dark Gold
b5|98|08|Kalliene Yellow
b5|98|a3|Mauve Shadows
b5|99|8e|Del Rio
b5|9b|7e|Wooded Acre
b5|9d|77|King's Ransom
b5|9e|5f|Antique Gold
b5|9e|ad|Mauve Muslin
b5|9f|55|Woolen Mittens
b5|a0|88|Shattell
b5|a1|97|Thorn Crown
b5|a6|42|Brass
b5|ab|9c|Desert Dune
b5|ac|94|Bison Hide
b5|ac|9f|Tungsten
b5|ac|ab|Rose Ashes
b5|ac|b2|Gellibrand
b5|ad|88|Hemp Fabric
b5|ad|b4|Madame Mauve
b5|ad|b5|Lost Lake
b5|b1|bf|Dreamland
b5|b3|5c|Hemp Tea
b5|b5|b5|Brainstem Grey
b5|b5|bd|Enchanted Silver
b5|b5|cb|Soft Sky
b5|b6|8f|Green Tea
b5|b6|ce|Madder Blue
b5|b8|a8|Antique Coin
b5|bb|c7|Blunt
b5|bf|50|Sativa
b5|c0|b3|Irish Moor
b5|c2|cd|Pre School
b5|c3|06|Bile
b5|c3|8e|Margarita
b5|c7|d2|Celestyn
b5|c8|c9|Misty Surf
b5|cb|bb|Subtle Green
b5|cc|39|Tender Shoots
b5|ce|08|Lime Rasp
b5|ce|d4|Starlight Blue
b5|ce|df|Omphalodes
b5|d0|a2|Apium
b5|d1|be|Pitcher
b5|d1|db|Light Airborne
b5|d1|df|Light Wavecrest
b5|d5|b0|Flower Stem
b5|d5|d7|Light Aqua Mist
b5|d9|6b|Melissa
b5|dc|d8|Catch The Wave
b5|dc|ea|Hint of Delphin
b5|de|da|Minerva
b5|e4|e4|Seascape Green
b6|0c|26|Cadmium Purple
b6|10|32|Toreador
b6|1c|50|Jazzy
b6|27|3e|Timeless Beauty
b6|31|6c|Hibiscus
b6|37|53|Raspberry Wine
b6|44|76|Valentino
b6|49|25|Cattail Red
b6|5d|48|Ginger Spice
b6|5f|9a|Rose Bud
b6|60|44|Maui Mai Tai
b6|63|25|Polished Copper
b6|66|d2|Rich Lilac
b6|6a|3c|Mincemeat
b6|6a|50|Clay
b6|70|6b|Terra Tone
b6|72|67|Morocco
b6|73|50|Outlawed Orange
b6|7a|63|Happy Trails
b6|7c|80|Fiesta Rojo
b6|82|38|Colonel Mustard
b6|85|7a|Brandy Rose
b6|89|60|Tudor Tan
b6|8c|37|Mayan Gold
b6|8d|4c|Yellow Acorn
b6|8f|52|Honey Mustard
b6|93|5c|Barley Corn
b6|96|42|Roti
b6|98|85|Nougat
b6|9e|87|Baked Potato
b6|9f|cc|Dechala Lilac
b6|a1|80|Montecito
b6|a1|94|Net Worker
b6|a3|8d|Antique Windmill
b6|a3|a0|Lilac Smoke
b6|a8|93|White Pepper
b6|a8|9a|Runelord Brass
b6|a8|d0|People's Choice
b6|ae|ae|Kid Gloves
b6|b0|95|Heathered Grey
b6|b0|a9|Mercurial
b6|b2|a1|Melmac Silver
b6|b5|a0|Turtle Trail
b6|b5|b1|Mud Pots
b6|b5|b8|Silver Bullet
b6|ba|99|Lint
b6|ba|a4|Tickled Crow
b6|bc|df|Wish
b6|c1|21|Fallout Green
b6|c3|d1|Pageant Song
b6|c4|06|Leafy Seadragon
b6|c4|bd|Patina Creek
b6|c4|d2|Bypass
b6|c5|c1|Blustery Wind
b6|c8|e4|Radar
b6|ca|ca|Berry Mojito
b6|cc|b6|Ultramint
b6|d3|c5|Little Beaux Blue
b6|d4|a0|In Good Taste
b6|d5|de|Light Blue Dam
b6|db|bf|Ice Mist
b6|db|e9|Hint of Sky Babe
b6|e1|2a|Jazzercise
b6|e5|d6|Ode to Green
b6|e9|c8|Mint-o-licious
b6|ec|de|Water Leaf
b6|ff|bb|Light Mint
b7|28|2e|Madder Red
b7|32|75|Very Berry
b7|38|6e|Fiery Fuchsia
b7|3d|3f|Cherry Bomb
b7|41|0e|Martian Ironcrust
b7|49|23|Orange Wood
b7|51|3a|Hot Chilli
b7|52|03|Burnt Sienna
b7|5e|41|Sun-Kissed Brick
b7|68|a2|Pearly Purple
b7|6b|a3|Bodacious
b7|6e|79|Rose Gold
b7|73|5e|Crushed Cinnamon
b7|73|7d|Hollyhock Bloom
b7|77|95|Choral Singer
b7|79|61|Myrtle Pepper
b7|7b|57|Japanese Wax Tree
b7|81|53|Cinnamon Sand
b7|84|a7|Opera Mauve
b7|87|27|University of California Gold
b7|89|99|Monastir
b7|8b|43|Bread Crust
b7|8d|61|Mission Gold
b7|90|d4|Pale Purple
b7|93|c0|Sheer Lilac
b7|94|00|Main Mast Gold
b7|98|26|Sahara
b7|99|7c|Coffee Clay
b7|9c|94|Creamed Caramel
b7|9d|69|Swamp Fox
b7|9e|66|Grainfield
b7|9e|94|Big Horn Mountains
b7|a2|8e|Hickory
b7|a4|67|Gypsy Canvas
b7|a5|94|Tavern
b7|a6|96|El Capitan
b7|a7|93|Humus
b7|a8|6d|Oatmeal Biscuit
b7|a8|a3|Martini
b7|a9|a2|Riveter Rose
b7|a9|ac|Ramadi Grey
b7|ab|b0|Arctic Rose
b7|b1|7a|Leek Powder
b7|b2|ac|Classic Cool
b7|b3|a4|Digital Garage
b7|b5|9f|Alfalfa
b7|b6|98|Disguise
b7|b7|bc|Powder Dust
b7|b8|a5|Pine Crush
b7|b9|b5|Greystone
b7|ba|b9|Mischief Mouse
b7|bd|c4|Silver Springs
b7|bd|c6|Blue Rinse
b7|bd|d6|Hazy Sky
b7|bf|6b|Avocado Cream
b7|bf|b0|Kahili
b7|c0|be|Haze Blue
b7|c0|d7|Xenon Blue
b7|c0|ea|Larkspur Bud
b7|c3|bf|Whispering Winds
b7|c4|d3|Stargate
b7|c6|1a|Rio Grande
b7|c9|e2|Light Blue Grey
b7|cc|c7|Sea Sprite
b7|cd|d9|Light Sea Breeze
b7|d0|c5|Quiet Drizzle
b7|d2|4b|Solid Gold
b7|d2|e3|Light Blue Ice
b7|d7|de|Everglade Mist
b7|da|dd|Light Watermark
b7|df|f3|Hint of Fish Pond
b7|e1|a1|Light Grey Green
b7|e3|a8|Madang
b7|ff|fa|Winter Meadow
b8|0c|e3|Vivid Mulberry
b8|28|2f|Toadstool
b8|40|48|Dragon's Blood
b8|52|41|Beni Shoga
b8|6d|29|Brown Alpaca
b8|6f|73|Exotic Incense
b8|72|43|Spice Cake
b8|73|33|Copper
b8|75|92|First Plum
b8|7a|59|Caramel Apple
b8|7f|84|Rennie's Rose
b8|86|0b|Dark Goldenrod
b8|86|6e|Red Gravel
b8|86|86|Bashful Rose
b8|88|84|Toki Brown
b8|89|95|Lilas
b8|8a|3d|Shade of Marigold
b8|8a|ac|Purple Lepidolite
b8|96|6e|Warrant
b8|98|6c|Shelter
b8|99|5b|Orlean's Tune
b8|99|6b|Golden Granola
b8|9b|6b|New Cork
b8|9b|6c|Eastern Gold
b8|9b|72|Lark
b8|9e|78|Earthy Ocher
b8|a0|2a|Pollination
b8|a4|7a|Sailor's Knot
b8|a4|87|Desert Grey
b8|a7|22|Earls Green
b8|a8|8a|Sepia Tone
b8|a9|9a|Oxford Tan
b8|ab|b1|Lavender Cloud
b8|ac|9e|Tapestry Beige
b8|ac|b4|Angel Finger
b8|ad|8a|Chino
b8|ad|9e|Feather Grey
b8|ae|98|True Khaki
b8|af|23|Citronelle
b8|b0|af|Grey Scape
b8|b2|be|Titmouse Grey
b8|b4|b6|Silver Bells
b8|b5|a1|Tana
b8|b7|a3|Ganadian Voodoo Grey
b8|b8|b8|Fortress Grey
b8|b8|bf|Mithril Silver
b8|b8|cb|Winter Dusk
b8|b8|f8|Purple Illusion
b8|b9|cb|Cosmic
b8|ba|87|Aloe Plant
b8|bf|c2|Grey Frost
b8|bf|ca|Kinder
b8|bf|cc|Mistral
b8|c1|b1|Kimberley Tree
b8|c4|d9|Alley
b8|c6|be|Nebula
b8|c8|d3|Light Hazy Daze
b8|ca|9d|Sprout
b8|cc|82|Nurgling Green
b8|ce|d9|Light Vanilla Ice
b8|d0|da|Mudra
b8|d3|e4|Light Mr Frosty
b8|d4|bb|Surf
b8|d7|a6|Apple Cream
b8|dc|a7|Embroidered Silk
b8|dc|ed|Hint of Club Cruise
b8|de|f2|Hint of Shimmer
b8|df|f8|Arctic Paradise
b8|e1|00|Livid Lime
b8|e2|dc|Fair Aqua
b8|eb|c5|Slimlime
b8|f8|18|Green Venom
b8|f8|b8|Spring Slumber Green
b8|f8|d8|Seafair Green
b8|ff|eb|Peppermint Frosting
b9|12|28|Goji Berry
b9|26|36|Ribbon Red
b9|3a|32|Aurora Red
b9|40|47|Chinese Safflower
b9|42|78|Emperors Children
b9|48|4e|Dusty Red
b9|4c|66|Pink Dahlia
b9|4e|41|Conker
b9|4e|48|Deep Chestnut
b9|55|43|Red River
b9|57|54|Chōshun Red
b9|5b|3f|Spice Route
b9|5b|6d|Candied Apple
b9|64|82|Raspberry Parfait
b9|69|02|Brown Orange
b9|6b|00|Indocile Indochine
b9|71|4a|Pottery Clay
b9|75|8d|Strawberry Surprise
b9|7a|77|Wild Party
b9|80|33|Cider Toddy
b9|81|42|Condiment
b9|83|91|Foxglove
b9|84|78|Dusky Damask
b9|86|75|Big Cypress
b9|88|41|Golden Slumber
b9|8c|5d|Caramel Cupcake
b9|8d|68|Fire Dust
b9|8e|68|Doe
b9|8f|af|Tiny Ribbons
b9|99|84|Brush
b9|9b|c5|Crocus Petal
b9|a0|23|Wet Leaf
b9|a0|d2|Purple Premiere
b9|a1|93|White Mouse
b9|a2|81|Taupe
b9|a3|79|Hemp Rope
b9|a3|7e|Tiki Straw
b9|a5|bd|Viola Sororia
b9|a7|7c|Texas Sage
b9|ab|8f|Prairie Dust
b9|ab|a3|Barren
b9|ab|a5|Moon Rose
b9|ab|ad|Aniline Mauve
b9|ac|bb|Lola
b9|ad|61|Gimblet
b9|b1|c8|Violet Bouquet
b9|b2|97|Flour Sack
b9|b3|bf|Ash Grove
b9|b3|c2|Juniper Berry
b9|b4|b1|Grey Marble
b9|b5|a4|Wells Grey
b9|b5|af|Soft Beige
b9|b7|9b|Trinity Islands
b9|ba|ba|Covered in Platinum
b9|ba|bd|Quiet Grey
b9|bb|ad|Grey Jade
b9|bc|b6|Blue Fox
b9|bd|97|Paspalum Grass
b9|bd|ae|Dry Catmint
b9|be|82|Early Harvest
b9|c0|c0|Maiden Mist
b9|c3|b3|Belize Green
b9|c3|be|Tiara
b9|c4|bc|Inviting Veranda
b9|c4|de|Etherium Blue
b9|c6|d8|Angora Blue
b9|c8|e0|Penna
b9|cb|5a|Asparagus Fern
b9|cc|81|Pale Olive
b9|d0|8b|Young Leaves
b9|d2|d3|Relax
b9|d4|e7|Light Sea Cliff
b9|d7|d6|Greenland Ice
b9|dc|c3|Sprite Twist
b9|de|f0|Hint of Deluxe Days
b9|e0|cf|Desert Mirage
b9|e1|c2|Lattice Work
b9|e5|e8|Soaring Sky
b9|e7|dd|Ice Cap Green
b9|ea|b3|Patina Green
b9|f2|ff|Northrend
b9|ff|66|Light Lime Green
ba|00|33|Warlord Purple
ba|0b|32|Lychee
ba|16|0c|International Orange
ba|40|3a|Naughty Hottie
ba|41|7b|Razzle Dazzle
ba|55|d3|Medium Orchid
ba|5b|6a|Love Bird
ba|5e|0f|Super Leaf Brown
ba|68|73|Dusky Rose
ba|69|a1|Spring Crocus
ba|78|2a|Pirate Gold
ba|79|7d|Dusty Rose
ba|87|59|Deer
ba|87|aa|Sunset Horizon
ba|8a|45|Antiquarian Gold
ba|8e|4e|Harvest Blessing
ba|8f|68|Tropical Wood
ba|8f|7f|Rosetta
ba|90|ad|Fabulous Fantasy
ba|92|38|Honey
ba|93|d8|Lenurple
ba|94|7b|Cool Clay
ba|94|7f|Caramelized
ba|99|a2|Playful Plum
ba|9b|97|Lilac Suede
ba|9b|a5|Pale Petticoat
ba|9e|88|Rogue Cowboy
ba|9f|99|Adobe Rose
ba|a1|b2|Parlor Rose
ba|a2|08|Snakebite Leather
ba|a2|43|Sea Squash
ba|a2|ce|Lucius Lilac
ba|a3|8b|Sesame
ba|a3|a9|Magical Mauve
ba|a4|82|Sticks & Stones
ba|aa|91|Safari
ba|ab|74|Heavy Goldbrown
ba|ab|87|Pavlova
ba|ae|9d|Camel Train
ba|af|b9|Down Dog
ba|b0|78|Gracious Glow
ba|b0|99|Kahlua Milk
ba|b1|a3|Stonelake
ba|b2|ab|City Street
ba|b2|b1|Soft Metal
ba|b4|a6|Pewter Patter
ba|b6|96|Bog
ba|b6|a9|Play on Grey
ba|b6|ab|Reclaimed Wood
ba|b6|b2|Clear Concrete
ba|b6|cb|Axis
ba|b7|b3|Dusty Warrior
ba|b8|6c|Olive Oil
ba|b8|d3|Purple Heather
ba|b9|a9|Gravel Dust
ba|bc|72|Savannah Grass
ba|bc|c0|Microchip
ba|bd|6c|Kelly's Flower
ba|bd|b8|Solstice
ba|bf|bc|Metal
ba|bf|c5|Blue To You
ba|c0|0e|La Rioja
ba|c0|8a|Jitterbug
ba|c0|b3|Tasman
ba|c0|b4|Pumice
ba|c2|aa|Healing Retreat
ba|c4|d5|Candela
ba|ca|d4|Light Heaven Sent
ba|cb|7c|Floral Bouquet
ba|cb|c4|Blue Shamrock
ba|cc|a0|New Frond
ba|d1|47|Shining Gold
ba|d1|b5|Lime Taffy
ba|d2|b8|Eucalyptus Leaf
ba|d5|6b|Rebounder
ba|d5|d4|Light Zenith Heights
ba|d7|ae|Bleached Spruce
ba|d7|dc|Light Sky Chase
ba|db|df|Light Wave
ba|db|e6|Alpine Alabaster
ba|df|30|Acid Lime
ba|e3|eb|Hint of Bluish Water
ba|e5|d6|Bay
ba|e5|ee|Hint of Piccolo
bb|00|00|Harlock's Cape
bb|00|11|Red Baron
bb|01|2d|Red Dead Redemption
bb|11|00|Red Prayer Flag
bb|11|11|Sinoper Red
bb|11|22|Ruby Star
bb|11|33|Active Volcano
bb|12|37|Ski Patrol
bb|22|00|Ravishing Rouge
bb|22|11|Redalicious
bb|22|22|Crisis Red
bb|22|99|Fuchsia Fluorish
bb|33|11|Virtual Boy
bb|33|77|Pink Shadow
bb|33|85|Medium Red Violet
bb|36|3f|Rococco Red
bb|3f|3f|Dull Red
bb|44|00|Bolognese
bb|44|11|Pindjur Red
bb|44|22|Devil’s Butterfly
bb|44|66|Mauve It
bb|44|77|Mauve Mystique
bb|44|88|Orchid Ecstasy
bb|44|aa|Ultraviolet Nusp
bb|44|bb|Ultraviolet Cryner
bb|44|cc|Ultraviolet Berl
bb|44|dd|Ultraviolet Onsible
bb|4f|35|Burnt Ochre
bb|4f|5c|Salsa Diane
bb|55|20|Taisha Brown
bb|55|48|Safflower Bark
bb|55|77|Shattan Gold
bb|55|88|Berry Boost
bb|5c|14|Hawaiian Sunset
bb|5f|34|Smoke Tree
bb|5f|60|Energy Peak
bb|65|28|Ruddy Brown
bb|65|69|Terra Rosa
bb|74|31|Meteor
bb|77|44|Palomino
bb|77|77|Nipple Pink
bb|77|88|Mauve Seductress
bb|77|96|Benifuji
bb|7a|2c|Inca Gold
bb|7c|3f|Tuscan Sunset
bb|81|41|Kitsurubami Brown
bb|85|2f|Gothic Gold
bb|88|00|Kenyan Sand
bb|88|11|Old Trail
bb|88|33|Burnished Copper
bb|88|55|Canvas
bb|88|66|Carnal Brown
bb|88|99|Mauvey Nude
bb|88|ff|Lilac Geode
bb|8a|8e|Shabby Chic
bb|8d|3b|Trading Post
bb|8d|88|Smoky Pink
bb|8d|a8|Elite Pink
bb|8e|34|Hokey Pokey
bb|8e|55|Summer Weasel
bb|8e|84|Venetian Pink
bb|91|74|Presidio Plaza
bb|93|4b|Alluvial Inca
bb|93|51|Maple Syrup
bb|93|7b|Turkish Bath
bb|94|71|Painted Pony
bb|96|62|Karak Stone
bb|98|9f|Magenta Twilight
bb|99|3a|Golden History
bb|99|55|Base Sand
bb|99|77|Boneyard
bb|9a|39|Gold Taffeta
bb|9b|7d|Maison De Campagne
bb|9c|7c|Woolly Mammoth
bb|9e|3f|Tiki Torch
bb|9e|7c|French Oak
bb|9e|9b|Awakening
bb|9e|ca|Purple Prophet
bb|9f|60|Eaton Gold
bb|9f|6a|Buffalo Hide
bb|9f|b1|Fiddlesticks
bb|a2|62|Shutterbug
bb|a2|b6|Melting Moment
bb|a4|6d|Pale Oak
bb|a5|28|Pickle Juice
bb|a5|a0|Shadow Grey
bb|a7|48|Forest Tent
bb|a8|7f|Malt Shake
bb|aa|22|Green Flavor
bb|aa|7e|Inner Cervela
bb|aa|97|Fangtooth Fish
bb|ac|7d|Nettle
bb|ad|a1|Silk
bb|ae|b9|Luminous Light
bb|af|ba|Inner Touch
bb|b0|85|Tomatillo Salsa
bb|b0|9b|Townhouse Taupe
bb|b0|a4|Drake Tooth
bb|b0|b1|Antique Mauve
bb|b1|a8|Chateau Grey
bb|b3|a2|Ashes to Ashes
bb|b4|65|Hi Def Lime
bb|b4|77|Misty Moss
bb|b5|8d|Coriander
bb|b7|ab|Powered Rock
bb|b8|d0|Fragile
bb|bb|7f|Ushabti Bone
bb|bb|bb|Gravel Fint
bb|bb|c1|Mithril Silver / Silver
bb|bb|ff|Dried Lilac
bb|bc|bc|Dust to Dust
bb|bc|de|Wisteria Fragrance
bb|bf|c3|Silver Lined
bb|c1|cc|Grey Dawn
bb|c3|dd|Blue Hydrangea
bb|c5|b2|Light Ceramic
bb|c6|a4|Quaking Grass
bb|c6|c9|Stormhost Silver
bb|c6|d6|Angelic Blue
bb|c6|d9|Pale Opal
bb|c6|de|Objectivity
bb|c8|e6|Pale Wisteria
bb|cc|22|Luscious Leek
bb|cc|99|White Grapes
bb|cc|dd|Arctic Grey
bb|cd|a5|Pixie Green
bb|d0|c9|Jet Stream
bb|d1|e8|Angelic Eyes
bb|d3|da|Light Salt Spray
bb|d5|ef|Light Island Light
bb|d6|ea|Light Template
bb|d7|5a|Frog Prince
bb|d9|bc|Lamina
bb|da|f8|Oh Boy!
bb|db|d0|Sweet Nothings
bb|dd|ee|Ice Rink
bb|de|e5|Disappearing Island
bb|df|d5|Short Phase
bb|e4|ea|Light Ice Pack
bb|ed|db|Salome
bb|ee|00|Lush Green
bb|f9|0f|Shishito Pepper Green
bb|ff|99|Apatite Crystal Green
bb|ff|ee|Summer Cloud
bb|ff|ff|Young Cornflower
bc|00|2d|Hinomaru Red
bc|01|2e|Akai Red
bc|13|fe|Neon Purple
bc|27|31|Mars Red
bc|2d|29|Ginshu
bc|30|33|Hot Jazz
bc|32|2c|Valiant Poppy
bc|36|3c|Rockin Red
bc|4d|39|Glowing Coals
bc|4e|40|Chili Sauce
bc|53|39|Orange Vermillion
bc|5d|58|Wild Chestnut
bc|64|a4|Young Purple
bc|6f|37|Lucky Penny
bc|76|3c|Cray
bc|81|43|Burmese Gold
bc|88|6a|Honey Graham
bc|89|6e|Foxtail
bc|8a|90|Rosenkavalier
bc|8d|1f|Arrowwood
bc|8f|8f|Rose Brown
bc|91|4d|Deep Sun
bc|92|29|Nugget
bc|92|63|Honey Haven
bc|98|7e|Pale Taupe
bc|98|9e|It's Your Mauve
bc|9b|1b|Buddha Gold
bc|9b|4e|Brown Rum
bc|9c|a2|Windflower
bc|9d|70|Gould Gold
bc|a1|7a|Satyr Brown
bc|a3|80|With the Grain
bc|a4|83|Curds and Whey
bc|a4|cb|Lavendula
bc|a5|9a|Frontier Land
bc|a6|6a|Southern Moss
bc|a8|ad|Pale Poppy
bc|a9|49|Cress Green
bc|aa|9f|Crushed Stone
bc|ab|8c|Bamboo Screen
bc|ab|9c|Stanford Stone
bc|ac|9f|Teddy's Taupe
bc|ac|cd|Jacey's Favorite
bc|ae|a0|Puppy
bc|ae|a1|Blind Date
bc|af|97|British Khaki
bc|af|bb|Window Box
bc|b0|9e|Cannery Park
bc|b4|c4|Misty Lilac
bc|b5|8a|Cress Vinaigrette
bc|b5|8c|Urahayanagi Green
bc|b6|b3|Smooth Stone
bc|b6|cb|Wedding Flowers
bc|b7|ad|Ghost Writer
bc|b7|b1|Rampart
bc|ba|ab|Greenwood
bc|bf|a8|Beryl Green
bc|c0|9e|Light Pine
bc|c0|cc|Starlight
bc|c2|3c|Tropic Canary
bc|c4|bd|Ashwood
bc|c5|cf|Blue Dolphin
bc|c6|a2|Seagrass
bc|c6|b1|Pattipan
bc|c8|c6|Sky Grey
bc|c9|c2|Powder Ash
bc|c9|cd|Gulf Wind
bc|ca|b3|Bok Choy
bc|ca|e8|Cuddle
bc|cb|7a|Greenish Tan
bc|cb|b2|Succulent Garden
bc|ce|db|Constellation
bc|cf|a4|Spumoni
bc|d4|e1|Pale Aqua
bc|d4|e6|Beau Blue
bc|d6|e9|Light Tidal Foam
bc|d7|d4|Viridian Green
bc|d7|df|Blue Perennial
bc|d8|d2|High Point
bc|d9|c8|Misty Jade
bc|d9|dc|Alexandrian Sky
bc|db|d4|Picnic Bay
bc|db|db|Misty Aqua
bc|df|8a|Green Chalk
bc|df|e8|Hint of Blue Glint
bc|df|ff|Dithered Sky
bc|e1|eb|Hint of Baby Motive
bc|e2|e8|Icy Water
bc|e3|df|Bleached Aqua
bc|e4|eb|Hint of Aqua Clear
bc|e6|e8|Light Karma
bc|e6|ef|Hint of July
bc|e8|dd|Aqua Oasis
bc|ec|ac|Light Sage
bc|f5|a6|Washed Out Green
bd|16|2c|Racing Red
bd|33|a4|Byzantine
bd|42|75|Lilac Rose
bd|57|01|Sebright Chicken
bd|57|45|Mecca Orange
bd|68|83|Creamed Raspberry
bd|6c|48|Adobe
bd|83|be|Lavender Sweater
bd|8c|66|Pastry Shell
bd|97|cf|Amethyst Show
bd|9d|95|Coca Mocha
bd|a2|89|Kangaroo Pouch
bd|a5|8b|Oakwood
bd|a6|c5|Extraordinaire
bd|a9|28|Greenfinch
bd|a9|98|Notorious
bd|aa|89|Green Olive Pit
bd|ab|9b|Old Doeskin
bd|ab|be|Lavender Frost
bd|ac|a3|Mushroom
bd|ad|a4|Thumper
bd|ae|b7|Castle Mist
bd|b0|a0|Discover
bd|b0|d0|Pastel Lilac
bd|b1|92|Terminatus Stone
bd|b2|68|Straw Hut
bd|b3|69|Golden Green
bd|b3|a7|Heavy Warm Grey
bd|b3|c3|Perplexed
bd|b6|ab|Silver Lining
bd|b6|ae|Silver Dollar
bd|b7|6b|Golden Cartridge
bd|b8|c7|Evening Haze
bd|ba|ae|Dusty Sand
bd|ba|ce|Blue Haze
bd|bb|ad|Hurricane Haze
bd|bb|d7|Lavender Grey
bd|bc|c4|Silver Fox
bd|bd|c6|Great White
bd|be|bd|Noqrei Silver
bd|bf|35|Enigma
bd|bf|c8|Anon
bd|c0|7e|Pine Glade
bd|c1|c1|Quest
bd|c2|33|Fluorescent Lime
bd|c2|bb|Silky Green
bd|c3|ac|Jungle Moss
bd|c6|dc|Halogen Blue
bd|c7|bc|Tree Pose
bd|c8|af|Tamboon
bd|c8|b3|Clay Ash
bd|c9|e3|Hindsight
bd|ca|a8|Pale Leaf
bd|cc|b3|Soft Froth
bd|cf|ea|Maritime
bd|d0|43|Polished Gold
bd|d0|b1|Apple Ice
bd|d0|c3|Spray of Mint
bd|d0|d1|Detroit
bd|d4|d1|Pale Icelandish
bd|d5|b1|Golden Elm
bd|d8|c0|Namaste
bd|da|57|June Bud
bd|dd|e1|Light Aqua Frost
bd|e1|c4|Mother Nature
bd|e1|d8|Serendipity
bd|e8|d8|Mint Ice
bd|f6|fe|Pale Sky Blue
bd|f8|a3|Reindeer Moss
bd|ff|ca|Coastal Trim
be|00|32|Crimson Glory
be|01|19|Red Tolumnia Orchid
be|01|3c|Traditional Rose
be|03|fd|Bright Purple
be|06|20|Shēn Hóng Red
be|26|33|Bow Tie
be|45|4f|Chrysanthemum
be|4b|3b|Summer Fig
be|4f|62|Popstar
be|51|41|Chili
be|5c|48|Flame Pea
be|64|00|Fire Ant
be|75|2d|Golden Oak
be|7f|51|Limonite
be|80|35|Fresh Clay
be|85|5e|Orpington Chicken
be|89|73|Terrazzo Tan
be|8a|4a|Spruce Yellow
be|96|77|Warm Hearth
be|9c|c1|Lupine
be|9e|48|Underbrush
be|9e|6f|Curry
be|a7|7d|Sonora Hills
be|a7|81|Equestrian
be|a8|8d|Coffee Diva
be|ac|90|Egyptian Sand
be|ad|b0|Moire
be|ae|8a|Wild Nude
be|b1|b0|Mouse Trap
be|b2|9a|Akaroa
be|b3|94|Easy
be|b4|9e|Polished Stone
be|b4|a8|Drifting
be|b4|ab|Tide
be|b6|a8|Ghost Town
be|b7|55|Parachute
be|b7|b0|Silver Cloud
be|b8|b6|Painted Desert
be|b8|cd|Wild Lilac
be|b9|a2|Heavy Hammock
be|ba|82|Slippery Moss
be|ba|a7|Ash
be|ba|d9|Beatrice
be|bb|c0|Mauve Pansy
be|bb|c9|Silverberry
be|bd|99|Esprit
be|bd|ac|Sapless Green
be|bd|b6|Silver Sand
be|bd|bc|Anti Rainbow Grey
be|bd|bd|Vapor Blue
be|bd|c2|Pied Wagtail Grey
be|be|be|Tin Soldier
be|be|c3|Rocket Man
be|bf|84|Pavilion
be|c0|aa|New Neutral
be|c0|af|Fibre Moss
be|c0|b0|Misty Meadow
be|c0|c2|Neo Tokyo Grey
be|c1|87|Kiss A Frog
be|c1|cf|Image Tone
be|c4|b7|Balsam
be|c4|d3|Blue Bayou
be|ca|60|Wild Willow
be|ce|61|Luster Green
be|ce|b4|Rhys
be|cf|cd|Babbling Brook
be|d1|e1|Sleep Baby Sleep
be|d3|8e|Lettuce Green
be|d3|cb|Quaver
be|d3|e1|Two Harbours
be|d5|65|Glow Worm
be|d7|f0|Light Blue Mist
be|dd|ba|Soft Lumen
be|dd|d5|Pinnacle
be|df|d3|Otto Ice
be|e0|e2|Light Poolside
be|e5|be|Lime Sorbet
be|e7|a5|Pastel Pea
be|e7|e2|Tropical Waterfall
be|e8|d3|Maypole
be|e9|e3|Pool Party
be|eb|71|Pisco Sour
be|ed|dc|Fresh Breeze
be|fd|73|Pale Lime
be|fd|b7|Glow in the Dark
bf|00|ff|Electric Purple
bf|0a|30|Old Glory Red
bf|19|32|True Red
bf|21|33|Relief
bf|27|35|Lolita
bf|31|60|Maroon Light
bf|3c|ff|Magnetos
bf|41|47|Watermelon Red
bf|4e|46|Le Corbusier Crush
bf|4f|51|Bittersweet Shimmer
bf|5b|3c|Tartare
bf|5b|b0|Mazzy Star
bf|64|64|Faded Rose
bf|65|2e|Dwarven Bronze
bf|69|55|Cedar Grove
bf|6f|31|Carrot Cake
bf|76|4c|Monarch Migration
bf|77|f6|Light Purple
bf|79|4e|Rakuda Brown
bf|7c|45|Sedona at Sunset
bf|8d|3c|Pizza
bf|8f|37|Arnica
bf|8f|c4|Violaceous
bf|90|05|Moutarde de Bénichon
bf|91|4b|Tussock
bf|91|b2|Mauve Magic
bf|92|3b|Wheat Beer
bf|94|e4|Bright Lavender
bf|9b|0c|Ocher
bf|9f|91|Earth Warming
bf|a2|70|Bread Pudding
bf|a2|a1|Foggy Quartz
bf|a3|87|Candied Ginger
bf|a4|6f|Hashibami Brown
bf|a5|8a|Pergament
bf|a7|7f|Taos Taupe
bf|a9|84|Handwoven
bf|aa|97|Trail Sand
bf|ac|05|Muddy Yellow
bf|ac|b1|Lavender Scent
bf|ae|5b|Mack Creek
bf|af|92|Pale Khaki
bf|af|b2|Black Shadows
bf|b1|8a|Weaver's Spool
bf|b3|b2|Pink Swan
bf|b4|cb|Orchid Petal
bf|b5|a2|Tea
bf|b5|a6|Sophistication
bf|b5|ca|Decency
bf|b6|aa|Vampiric Shadow
bf|b9|a3|Tidal Foam
bf|b9|d4|Lemures
bf|b9|d5|Playful Purple
bf|ba|af|Cotton Seed
bf|bd|c1|French Grey
bf|be|ad|Land Before Time
bf|bf|bd|Spotted Dove
bf|c0|ab|Kidnapper
bf|c0|ee|Vodka
bf|c1|cb|Slipper Satin
bf|c2|98|Green Mist
bf|c3|ae|Sidekick
bf|c7|d4|Northern Exposure
bf|c7|d6|Arctic Ice
bf|c8|c3|Smoke
bf|c9|21|Key Lime Pie
bf|c9|d0|Bay of Hope
bf|ca|87|Apple II Beige
bf|ca|d6|Plein Air
bf|cd|c0|Paris White
bf|cd|cc|Misty Blue
bf|cf|c8|Soft Celadon
bf|d0|cb|White Box
bf|d1|ad|Gleam
bf|d1|af|Gamin
bf|d1|b3|Seacrest
bf|d1|c9|Rolling Waves
bf|d1|ca|Sonoma Sky
bf|d2|d0|Antarctica Lake
bf|d3|cb|Spearmint Ice
bf|d4|c4|Garden Statue
bf|d5|b3|Nature
bf|d5|eb|Light Water Wash
bf|d6|c8|Malted Mint
bf|d9|ce|Silverton
bf|de|af|Bowling Green
bf|df|df|Aqua Whisper
bf|e0|e4|Hint of Bathing
bf|e1|e6|Hint of Sea Spray
bf|e4|d4|Beru
bf|e5|b1|Almost Aloe
bf|e7|ea|Light Vandamint
bf|f1|28|Yellowy Green
bf|fe|28|Lemon Lime
bf|ff|00|Limoncello
c0|00|00|Free Speech Red
c0|02|2f|Lipstick Red
c0|13|52|Love Potion
c0|2e|4c|Dry Rose
c0|35|43|Striking Red
c0|36|2c|Cadillac Coupe
c0|36|2d|Golden Gate Bridge
c0|3f|20|Shēn Chéng Orange
c0|40|00|Mahogany
c0|42|8a|Rose Violet
c0|44|8f|Boat Orchid
c0|4e|01|Crustose Lichen
c0|51|4a|Sunset
c0|6f|68|Shepherd's Warning
c0|71|fe|Easter Purple
c0|72|81|Briar Rose
c0|73|7a|Cinnamon Roll
c0|77|65|Himalayan Salt
c0|7c|40|Brandy Punch
c0|7c|7b|Gypsy Dancer
c0|80|81|Old Rose
c0|85|91|Strawberry Jubilee
c0|87|68|Toasted Nut
c0|8a|80|Cameo Brown
c0|8f|45|Centra
c0|90|78|Copper Lake
c0|90|84|Revival Rose
c0|91|6c|Fenugreek
c0|92|78|Charleston Chocolate
c0|98|56|Amaretto Sours
c0|99|62|Cheers!
c0|99|a0|Plum Mouse
c0|9c|6a|Welcome Home
c0|9e|6c|Gilded Pear
c0|a0|4d|Tupelo Honey
c0|a2|c7|Pale Grape
c0|a4|80|Graham Cracker
c0|a5|ae|Keepsake Lilac
c0|a8|5a|Yellow Maize
c0|a9|cc|Immortal
c0|aa|c0|Fair Orchid
c0|ac|92|Papyrus Map
c0|ad|a6|Mauve Nymph
c0|af|87|Owl Manner Malt
c0|af|92|Rock Cliffs
c0|b0|5d|Spring Marsh
c0|b2|8e|Trailblazer
c0|b2|b1|Jack Rabbit
c0|b2|d7|Moonraker
c0|b5|aa|Light Glaze
c0|b7|cf|Savile Row
c0|b9|ac|City Dweller
c0|bd|81|Krieg Khaki
c0|bf|c7|Ghost
c0|c0|c0|Silver
c0|c0|ca|Lavender Oil
c0|c2|a0|Chameleon Tango
c0|c3|c4|Foil
c0|c6|c9|Ash Blue
c0|ca|bc|Desert Panzer
c0|cb|a1|Seedling
c0|ce|d6|Keepsake
c0|ce|da|Ballad Blue
c0|cf|3f|Grunervetliner
c0|d2|d0|Icy Waterfall
c0|d5|ca|Soft Fresco
c0|d5|ef|Light Breezy
c0|d7|25|Lime Punch
c0|d7|cd|Meadow Lane
c0|d8|eb|Light Blue Veil
c0|db|3a|Lime Popsicle
c0|dc|cd|Dusty Aqua
c0|df|e2|Hint of Imagine
c0|e1|e4|Hint of Jellyfish Blue
c0|e2|e1|Yù Shí Bái White
c0|e5|ec|Hint of Washed Blue
c0|e7|40|Energos
c0|e7|eb|Light Sky Cloud
c0|e8|d5|Aero Blue
c0|f7|db|Out of Blue
c0|fa|8b|Pistachio Mousse
c0|fb|2d|Grass Stain Green
c0|ff|00|French Lime
c1|26|4c|Zǎo Hóng Maroon
c1|4a|09|Brick Orange
c1|4d|36|Grenadier
c1|54|c0|Still Fuchsia
c1|54|c1|Deep Fuchsia
c1|5a|4b|Martian Ironearth
c1|61|04|Crema
c1|65|12|Marmalade
c1|6c|7b|Pink Manhattan
c1|6f|45|Screaming Bell Metal
c1|6f|68|Contessa
c1|74|44|Ginger Root
c1|82|44|Sweet Tea
c1|88|62|Sassy
c1|89|78|Copper Trail
c1|91|56|Twine
c1|93|c0|Violet Tulle
c1|95|52|Amber Gold
c1|98|51|Where Buffalo Roam
c1|9a|13|Rapeseed
c1|9a|51|Fallow
c1|9a|62|Lion
c1|9a|6b|Wobbegong Brown
c1|9a|6c|Cardboard
c1|9a|a5|Artichoke Mauve
c1|9d|61|Gold Spell
c1|9e|78|Tan Plan
c1|9f|b3|Lily
c1|a3|93|Top Hat Tan
c1|a3|b9|Blackberry Sorbet
c1|a4|4a|Creed
c1|a5|8d|Summer Hill
c1|a6|5c|Nonpareil Apple
c1|a6|8d|Cuban Sand
c1|a8|7c|Antiquity
c1|aa|91|Camel Hide
c1|ac|c3|Monet Magic
c1|ad|a9|Perdu Pink
c1|b1|9d|Warm Neutral
c1|b2|3e|Pesto
c1|b4|a0|Pigeon Grey
c1|b5|5c|Tarpon Green
c1|b5|a9|Ash Grey
c1|b7|b0|Silver Grey
c1|b9|93|Salty Seeds
c1|b9|aa|Bright Loam
c1|bc|ac|Pelican
c1|be|cd|Gentleman's Suit
c1|c1|c1|Stonewall Grey
c1|c1|c5|Mote of Dust
c1|c1|d1|Pale Cast of Thought
c1|c2|c3|Magnesium
c1|c6|ad|Sicily Sea
c1|c6|d3|Hūi Sè Grey
c1|c6|fc|Light Periwinkle
c1|c8|af|Cushion Bush
c1|ca|b0|Green Dragon Spring
c1|ce|c1|Green Lily
c1|ce|da|Magical
c1|d0|b2|Stability
c1|d1|c4|Opaline
c1|d1|e2|Drenched Rain
c1|d8|ac|Winter Willow Green
c1|d8|c5|Edgewater
c1|d8|eb|Light Featherbed
c1|db|e7|Hint of Sky Bus
c1|de|ea|Hint of Bobby Blue
c1|e0|89|Green Onion
c1|e0|a3|Cactus Spike
c1|e2|8a|Oxalis
c1|e3|e9|Hint of Blue Stream
c1|e5|d5|Jade Spell
c1|e5|ea|La Paz Siesta
c1|e8|ea|Light Opale
c1|ed|d3|Spatial Spirit
c1|f8|0a|Chartreuse
c1|f9|a2|Menthol
c1|fd|95|Celery Mousse
c2|00|78|Purple Anxiety
c2|19|1f|Evil Sunz Scarlet
c2|21|47|Ahmar Red
c2|3b|22|Dark Pastel Red
c2|45|2d|Autumn Robin
c2|55|c1|Fuchsia Tint
c2|5a|3c|Orange Rust
c2|61|57|Barbecue
c2|6a|35|Sesame Crunch
c2|6a|5a|Apricot Brandy
c2|72|77|Cranberry Pie
c2|76|35|Orange Squash
c2|7e|79|Brownish Pink
c2|7f|38|Ginger Beer
c2|83|59|Fall Foliage
c2|87|7b|Whisky
c2|87|99|Polignac
c2|89|96|Desert Bud
c2|8a|35|Butter Base
c2|8b|a1|Winsome Rose
c2|8e|88|Oriental Pink
c2|92|a1|Light Mauve
c2|93|7b|Potter's Pink
c2|94|36|Oro
c2|95|94|Mutabilis
c2|98|67|Chalet
c2|a0|80|Meringue Tips
c2|a2|60|Magic Lamp
c2|a3|77|Applesauce Cake
c2|a5|93|Pragmatic
c2|a5|94|Rugby Tan
c2|a8|4b|Deadsy
c2|a9|db|Perfume
c2|aa|87|Tan Oak
c2|ac|b1|Violet Ice
c2|ae|87|Horned Frog
c2|ae|88|Desert Camel
c2|ae|c3|Lavish Lavender
c2|b1|a1|Coral Clay
c2|b1|c8|Purple Essence
c2|b2|80|Ecru
c2|b2|f0|Purple Sand
c2|b3|98|Self-Destruct
c2|b7|09|Olive Yellow
c2|b7|9a|Distant Valley
c2|b7|9e|Wagon Wheel
c2|ba|8e|Goody Two Shoes
c2|bb|b2|Soft Dove
c2|bb|bf|Registra
c2|bb|c0|Lace Wisteria
c2|bc|a9|Apparition
c2|bc|b1|Cloud Over London
c2|bd|ba|Grey Shadows
c2|bd|c2|Eskimo White
c2|be|0e|Oilseed Crops
c2|be|ad|Evening Dove
c2|be|b6|Ooid Sand
c2|c0|a9|Swing Sage
c2|c1|8d|Beechnut
c2|c1|cb|Pensive
c2|c3|c7|Pico Metal
c2|c3|d3|Horizon Sky
c2|c7|db|Iced Lavender
c2|cb|b4|Fog Green
c2|cb|d2|Light Oxford
c2|d0|df|Stillwater Lake
c2|d1|e2|Light Ballet Blue
c2|d2|d8|Light Pure Blue
c2|d2|e0|Sea Drive
c2|d3|af|Morris Leaf
c2|d3|d6|Scandinavian Sky
c2|d5|c4|Misty Lake
c2|d6|2e|Fuego
c2|d7|ad|Jade Bracelet
c2|d7|df|Falling Tears
c2|d7|e9|Touch of Blue
c2|db|c6|Quintessential
c2|dd|e6|Hint of June
c2|df|e2|Hint of Continental Waters
c2|e2|e3|Light Timeless
c2|e3|e8|Light Skyway
c2|e4|bc|Sweet Menthol
c2|e4|e7|Light Daly Waters
c2|e6|ec|Onahau
c2|e7|e8|On Cloud Nine
c2|eb|d1|Lost Lace
c2|ec|bc|Lime Dream
c2|f0|e6|Light Water Wings
c2|ff|89|Light Yellowish Green
c3|02|32|Pomodoro
c3|0b|4e|Pictorial Carmine
c3|21|48|Bright Maroon
c3|21|49|Grenade
c3|22|49|Maroon Flush
c3|27|2b|Akabeni
c3|31|40|C-3PO
c3|41|21|Pureed Pumpkin
c3|55|50|Pomegranate
c3|58|5c|Pimm's
c3|64|c5|Purple Urn Orchid
c3|66|3f|Clay Pot
c3|70|5f|Cajun Spice
c3|7c|59|Brown Clay
c3|7c|b3|Daphne Rose
c3|87|43|Fox
c3|8b|36|Victorian Crown
c3|90|9b|Grey Pink
c3|91|43|Yellow Ocher
c3|91|91|Floral Tapestry
c3|94|49|Narcissus
c3|96|4d|Tinsel
c3|98|8b|Muddy Quicksand
c3|99|53|Aztec Gold
c3|9b|6a|Taffy
c3|9e|44|Golden Field
c3|9e|81|Retributor Armour Metal
c3|a1|b6|Pretty Lady
c3|a6|79|Medallion
c3|a7|9a|Taupe Tapestry
c3|ab|a8|Dusky
c3|ac|98|Transcend
c3|ac|b7|Breathtaking View
c3|b0|91|Khaki
c3|b1|9f|Frontier Fort
c3|b1|be|La-De-Dah
c3|b2|96|Beachside Villa
c3|b3|b2|Soft Tone
c3|b4|b3|Young Fawn
c3|b9|a6|Dusty Trail Rider
c3|b9|d8|Lilac Lust
c3|b9|dd|Melrose
c3|ba|bf|Lilac Marble
c3|bc|90|Candidate
c3|bc|b3|Linnet
c3|bd|aa|Candle Bark
c3|bd|ab|White Primer
c3|bd|b1|Heifer
c3|be|bb|Pale Slate
c3|c0|bb|Grey Pearl
c3|c1|75|Grass Root
c3|c3|b8|Baby Barn Owl
c3|c3|bd|Grey Nickel
c3|c6|a4|Sage Splendor
c3|c6|c8|Oyster Mushroom
c3|c6|cd|Flat Aluminum
c3|c7|b2|Pale Pine
c3|c7|bd|Silent Storm
c3|c9|e6|Powdered Granite
c3|ca|d3|Light Spirit
c3|cd|c9|Rediscover
c3|cd|e6|Periwinkle Grey
c3|d3|63|Wild Lime
c3|d3|a8|Reed
c3|d4|e7|Cry Baby Blue
c3|d5|e5|Light Ridge Light
c3|d5|e8|Light Newman's Eye
c3|d6|bd|Surf Crest
c3|d8|25|Young Grass
c3|d9|97|Lickety Split
c3|d9|cb|Snow Goose
c3|d9|ce|Fuchsite
c3|d9|e4|Magic Wand
c3|dc|68|Citrus Lime
c3|dc|d5|Green Wave
c3|dc|e9|Purification
c3|dd|d6|Opal Blue
c3|dd|ee|Island View
c3|e7|e8|Pale Seafoam
c3|e9|d3|Martian Moon
c3|e9|e4|Soothing Sea
c3|ec|e9|Light Cool Crayon
c3|fb|f4|Duck Egg Blue
c4|02|33|Vampire Bite
c4|1e|3a|Cardinal
c4|40|41|Costa Rican Palm
c4|42|40|Reddish
c4|55|08|Rust Orange
c4|56|55|Fuzzy Wuzzy Brown
c4|62|10|Alloy Orange
c4|62|15|Autumn Maple
c4|7c|5e|Terracotta Chip
c4|86|77|Argyle Rose
c4|8d|69|Hitching Post
c4|8e|36|Calico Cat
c4|8e|69|Shiracha Brown
c4|8e|fd|Liliac
c4|90|87|Evening Blush
c4|91|5e|Mid Tan
c4|96|2c|Tawny Olive
c4|98|9e|Rose Meadow
c4|9b|d4|Mauve Mist
c4|9c|a5|Casa Talec
c4|9e|69|Good Life
c4|9e|8f|Whistler Rose
c4|a2|95|Just Rosey
c4|a3|bf|Marsh Orchid
c4|a6|47|Oil Yellow
c4|a6|61|Spring Roll
c4|a7|77|Gold Rush
c4|a8|cf|Feminine Fancy
c4|aa|4d|Sun Dance
c4|ab|7d|Cobbler
c4|ab|86|Croissant
c4|ac|b2|Pale Lychee
c4|ad|92|Kangaroo Fur
c4|ad|c9|Purple Chalk
c4|ae|96|Persuasion
c4|af|b3|Mature
c4|b7|d8|Tinted Iris
c4|b9|b7|Elegant Ice
c4|b9|b8|Nebulous
c4|ba|a1|Dancing Dolphin
c4|ba|b6|Mauve Stone
c4|ba|b7|Japanese Poet
c4|bd|ba|Hush
c4|bf|71|Linden Green
c4|c0|e9|Violet Gems
c4|c2|ab|Delta Waters
c4|c2|bc|San Francisco Fog
c4|c3|d0|Lavender Dust
c4|c4|bc|Mist Grey
c4|c4|c4|Weathered Stone
c4|c4|c7|Runefang Steel
c4|c5|ad|Bahia Grass
c4|c7|c4|Solitary State
c4|c9|e2|Silver Sweetpea
c4|cc|7a|Calamansi Green
c4|cd|87|Soft Celery
c4|ce|3b|Greedy Gold
c4|ce|bf|Gentle Calm
c4|d1|c2|Dewkist
c4|d3|dc|Sentimental Lady
c4|d3|e3|Leap of Faith
c4|d5|cb|Gracilis
c4|d6|af|Hamster Habitat
c4|d7|cf|Geyser
c4|d9|eb|Light Morality
c4|d9|ef|Light Powder Blue
c4|da|dd|Light Dewpoint
c4|dd|e2|Galactica
c4|ea|d5|Frozen Pea
c4|ee|e8|Light Chalk Blue
c4|fe|82|Light Pea Green
c4|ff|f7|Crushed Ice
c5|19|59|Bright Rose
c5|31|51|Dingy Dungeon
c5|33|46|Tomato Puree
c5|3a|4b|Calypso Berry
c5|3d|43|Red Safflower
c5|4b|8c|Mulberry Yogurt
c5|4f|33|Trinidad
c5|73|3d|Peach Caramel
c5|75|56|Spanish Peanut
c5|76|44|Tomato Cream
c5|7f|2e|Mulberry Thorn
c5|83|2e|Geebung
c5|83|80|Prancer
c5|84|7c|Luscious Lobster
c5|8e|ab|Bonny Belle
c5|8f|94|Dogwood Bloom
c5|8f|9d|Beetroot Rice
c5|91|37|Golden Grain
c5|97|82|Revenant Brown
c5|98|8c|Persian Bazaar
c5|a1|93|Mahogany Rose
c5|a2|53|Sauterne
c5|a5|82|Latte
c5|ad|b4|Velvet Ears
c5|ae|7c|Butterbrot
c5|ae|91|Warm Sand
c5|ae|b1|Burnished Lilac
c5|ae|cf|Orchid Bloom
c5|b1|a0|Cracked Earth
c5|b2|8b|Earthy Cane
c5|b3|58|Vegas Gold
c5|b4|7f|Aviva
c5|b4|97|Barking Prairie Dog
c5|b5|a4|Steveareno Beige
c5|b5|ca|Delicate Mauve
c5|b8|a8|White Tiger
c5|b9|b4|Rubidium
c5|b9|d3|Lavender Pillow
c5|ba|a0|Sisal
c5|bb|ae|Peyote
c5|bb|af|Sequoia Fog
c5|bd|c4|Stately Frills
c5|c0|ac|Serene Thought
c5|c1|a3|Northern Landscape
c5|c2|be|Gallery Grey
c5|c3|b0|Kangaroo
c5|c5|6a|Powdered Green Tea
c5|c5|ac|Tame Thyme
c5|c5|c5|Lunar Rock
c5|c5|d3|Kiri Mist
c5|c6|c7|Glacier Grey
c5|c9|c7|Fireplace Kitten
c5|ca|be|Life Lesson
c5|cb|e1|Periwinkle Powder
c5|cc|7b|Celery Green
c5|cc|c0|Green Tint
c5|cd|40|Sunny Green
c5|ce|d8|Light Elusive Blue
c5|cf|98|Lily Green
c5|cf|b1|April Wedding
c5|cf|b6|Tender Greens
c5|d0|d9|Light Pre School
c5|d0|e6|Periwinkle Dust
c5|d1|d8|Wind Weaver
c5|d1|da|Polished Silver
c5|d2|b1|Hidden Hills
c5|d2|df|Light Time Travel
c5|d8|e9|Light Melt Ice
c5|d9|e3|Blue Pearl
c5|dc|b3|White Vienna
c5|de|d1|Light Lichen
c5|e3|84|Yellow Green Shade
c5|e5|e2|Swan Lake
c5|e6|a4|Field Day
c5|e6|d1|Mint Smoothie
c5|e7|cd|Granny Apple
c5|e8|e7|Saline Water
c5|f5|e8|Shallow End
c6|17|4e|Virtual Pink
c6|1a|1b|Hemoglobin Red
c6|21|68|Pink Peacock
c6|2d|42|Pink Pepper
c6|45|2f|Mexican Red Papaya
c6|49|4c|Rusty Chainmail
c6|51|02|Dark Orange
c6|57|7c|Panama Rose
c6|67|87|Old Geranium
c6|6b|27|Kincha Brown
c6|6b|30|Desert Spice
c6|72|3b|Zest
c6|73|63|Sahara Sun
c6|79|5f|Gold Pheasant
c6|7f|ae|Crocus
c6|84|00|Bubonic Brown
c6|84|63|Pheasant
c6|87|6f|Secluded Canyon
c6|88|86|All's Ace
c6|8e|3f|Anzac
c6|8f|65|Butterum
c6|97|3f|Golden Spice
c6|98|96|Fall Canyon
c6|9c|04|Molten Bronze
c6|9c|5d|Wildflower Honey
c6|9f|26|Mustard Seed
c6|9f|59|Camel
c6|a4|99|Rose Bisque
c6|a4|a4|Pale Mauve
c6|a6|68|Flickering Gold
c6|a6|98|Howdy Partner
c6|a9|5e|Laser
c6|aa|2b|Hippie Trail
c6|aa|81|Pony
c6|ae|aa|Wispy Mauve
c6|b1|83|Desert Floor
c6|b2|be|Masked Mauve
c6|b4|9c|Best Beige
c6|b4|a9|Portrait Pink
c6|b6|b2|Grey Rose
c6|b7|88|Bakelite Yellow
c6|b8|ae|Froth
c6|ba|af|Legendary
c6|bb|68|Secret Safari
c6|bb|9c|Beach Dune
c6|bb|a2|Winding Path
c6|bb|db|New Love
c6|bd|bf|Wallis
c6|be|dd|Purple Dragon
c6|bf|a7|Zen Essence
c6|c1|91|Lime Peel
c6|c2|b6|Kamenozoki Grey
c6|c5|c6|Antarctica
c6|c6|c2|Brume
c6|c6|c6|Silver Polish
c6|c8|cf|Herring Silver
c6|cc|d4|Light Blunt
c6|ce|c3|Silver Grass
c6|cf|ad|Bamboo White
c6|d2|d2|Ice Flow
c6|d2|de|Light Bypass
c6|d4|ac|Pistachio Pudding
c6|d4|e1|Light Cameo Blue
c6|d5|e4|Light Blue Ballerina
c6|d5|ea|Light Radar
c6|d6|24|Lime Twist
c6|d6|d7|Skydiving
c6|d8|c7|Marsh Fog
c6|da|36|Las Palmas
c6|dc|c7|Misty Afternoon
c6|dc|e7|Hint of Wavecrest
c6|dd|cd|Green Wash
c6|dd|e4|Hint of Airborne
c6|de|cf|Solitaire
c6|de|df|Light Dante Peak
c6|e0|e1|Hint of Aqua Mist
c6|e3|e1|Blue Glass
c6|e3|f7|Fresh Water
c6|e4|e9|Hint of Tenzing
c6|e4|eb|Surf's Up
c6|e5|ca|Wintergreen Mint
c6|ea|80|Sulu
c6|ea|dd|Mint Tulip
c6|ec|7a|Sharp Green
c6|f0|e7|Light Gentle Giant
c6|f8|08|Green Yellow
c6|fc|ff|Thin Air
c7|03|1e|Monza
c7|15|81|Bramble Jam
c7|15|85|Medium Violet Red
c7|1f|2d|High Risk Red
c7|2c|48|French Raspberry
c7|43|75|Fuchsia Rose
c7|47|67|Deep Rose
c7|54|33|Spicy Tomato
c7|60|7b|Cherry Pink
c7|60|ff|Jacaranda Pink
c7|61|0f|Kvass
c7|61|55|Sunglo
c7|72|c0|Gulābī Pink
c7|76|90|Watermelon Pink
c7|79|43|Golden Ochre
c7|79|86|Old Pink
c7|7e|4d|Fuegan Orange
c7|88|7f|Sunstone
c7|8b|95|Solid Pink
c7|92|7a|African Bubinga
c7|96|85|Cafe Creme
c7|99|4f|Laredo Road
c7|9b|36|Sun Dial
c7|9d|9b|Pepperberry
c7|9e|5f|Ole Yeller
c7|9e|a2|Beauty Secret
c7|9f|ef|Lavender Cream
c7|a0|6c|Bleached Maple
c7|a1|a9|Lighthearted Rose
c7|a3|84|Rodeo Dust
c7|a7|7b|Sugar Pie
c7|a9|98|Arrow Quiver
c7|aa|71|Taiwan Gold
c7|aa|7c|Waves of Grain
c7|ab|84|Middlestone
c7|ac|7d|Toupe
c7|af|88|Earth Chi
c7|b3|9e|Rincon Cove
c7|b5|95|Mojave Desert
c7|b6|3c|Warm Olive
c7|b8|82|Yuma
c7|b8|9f|Forgotten Gold
c7|b8|a4|Sandy Toes
c7|b8|a9|Mooloolaba
c7|bb|a4|Another One Bites the Dust
c7|bc|a2|Coral Reef
c7|bd|a8|Seagull Wail
c7|bd|c1|Pale Lady
c7|be|be|Oil Of Lavender
c7|be|c4|Glass Bead
c7|bf|c3|Easter Rabbit
c7|c0|a7|Country Charm
c7|c0|ce|Clary Sage
c7|c1|0c|Cricket Chirping
c7|c1|b7|Gettysburg Grey
c7|c1|bb|Taupe White
c7|c2|ce|Femininity
c7|c3|be|Overdue Grey
c7|c4|a5|Ta Prohm
c7|c5|ba|Union Station
c7|c5|dc|Violet Sweet Pea
c7|c7|a1|Watercress Pesto
c7|c7|c2|Dolphin Tales
c7|c7|c3|Bleaches
c7|c7|c9|Shining Silver
c7|c8|44|Tansy
c7|ca|86|Chimes
c7|cc|d8|Violet Powder
c7|cc|e7|Ace
c7|cd|d3|Light Blue Rinse
c7|cd|d8|Link Water
c7|ce|e8|Purple Pj's
c7|cf|be|Frosty Pine
c7|d1|db|Memory Lane
c7|d2|dd|Light Stargate
c7|d3|68|Soft Fern
c7|d3|d5|Whale's Mouth
c7|d3|e0|Ozone Blue
c7|d4|ce|Synchronicity
c7|d7|e0|Yeti Footprint
c7|d8|e3|Water Mist
c7|d9|cc|Dry Lichen
c7|db|d9|Julep Green
c7|dc|68|Dry Seedlings
c7|de|88|Coincidence
c7|df|b8|Satin Green
c7|df|e6|Hint of Blue Dam
c7|e0|d9|Ulthuan Grey
c7|e5|df|Moonlight Jade
c7|fd|b5|Distilled Venom
c7|ff|ff|VIC 20 Blue
c8|08|15|Venetian Red
c8|38|5a|Cherry Lolly
c8|3c|b9|Purple Pink
c8|41|86|Smitten
c8|4c|61|Claret Red
c8|51|79|Middle Safflower
c8|5a|53|Dark Salmon
c8|6b|3c|Apricot Orange
c8|71|63|Living Large
c8|75|6d|Red Sparowes
c8|75|c4|Moth Orchid
c8|76|06|Dirty Orange
c8|76|29|Desert Sun
c8|77|63|Pompeian Pink
c8|7f|89|Grey Matter
c8|8c|a4|Pinch Me
c8|8d|94|Greyish Pink
c8|91|34|Mecca Gold
c8|91|80|Black Hills Gold
c8|96|72|Sonora Shade
c8|97|20|Nugget Gold
c8|98|7e|Chinook Salmon
c8|9b|75|Chimera Brown
c8|9d|3f|Goldie
c8|9f|59|Warm Leather
c8|9f|a5|Zephyr
c8|a2|c8|Stormy Sunrise
c8|a3|bb|Exquisite
c8|a4|bd|Dancing Wand
c8|a4|bf|Lilac Fluff
c8|a6|92|Moenkopi Soil
c8|a6|a1|Parfait
c8|a8|83|Toffee Tan
c8|a8|9e|Teatime Mauve
c8|a9|92|Friendly Homestead
c8|ac|89|Dwarf Rabbit
c8|ac|a9|Pinkish Grey
c8|ad|7f|Light French Beige
c8|ae|96|Light Brown Sugar
c8|b0|89|Cappuccino Froth
c8|b1|65|Split Pea Soup
c8|b1|c0|Maverick
c8|b6|9e|Puddle
c8|ba|63|Baby Frog
c8|ba|d4|Purple Shine
c8|bc|b7|Fond Memory
c8|bd|6a|Moray
c8|be|b1|Raw Cashew Nut
c8|c0|aa|Hideaway
c8|c1|ab|Castle Wall
c8|c2|be|Dim
c8|c2|c0|White Flag
c8|c2|c6|Haze
c8|c3|87|Fiddlehead Fern
c8|c5|a7|Cargo Green
c8|c5|d7|Amourette
c8|c6|b4|Moss Island
c8|c6|da|Pax
c8|c7|c2|Grey Spell
c8|c7|c5|Grey Dolphin
c8|c8|b4|Nature Spirits
c8|ca|b5|Whispering Pine
c8|cb|cd|Porpoise Fin
c8|cc|9e|Dancing Kite
c8|cc|ba|Green Alabaster
c8|cc|bc|Lamb's Ears
c8|cd|37|Yellow-Green Grosbeak
c8|cd|d8|Light Mistral
c8|ce|c3|Cippolino
c8|ce|d6|Light Kinder
c8|d0|ca|Infusion
c8|d1|c4|White Granite
c8|d2|e2|Light Alley
c8|d4|e7|Light Penna
c8|d5|bb|Willow Tree Mouse
c8|d5|dd|Hint of Hazy Daze
c8|d7|d2|Blue Lullaby
c8|d8|e8|Light Placid Blue
c8|da|c2|Snow Green
c8|da|e3|Hint of Sea Breeze
c8|da|f5|Fly a Kite
c8|db|ce|Tenderness
c8|dd|ea|Hint of Blue Ice
c8|dd|ee|Blue Booties
c8|de|ea|Hint of Mr Frosty
c8|df|c3|Shanghai Silk
c8|e0|e0|Skylight
c8|e3|d2|Duck Egg Cream
c8|e4|b9|Iced Avocado
c8|f3|cd|Mint Gloss
c8|fd|3d|Yellow Green
c8|ff|b0|Light Light Green
c9|00|16|Harvard Crimson
c9|1f|37|Karakurenai Red
c9|23|51|Rose Red
c9|31|2b|Hot Lips
c9|34|13|Harley Davidson Orange
c9|35|43|Red Icon
c9|37|56|Nakabeni Pink
c9|4c|be|Zǐ Sè Purple
c9|54|3a|Cinnamon Stone
c9|5a|49|Cedar Chest
c9|5b|83|Lipstick
c9|5e|fb|After-Party Pink
c9|61|38|Ecstasy
c9|64|3b|Hashut Copper
c9|73|6a|Bombay Pink
c9|73|76|Pink Dazzle
c9|73|a2|Deep Carnation
c9|75|86|Long Spring
c9|92|6e|Texas Hills
c9|93|6f|Surprise
c9|93|87|Mexican Moonlight
c9|9a|a0|Careys Pink
c9|9c|59|Liddell
c9|9f|99|Aged Pink
c9|a0|dc|Autumn Wisteria
c9|a0|df|Silver Rust
c9|a0|ff|Light Wisteria
c9|a1|71|New Fawn
c9|a1|96|Raspberry Kahlua
c9|a3|75|Outback
c9|a3|8d|Maple Sugar
c9|a4|80|Siesta Dreams
c9|a4|87|Labyrinth Walk
c9|a8|6a|Ginger Ale
c9|a8|ce|Catmint
c9|ac|d6|Darling Lilac
c9|ae|74|Sandstone
c9|af|a9|Young Turk
c9|af|d0|Windsor Purple
c9|b0|03|Brownish Yellow
c9|b2|7c|Roasted Pistachio
c9|b5|9a|Sourdough
c9|b7|ce|Softly Softly
c9|bb|a1|Land Rush Bone
c9|bb|a3|Dusty Trail
c9|bd|88|Olive Hint
c9|bd|b7|Dusky Taupe
c9|bd|b8|Vast
c9|bf|b2|Ashen
c9|c0|b1|Malibu Beige
c9|c0|bb|Pale Silver
c9|c3|b5|Whisper Ridge
c9|c3|d2|Laughing Jack
c9|c8|44|Wiggle
c9|ca|d1|Sharp Grey
c9|cb|be|Pale Celadon
c9|cc|4a|Slap Happy
c9|cc|d2|Light Blue Moon
c9|d1|79|Greenish Beige
c9|d1|e9|Arctic Glow
c9|d2|d1|Killer Fog
c9|d2|df|Light Candela
c9|d3|d3|Sky Splash
c9|d3|dc|Illusion Blue
c9|d4|e1|Light Angora Blue
c9|d6|c2|French Limestone
c9|d7|7e|Daiquiri Green
c9|da|e2|Hint of Vanilla Ice
c9|db|c7|Mystified
c9|dc|87|Medium Spring Bud
c9|dc|dc|Whispering Blue
c9|e0|c8|Spring Burst
c9|e1|e0|Light Greenland Ice
c9|e2|cf|Enchanted
c9|e3|cc|Katsura
c9|e3|e5|Hint of Watermark
c9|e4|23|Electric Energy
c9|e7|e3|Light Starlight Blue
c9|f0|d1|Pickford
c9|ff|27|Gǎn Lǎn Huáng Olive
ca|01|47|Ruby
ca|1f|1b|Bloody Red
ca|1f|7b|Magenta Dye
ca|24|25|Flush Mahogany
ca|2c|92|Royal Fuchsia
ca|34|22|Poinciana
ca|34|35|Young Mahogany
ca|37|67|Raspberry Jam
ca|4b|65|California Wine
ca|53|33|Orange Keeper
ca|62|8f|Ibis Rose
ca|66|36|Winter Sunset
ca|66|41|Zōng Hóng Red
ca|69|24|Kohaku Amber
ca|6b|02|Sludge
ca|6c|4d|Reikland Fleshshade
ca|6c|56|Langoustino
ca|79|88|Violet Orchid
ca|7b|80|Dirty Pink
ca|7c|74|Chili Soda
ca|81|36|Golden Bell
ca|84|8a|Brandied Apricot
ca|88|4e|Coral Sand
ca|92|34|Alameda Ochre
ca|93|c1|Pomtini
ca|94|56|Honey Yellow
ca|99|4e|Gingerbread House
ca|9a|5d|Raffles Tan
ca|9b|f7|Baby Purple
ca|9e|9c|Remembrance
ca|9f|a5|Primula
ca|a0|ff|Hydrangea Purple
ca|a8|4c|Grandiose
ca|a9|06|Christmas Gold
ca|ad|76|Sigmarite
ca|ad|92|Basketweave Beige
ca|ae|ab|Lacey
ca|ae|b8|Scented Frill
ca|b0|8e|Spanish Sand
ca|b2|66|Canadian Maple
ca|b2|c1|Runic Mauve
ca|b4|8e|Foothill Drive
ca|b4|d4|Elfin Herb
ca|b5|b2|Cold Turkey
ca|b6|98|Desert Pebble
ca|b7|c0|High Society
ca|b8|a2|Grain Brown
ca|b8|ab|Grey Mauve
ca|ba|a9|Dinosaur Egg
ca|ba|e0|Viking Diva
ca|be|b5|Grey Morn
ca|bf|bf|Nantucket Mist
ca|c0|b0|Beach Woods
ca|c1|9a|Tangled Vines
ca|c2|b9|Pumice Stone
ca|c5|c2|Wind Chimes
ca|c6|ba|Ghosting
ca|c7|b7|Chrome White
ca|c7|bc|Pipe Clay
ca|c7|bf|Early Evening
ca|c7|c4|Ice Grey
ca|c8|b6|French Grey Linen
ca|ca|cb|Leadbelcher
ca|cc|cb|Dawn Blue
ca|cd|ca|Silver Strand Beach
ca|ce|d2|Light Blue To You
ca|cf|dc|Pale Shale
ca|cf|e0|Peace N Quiet
ca|d1|75|Fool's Gold
ca|d2|d4|Salina Springs
ca|d3|c1|Tomatillo Peel
ca|d3|d4|Mount Sterling
ca|d5|c8|Falling Star
ca|d6|c4|Green Lane
ca|d6|de|Hint of Heaven Sent
ca|d7|de|Bit of Heaven
ca|da|da|Cosmic Ray
ca|db|bd|Bethany
ca|db|df|Reflection Pool
ca|dc|de|Shark
ca|dd|de|Light Relax
ca|de|a5|Butterfly
ca|df|dd|Silver Spruce
ca|df|ec|Hint of Sea Cliff
ca|e0|df|Hint of Zenith Heights
ca|e1|d9|Melting Ice
ca|e2|77|Wasabi Paste
ca|e7|e2|Jagged Ice
ca|ed|d0|Celery Stick
ca|ed|e4|Light Ice Cap Green
ca|ff|fb|Light Light Blue
cb|00|f5|Hot Purple
cb|01|62|Deep Pink
cb|34|41|Poinsettia
cb|3d|3c|Heart Throb
cb|41|0b|Sinopia
cb|41|54|New Brick Red
cb|41|6b|Dark Pink
cb|46|4a|Zhū Hóng Vermillion
cb|52|51|Deep Hibiscus
cb|66|49|Enshūcha Red
cb|68|43|Terracotta
cb|6d|51|Copper Red
cb|6f|4a|Red Damask
cb|73|51|Reikland Fleshshade Gloss
cb|73|8b|Allyson
cb|77|23|Brownish Orange
cb|7e|1f|Yamabukicha Gold
cb|8e|00|Festering Brown
cb|8e|81|Rose de Mai
cb|90|4e|Slightly Golden
cb|99|c9|Pastel Violet
cb|9d|06|Yellow Ochre
cb|a1|35|Satin Sheen Gold
cb|a5|60|Sand Brown
cb|a7|92|Primal
cb|a9|56|Glorious Gold
cb|b3|94|Sycorax Bronze
cb|b4|89|Somber
cb|b5|c6|Cool Quiet
cb|b6|8f|Warm and Toasty
cb|ba|61|Lemon Lime Mojito
cb|bb|92|Balsa Stone
cb|bf|b3|Finishing Touch
cb|c0|b3|Loophole
cb|c1|ae|Oyster Grey
cb|c2|ad|Tuft
cb|c3|b4|Oatmeal
cb|c4|c0|In the Shadows
cb|c5|c6|Dangerous Robot
cb|c5|d9|Lilac Crystal
cb|c8|c2|Vanilla Quake
cb|c8|dd|Gregorio Garden
cb|c9|c0|Quill Grey
cb|ca|b6|Tropical Fog
cb|cb|bb|Livingstone
cb|cb|cb|Cerebellum Grey
cb|cc|b5|Only Olive
cb|cd|c4|Silhouette
cb|cd|cd|Machined Iron
cb|ce|be|Celadon Tint
cb|ce|c0|Harp
cb|d0|cf|Geyser Steam
cb|d0|d7|Light Starlight
cb|d0|dd|Debonaire
cb|d1|d0|Ghost Whisperer
cb|d1|e1|Sweet Emily
cb|d3|c1|Carrot Flower
cb|d3|c3|Iced Aniseed
cb|d3|c6|Parakeet Pete
cb|d3|e6|Light Objectivity
cb|d4|df|Light Angelic Blue
cb|d5|b1|Mint Soap
cb|d7|d2|Sprout Green
cb|d7|ed|Light Cuddle
cb|d9|d7|Thunder Bay
cb|dc|df|Wan Blue
cb|de|e2|Embellishment
cb|de|e3|Hint of Salt Spray
cb|e1|e4|Hint of Sky Chase
cb|e1|ee|Hint of Template
cb|e1|f2|Hint of Island Light
cb|e3|ee|Niagara Falls
cb|e4|e7|Hint of Wave
cb|e8|df|Light Short Phase
cb|e8|e8|Mabel
cb|e9|c9|Frosty Dawn
cb|ea|ee|Hint of Ice Pack
cb|ed|e5|Whisper of Grass
cb|ef|cb|Carolina
cb|f8|5f|Pear Spritz
cc|00|00|Boston University Red
cc|00|01|Albanian Red
cc|00|11|Lazy Shell Red
cc|00|22|Rare Rhubarb
cc|00|33|Vivid Crimson
cc|00|cc|Screaming Magenta
cc|00|ff|Vivid Orchid
cc|04|04|Rebellion Red
cc|11|00|Vampire State Building
cc|11|11|Hawthorn Berry
cc|1c|3b|Lollipop
cc|22|00|Piment Piquant
cc|22|44|Pepper Jelly
cc|22|88|Purple Heart Kiwi
cc|33|00|Pleasant Pomegranate
cc|33|11|Amarantha Red
cc|33|33|Persian Red
cc|33|36|Madder Lake
cc|33|44|Infrared Flush
cc|33|55|Infrared Gloze
cc|33|8b|Magenta Pink
cc|33|cc|Steel Pink
cc|36|3c|Bento Box
cc|44|00|Mellow Mango
cc|44|ff|Pink Insanity
cc|47|4b|English Vermillion
cc|4e|5c|Dark Terra Cotta
cc|51|60|Cherry Hill
cc|55|00|Burnt Orange
cc|55|33|Bronze Satin
cc|55|88|Pretty in Plum
cc|55|ff|Pink Fever
cc|66|66|Fuzzy Wuzzy
cc|66|99|Nocturnal Rose
cc|66|dd|Blueberry Glaze
cc|67|58|Southwestern Clay
cc|69|e4|Purple Snail
cc|73|57|Dusted Clay
cc|74|46|Garnet Sand
cc|77|00|Mountain Ash
cc|77|11|Tree Sap
cc|77|22|Ochre
cc|77|33|Ochre Maroon
cc|77|55|Caramel Infused
cc|77|88|Smoke Bush
cc|7a|8b|Dusky Pink
cc|81|49|Sticky Toffee
cc|85|5a|Shamanic Journey
cc|86|54|Caramel Bar
cc|88|11|Lobster Butter Sauce
cc|88|33|Brown Beige
cc|88|44|Raw Linen
cc|88|55|Cork Brown
cc|88|88|Almond Rose
cc|88|99|Puce
cc|88|dd|Blush Essence
cc|88|ff|Crash Pink
cc|8f|15|End of Summer
cc|94|69|Santa Fe Sunrise
cc|94|be|Moorland Heather
cc|97|4d|Bengal
cc|99|00|Vivid Amber
cc|99|11|Australien
cc|99|22|Duck Sauce
cc|99|33|Gomashio Yellow
cc|99|99|Silk Stone
cc|99|aa|Honey Pink
cc|99|bb|Peach Buff
cc|99|cc|Light Greyish Magenta
cc|99|ff|Lilás
cc|9d|c6|Prize Winning Orchid
cc|a1|95|Musk
cc|a4|83|Kamut
cc|a5|80|Porcini
cc|a6|bf|Safflower Wisteria
cc|aa|00|Hot Sand
cc|aa|55|Golden Blond
cc|aa|77|Burning Gold
cc|aa|88|African Sand
cc|aa|99|Tempting Taupe
cc|aa|ff|Purple Hepatica
cc|ac|86|DaVanzo Beige
cc|ad|60|Desert
cc|af|92|Dover Plains
cc|b0|b5|Adeline
cc|b3|90|Almond Buff
cc|b4|90|Windsor Toffee
cc|b4|9a|Stonish Beige
cc|b6|9b|Vanilla Seed
cc|b8|8d|Canvas Satchel
cc|b8|96|Real Simple
cc|b8|b3|Subdue Red
cc|b8|d2|Liberace
cc|b9|7e|Dried Moss
cc|b9|94|Veranda Hills
cc|ba|b1|Osprey Nest
cc|ba|be|Pink Polar
cc|bb|88|Sand Paper
cc|bb|99|Intimate Journal
cc|bb|bb|Silentropae Cloud
cc|bb|c0|Lady Fingers
cc|bb|ff|Lavender Tonic
cc|bd|b9|Barely Mauve
cc|be|ac|Birchwood
cc|be|b6|Blanched Driftwood
cc|bf|c7|Silk Chiffon
cc|bf|c9|Puffball
cc|c1|da|Awesome Aura
cc|c4|ae|Bauhaus Tan
cc|c6|d7|Dreamweaver
cc|c7|a1|Floating Lily Pad
cc|ca|a8|Thistle Green
cc|cc|00|Golden Foil
cc|cc|33|Lizard Belly
cc|cc|ba|Mix Or Match
cc|cc|bb|Kittiwake Gull
cc|cc|cc|Cerebral Grey
cc|cc|d3|Ghostly Grey
cc|cc|dd|Lunar Dust
cc|cc|ff|Lavender Blue
cc|cf|82|Deco
cc|d0|da|Light Image Tone
cc|d1|c8|Washed Green
cc|d3|d8|Shiny Nickel
cc|d4|cb|Celadon Glaze
cc|d5|ff|Pale Phthalo Blue
cc|d6|b0|Chinese Leaf
cc|d8|7a|Goody Gumdrop
cc|da|d7|Chalk Blue
cc|db|1e|Evening Primrose
cc|dd|00|Octarine
cc|dd|99|Pear Perfume
cc|dd|a1|Frisky
cc|dd|bb|Golden Crested Wren
cc|dd|ee|Tuğçe Silver
cc|dd|ff|Arc Light
cc|df|dc|Light Pale Icelandish
cc|df|e8|Duck's Egg Blue
cc|e1|c7|Soft Moss
cc|e1|ee|Hint of Tidal Foam
cc|e2|dd|Light High Point
cc|e5|e8|Hint of Aqua Frost
cc|e7|e8|Hint of Pool Side
cc|eb|f5|Frosty Day
cc|ee|bb|Toxic Essence
cc|ee|c2|Celery Victor
cc|ee|cc|Spring Savor
cc|f1|e3|Light Salome
cc|fd|7f|Light Yellow Green
cc|ff|00|Electric Lime
cc|ff|02|Fluorescent Yellow
cc|ff|cc|Distilled Moss
cc|ff|ff|Dawn Departs
cd|01|01|Lannister Red
cd|07|1e|Chinese Red
cd|0d|01|Diablo Red
cd|21|2a|Flame Scarlet
cd|40|35|Rebel Red
cd|4a|4a|African Mahogany
cd|52|52|Chestnut Rose
cd|52|5b|Mandy
cd|52|6c|Cabaret
cd|57|00|Tenné
cd|59|09|Rusty Orange
cd|5b|26|Bright Delight
cd|5b|45|Bugman's Glow
cd|5c|51|Firebug
cd|5c|5c|Common Chestnut
cd|5e|3c|Reed Mace
cd|60|7e|Cinnamon Satin
cd|68|e2|Sensual Fumes
cd|6d|93|Hopbush
cd|75|84|Discrete Pink
cd|7a|00|German Mustard
cd|7a|50|Challah Bread
cd|7d|b5|Peruvian Lily
cd|7e|4d|Apricot Buff
cd|7f|32|Polished Bronze
cd|80|32|Chinese Bronze
cd|82|7d|Raspberry Ripple
cd|84|31|Dixie
cd|85|3f|Peru
cd|91|5c|Napa Sunset
cd|99|45|Arabian Bake
cd|a0|35|Tiger Cat
cd|a0|9a|Raffia Cream
cd|a2|ac|Whisper of Rose
cd|a3|23|Lemon Curry
cd|a4|de|Spring Wisteria
cd|a5|63|Caribou Herd
cd|a5|9c|Eunry
cd|a5|df|Tropical Violet
cd|a8|94|Half Moon Bay Blush
cd|ad|59|Hay Wain
cd|ae|70|Putty
cd|ae|a5|Lime Hawk Moth
cd|b1|ab|Garden Snail
cd|b2|a5|Rose Dust
cd|b3|86|Oak Harbour
cd|b6|9b|Glass Sand
cd|b6|a0|Recycled
cd|b8|91|Flier Lie
cd|b9|a2|Rustic Taupe
cd|ba|99|Spiced Vinegar
cd|ba|cb|Antique Heather
cd|bb|a5|Wise Owl
cd|bd|ba|Wafting Grey
cd|bf|c6|Elusive Dream
cd|c2|ca|Limpid Light
cd|c4|ba|Eggshell Pink
cd|c5|0a|Dirty Yellow
cd|c5|86|Tyrant Skull
cd|c5|c2|Silver Cross
cd|c6|bd|Moonbeam
cd|c6|c5|Alto
cd|c7|96|Martini Olive
cd|c7|bb|Featherstone
cd|c8|d2|Chrome Chalice
cd|ca|98|Tidal Green
cd|ca|ce|Light Mauve Pansy
cd|cc|be|Metallic Mist
cd|cc|d0|Dusty Grey
cd|cd|cd|Compact Disc Grey
cd|ce|be|Pallid Wych Flesh
cd|ce|d5|Light Anon
cd|d0|c0|Glass Tile
cd|d2|bc|Garlic Suede
cd|d2|c9|Fundy Bay
cd|d2|de|Light Blue Bayou
cd|d3|a3|True To You
cd|d4|7f|Green Gecko
cd|d4|c6|Horizon Island
cd|d5|d5|Zumthor
cd|d6|c2|Ligado
cd|d6|ea|Light Hindsight
cd|d7|8a|Lime Sherbet
cd|d7|9d|Cucumber Ice
cd|d7|ec|Lilac Cotton Candy
cd|db|dc|Light Detroit
cd|dc|e3|Dartmoor Mist
cd|dc|ed|Alaskan Skies
cd|de|d7|Light Quaver
cd|e2|de|Big Sky
cd|e5|de|Light Picnic Bay
cd|e5|e2|Light Supernova
cd|e7|dd|Light Otto Ice
cd|ea|cd|Applemint
cd|ec|ed|Hint of Karma
cd|f8|0c|Liquid Lime
cd|fd|02|Greenish Yellow
ce|11|27|Philippine Red
ce|16|20|Fire Axe Red
ce|20|29|Fireball
ce|26|1c|Clear Red
ce|31|75|Pink Yarrow
ce|46|76|Rubber Band
ce|4e|35|Bonfire Flame
ce|59|24|Play School
ce|5b|78|Fruit Dove
ce|5d|ae|Pú Táo Zǐ Purple
ce|5e|9a|Phlox Pink
ce|5f|38|Campfire
ce|6b|a4|Super Pink
ce|72|59|Japonica
ce|76|39|Wulfenite
ce|77|90|Devilish Diva
ce|78|50|Brazen Orange
ce|7b|5b|Brandied Melon
ce|84|77|Canyon Clay
ce|84|98|Wild Rose
ce|85|44|Melted Copper
ce|87|9f|Cashmere Rose
ce|8c|42|Flesh Wash
ce|8e|8b|Rosette
ce|90|96|Ducal Pink
ce|94|80|Tint of Earth
ce|95|00|Elysium Gold
ce|98|44|Mayan Treasure
ce|9f|2f|Herald's Trumpet
ce|9f|6f|White Oak
ce|a1|9f|Sakura Mochi
ce|a2|fd|Lilac
ce|aa|64|Ginger Crunch
ce|ab|77|Golden Age
ce|ab|90|Beach Boardwalk
ce|ad|8e|Woven Navajo
ce|ad|be|Fragrant Lilac
ce|ae|bb|Pink Potion
ce|ae|fa|Pale Violet
ce|af|81|Saxophone Gold
ce|b0|2a|Grass Daisy
ce|b3|01|Mustard
ce|b5|b3|Smoked Lavender
ce|b5|c8|Janey's Party
ce|b7|36|Yellowstone
ce|b8|99|Semolina
ce|b9|c4|Rose Marble
ce|ba|a8|Smoke Grey
ce|ba|da|Pussy Foot
ce|be|9f|Bungalow Taupe
ce|be|da|Perspective
ce|bf|9c|Tumbling Tumbleweed
ce|c1|92|Rainforest Fern
ce|c1|a5|Stylish
ce|c1|b5|Whippet
ce|c3|d2|Orchid Hush
ce|c5|ad|Prairie Dusk
ce|c5|b6|Tombstone Grey
ce|c6|bb|Zebra Finch
ce|c7|dc|Angel Kiss
ce|c8|ef|Soap
ce|ca|ba|White Duck
ce|ca|c1|Swirling Smoke
ce|ca|e1|Opus
ce|cd|ad|Eaves
ce|cd|b8|Moon Mist
ce|cd|bb|Pale Tendril
ce|cd|c5|So Chic!
ce|ce|af|Longbeard Grey
ce|cf|d6|Light Lavender Oil
ce|d2|ab|Olive Martini
ce|d3|c1|Merry Music
ce|d5|e4|Light Pale Lilac
ce|d8|c1|Turtle Chalk
ce|da|c3|Breakaway
ce|dc|d4|Light Soft Celadon
ce|dc|d6|Light White Box
ce|dd|a2|Lettuce Alone
ce|dd|da|Light Antarctica Lake
ce|dd|e7|Simply Elegant
ce|de|e2|High Sierra
ce|de|e7|Fenrisian Grey
ce|e0|e3|Nymphaeaceae
ce|e1|c8|Endive
ce|e1|d4|Clearly Aqua
ce|e1|d9|Light Meadow Lane
ce|e1|f2|Hint of Blue Mist
ce|e2|e2|Lens Flare Blue
ce|e3|d9|Light Silverton
ce|e3|dc|Dew Not Disturb
ce|e5|df|Light Pinnacle
ce|e9|a0|Crystal Apple
ce|ee|ef|Morning Calm
ce|ef|e4|Hummingbird
ce|f0|cc|Pastel Mint
ce|f2|e4|Light Shutterbug
ce|ff|00|Volt
cf|02|34|Cherry
cf|10|20|Lava
cf|2d|71|Beetroot Purple
cf|34|76|Telemagenta
cf|3a|24|Ake Blood
cf|3c|71|Qermez Red
cf|3f|4f|Hóng Lóu Mèng Red
cf|52|4e|Dark Coral
cf|62|75|Tuna Sashimi
cf|69|77|Desert Rose
cf|71|af|Sky Magenta
cf|75|8a|First Love
cf|81|79|Coral Garden
cf|87|5e|Georgian Leather
cf|87|5f|Harvest Time
cf|8d|6c|Cinnamon Brandy
cf|93|46|Fleshtone Shade Wash
cf|93|84|Rosy Queen
cf|96|32|Golden Pheasant
cf|9c|63|Oak Buff
cf|9f|52|Bright Gold
cf|9f|a9|Pink Ice
cf|a1|4a|Chipmunk
cf|a3|3b|Cremini
cf|a4|6b|Root Beer Float
cf|a7|43|Brassed Off
cf|ac|47|Haystacks
cf|ae|74|Let It Ring
cf|af|7b|Fawn
cf|b0|95|Beige Ganesh
cf|b1|d8|Sea Lavender
cf|b3|52|Gold Gleam
cf|b3|a6|Cosmic Aura
cf|b5|3b|Old Gold
cf|b7|c9|Soft Amethyst
cf|b9|89|Appalachian Trail
cf|b9|99|High Noon
cf|bb|9b|Bird's Nest
cf|bb|d8|Petite Purple
cf|bd|ba|Moth Pink
cf|be|a5|Soft Amber
cf|bf|b9|Musk Dusk
cf|c5|a7|Cyrus Grass
cf|c5|b6|Sunray Venus
cf|c6|bc|Intuitive
cf|c7|b9|Cobblestone Street
cf|c7|d5|Moon Goddess
cf|c8|b8|Beige Royal
cf|c8|bd|Rainy Day
cf|c9|bc|Storm's Coming
cf|c9|c0|Limed White
cf|c9|c5|Slight Mushroom
cf|c9|c7|Warm Ash
cf|ca|c1|Grey Pebble
cf|cd|bb|Cargo River
cf|cd|cf|Very Light Grey
cf|cf|c4|Pastel Grey
cf|cf|cf|American Silver
cf|d0|c1|Serena
cf|d1|b2|Bitter Melon
cf|d1|d8|Light Slipper Satin
cf|d2|b5|Pickling Spice
cf|d2|c7|Frivolous Folly
cf|d3|a2|Calming Effect
cf|d5|a7|Trailing Vine
cf|d5|d7|Veiled Spotlight
cf|d9|de|Zen
cf|da|c3|Issey-San
cf|db|8d|Lime Splash
cf|db|d1|Milky Green
cf|dd|7b|Golden Hop
cf|dd|b9|Green Parlor
cf|de|d7|Light Spearmint Ice
cf|df|db|Snow Leopard
cf|df|dd|Water Baptism
cf|df|ef|Hint of Water Wash
cf|e0|9d|Shadow Lime
cf|e0|d7|Light Soft Fresco
cf|e0|f2|Hint of Breezy
cf|e1|ef|Hint of Blue Veil
cf|e2|e0|Mountain Dew
cf|e2|ef|Hint of Featherbed
cf|e4|ee|Diamond Blue
cf|e5|87|Refreshed
cf|e5|f0|Pale Frost
cf|e7|cb|Butter Lettuce
cf|e8|38|Lime Fizz
cf|e8|b6|Frozen Forest
cf|eb|de|Light Beru
cf|ec|ee|Hint of Vandamint
cf|ee|e8|Underwater
cf|f6|f4|Tinted Ice
cf|f7|ef|Mid Spring Morning
cf|fd|bc|Very Pale Green
cf|ff|00|Bitter Lime
cf|ff|04|Neon Yellow
d0|1c|1f|Fiery Red
d0|41|7e|Jaipur Pink
d0|4a|70|Pink Punch
d0|57|6b|Imayou Pink
d0|5e|34|Chilean Fire
d0|73|60|OK Corral
d0|74|8b|Charm
d0|83|63|Burning Sand
d0|89|3f|Yam
d0|8a|9b|Can Can
d0|92|58|Polo Pony
d0|93|51|Cold Pilsner
d0|98|00|Leopard
d0|a0|00|Lepton Gold
d0|a4|92|The Boulevard
d0|a6|64|Burnside
d0|a7|a8|Baby Jane
d0|ab|70|More Maple
d0|ab|8c|Cliff Brown
d0|b0|64|Filtered Rays
d0|b0|82|Warm Butterscotch
d0|b2|5c|Tanami Desert
d0|b5|5a|Warm Woolen
d0|b9|97|Community
d0|bb|a7|Chinchilla Chenille
d0|bb|b0|Desert Morning
d0|bc|a2|Country Rubble
d0|bd|94|Subtle Suede
d0|c1|01|Banana Powder
d0|c1|17|Bird Flower
d0|c1|c3|Ancestral
d0|c2|b4|Gotta Have It
d0|c3|83|Winter Hazel
d0|c4|ac|Trail Dust
d0|c4|af|Russian Toffee
d0|c5|be|En Plein Air
d0|c6|a1|Sand Trail
d0|c6|b5|Lover's Hideaway
d0|c7|c3|Bleached Bare
d0|c8|a9|Desert Cover
d0|c8|b0|Kitsilano Cookie
d0|c8|c4|Mud Berry
d0|c8|c6|Lunette
d0|c8|e6|Italian Fitch
d0|c9|c3|Pearl Ash
d0|c9|c6|Amethyst Ice
d0|ca|cd|Light Registra
d0|cb|b6|Skipping Stone
d0|cb|ce|Light Lace Wisteria
d0|cc|a9|Canary Grass
d0|cc|c5|Cool Slate
d0|cc|c9|Orca White
d0|d0|d0|Ancestral Water
d0|d0|d7|Light Pensive
d0|d0|da|Lilac Hint
d0|d1|c1|Wishing Well
d0|d1|e1|Hailstorm
d0|d2|c5|Particular Mint
d0|d2|de|Light Horizon Sky
d0|d3|4d|Southern Platyfish
d0|d3|b7|Aloe Wash
d0|d3|d3|Elemental
d0|d4|e3|Light Iced Lavender
d0|d5|57|Citrus Delight
d0|d6|bf|Green Frost
d0|d7|df|Twinkle Blue
d0|d8|be|Celery Satin
d0|d9|d4|Blue Flower
d0|db|61|Chinese Green
d0|db|c4|Pale Moss Green
d0|db|d7|Morning Fog
d0|dc|e8|Blue Silk
d0|dd|cc|St. Augustine
d0|dd|e9|Hint of Ballet Blue
d0|e1|e8|Goddess
d0|e4|29|Sickly Yellow
d0|e7|98|Clean N Crisp
d0|ea|e8|Foam
d0|ee|fb|Blue Hijab
d0|f0|c0|Tea Green
d0|f7|e4|Pale Cactus
d0|fe|1d|Lime Yellow
d0|fe|fe|Pale Blue
d0|ff|14|Arctic Lime
d1|00|1c|Blood Orange
d1|00|47|Spanish Carmine
d1|00|56|Rubine Red
d1|4e|2f|Dizzy Days
d1|58|37|Koi
d1|58|4c|Wet Coral
d1|5b|9b|Crushed Berries
d1|62|77|Rapture Rose
d1|69|1c|Hot Cinnamon
d1|6a|68|Lippie
d1|6d|76|Mexican Chile
d1|6f|52|Arabesque
d1|76|8c|Razzberries
d1|76|8f|Muted Pink
d1|82|a0|Heirloom Rose
d1|84|89|Mauve Glow
d1|8e|54|Honey Fungus
d1|90|33|Fuel Yellow
d1|90|7c|Orange Essential
d1|90|8e|Tongue
d1|92|75|Feldspar
d1|94|31|Jackpot
d1|94|a1|Madagascar Pink
d1|97|76|Tawny Amber
d1|98|b5|Exotic Lilac
d1|9b|2f|Roman Gold
d1|9c|97|Dark Rose Tan
d1|9f|e8|Bright Ube
d1|a0|54|Honey Gold
d1|a1|4e|Ogryn Flesh Wash
d1|a1|9b|Evening Dress
d1|a3|69|Great Dane
d1|ab|99|Salt Water Taffy
d1|ac|ce|Orchid Bouquet
d1|af|b7|Iced Watermelon
d1|b0|88|Cracker Bitz
d1|b2|6f|Tan
d1|b2|72|Indonesian Rattan
d1|b3|99|Cashmere
d1|b4|c6|Tsarina
d1|b5|ca|Mary Poppins
d1|b6|c3|Pink Pampas
d1|b7|91|Hint of Adobe
d1|b7|a0|Frappe
d1|b7|a7|Treeless
d1|b8|71|Sweet Mustard
d1|b9|92|Stacked Limestone
d1|b9|9b|Cozy Wool
d1|b9|ab|Corkscrew Willow
d1|bd|92|Savannah
d1|be|92|Beaten Track
d1|be|a8|Dark Vanilla
d1|c0|bf|Hushed Violet
d1|c2|c2|Hint Of Lavender
d1|c3|ad|Pale Parchment
d1|c7|b8|Parisian Cashmere
d1|c8|7c|Muted Lime
d1|c9|ba|Moth Grey
d1|cc|c2|Crocodile Tooth
d1|cd|ca|Free Reign
d1|cd|d0|Light Eskimo White
d1|ce|b4|Bright Sage
d1|d0|d1|Clouded Vision
d1|d1|bb|With A Twist
d1|d2|be|Soft Kind
d1|d2|bf|Spooky
d1|d2|dc|Glacier Pearl
d1|d3|c0|Brainstorm
d1|d3|cc|Grey Nurse
d1|d3|cf|Tornado
d1|d3|e0|White Shadow
d1|d5|d0|Foggy Dew
d1|d5|e7|Chill in the Air
d1|d6|eb|Light Powdered Granite
d1|d8|d6|Rainy Season
d1|d8|dd|Hint of Oxford
d1|d9|d7|Summer Shade
d1|da|c0|Zen Garden
d1|da|d5|Sculptural Silver
d1|db|d2|Light Zen
d1|dc|d8|Sky Glass
d1|dd|86|Lime Ice
d1|dd|e1|Hint of Pure Blue
d1|de|e4|Breakwater
d1|df|eb|Hint of Ridge Light
d1|e0|e9|Lupin Grey
d1|e2|31|Pear
d1|e2|d8|Light Snow Goose
d1|e6|d5|Peppermint Patty
d1|e8|c2|Sweet Spring
d1|ea|ea|Teardrop
d1|ea|ec|Hint of Daly Waters
d1|ea|ed|Hint of Skyway
d1|ed|ee|Hint of Opale
d1|ed|ef|Hint of Sky Cloud
d1|ef|9f|Reef
d1|ef|dd|Light Martian Moon
d1|f0|dd|Light Lost Lace
d1|f0|f6|Frostproof
d1|f1|de|Light Spatial Spirit
d1|f1|f5|Windswept
d1|ff|bd|Very Light Green
d2|08|cc|Awkward Purple
d2|2d|1d|Pure Red
d2|38|6c|Raspberry Sorbet
d2|57|62|Tandoori Red
d2|66|43|Citrus Notes
d2|69|11|Cinnamon
d2|69|1e|Chocolate
d2|69|3e|Fresh Acorn
d2|73|8f|Pink Garnet
d2|7d|46|Pumpkin Bread
d2|7d|56|Coral Gold
d2|7f|63|Sun Baked
d2|80|34|Yellow Mandarin
d2|80|6c|Fire Chalk
d2|80|83|Galah
d2|80|85|Victorian Rouge
d2|81|3a|Phoenix Rising
d2|82|39|Rapakivi Granite
d2|8b|72|Helena Rose
d2|8c|a7|Kiss
d2|8f|b0|Moonlit Mauve
d2|90|62|Whiskey
d2|93|80|Muted Clay
d2|94|aa|Orchid Smoke
d2|9b|83|Dusty Coral
d2|a1|72|Muntok White Pepper
d2|a5|a3|La Vie en Rose
d2|a5|be|Enhance
d2|a6|94|Tiffany Rose
d2|a9|6e|Artemis
d2|ad|84|Toast and Butter
d2|ad|87|Cheddar Biscuit
d2|ad|b5|Fresh Pink Lemonade
d2|b3|95|Hiker's Delight
d2|b3|a9|Clam Shell
d2|b4|8c|Link to the Past
d2|b4|9c|Roasted Almond
d2|b6|98|Slopes
d2|b9|60|Tacha
d2|bb|95|Thermos
d2|bb|b2|Forever Fairytale
d2|bc|9b|Pony Tail
d2|bd|0a|Mustard Flower
d2|bd|9e|Bluff Stone
d2|bf|c4|Pink Linen
d2|c0|98|Sandy Pail
d2|c2|9d|Soybean
d2|c2|ac|Frosted Almond
d2|c2|b2|Bongo Drum
d2|c3|a3|Double Spanish White
d2|c4|78|Tropical Moss
d2|c4|d6|Lavender Fog
d2|c5|95|Vast Escape
d2|c5|ae|Dry Riverbed
d2|c6|1f|Barberry Bush
d2|c6|ae|Nomadic Taupe
d2|c6|b6|Stark White
d2|c7|85|Sour Apple
d2|c8|80|Serene Scene
d2|c8|bb|Fossil Sand
d2|c9|df|Lavender Water
d2|ca|af|Oyster White
d2|cb|af|Moth
d2|cc|81|Yellow Endive
d2|cc|a0|Wasabi Zing
d2|cc|b4|Steamboat Geyser
d2|cc|d1|Light Stately Frills
d2|cc|da|Kundalini Bliss
d2|cc|e5|Vision
d2|cd|b4|Asparagus Green
d2|cd|bc|Bay Salt
d2|cf|c1|Lunar Landing
d2|cf|c4|Silver Birch
d2|cf|cc|Elusion
d2|d1|cd|Concrete
d2|d2|5a|Energized
d2|d2|c0|400XT Film
d2|d2|df|Tranquil Sea
d2|d3|b3|Orinoco
d2|d3|e1|Light Blue Cloud
d2|d4|c3|White Sage
d2|d5|9b|Misty Bead
d2|d5|da|Sparkling Frost
d2|d8|8f|Golden Delicious
d2|d8|d2|Murmur
d2|d8|de|Hint of Spirit
d2|d8|f4|Flax Bloom
d2|d9|cd|Light Gentle Calm
d2|d9|db|Aluminum Foil
d2|da|ed|Hawkes Blue
d2|db|32|Bitter Lemon
d2|dc|de|Pinwheel Geyser
d2|df|ed|Hint of Newman's Eye
d2|e0|d6|Light Gracilis
d2|e2|ef|Hint of Morality
d2|e2|f2|Hint of Powder Blue
d2|e3|cc|Lime Flip
d2|e6|d3|Herbal Mist
d2|e6|e8|Blue Phlox
d2|e7|ca|Ambrosia
d2|e8|e0|Aqua Glass
d2|ea|ea|Hint of Timeless
d2|ea|f1|Ice Cold
d2|eb|ea|Sea Spray
d2|f2|e7|Minty Fresh
d2|f3|eb|Hint of Water Wings
d2|f4|dd|Fennel Tea
d3|00|3f|Utah Crimson
d3|21|2d|Amaranth Red
d3|33|00|Native Hue of Resolution
d3|34|79|Fuchsia Purple
d3|49|4e|Faded Red
d3|4e|36|Glazed Persimmon
d3|50|7a|Pink Flambe
d3|69|1f|Fresh Gingerbread
d3|74|d5|Deep Mauve
d3|7f|6f|Tawny Orange
d3|87|98|Speckled Easter Egg
d3|89|77|Zanci
d3|8a|57|Bestigor Flesh
d3|98|98|Tobermory
d3|9b|cb|Light Medium Orchid
d3|9c|43|Mineral Yellow
d3|9f|5f|Honey Beehive
d3|a0|83|Orange Maple
d3|a1|94|Pale Dry Rose
d3|a2|97|Peach Beige
d3|a5|d6|Favorite Lavender
d3|a9|07|Armageddon Dust
d3|a9|5c|Afghan Sand
d3|af|37|American Gold
d3|b0|9c|Indian Khaki
d3|b1|7d|Steamed Chestnut
d3|b1|91|Cinnamon Frost
d3|b4|ad|Rose Smoke
d3|b5|87|Camelback Mountain
d3|b6|67|Wax Way
d3|b6|83|Very Light Brown
d3|b6|ba|Rose Stain
d3|b7|8b|Craftsman Gold
d3|b9|9b|Bruin Spice
d3|b9|b0|Cracker Crumbs
d3|bb|96|Smooth Beech
d3|bc|9e|Gaia
d3|bf|c4|Bunny Soft
d3|bf|e5|York Plum
d3|c1|c5|Aroma
d3|c1|cb|Bassinet
d3|c8|ba|Lucky Dog
d3|cb|c6|Desolate Field
d3|cc|a3|Hay
d3|cc|cd|Light Pale Lady
d3|ce|c5|Miner's Dust
d3|cf|ab|Crystal Palace
d3|d0|dd|Lavender Haze
d3|d1|c4|Muslin
d3|d1|dc|Frosted Lilac
d3|d2|dd|Light Kiri Mist
d3|d3|d2|Silver Spoon
d3|d3|d3|Pinball
d3|d6|c4|Wine Bottle
d3|d6|e9|Light Silver Sweetpea
d3|d8|de|Hint of Blunt
d3|d9|d1|Zephyr Blue
d3|da|e1|Hint of Elusive Blue
d3|db|cb|Ottoman
d3|db|e2|Hint of Pre School
d3|db|ec|Snowy Shadow
d3|dd|d6|Periwinkle Tint
d3|dd|e4|Hint of Bypass
d3|dd|e7|Hint of Time Travel
d3|de|c4|Meadow Mist
d3|de|df|Spa Blue
d3|df|ea|Hint of Blue Ballerina
d3|e0|b1|Rockmelon Rind
d3|e0|de|Spring Mist
d3|e0|ec|Haunting Hue
d3|e1|d3|Light Marsh Fog
d3|e2|ee|Hint of Melt Ice
d3|e3|e5|Hint of Dew Point
d3|e4|e6|Aqua Sparkle
d3|e5|db|Summer Breeze
d3|e5|eb|Ocean Breeze
d3|e5|ef|Pattens Blue
d3|e7|c7|Tactile
d3|e7|dc|Light Light Lichen
d3|e7|e5|Plateau
d3|e9|ec|Enchanted Evening
d3|ee|ec|Hint of Sea Foam
d3|f1|ee|Hint of Cool Crayon
d3|f2|ed|Hint of Chalk Blue
d4|00|00|Rosso Corsa
d4|3e|38|Red Clown
d4|57|4e|Valencia
d4|58|71|Kenny's Kiss
d4|6a|7e|Pinkish
d4|6b|ac|Fudgesicle
d4|6f|31|Tango
d4|73|d4|French Mauve
d4|82|3c|Clay Terrace
d4|8c|46|Cognac
d4|91|5d|Whiskey Sour
d4|95|95|Keel Joy
d4|9f|4e|Saffron Robe
d4|a1|b5|Gizmo
d4|a5|5c|Sweet Honey
d4|ac|99|Hayride
d4|ac|ad|Pale Persimmon
d4|ae|40|Ceylon Yellow
d4|ae|76|Drops of Honey
d4|af|37|Metallic Gold
d4|b1|85|Buttery Leather
d4|b2|c0|Kindness
d4|b5|b0|Oyster Pink
d4|b8|bf|Melting Violet
d4|b9|cb|Winsome Orchid
d4|ba|8c|Buckskin
d4|ba|b6|Sepia Rose
d4|bb|b1|Wafer
d4|bc|94|Crepe
d4|bd|df|Plum Point
d4|bf|bd|Salmon Smoke
d4|c0|c5|Elusive Violet
d4|c1|9e|Gold Wash
d4|c3|cc|Tinge Of Mauve
d4|c4|77|Marsh Field
d4|c4|a7|Stalactite Brown
d4|c4|d2|Frosted Grape
d4|c5|ba|Christobel
d4|c5|ca|Victorian Cottage
d4|c6|db|Prudence
d4|c7|d9|Modesty
d4|c9|a6|Sanctuary
d4|ca|c5|Crushed Almond
d4|ca|cd|Grey Lilac
d4|cb|83|Deduction
d4|cb|c4|Alibi
d4|cb|cc|Eagle's View
d4|cb|ce|Light Pale Pearl
d4|cc|9a|Dusty Yellow
d4|cc|ce|Light Wallis
d4|cd|b5|Only Oatmeal
d4|cd|d2|Light Glass Bead
d4|ce|bf|Porous Stone
d4|ce|cd|Light Oil Of Lavender
d4|ce|d1|Light Easter Rabbit
d4|cf|b4|White Rock
d4|cf|c5|Westar
d4|cf|cc|Light Ghost Town
d4|cf|d6|Jam Session
d4|d0|c5|Greybeard
d4|d1|58|Sequesta
d4|d1|d9|Light Femininity
d4|d3|e0|Light Amourette
d4|d4|c4|Daikon White
d4|d8|ed|Light Ace
d4|da|e2|Aster Petal
d4|db|b2|White Jade
d4|db|d1|Light Silver Grass
d4|dc|d6|Buckwheat
d4|dc|da|Thin Cloud
d4|dd|dd|Winter's Breath
d4|dd|e2|Ocean Dream
d4|de|e8|Hint of Cameo Blue
d4|e0|92|Charming
d4|e0|ef|Hint of Radar
d4|e2|e6|Aloof
d4|e2|eb|Pale Grey Blue
d4|e3|d7|Light Dry Lichen
d4|e3|e2|Meadowsweet Mist
d4|e6|b1|Lasting Thoughts
d4|e6|d9|Light Green Wash
d4|e7|e7|Hint of Dante Peak
d4|eb|dd|Persian Fable
d4|ed|e3|Warm Winter
d4|ed|e6|Cascade
d4|f1|f9|Water
d4|fb|79|Honeydew Peel
d4|ff|ff|Really Light Blue
d5|17|4e|Lusty Lips
d5|2b|2d|Chi-Gong
d5|62|31|Harvest Pumpkin
d5|6c|2b|Christmas Orange
d5|6c|30|Gold Drop
d5|78|35|Decaying Leave
d5|7c|6b|Masoho Red
d5|84|7e|Salmon Pate
d5|86|9d|Dull Pink
d5|87|7e|Pink Papaya
d5|8a|94|Dusty Pink
d5|8d|8a|Pink Slip
d5|94|66|Pumpkin Patch
d5|9c|6a|Prayer Flag
d5|9c|fc|Plasma Trail
d5|a1|93|Indian Mesa
d5|a1|a9|Young At Heart
d5|a3|00|Moldy Ochre
d5|a5|85|Yolande
d5|a6|ad|Foxy Lady
d5|a8|84|Desert Riverbed
d5|ab|09|Burnt Yellow
d5|ab|2c|Brassy
d5|b1|85|Calico
d5|b5|9c|Kraft Paper
d5|b6|0a|Dark Yellow
d5|b6|cd|Pink Power
d5|b6|d4|Lilac Haze
d5|b7|cb|Icing Flower
d5|bc|26|Indian Pale Ale
d5|bc|c2|Frosted Sugar
d5|bd|66|Pale Mustard
d5|bd|a4|Esplanade
d5|bf|a5|Pine Strain
d5|bf|b4|Wild Rice
d5|c0|a1|Dunes Manor
d5|c3|ad|Swiss Coffee
d5|c6|bd|Desert Rock
d5|c6|c2|Weathered Hide
d5|c6|d6|Tender Touch
d5|c7|57|Citron
d5|c7|b3|Desert Suede
d5|c7|b6|Emily Ann Tan
d5|c7|b9|Chintz
d5|c7|e8|Foggy Love
d5|cb|b2|Aths Special
d5|cd|94|Golden Mist
d5|cd|b4|Ecru Wealth
d5|ce|69|Force of Nature
d5|cf|bd|Doric White
d5|d0|cb|Light Taupe White
d5|d1|cb|Campfire Smoke
d5|d1|cc|Light Subdue
d5|d2|d1|Day On Mercury
d5|d3|c3|Static
d5|d3|e3|Light Pax
d5|d4|ce|Slow Perch
d5|d4|d0|Light Bleaches
d5|d5|93|Mellow Green
d5|d5|ce|Kefir
d5|d5|d8|Nimbus Cloud
d5|d7|17|Sulphur Spring
d5|d7|bf|Medlar
d5|d7|d9|December Sky
d5|d8|bc|Pine Mist
d5|d8|c9|Light Green Alabaster
d5|d9|dd|Hint of Blue Rinse
d5|da|d1|Light Cipollino
d5|da|e0|Hint of Kinder
d5|da|e1|Hint of Mistral
d5|da|ee|Blissful Meditation
d5|db|d5|Silvery Streak
d5|dc|ce|Caribbean Pleasure
d5|dc|dc|Sea Frost
d5|dd|e5|Hint of Stargate
d5|df|d3|Light Silver Dollar
d5|e0|d0|Light French Limestone
d5|e1|e0|Pristine Petal
d5|e2|e1|Pistachio Cream
d5|e2|ee|Hint of Placid Blue
d5|e3|d0|Light Snow Green
d5|e3|de|Morning Breeze
d5|e6|9d|Apple Bob
d5|eb|ac|Faith
d5|eb|dd|Light Duck Egg Cream
d5|ed|fb|Ice Castle
d5|f3|ec|Hint of Gentle Giant
d5|f5|34|Stadium Grass
d5|ff|ff|Very Light Blue
d6|34|1e|Rackham Red
d6|3d|3b|Red Power
d6|48|d7|Pinkish Purple
d6|85|9f|Primrose
d6|87|ba|Cyclamen
d6|8a|59|Bright Sienna
d6|8b|80|My Pink
d6|8f|9f|Sugar Tooth
d6|9c|2f|Mango Mojito
d6|9f|a2|Bridal Rose
d6|a3|32|Curry Sauce
d6|a5|cd|Berry Popsicle
d6|a7|66|Ungor Flesh
d6|b2|ad|Victoriana
d6|b3|a9|Naked Lady
d6|b3|c0|Mauvelous
d6|b4|fc|Light Violet
d6|b7|e2|Pretty Petunia
d6|b8|bd|Nostalgia
d6|ba|9b|Terracotta Sand
d6|c0|a4|Almond Latte
d6|c1|c5|Sprig Muslin
d6|c3|b9|New Wool
d6|c4|43|Limone
d6|c4|c1|Just Gorgeous
d6|c5|a0|Aloof Lama
d6|c5|a9|Pale Beach
d6|c6|9a|Parsnip
d6|c6|b4|Cafe Latte
d6|c7|a6|Thatched Cottage
d6|c7|be|Perk Up
d6|c7|d6|Shy Violet
d6|ca|3d|Wattle
d6|ca|dd|Languid Lavender
d6|cb|bf|In the Buff
d6|cb|da|Dusky Lilac
d6|cd|b7|Desert Khaki
d6|cd|d0|Light Orchid Haze
d6|ce|be|Almond Milk
d6|ce|c3|Male
d6|ce|d3|Light Bay Fog
d6|cf|bf|Gypsum Sand
d6|d0|cf|Light White Flag
d6|d1|c0|Ecru White
d6|d1|dc|Light Laughing Jack
d6|d5|d2|Light Brume
d6|d6|9b|Crocodile Tears
d6|d6|d1|Modern Monument
d6|d6|d6|Silver Medal
d6|d7|d2|Fog
d6|d8|cd|Light Pale Celadon
d6|d9|63|Banana Chalk
d6|d9|cb|Light Lamb's Ears
d6|d9|dd|Hint of Blue Moon
d6|db|c0|Breezeway
d6|db|d9|Blue Blush
d6|dd|d3|Crushed Limestone
d6|dd|dc|December Rain
d6|dd|e6|Hint of Candela
d6|de|c9|Canary Green
d6|de|e9|Hint of Alley
d6|df|e7|Blustery Day
d6|df|e8|Hint of Angora Blue
d6|df|ec|Hint of Penna
d6|e1|c2|Security
d6|e1|e4|Wavecrest
d6|e4|d4|Light Mystified
d6|e5|e2|Cave Pearl
d6|e6|e6|Hint of Relax
d6|e7|e3|Peaceful Night
d6|e8|d5|Light Spring Burst
d6|e8|e1|Lit'L Buoy Blew
d6|e9|ca|White Green
d6|ea|d8|Light Katsura
d6|ea|db|Light Enchanted
d6|ea|e8|After Eight Filling
d6|ea|fc|Cloudless
d6|ed|f1|Sparkling River
d6|ef|da|Garden Shed
d6|f0|cd|Snowy Mint
d6|ff|fa|Ice
d6|ff|fe|Very Pale Blue
d7|00|3a|Kurenai Red
d7|00|40|Sunset Riders
d7|00|41|Rich Carmine
d7|0a|53|Debian Red
d7|18|68|Dogwood Rose
d7|25|de|Demonic Purple
d7|2e|83|Highlighter Lilac
d7|3b|3e|Jasper
d7|3c|26|Spicy Orange
d7|48|94|Kirby Pink
d7|5c|5d|Spiced Coral
d7|67|ad|Pale Magenta
d7|69|68|Geranium Red
d7|7e|70|Golgfag Brown
d7|81|87|Rhubarb Pie
d7|82|4b|Seraphim Sepia
d7|83|7f|York Pink
d7|83|ff|Lavender Tea
d7|87|75|Freckles
d7|8a|6c|Bronzed Orange
d7|90|43|Suede Vest
d7|94|2d|Golden Orange
d7|95|84|Sunburnt Toes
d7|99|79|Italian Clay
d7|9c|5f|Ritzy
d7|a9|8c|White Acorn
d7|aa|60|Streusel Cake
d7|ac|7f|Paper Brown
d7|ad|62|Butterscotch Bliss
d7|b1|a5|Sandpaper
d7|b1|b0|Mary Rose
d7|b1|b2|Radiant Rouge
d7|b2|35|Ogen Melon
d7|b3|b9|Floss
d7|b5|5f|Strike It Rich
d7|b5|7f|New Wheat
d7|b8|ab|Pink Apatite
d7|b9|cb|Spring Boutique
d7|ba|d1|Sunday Gloves
d7|bf|a6|Pancake Mix
d7|c0|c7|Pelican Bill
d7|c1|ba|Lilac Light
d7|c2|75|Citrus Yellow
d7|c6|e1|Oriental Blush
d7|c9|a5|Spa Sangria
d7|c9|e3|Purity
d7|ca|b0|Wood Ash
d7|cb|c4|Crystal Grey
d7|cd|cd|Lilac Ash
d7|ce|b9|Atlantic Fig Snail
d7|ce|c5|Swirl
d7|ce|cd|Light Nantucket Mist
d7|cf|bb|Pistachio Shell
d7|cf|c1|Sandy Day
d7|d0|c0|Bone Trace
d7|d0|e1|Dusty Plum
d7|d1|c6|Rotunda White
d7|d2|b8|Pistachio Tang
d7|d2|d1|Balanced
d7|d2|e2|Light Lilac Crystal
d7|d3|a6|Pale Avocado
d7|d3|ca|Light Ghosting
d7|d3|e0|Light Dreamweaver
d7|d4|e4|Light Gregorio Garden
d7|d7|ad|Green Mesh
d7|d7|c7|Silver Green
d7|da|dd|Hint of Blue To You
d7|dd|cd|Light Green Ash
d7|dd|ec|Weeping Wisteria
d7|de|eb|Hint of Objectivity
d7|df|d6|Secret Crush
d7|e0|e2|Blue Smoke
d7|e0|e7|Harbour Light
d7|e0|eb|Beyond the Wall
d7|e1|e5|Tahoe Snow
d7|e2|d5|Green Mirror
d7|e2|db|Night Wind
d7|e2|de|Windsurfer
d7|e2|e5|Glassine
d7|e4|cc|Light Bethany
d7|e4|ed|Snow Shadow
d7|e5|b4|Natural Youth
d7|e6|ee|Dream Blue
d7|e7|cd|Greenhouse Glass
d7|e7|d0|Peppermint
d7|e7|da|Toadstool Dot
d7|e7|e0|Echo
d7|e8|bc|Lime Cream
d7|e9|c8|Korila
d7|e9|e8|Hint of Greenland Ice
d7|ec|cd|Lantana Lime
d7|ed|ea|Hint of Starlight Blue
d7|ee|e4|White Ice
d7|ef|d5|Light Frosty Dawn
d7|f3|dd|Light Pickford
d7|ff|fe|Refreshing Primer
d8|00|cc|Fúchsia Intenso
d8|41|39|Dangerously Red
d8|55|25|Lāl Red
d8|61|30|Tangerine Bliss
d8|62|5b|Roman
d8|6d|39|Jaffa Orange
d8|6f|3c|Field Poppy
d8|76|78|Red Cedar
d8|7c|3b|Sweet Potato
d8|81|67|Summer Sunset
d8|86|3b|Dull Orange
d8|87|7a|Island Coral
d8|8e|2d|Turmeric Tea
d8|91|66|Copper Cove
d8|91|ef|Bright Lilac
d8|9f|66|Kombucha
d8|a1|c4|Pastel Lavender
d8|a3|73|Japanese Yew
d8|a6|86|Clay Fire
d8|a7|23|Galliano
d8|a8|92|North Rim
d8|aa|b7|Pink Nectar
d8|ad|39|Yarrow
d8|b4|b6|Pink Flare
d8|b6|91|Nutmeg Glow
d8|b7|78|Sinking Sand
d8|b7|cf|Light Mulberry
d8|b8|f8|Pink Illusion
d8|b9|8c|Splash of Honey
d8|b9|98|Mellow Buff
d8|ba|a6|Maiko
d8|bf|d8|Thistle
d8|c0|95|Grain Mill
d8|c0|ad|Shifting Sand
d8|c2|ca|Old Mission Pink
d8|c2|cd|Tip Toes
d8|c3|9f|Golden Ecru
d8|c4|75|Grassroots
d8|c6|d6|Naked Pink
d8|c7|b6|Dry Creek
d8|c8|be|Curly Maple
d8|c9|cc|Light Pink Polar
d8|ca|a9|Fiji Sands
d8|ca|b2|Raw Sugar
d8|cb|ad|Soft Suede
d8|cb|b5|Brown Mouse
d8|cb|cf|Light Lady Fingers
d8|cc|9b|Tahuna Sands
d8|cc|bb|Sandshell
d8|cc|c6|Subpoena
d8|cd|c4|River Rock
d8|cd|c8|Thought
d8|cd|d0|Light Mosque
d8|cd|d3|Light Elusive Dream
d8|ce|b9|Vintage Ephemera
d8|cf|b2|Frozen Dew
d8|cf|be|Crushed Silk
d8|cf|c1|Fine Grain
d8|cf|c3|Sago
d8|d0|bd|Grand Piano
d8|d3|e6|Violet Crush
d8|d4|dd|Take the Plunge
d8|d5|d0|Light Vanilla Quake
d8|d5|e3|Heavenly Haze
d8|d6|cc|Light Pipe Clay
d8|d6|d1|Fog Beacon
d8|d6|d7|Cape Hope
d8|d7|ca|Light Livingstone
d8|d7|d3|Cloudy
d8|d8|d0|Subtle Shadow
d8|da|db|Silver Setting
d8|db|e1|Hint of Starlight
d8|dc|b3|Spring Thyme
d8|dc|c8|Silver Laurel
d8|dc|d6|Light Grey
d8|dd|cc|Liberated Lime
d8|dd|da|Mystic
d8|de|ce|Pale Vista
d8|de|cf|Light Carrot Flower
d8|de|d0|Light Iced Aniseed
d8|de|e3|Billowing Clouds
d8|de|e7|Hint of Angelic Blue
d8|df|da|Rapier Silver
d8|e1|f1|Hint of Cuddle
d8|e3|d7|Fairest Jade
d8|e4|de|Fizzle
d8|e4|e7|Eskimo Blue
d8|e4|e8|Baby's Breath
d8|e5|dd|Cactus Blossom
d8|e6|98|Young Greens
d8|e6|cb|Great Joy
d8|e6|ce|Light Lime Sherbet
d8|e7|e1|Ice Floe
d8|e7|e7|Billowing Sail
d8|e8|e6|Frozen Mint
d8|e9|e5|Hushed Green
d8|eb|d6|Chic Green
d8|ee|e7|Hint of Short Phase
d8|ee|ed|Blue Green Rules
d8|f0|d2|Blue Romance
d8|f1|cb|Fresh Lime
d8|f1|eb|Hint of Ice Cap Green
d8|f1|f4|Let it Snow
d8|f2|dc|Light Celery Stick
d8|f2|ee|Air of Mint
d8|f3|d7|Light Carolina
d8|f8|78|Mystic Green
d9|00|4c|UA Red
d9|01|66|Dark Hot Pink
d9|1f|ff|Afterlife
d9|21|21|Maximum Red
d9|33|3f|Safflower Red
d9|4f|f5|Heliotrope
d9|54|4d|Pale Red
d9|60|3b|Medium Vermilion
d9|61|5b|Deep Sea Coral
d9|62|3b|Flint Corn Red
d9|79|a2|Wild Orchid
d9|82|b5|Middle Purple
d9|86|95|Shimmering Blush
d9|8a|3f|Coppersmith
d9|90|58|Persian Orange
d9|92|2e|Autumn Blaze
d9|92|94|Pink Clay Pot
d9|96|31|Leprous Brown
d9|98|a0|Parrot Pink
d9|9b|7c|Peach Bloom
d9|9b|82|Pinkish Tan
d9|9f|4d|Gold Foil
d9|a0|5f|Butterscotch Syrup
d9|a0|77|Soft Leather
d9|a6|a1|Mellow Rose
d9|a6|c1|Rhubarb Gin
d9|ad|9e|Montezuma's Castle
d9|af|ca|Pink Lavender
d9|b1|9f|Suntan
d9|b6|11|Patrinia Flowers
d9|bb|8e|San Carlos Plaza
d9|bc|b7|Rose Yogurt
d9|be|bc|Tea Time
d9|c0|9c|Golden Gate
d9|c1|b7|Country Cottage
d9|c3|a1|Birch Beige
d9|c4|d0|Mauve Organdie
d9|c5|a1|Afternoon Stroll
d9|c7|37|Gone Giddy
d9|c8|b7|Clay Pipe
d9|ca|a5|Chino Green
d9|ca|c3|Goodbye Kiss
d9|cc|c7|Raspberry Ice
d9|cc|c8|Nut Milk
d9|cd|c4|Day Dreamer
d9|cd|e5|Bashful Pansy
d9|ce|52|Green Sheen
d9|ce|c7|Instant
d9|ce|d2|Capella
d9|ce|d5|Light Puffball
d9|cf|be|Buff It
d9|d0|c1|Cool Concrete
d9|d0|c2|Blanc
d9|d0|c4|Porcelain Basin
d9|d1|40|Viameter
d9|d2|c9|Light Eggshell Pink
d9|d5|c5|Plume Grass
d9|d6|cf|Timber Wolf White
d9|d7|b8|Ghostly Green
d9|d7|d9|Hint of Mauve Pansy
d9|d9|d6|Winter Morn
d9|d9|f3|Quartz
d9|da|d2|Silver Creek
d9|db|df|Hint of Anon
d9|dc|d1|Wayward Willow
d9|dc|d5|Lighthouse View
d9|dc|db|Thin Ice
d9|dc|dd|Spring Thaw
d9|dc|e4|Hint of Image Tone
d9|dd|cb|Light Garlic Suede
d9|dd|d5|Aqua Haze
d9|dd|e5|Hint of Blue Bayou
d9|df|cd|Gin
d9|df|e0|Cold Water
d9|df|e3|Chickweed
d9|e0|d0|Light Ligado
d9|e0|ee|Hint of Hindsight
d9|e1|c1|Mountain Spring
d9|e3|d9|Eye of the Storm
d9|e3|e5|Subtle Blue
d9|e4|9e|Curious
d9|e4|de|Breezy Aqua
d9|e4|e5|Beachcomber
d9|e5|e4|Hint of Detroit
d9|e6|50|Maximum Green Yellow
d9|e6|a6|Mermaid Tears
d9|e6|e0|Hint of Quaver
d9|e6|e8|Smoke and Mirrors
d9|e6|ee|First Light
d9|e7|e3|Hint of Pale Icelandish
d9|e8|c9|Flower Bulb
d9|e9|e5|Hint of High Point
d9|ea|e5|Tropical Dream
d9|ec|e6|Hint of Picnic Bay
d9|ec|e9|Hint of Supernova
d9|ee|b4|Chicon
d9|f4|ea|Hint of Salome
da|1d|81|Vivid Cerise
da|2c|43|Bloody Rust
da|32|1c|Orange Com
da|32|87|Deep Cerise
da|3b|1f|Vermillion
da|3d|58|Geranium
da|46|7d|Darkish Pink
da|52|65|Cranberry Splash
da|63|04|Ancient Bamboo
da|65|5e|Salami Slice
da|68|0e|Apple II Chocolate
da|6d|91|Paris Pink
da|70|d6|Pink Orchid
da|7c|55|Deep Coral
da|7e|7a|Lantana
da|84|33|Sunlounge
da|84|6d|Indian Princess
da|8a|67|Copper Coin
da|8a|88|Copperfield
da|8f|67|Copper Pipe
da|91|00|Harvest Eve Gold
da|94|29|Buttercup
da|95|85|Paddy
da|97|90|Petite Orchid
da|99|5f|Apple Cider
da|9e|35|Saffron Sunset
da|9e|38|Golden Hamster
da|a3|6f|Western Sunrise
da|a4|36|Yellow Jasper
da|a5|20|Chanterelle
da|a5|aa|Prom
da|a6|31|Golden Grass
da|ae|00|Palomino Gold
da|ae|49|Golden Rule
da|b1|60|Equator
da|b2|7d|Pale Clay
da|b4|cc|Purple Poodle
da|b5|8f|Sheepskin
da|b6|cd|Blissfully Mine
da|b7|7f|Brik Dough
da|b7|be|Strawberry Glaze
da|b9|65|Misted Yellow
da|bd|84|Brown Rice
da|be|81|Jojoba
da|be|82|Vermicelle
da|bf|92|Del Sol Maize
da|bf|a4|Curious Chipmunk
da|c0|1a|Zingiber
da|c0|a7|Ivory Cream
da|c0|ba|Reindeer
da|c0|cd|Twilight Light
da|c3|95|Chamomile Tea
da|c5|b1|Hanover
da|c6|a8|Mission Tan
da|c7|ab|Biscotti
da|ca|b7|Brazilian Sand
da|cb|a7|Light Aspiration
da|cb|a9|Baked Bread
da|cb|be|Whisper Pink
da|cb|bf|Bermuda Sand
da|cc|b4|Bleached Sand
da|cd|65|Acacia
da|cd|81|Hay Day
da|cf|ba|Toasted Almond
da|d0|00|Chartreuse Shot
da|d1|c0|Clam
da|d1|ce|Light Antique Lace
da|d1|d7|Light Limpid Light
da|d4|c5|Mexican Sand Dollar
da|d4|e4|Light Angel Kiss
da|d5|c7|Light Beige Royal
da|d6|ae|Morning Moor
da|d6|cc|White Pointer
da|d6|df|Violet Whimsey
da|d7|ad|Mǐ Bái Beige
da|d7|c8|Fennec Fox
da|d7|e8|Light Opus
da|d8|c9|Veil of Dusk
da|db|df|Cumberland Fog
da|db|e0|Hint of Lavender Oil
da|db|e1|Hint of Slipper Satin
da|dc|c1|Garden Gate
da|dc|d0|Icepick
da|dc|d3|Anonymous
da|de|b5|April Showers
da|de|e6|Irradiant Iris
da|de|e9|Pale Cloud
da|df|ea|Hint of Pale Lilac
da|e1|cf|Lime Spritz
da|e1|e3|Harbour Mist
da|e2|e9|Star Map
da|e3|d0|Light Breakaway
da|e3|e7|Cityscape
da|e3|e9|First Frost
da|e4|de|Hint of Soft Celadon
da|e4|ee|Iceberg
da|e5|e0|Hint of White Box
da|e6|dd|Swans Down
da|e6|e3|Jack Frost
da|e6|e9|Airy
da|e6|ef|Space Wolves Grey
da|e8|e1|Hint of Meadow Lane
da|e9|dc|Tint of Green
da|ea|6f|Mindaro
da|ea|e2|Hint of Silverton
da|ec|c5|Greenette
da|ec|e7|Hint of Pinnacle
da|ee|d3|Mint Shake
da|ee|e6|Hint of Otto Ice
da|f0|e6|Hint of Beru
da|f1|e0|Green Brocade
da|f4|ea|Hint of Shutterbug
db|47|2c|Hunter's Orange
db|4b|da|Pink Purple
db|50|79|Rose Turkish Delight
db|58|56|Bricks of Hope
db|5a|6b|Kōbai Red
db|64|84|Surfer Girl
db|70|93|Pale Violet Red
db|71|92|Pale Red Violet
db|80|79|Cranapple
db|81|7e|Sea Pink
db|8b|67|Copper Wire
db|93|51|Brushed Clay
db|99|5e|Di Sierra
db|9b|59|Golden Nugget
db|a2|9e|Passive Pink
db|a3|9a|Quiet Pink
db|a3|ce|Chateau Rose
db|a4|96|Conch Pink
db|a5|39|Scrofulous Brown
db|a6|37|Sunny Disposition
db|a6|74|Gehenna's Gold
db|b0|a2|Rose Cloud
db|b2|bc|Pentalon
db|b4|0c|Gold Tooth
db|b4|86|Butterscotch Sundae
db|b6|7a|Soft Chamois
db|b7|ba|Mystic Mauve
db|b7|bb|Pencil Eraser
db|b8|81|Honey Bunny
db|b9|b6|Rose Hip Tonic
db|bb|a7|Cinnamon Ice
db|be|b7|Peach Whip
db|bf|a3|Shrimp Boudin
db|c2|ab|Old Bone
db|c3|b6|Basic Coral
db|c8|b6|Cocoa Cream
db|c9|63|Chifle Yellow
db|cb|ab|Sweet Dough
db|cb|bd|Pink Tint
db|cc|b5|Creamy Cappuccino
db|cc|d3|Silver Mauve
db|cd|ad|Cotswold Dill
db|ce|ac|Lovely Linen
db|d0|a8|Capital Grains
db|d0|ca|Mushroom Risotto
db|d0|ce|Lava Geyser
db|d1|e8|Shimmering Sky
db|d2|db|Orchid Tint
db|d3|bd|Pearly Putty
db|d4|ab|Dull Sage
db|d5|ce|Light Limed White
db|d5|d1|White Castle
db|d5|e6|Slaanesh Grey
db|d6|cb|Shady
db|d6|d2|Light Slight Mushroom
db|d6|d3|Light Warm Ash
db|d6|d8|Hint of Registra
db|d7|c4|Crêpe Papier
db|d7|ce|Silent Smoke
db|d7|d0|Light Grey Pebble
db|d7|d2|Eastern Wolf
db|d7|d9|Hint of Lace Wisteria
db|d7|e4|Misty Violet
db|d7|f2|Lavender Sky
db|d8|ca|Sassafras Tea
db|d9|c2|Loafer
db|d9|c9|Light Cargo River
db|da|cb|Light Pale Tendril
db|db|70|Moist Gold
db|db|bc|Apple Cucumber
db|db|da|Porpoise
db|dc|c4|Slow Dance
db|dc|e2|Rare Orchid
db|df|d4|Angel's Whisper
db|e0|d0|Feta
db|e2|cc|Light Celery Satin
db|e4|d1|Light Issey-San
db|e4|dc|Aqua Squeeze
db|e4|e5|Alpine Blue
db|e5|b9|Aloe Cream
db|e5|d2|Frostee
db|e6|9d|Fresh Frappe
db|e7|e1|Hint of Spearmint Ice
db|e7|e3|Hint of Antarctica Lake
db|e8|df|Hint of Soft Fresco
db|e9|df|Clair De Lune
db|e9|ed|Sidewalk Chalk Blue
db|e9|f4|Azureish White
db|ee|e0|Sea Mist
db|f4|d8|Light Pastel Mint
dc|14|3c|Wild Rider Red
dc|30|23|Shōjōhi Red
dc|34|3b|Poppy Red
dc|38|55|Teaberry
dc|41|f1|Apple II Magenta
dc|43|33|Punch
dc|4d|01|Deep Orange
dc|50|6e|Rosy Cheeks
dc|6b|67|Native Berry
dc|72|2a|Tahiti Gold
dc|79|3a|Orange Ochre
dc|79|3e|Amberglow
dc|7b|7c|Babe
dc|8c|59|Hematitic Sand
dc|93|8c|Tuscan Image
dc|93|8d|Coral Atoll
dc|93|99|Dancer
dc|9b|68|Coyote
dc|9f|9f|Pink Pussycat
dc|b1|49|Honey Grove
dc|b1|af|Silver Pink
dc|b3|97|Sunset Cove
dc|b6|39|Woven Gold
dc|b6|8a|Brandy
dc|ba|42|Credo
dc|bb|ba|Lilac Paradise
dc|bd|9e|Honey Peach
dc|be|97|Bananas Foster
dc|bf|a6|Adobe Beige
dc|bf|ac|Just Right
dc|bf|e1|Sky Blue Pink
dc|c2|cb|Baby Tone
dc|c4|9b|True Blonde
dc|c6|a0|Raffia
dc|c6|b9|Mornington
dc|c7|c0|Cheerful Heart
dc|c9|9e|Reed Yellow
dc|c9|a8|Ancient Doeskin
dc|c9|ae|Sunday Drive
dc|ca|a8|Egg Liqueur
dc|ca|d8|Creamy Mauve
dc|ca|e0|Grape Glimmer
dc|cb|18|Ryoku-Ou-Shoku Yellow
dc|cc|b4|Seriously Sand
dc|cd|bc|Tapioca
dc|ce|bb|Snip of Tannin
dc|cf|ce|Light Hint Of Lavender
dc|d0|bb|Ostrich Egg
dc|d0|ff|Pale Lavender
dc|d1|bb|Hog Bristle
dc|d3|b2|Suna White
dc|d3|bc|Gunny Sack
dc|d3|ce|Thick Fog
dc|d5|c8|Polished Limestone
dc|d5|d2|Light Bleached Bare
dc|d5|d3|Light Lunette
dc|d6|d1|Light Pearl Ash
dc|d6|d2|Light Mud Berry
dc|d6|d3|Light Amethyst Ice
dc|d7|d1|Gallery
dc|d8|67|Species
dc|d8|a8|Garden Glade
dc|d8|c7|Limestone
dc|d8|cb|Light White Duck
dc|d8|d4|Heirloom Shade
dc|d8|d7|Go To Grey
dc|d9|cd|Milk White
dc|d9|db|Hint of Eskimo White
dc|d9|eb|Light Vision
dc|db|ca|Tree Moss
dc|dc|cf|Light Serena
dc|dc|dc|Gainsboro
dc|dd|65|Succulent
dc|dd|b8|Beach Grass
dc|dd|cc|Light Soft Kind
dc|dd|dd|Athens Grey
dc|dd|e5|Hint of Horizon Sky
dc|df|b0|Glass Green
dc|df|e5|Bright Haze
dc|df|ef|Hint of Powdered Granite
dc|e0|cd|Light Green Frost
dc|e0|ea|Hint of Iced Lavender
dc|e2|e5|Cosmic Dust
dc|e3|e2|Inverness Grey
dc|e4|d7|Phantom Green
dc|e4|dd|Hint of Zen
dc|e4|e9|Pearl City
dc|e5|cc|Misty Hillside
dc|e5|d8|Mint Wafer
dc|e6|e3|Mild Mint
dc|e6|e5|Cameo Green
dc|e7|e5|Starburst
dc|ec|dc|Cottage Green
dc|ec|e7|Waterscape
dc|ec|f5|Ice Fishing
dc|ee|db|Dewmist Delight
dc|f1|c7|Green Glint
dc|f2|e3|Aloe Mist
dc|f4|e6|Hint of Spatial Spirit
dd|00|00|Red Pegasus
dd|00|11|Red Knuckles
dd|00|22|Untamed Red
dd|00|44|Eternal Cherry
dd|00|cc|Passionate Pink
dd|00|ee|Piercing Pink
dd|00|ff|Psychedelic Purple
dd|11|00|Midwinter Fire
dd|11|11|Track and Field
dd|11|22|Piercing Red
dd|11|33|Rare Red
dd|11|dd|Drunk-Tank Pink
dd|22|00|Ares Red
dd|22|22|Chicken Comb
dd|22|44|Infrared Tang
dd|22|55|Rose Rush
dd|33|11|Dynamite Red
dd|33|33|Infrared Burn
dd|33|44|Cruel Ruby
dd|33|55|Very Cherry
dd|41|24|Furnace
dd|41|32|Vampire Red
dd|44|00|Macharius Solar Orange
dd|44|55|Celestial Coral
dd|44|92|Prunus Avium
dd|48|2b|Astorath Red
dd|55|11|Liselotte Syrup
dd|55|44|Coral Burst
dd|55|55|Flushed
dd|55|66|Nectarous Nectarine
dd|55|99|Bit of Berry
dd|55|cc|Fuchsia Flash
dd|66|00|Orange Danger
dd|66|11|Tiger Moth Orange
dd|66|33|Bronzed
dd|66|55|Barely Brown
dd|66|bb|Pink Charge
dd|6b|38|Sorbus
dd|77|00|Orange Outburst
dd|77|44|Orange Shot
dd|77|55|Peachy Scene
dd|77|88|Creamy Coral
dd|77|dd|Hibiscus Pop
dd|77|ff|Pink Fetish
dd|79|a2|Real Raspberry
dd|83|5b|Show Business
dd|83|74|New York Pink
dd|85|d7|Lavender Pink
dd|88|00|Fox Tails
dd|88|11|Non-Stop Orange
dd|88|99|Melancholy
dd|92|89|Lobster Bisque
dd|94|75|Buffed Copper
dd|95|92|Dusty Cedar
dd|97|60|Apricot Tan
dd|97|89|Holland Tile
dd|99|33|Lion King
dd|99|66|Brown Yellow
dd|99|77|Totally Toffee
dd|99|99|Blushing Bud
dd|9c|6b|Gold Earth
dd|a0|26|Zamesi Desert
dd|a0|dd|Damson Plum
dd|a0|df|Pale Plum
dd|a0|fd|Medium Lavender Magenta
dd|a6|9f|Coral Cove
dd|a7|58|Golden Apricot
dd|a8|96|Cedarville
dd|aa|00|Chinese Gold
dd|aa|33|Currywurst
dd|aa|44|Crispy Chicken Skin
dd|aa|55|Old Whiskey
dd|aa|99|Perrigloss Tan
dd|aa|aa|Peach Poppy
dd|aa|bb|Apple Infusion
dd|aa|dd|Barely Bloomed
dd|aa|ee|Petal Plush
dd|ab|ab|Pink Stock
dd|ad|56|Rob Roy
dd|ad|af|Pale Chestnut
dd|af|8e|Boot Hill Ghost
dd|b1|a8|Mesa Pink
dd|b5|96|Crossed Fingers
dd|b6|14|Sulphur
dd|b6|ab|Evening Sand
dd|b9|94|Friar Tuck
dd|bb|11|Golden Schnitzel
dd|bb|66|Termite Beige
dd|bb|88|Death Valley Beige
dd|bb|99|Cane Sugar Glaze
dd|bb|cc|Smoked Silver
dd|bb|ff|Lavender Fragrance
dd|bc|a0|Apple Blossom
dd|bd|a3|Brown-Bag-It
dd|bd|ba|Strawflower
dd|be|dd|Faded Violet
dd|c0|73|Tropical Siesta
dd|c2|83|Caramel Milk
dd|c3|b7|Canyon Dusk
dd|c4|7e|Germania
dd|c4|d4|Blissful
dd|c5|aa|Cliff's View
dd|c5|d2|Frozen Frappe
dd|c7|a2|Oatmeal Bath
dd|c9|c6|Misty Blush
dd|ca|af|Cameo Role
dd|cb|46|Confetti
dd|cb|91|Sonoma Chardonnay
dd|cc|00|Mogwa-Cheong Yellow
dd|cc|33|Mustard On Toast
dd|cc|66|Gluten
dd|cc|77|Sand Pyramid
dd|cc|aa|Heavy Gluten
dd|cc|bb|Hint of Garlic
dd|cd|ab|Fabulous Forties
dd|cd|b3|Cochise
dd|ce|a7|Stonebread
dd|ce|ad|Champagne Bubbles
dd|ce|d1|Light Pink Linen
dd|cf|bc|Malt
dd|cf|bf|Brig O'Doon
dd|d1|bf|Light Rice
dd|d2|a9|Bleached Wheat
dd|d3|ae|Stardust
dd|d4|c5|Urban Bird
dd|d5|ce|Steel Me
dd|d6|18|Chips Provencale
dd|d6|b7|Handmade Linen
dd|d6|cb|Pearl Oyster
dd|d6|e1|Titan White
dd|d6|e7|Light Lavender Water
dd|d7|d1|Light Crushed Almond
dd|d8|c6|Salisbury Stone
dd|db|c5|I Miss You
dd|dc|bf|Woven Reed
dd|dc|da|Grey Ghost
dd|dc|db|Porcelain
dd|dc|e1|Hint of Pensive
dd|dc|ef|Chinese Silver
dd|dd|00|Golden Gun
dd|dd|11|Golden Chandelier
dd|dd|88|Garlic Toast
dd|dd|99|Chalcedony
dd|dd|aa|Spaghetti Carbonara
dd|dd|bb|Endless Silk
dd|dd|cc|Pinch of Pistachio
dd|dd|dd|Grey Area
dd|dd|ee|Artemis Silver
dd|dd|ff|Transparent Blue
dd|df|e8|Hint of Blue Cloud
dd|e0|df|Barely Blue
dd|e0|e8|Orchid Whisper
dd|e0|ea|Monet's Lavender
dd|e2|6a|Green Glitter
dd|e2|d7|Salty Breeze
dd|e2|d9|Hint of Gentle Calm
dd|e2|e6|Bright Star
dd|e3|d5|Water Lily
dd|e3|e6|Cold Light
dd|e4|e3|Dewdrop
dd|e4|e8|Elusive Blue
dd|e6|d7|Lime Daiquiri
dd|e7|df|Icicle
dd|e8|e0|Hint of Gracilis
dd|e8|ed|Moby Dick
dd|ea|e0|Hint of Snow Goose
dd|ed|bd|Mellow Mint
dd|ed|e9|Tranquil
dd|ee|cc|Tzatziki Green
dd|ee|e2|Maggie's Magic
dd|ee|ee|White Glaze
dd|ee|ff|Calcareous Sinter
dd|f3|c2|Envious Pastel
dd|f3|e5|Hint of Lost Lace
dd|f3|e6|Hint of Martian Moon
dd|ff|00|Lime Zest
dd|ff|dd|Transparent Green
dd|ff|ee|Crystal Glass
dd|ff|ff|Apollo's White
de|01|70|Magenta Elephant
de|0c|62|Exotic Liras
de|31|63|Cerise Red
de|57|30|Untamed Orange
de|5d|83|Blush d'Amour
de|5f|2f|Full Of Life
de|6f|a1|Liseran Purple
de|70|a1|Chinese Pink
de|7a|63|Rich Georgia Clay
de|7e|5d|Dark Peach
de|82|86|Peach Blossom
de|8e|65|Copper Tan
de|8f|4e|Jasper Orange
de|94|08|Beige Red
de|96|c1|Gumdrop
de|98|51|Magic Melon
de|9b|c4|Lilac Chiffon
de|9d|ac|Faded Pink
de|a1|dd|Plum Juice
de|a5|a4|Pastel Pink
de|aa|88|Tumbleweed
de|aa|9b|Tamanegi Peel
de|ae|46|Tiger Cub
de|b3|68|Burst of Gold
de|b4|c5|Mental Floss
de|b5|9a|Pink Tulle
de|b6|99|Field of Wheat
de|b7|d9|French Lilac
de|b8|87|Jerboa
de|c0|5f|Cream Gold
de|c1|b8|Monroe Kiss
de|c3|71|Chenin
de|c3|c9|Bunny Pink
de|c4|d2|Elusive Mauve
de|c5|d3|Blushed Velvet
de|c6|d3|Matt Lilac
de|c7|cf|Kellie Belle
de|c9|a9|Czech Bakery
de|ca|ae|Skin Tone
de|ca|c5|Kangaroo Paw
de|cb|81|Sandwisp
de|cb|ab|Sand Blast
de|cb|b1|Toledo Cioio
de|cc|af|Tatami
de|cc|e4|Recuperate
de|cd|be|Sand Dollar
de|ce|96|Bongo Skin
de|ce|d1|Light Bunny Soft
de|cf|b3|Sand Fossil
de|cf|d2|Light Aroma
de|d0|d8|Light Bassinet
de|d1|a3|Summer Solstice
de|d1|b7|Spanish White
de|d1|c6|Pearl Bush
de|d3|e6|Alpine Moon
de|d5|c7|Shoji Screen
de|d5|e2|Light Modesty
de|d7|c8|Turtledove
de|d7|da|Hint of Pale Pearl
de|d8|dc|Hint of Stately Frills
de|d9|db|Hint of Easter Rabbit
de|db|c4|River Reed
de|db|cc|Cocoon
de|db|e5|Pale Orchid
de|dc|c6|Light Sandbank
de|dc|e2|Hint of Femininity
de|dd|98|Bored Accent Green
de|dd|cb|Green White
de|dd|dd|Silver Lake
de|de|cf|Corinthian Column
de|de|e5|Hint of Kiri Mist
de|de|ff|Contrail
de|df|c9|Sip of Mint
de|df|e2|Wayward Wind
de|e1|e9|Frosty Fog
de|e1|ed|Hint of Silver Sweetpea
de|e2|ec|Violet Extract
de|e3|de|Whitecap Foam
de|e3|e3|Zircon
de|e4|dc|Morning Rush
de|e6|e7|Austrian Ice
de|e8|e3|Sandwashed Glassshard
de|ea|aa|High Hopes
de|ea|bd|Budding Bloom
de|ea|d8|Lily Pond
de|ea|dc|Frozen Grass
de|ea|e0|Pine Frost
de|ec|e1|Hint of Green Wash
de|ec|ed|Winter Breath
de|ed|d4|Light Tactile
de|ed|e4|Hint of Light Lichen
de|ee|ed|Free Spirit
de|f0|a3|Mint Julep
de|f1|dd|Tara
de|f1|e7|Snow Ballet
de|f7|fe|Winter's Day
de|ff|00|Citron Goby
df|00|ff|Phlox
df|01|f0|Deep Flamingo
df|31|63|Intense Passion
df|3f|32|Bacon Strips
df|4e|c8|Purplish Pink
df|61|24|Vivid Red Tangelo
df|69|1e|Fading Ember
df|6e|a1|China Pink
df|6f|a1|Thulian Pink
df|71|63|Pale Scarlet
df|73|ff|Venus Slipper Orchid
df|74|5b|Rustic Pottery
df|75|00|Orange Pepper
df|8f|67|Pale Copper
df|98|76|Baked Salmon
df|9c|45|Pavilion Peach
df|9d|5b|Porsche
df|9e|9d|Pimlico
df|a3|ba|Pink Gin
df|ab|56|Rip Cord
df|ac|4c|Brass Buttons
df|ac|59|Brown Mustard
df|b1|9b|Pink Sand
df|b1|b6|Sakura
df|b4|5f|Birch Strain
df|b5|b0|Princess Pink
df|b7|b4|Cherry Tree
df|b8|b6|Peachskin
df|b9|00|Plague Brown
df|b9|92|Pancho
df|ba|5a|Sun God
df|ba|a9|Spanish Villa
df|bb|7e|Wheat Bread
df|bb|86|Honey Robber
df|c0|8a|Sahara Gravel
df|c0|9f|Winter Wheat
df|c0|a6|Weathered Sandstone
df|c1|6d|Highlight Gold
df|c1|c3|Cameo Appearance
df|c2|81|Chalky
df|c3|93|Dirty Blonde
df|c5|d5|Extreme Lavender
df|c5|fe|Light Blue Lavender
df|c6|aa|Larb Gai
df|ca|aa|Land Light
df|ca|e4|Syrian Violet
df|cb|cf|Light Frosted Sugar
df|cd|c6|Morganite
df|cd|c7|Lip Gloss
df|cf|ca|Watermelon Milk
df|d0|c0|Shetland Lace
df|d1|bb|Angora
df|d2|d9|Light Tinge Of Mauve
df|d3|ca|Light Christobel
df|d3|e3|Light Prudence
df|d4|b7|Sahara Wind
df|d4|c0|Whirligig Geyser
df|d4|c4|Wheat Sheaf
df|d5|c8|Casual Elegance
df|d7|bd|Wheatfield
df|d7|d2|Bonjour
df|d8|b3|Rancho Verde
df|d8|d9|Hint of Wallis
df|d8|e1|Pastel Day
df|d9|da|Hint of Pale Lady
df|d9|dc|Hint of Glass Bead
df|da|d9|Hint of Oil Of Lavender
df|da|e0|Breathless
df|db|d8|Hint of Ghost Town
df|dc|d5|River Shark
df|dd|d6|Sea Fog
df|dd|d7|Vaporous Grey
df|de|e5|Violet Echo
df|df|ea|Hint of Pax
df|e1|cc|Light Medlar
df|e2|e4|Porcelain Jasper
df|e2|e5|January Dawn
df|e2|f0|Hint of Ace
df|e3|84|Grape Cassata
df|e3|d0|Lime Wash
df|e4|da|Distant Haze
df|e4|dc|Hint of Silver Grass
df|e6|9f|Pale Lime Yellow
df|e6|cf|Willow Brook
df|e6|da|Cloudy Day
df|e6|ea|City Lights
df|e7|e8|Filigree
df|e7|eb|Cloud Abyss
df|ea|db|Hint of Snow Green
df|ea|de|Hint of Marsh Fog
df|ea|e1|Hint of Dry Lichen
df|ea|e8|Teton Breeze
df|eb|b1|Fresh Up
df|eb|d6|Mineral Water
df|eb|e9|Honesty
df|eb|ee|Prelude
df|ec|e9|Second Wind
df|ef|87|Sunny Lime
df|ef|ea|Clear Day
df|f0|e2|Ice-Cold White
df|f1|d6|Hint of Green
df|f1|fd|Wizard White
df|fa|e1|Misty Lawn
df|fb|f3|Mint Condition
df|ff|00|Dancing-Lady Orchid
df|ff|11|Bright Chartreuse
df|ff|4f|Tennis Ball
e0|11|5f|Ruby Dust
e0|20|06|Hóng Bǎo Shū Red
e0|21|8a|Myoga Purple
e0|3c|28|Lionfish Red
e0|3c|31|CG Red
e0|3f|d8|Méi Gūi Zǐ Purple
e0|4f|80|Fandango Pink
e0|5a|ec|Clematis Magenta
e0|6f|8b|Raspberry Mousse
e0|77|57|Potash
e0|81|19|Dark Cheddar
e0|81|5e|Sohi Orange
e0|81|6f|Wet Pottery Clay
e0|8a|1e|Sumac dyed
e0|8d|3c|Texas Longhorn
e0|93|ab|Kobi
e0|98|42|Fire Bush
e0|9c|ab|Colorado Dawn
e0|9e|87|Chinese Ibis Brown
e0|9f|78|Pecan Veneer
e0|b0|ff|Mauve
e0|b4|93|Sonora Apricot
e0|b4|a4|Prosciutto
e0|b5|89|Desert Mist
e0|b6|95|Oakley Apricot
e0|b7|c2|Melanie
e0|b8|b1|Cavern Pink
e0|bb|95|Lama
e0|c5|a1|Fortune Cookie
e0|c7|d7|Lilac Snow
e0|c9|97|Nomadic Travels
e0|ca|c0|Ancient Ruins
e0|cb|82|Camel Cord
e0|ce|57|Gold Deposit
e0|ce|b7|Chalkware
e0|cf|b5|Inside Passage
e0|cf|b9|Soft Doeskin
e0|cf|d2|Light Sprig Muslin
e0|d0|db|Orchid Ice
e0|d1|bb|Clambake
e0|d2|ba|Magic Sail
e0|d3|bd|Banded Tulip
e0|d4|d0|Light Weathered Hide
e0|d4|e0|Light Tender Touch
e0|d5|c6|Whitecap Grey
e0|d5|c9|Light Chintz
e0|d5|cd|Light Perk Up
e0|d5|e3|Coin Purse
e0|d5|e9|Light Purity
e0|d6|8e|Flax Fiber
e0|d7|c6|Bone
e0|d8|a7|Buckwheat Groats
e0|d8|df|Little Lilac
e0|d9|da|Hint of Orchid Haze
e0|db|c7|Cozy Cream
e0|dc|d7|Hint of Taupe White
e0|dc|d8|Hint of Subdue
e0|dc|da|Hint of White Flag
e0|dc|db|Snow Peak
e0|dc|e4|Hint of Laughing Jack
e0|dd|dd|Royal Silver
e0|de|b8|Tropical Tale
e0|de|d7|Black Haze
e0|de|d8|Seagull
e0|de|e3|February Frost
e0|df|db|Hint of Bleaches
e0|df|e8|Hint of Amourette
e0|e0|dc|Hint of Brume
e0|e0|ff|Stoic White
e0|e1|c1|Lilylock
e0|e1|d1|Wild Wheat
e0|e1|d8|Hint of Pale Celadon
e0|e1|e2|Yín Bái Silver
e0|e3|c8|More Melon
e0|e3|ef|Iris Ice
e0|e4|db|Hint of Cipollino
e0|e4|dc|Catskill White
e0|e4|e2|Grey Glimpse
e0|e5|e2|Icy Bay
e0|e6|d7|Whisper Green
e0|e6|f0|Moon Dust
e0|e7|dd|Hint of Silver Dollar
e0|e8|db|December Forest
e0|e8|ec|Sweet Illusion
e0|e9|d0|Light Security
e0|e9|e4|Sea Pearl
e0|e9|f3|Harbour Afternoon
e0|ea|d7|Gratitude
e0|eb|af|Grandiflora Rose
e0|eb|fa|Husky
e0|ee|d4|Light Korila
e0|ee|df|Hint of Spring Burst
e0|ef|e1|Hint of Katsura
e0|ef|e3|Hint of Enchanted
e0|ef|e9|Morning Light Wave
e0|f0|e5|Hint of Duck Egg Cream
e0|f1|c4|Green Veil
e0|f6|fb|Coastal Breeze
e0|ff|ff|Light Cyan
e1|21|20|Akira Red
e1|2c|2c|Permanent Geranium Lake
e1|5f|65|Briquette
e1|63|4f|Flamingo
e1|69|7c|Slice of Watermelon
e1|77|01|Pumpkin Soup
e1|78|61|Annular
e1|82|89|Pulp
e1|8e|3f|Orange Drop
e1|8e|96|Ruddy Pink
e1|92|7a|Canyon Sunset
e1|96|40|Angel Shark
e1|98|b4|Peach Flower
e1|a0|cf|Exotic Violet
e1|a4|b2|Iced Vovo
e1|a8|4b|Brass Mesh
e1|a8|90|Rose Tattoo
e1|a9|5f|Earth Yellow
e1|ad|01|Mustard Yellow
e1|ad|21|Urobilin
e1|b2|70|Demerara Sugar
e1|b9|c2|Love In A Mist
e1|bb|87|Regency Cream
e1|bb|db|Sweetie Pie
e1|bd|27|Durian Yellow
e1|be|d9|Pink Peony
e1|c1|2f|Finger Banana
e1|c1|61|Candelabra
e1|c2|be|Slubbed Silk
e1|c2|c1|Spice Girl
e1|c3|bb|Light Lily
e1|c5|c9|Pink Pandora
e1|c6|8f|Clay Bake
e1|c6|a8|My Love
e1|c6|cc|Pale Lilac
e1|c7|a8|Persian Flatbread
e1|c8|d1|Tinted Rosewood
e1|cb|b6|Practical Tan
e1|cb|da|Diva Girl
e1|cc|a6|Hearth
e1|cd|a4|Organic Bamboo
e1|ce|ad|Boutique Beige
e1|ce|d4|Light Pelican Bill
e1|cf|a5|Foothills
e1|cf|af|Creamy Chenille
e1|cf|b2|Almond Silk
e1|cf|c6|Shell
e1|d0|af|Braided Raffia
e1|d0|b2|Assateague Sand
e1|d0|d8|Light Tip Toes
e1|d3|8e|Leaf Print
e1|d4|b4|Garden Lattice
e1|d4|e8|Light Oriental Blush
e1|d5|90|Lima Bean
e1|d5|a6|Sapling
e1|d8|b8|Flowering Reed
e1|d8|bb|Physalis Peal
e1|d9|56|Kowloon
e1|d9|b8|Sesame Seed
e1|d9|dc|Smoky Orchid
e1|da|bb|Coconut Cream
e1|da|ca|Tiger Claw
e1|da|cb|Albescent White
e1|da|cf|Light Sandy Day
e1|da|d9|Hint of Nantucket Mist
e1|da|dd|Hint of Bay Fog
e1|db|d0|Merino
e1|dd|8e|Lively Laugh
e1|dd|bf|Silver Fern
e1|dd|db|Fall Chill
e1|de|d8|Hush Grey
e1|de|e5|Frozen Statues
e1|de|e7|Hint of Dreamweaver
e1|de|e8|Hint of Lilac Crystal
e1|df|e0|Christmas Silver
e1|e0|eb|Hint of Gregorio Garden
e1|e1|be|Forgive Quickly
e1|e1|cf|Emerging Leaf
e1|e1|d5|Fish Ceviche
e1|e1|db|Tundra Frost
e1|e1|dd|Night White
e1|e1|e2|Jupiter
e1|e2|d6|Hint of Green Alabaster
e1|e3|6e|Ripe Pear
e1|e3|a9|Young Wheat
e1|e3|d7|Hint of Lamb's Ears
e1|e3|e4|Cold Wind
e1|e4|c5|Frost
e1|e5|ac|Bit of Lime
e1|e5|d7|Touch of Lime
e1|e5|dc|Water Droplet
e1|e6|eb|Winter Haven
e1|e6|f2|Crystal Falls
e1|e8|db|Summer Rain
e1|e9|db|Hint of French Limestone
e1|ea|ec|Summer Mist
e1|eb|d8|Hint of Bethany
e1|eb|de|Hint of Mystified
e1|eb|e5|Delicate Mist
e1|ec|a5|Wedge of Lime
e1|ec|d9|Hint of Lime Sherbet
e1|ed|e6|Molten Ice
e1|ee|e6|Cool Icicle
e1|ee|ec|Thawed Out
e1|ef|dd|Distant Landscape
e1|f2|df|Hint of Frosty Dawn
e1|f5|e5|Hint of Pickford
e1|f8|e7|Toxic Latte
e2|04|1b|Shojo's Blood
e2|06|2c|Medium Candy Apple Red
e2|46|66|Rouge Red
e2|50|98|Raspberry Pink
e2|55|2c|Orangeade
e2|58|22|Flame
e2|58|3e|Tigerlily
e2|60|58|Fiery Coral
e2|68|1b|Brihaspati Orange
e2|6b|81|Cherry Brandy
e2|72|5b|Phoenix Red
e2|79|45|Jaffa
e2|7a|53|Dusty Orange
e2|7e|8a|True Love
e2|81|3b|Tree Poppy
e2|90|b2|Rosebloom
e2|9a|86|Shrimp
e2|9c|45|Kikuchiba Gold
e2|9d|94|Coral Almond
e2|9f|31|Shì Zǐ Chéng Persimmon
e2|a6|95|Pelican Pink
e2|a8|29|Dried Goldenrod
e2|a9|a1|Coral Cloud
e2|ac|78|Buffalo Trail
e2|af|80|Manhattan
e2|b0|51|Yolk Yellow
e2|b1|3c|Themeda Japonica
e2|b2|27|Gold Tips
e2|b5|bd|Heart's Content
e2|ba|bf|Puppy Love
e2|bc|b3|Sweet Peach
e2|bc|b8|Balcony Rose
e2|bd|b3|Peach Powder
e2|be|9f|Eggshell Paper
e2|be|a2|Amberlight
e2|be|b4|Muddy Rose
e2|c2|8d|Lira
e2|c2|8e|Birdseed
e2|c2|99|Dapper Dingo
e2|c3|92|Halo
e2|c3|cf|In The Slip
e2|c4|a6|Apricot Illusion
e2|c4|af|Gypsum Rose
e2|c5|91|Sideshow
e2|c5|9c|Faint Fawn
e2|c6|81|Salty Cracker
e2|c7|4f|Golden Yarrow
e2|c7|79|Waffle Cone
e2|c7|b6|Birthday Suit
e2|c8|b7|Ellen
e2|c9|c8|Youth
e2|c9|ce|Perfume Cloud
e2|c9|ff|Foggy Heath
e2|ca|73|Dijon Mustard
e2|ca|76|Sand
e2|ca|af|You're Blushing
e2|cc|9c|Prairie Land
e2|cc|c7|Pale Berries
e2|cd|52|Citrus Spice
e2|cd|d5|Prim
e2|d0|b9|Smashed Potatoes
e2|d3|9b|Twinkle Toes
e2|d4|d6|Hapsburg Court
e2|d4|df|Soft Lilac
e2|d4|e1|Light Naked Pink
e2|d5|d3|Whirlwind
e2|d6|bd|Candy Grass
e2|d6|d8|Hint of Pink Polar
e2|d7|b5|Afghan Hound
e2|d7|c1|Garlic Clove
e2|d7|da|Hint of Lady Fingers
e2|d8|c2|Mission White
e2|d8|c3|Exclusive Ivory
e2|d8|cb|Maybe Mushroom
e2|d8|d3|Light Raspberry Ice
e2|d8|d4|Light Thought
e2|d9|d2|Light Daydreamer
e2|d9|d4|Light Instant
e2|d9|db|Hint of Mosque
e2|d9|dd|Hint of Elusive Dream
e2|da|c2|Grass Skirt
e2|da|c6|Beige Linen
e2|da|d1|Lahmian Medium
e2|da|df|Hint of Puffball
e2|db|ca|Frankly Earnest
e2|dc|ab|Virgin Olive Oil
e2|dc|cc|Light Grand Piano
e2|dc|d4|Thistle Grey
e2|dd|c7|Travertine
e2|dd|d1|Texan Angel
e2|de|c8|Light Pistachio Tang
e2|de|d6|Hint of Ghosting
e2|de|df|Ardcoat
e2|e0|d8|Hint of Pipe Clay
e2|e0|db|Hint of Vanilla Quake
e2|e1|c8|Light Ghostly Green
e2|e1|d6|Hint of Livingstone
e2|e2|ed|Icy Lavender
e2|e3|eb|Water Iris
e2|e4|d7|Ice Palace
e2|e4|e9|Silver City
e2|e5|c7|Lazy Caterpillar
e2|e5|de|Chinese White
e2|e6|d1|Hint of Jade
e2|e6|d7|Hint of Green Ash
e2|e6|db|Hint of Iced Aniseed
e2|e6|e0|Bluewash
e2|e7|e7|White Lake
e2|e8|df|Spider Cotton
e2|ea|eb|Bit of Blue
e2|ea|f0|Himalaya Peaks
e2|eb|e5|Hallowed Hush
e2|ec|f2|Dissolved Denim
e2|ed|c1|Spring Shoot
e2|ef|c2|New Hope
e2|ef|dd|Soft Focus
e2|f0|d2|Light Greenette
e2|f2|e4|Frosted Mint
e2|f4|d7|Light Fresh Lime
e2|f4|e4|Hint of Celery Stick
e2|f5|e1|Hint of Carolina
e2|f7|d9|Frosted Garden
e2|f7|f1|Frosty Mint
e3|00|22|Cadmium Red
e3|0b|5c|Razzmatazz
e3|0b|5d|Raspberry Yogurt
e3|25|6b|Razzmatazz Lips
e3|26|36|Alizarin Crimson
e3|36|36|Rose Madder
e3|42|34|Carpaccio
e3|42|44|Vermilion Cinnabar
e3|42|85|Christmas Pink
e3|46|36|Alizarin
e3|4b|50|Thimbleberry
e3|5b|8f|Carmine Rose
e3|5b|d8|Free Speech Magenta
e3|5c|38|Sohi Red
e3|6f|8a|Deep Blush
e3|8e|84|Coral Haze
e3|8f|ac|Light Thulian Pink
e3|98|af|Passion Potion
e3|99|ca|Crepe Myrtle
e3|9f|08|Bilious Brown
e3|a1|b8|Blushing Tulip
e3|a4|9a|Cuticle Pink
e3|a4|b8|Garden Party
e3|a8|57|Indian Yellow
e3|ab|57|Sunray
e3|ac|3d|Tulip Tree
e3|ad|59|Autumn Avenue
e3|b1|30|Nanohanacha Gold
e3|b3|4c|Va Va Voom
e3|b4|6f|Fire Coral
e3|b5|ad|Stormy Pink
e3|b6|aa|Salmon Grey
e3|b8|bd|Seven Veils
e3|b9|82|Cane Sugar
e3|bc|8e|Desert Dust
e3|bc|bc|Soft Blush
e3|be|b0|Adorable
e3|c2|95|Dromedary
e3|c5|d6|Favourite Lady
e3|c6|d6|Pretty Pale
e3|c7|c6|Powdered Petals
e3|c9|be|Sultan Sand
e3|ca|b5|Geyser Basin
e3|cb|a8|Gourmet Honey
e3|cb|c0|Belle of the Ball
e3|cc|81|Dusky Citron
e3|cd|ac|Warm Biscuits
e3|ce|b8|Comfort
e3|ce|c6|Ginger Shortbread
e3|cf|ab|Melt with You
e3|d0|ad|Cream Cake
e3|d0|bf|Ice Cream Cone
e3|d0|d5|Santolina Blooms
e3|d1|c8|Wheat Seed
e3|d1|cc|China Silk
e3|d2|c0|Sand Dune
e3|d2|ce|Romeo
e3|d2|cf|Light Lavender Blush
e3|d2|db|Light Mauve Organdie
e3|d3|b5|Loofah
e3|d3|bf|Oyster
e3|d4|74|Golden Rice
e3|d4|b9|Celestial Moon
e3|d4|bb|Raw Cotton
e3|d5|b8|Gentle Touch
e3|d6|bc|Pollinate
e3|d6|c7|Light Clay Pipe
e3|d6|e9|Old Chalk
e3|d7|bb|Cornerstone
e3|d7|e5|Lavender Vista
e3|d8|d4|Light Nut Milk
e3|d9|a0|Russet Green
e3|da|c6|Instant Classic
e3|da|c9|Skull
e3|da|e9|Awakened
e3|db|cd|Light Buff It
e3|db|d0|Light Male
e3|dc|d6|Hint of Eggshell Pink
e3|dc|da|Hint of Antique Lace
e3|dc|e0|Hint of Limpid Light
e3|dd|39|Starship
e3|dd|bd|Flaxen Fair
e3|dd|cc|Fossil Stone
e3|de|c6|Bamboo
e3|df|84|Crescendo
e3|df|d9|Vista White
e3|df|ea|Hint of Angel Kiss
e3|df|ec|Velvet Scarf
e3|e0|da|Hint of Grey Pebble
e3|e1|cc|Persian Blinds
e3|e1|ed|Hint of Opus
e3|e2|d7|Hint of Pale Tendril
e3|e3|d7|Light Sprinkle
e3|e3|dc|Snow Drift
e3|e4|d9|Hint of Serena
e3|e4|e2|Aria
e3|e4|e5|Windswept Beach
e3|e5|b1|Tusk
e3|e5|e8|Arctic Dawn
e3|e6|d6|Hint of Garlic Suede
e3|e6|da|Hint of Carrot Flower
e3|e7|c4|Tinted Mint
e3|e7|e1|White Blaze
e3|e8|d9|Milkweed
e3|e8|db|Hint of Ligado
e3|e9|cf|Light Mountain Spring
e3|e9|e8|Evening Mist
e3|ea|a5|Luminary Green
e3|ea|db|Hint of Breakaway
e3|eb|ae|Daydream
e3|eb|b1|Awareness
e3|eb|ea|Artemesia
e3|ec|c5|Green Eggs
e3|ed|e0|Green Tease
e3|ed|ed|Bashful
e3|ee|e3|Green Whisper
e3|ef|b2|Spring Kiss
e3|ef|dd|Winter Shamrock
e3|ef|e1|Hint of Mint
e3|ef|e3|Molly Green
e3|f1|eb|Mist of Green
e3|f5|e5|After Dinner Mint
e3|ff|00|Lime Jelly
e4|00|0f|Mario Red
e4|00|46|Lotti Red
e4|00|58|Framboise
e4|00|78|Red Purple
e4|00|7c|Mexican Pink
e4|03|0f|Miyamoto Red
e4|44|5e|Paradise Pink
e4|5c|10|Tobiko Orange
e4|5e|32|Red Cray
e4|65|8e|Love Letter
e4|6b|71|Redstone
e4|6f|34|Lava Pit
e4|71|27|Russet Orange
e4|71|7a|Natural Candy Pink
e4|7c|b8|Fuchsia Blush
e4|7f|7a|Tango Pink
e4|84|00|Fulvous
e4|89|8a|Pink Chi
e4|8b|59|Aegean Sky
e4|9b|0f|Gamboge
e4|9c|86|Opal Fire
e4|b0|95|Hush Puppy
e4|b3|cc|Muddy Mauve
e4|b5|b2|Pink Dust
e4|b8|57|Mr Mustard
e4|bf|45|Super Lemon
e4|bf|b3|Pale Blush
e4|c1|4d|Indian Maize
e4|c3|85|New Orleans
e4|c3|8f|Cozy Cover
e4|c5|00|Zhohltyi Yellow
e4|c5|90|Bungalow Maple
e4|c6|83|Beachcombing
e4|c7|b8|Cream Tan
e4|c7|c8|Girl Talk
e4|cb|ff|Lens Flare Pink
e4|cc|b0|Jacobean Lace
e4|cc|c6|Peach Blush
e4|ce|b5|Warm Croissant
e4|cf|99|Double Colonial White
e4|cf|b6|Macadamia
e4|cf|d3|Light Bunny Pink
e4|cf|d7|Light Baby Tone
e4|d0|0a|Citrine
e4|d1|95|Garden Picket
e4|d1|bc|Bonnie Dune Beach
e4|d2|d8|Ibis Mouse
e4|d4|66|Bananarama
e4|d4|be|Bread Crumb
e4|d5|bc|Cria Wool
e4|d5|c0|Figurine
e4|d6|ba|Yellowstone Park
e4|d7|c5|White Swan
e4|d7|e5|Snuff
e4|d8|9a|Subtle Sunshine
e4|d8|ab|Rice Fibre
e4|d8|d8|Star Magic
e4|d9|6f|Straw
e4|d9|c5|Fish Bone
e4|da|d3|Light Subpoena
e4|db|55|Manz
e4|dc|8a|Dead Grass
e4|de|65|Fandangle
e4|de|8e|Citrus Butter
e4|de|cd|Winter Frost
e4|de|d2|Oyster Haze
e4|de|d5|Sandy Ash
e4|df|d1|Southern Breeze
e4|e0|d4|Hint of Beige Royal
e4|e0|da|Hint of Limed White
e4|e0|dc|Hint of Mud Berry
e4|e0|dd|Hint of Slight Mushroom
e4|e1|d6|Hint of White Duck
e4|e1|de|Hint of Warm Ash
e4|e1|e3|Lavender Breeze
e4|e1|e4|Orchid Blossom
e4|e1|ea|Guardian Angel
e4|e2|d6|Hint of Cargo River
e4|e2|dc|Wan White
e4|e4|c5|Fountain Frolic
e4|e4|cb|Light Apple Cucumber
e4|e4|d5|Garden Pebble
e4|e4|da|Pearly Star
e4|e5|ce|Pineapple Soda
e4|e5|d2|Sage Splash
e4|e6|dc|Crystal Brooke
e4|e6|ea|Little Dipper
e4|e8|a7|Hip Hop
e4|e8|e1|Poetic License
e4|ea|df|Lightest Sky
e4|ea|ed|Calla Lily
e4|eb|b1|Cucumber Cream
e4|eb|dc|Hint of Issey-San
e4|eb|e7|Mist Spirit
e4|ec|df|Window Pane
e4|ec|e9|Morning Song
e4|ef|de|Chilled Mint
e4|ef|e5|Stone Path
e4|f3|e0|Mojito
e4|f5|e1|Hint of Pastel Mint
e4|f7|e7|Weisswurst White
e5|00|00|Lifeguard Red
e5|1a|4c|Spanish Crimson
e5|2b|50|Manganese Red
e5|60|24|Vivid Vermilion
e5|6d|75|Froly
e5|70|59|Orangeville
e5|7f|3d|Pizazz
e5|7f|5b|Tangerine Flake
e5|81|a0|Hope
e5|82|3a|West Side
e5|85|a5|Rose Glory
e5|86|7b|Cultured Rose
e5|8e|73|Middle Red
e5|93|68|Gypsy
e5|97|52|Butternut Pizazz
e5|97|b2|Usu Koubai Blossom
e5|9b|34|Persimmon
e5|a0|90|Coral Blush
e5|a1|92|Rose Dusk
e5|a1|a0|Bussell Lace
e5|a2|ab|Berry Riche
e5|a5|c1|Think Pink
e5|aa|70|Ninjin Orange
e5|ab|be|Sekichiku Pink
e5|b3|21|Kogane Gold
e5|b3|9b|Almost Apricot
e5|b3|b2|Perfect Pink
e5|b7|3b|Meat Brown
e5|b7|a5|Fall Leaf
e5|bc|a5|Starfish
e5|bd|df|Blackberry Yogurt
e5|c1|a7|Adobe South
e5|c1|b3|Calico Rose
e5|c3|82|Autumn Glow
e5|c4|c0|Rose Colored Glasses
e5|ca|c0|Red Sandstorm
e5|cb|3f|Crazy
e5|cc|af|Grey Sand
e5|cc|bd|Peach Brick
e5|cf|de|Summer Clover
e5|d0|b0|Chaparral
e5|d0|b1|Blonde Wool
e5|d0|ca|Pink Marble
e5|d0|cf|Mauve Chalk
e5|d2|95|Desert Wind
e5|d2|b0|Bisque Tan
e5|d2|b2|Chowder Bowl
e5|d2|c9|Blossom Time
e5|d2|dd|Light Blissful
e5|d3|b9|Almond Brittle
e5|d4|c9|Light Mornington
e5|d5|ba|Pale Sand
e5|d5|bd|Scallywag
e5|d6|8e|Copacabana Sand
e5|d7|c4|Sandcastle
e5|d7|d4|Lost Love
e5|d8|e1|Wine Frost
e5|d9|d3|Pastel Parchment
e5|d9|dc|Hint of Pink Linen
e5|da|9f|Bamboo Mat
e5|da|e1|Violet Vapor
e5|db|c5|Almond Paste
e5|db|da|Hint of Hint Of Lavender
e5|dd|c8|Lime Chalk
e5|dd|cb|Light Hog Bristle
e5|dd|e7|Orchid Lane
e5|de|ca|Light Ecru
e5|de|cc|Moondance
e5|df|cd|Pueblo White
e5|df|dc|Hint of Bleached Bare
e5|e0|cc|Misty Moonstone
e5|e0|d2|Focus
e5|e0|d5|Hourglass
e5|e0|db|Hint of Pearl Ash
e5|e0|dd|Hint of Lunette
e5|e0|ec|Hint of Lavender Water
e5|e1|cc|Canyon Echo
e5|e1|dd|Hint of Amethyst Ice
e5|e1|de|Dusky Dawn
e5|e2|e1|Diamonds In The Sky
e5|e2|e7|Violet Hush
e5|e3|bf|Spring Fever
e5|e3|e5|Tripoli White
e5|e3|ef|Hint of Vision
e5|e4|db|Black White
e5|e4|dd|Swan Dive
e5|e4|e2|Platinum
e5|e5|e1|Apollo Landing
e5|e5|fa|Lavender Mist
e5|e6|d7|Twilight Twist
e5|e6|df|Black Squeeze
e5|e7|90|Charlock
e5|e7|d5|Pine Water
e5|e7|e5|Whale Bone
e5|e7|e6|Radisson
e5|e7|e8|Silent Delight
e5|e7|e9|Wisp of Smoke
e5|e8|d9|Hint of Green Frost
e5|e8|e6|Grey Wonder
e5|e8|f2|Whisper Blue
e5|e9|99|Orchid Hue
e5|e9|b7|Iced Celery
e5|e9|e1|Tidal Mist
e5|ea|d8|Hint of Celery Satin
e5|ea|e6|Distant Cloud
e5|eb|e3|Summer Shower
e5|eb|e6|Lightning Bolt
e5|ec|b7|Lots of Bubbles
e5|ed|f1|Morning Mist
e5|ef|d7|Translucent Vision
e5|f1|ee|Aqua Tint
e5|f2|e7|Polar
e5|f4|d5|Light Green Glint
e6|00|00|Electric Red
e6|00|26|Spanish Red
e6|06|26|Xiān Hóng Red
e6|20|20|Lust
e6|4d|1d|Nasturcian Flower
e6|54|1b|Tingle
e6|67|71|Light Carmine Pink
e6|6a|77|Bleeding Heart
e6|7c|7a|Lively Coral
e6|80|95|Carissima
e6|83|64|Brewed Mustard
e6|87|50|Orange Poppy
e6|8e|96|Poudretteite Pink
e6|8f|ac|Charm Pink
e6|93|32|Sanskrit
e6|99|4c|Colorado Peach
e6|9b|3a|Culpeo
e6|9d|ad|Brandywine
e6|a2|55|Roasted Squash
e6|a5|7f|Orange Clay
e6|a7|ac|Perennial Phlox
e6|a8|d7|Light Orchid
e6|af|91|Peach Nougat
e6|b0|af|Chewing Gum
e6|b2|a6|Shilo
e6|b2|b8|Amazon River Dolphin
e6|b4|a6|City of Pink Angels
e6|b7|6c|California Chamois
e6|b7|7e|Fulgurite Copper
e6|b9|9f|Seasonal Beige
e6|ba|45|Capital Yellow
e6|bc|cd|Pink Mist
e6|bd|8f|Gold Plate
e6|be|59|Golden Appeal
e6|be|8a|Bourbon Spice
e6|be|9c|Bronze Sand
e6|c1|bb|Rose Petal
e6|c2|6f|Turner's Yellow
e6|c5|ca|Chalk Pink
e6|c7|b7|Cupcake Rose
e6|c8|a9|Pumpkin Cream
e6|c8|ff|Wisteria Powder
e6|cd|b5|Ginseng Root
e6|cd|ca|Whirligig
e6|ce|e6|Footie Pajamas
e6|cf|cc|Hugo
e6|cf|ce|Slightly Rose
e6|d0|ab|Durian White
e6|d0|b6|Beachy Keen
e6|d0|ca|Pianissimo
e6|d1|dc|Light Elusive Mauve
e6|d2|dc|Light Frozen Frappe
e6|d4|a5|Bakelite
e6|d5|ba|Warm Buttercream
e6|d5|ce|Blossom Pink
e6|d6|99|Pale Oriental
e6|d6|ba|Palomino Mane
e6|d6|cd|Dawn Pink
e6|d7|cc|Warmstone
e6|d8|d4|Ebb
e6|d9|43|Citrus Sugar
e6|d9|e2|Rajah Rose
e6|da|78|Lustrous Yellow
e6|da|a6|Beige
e6|da|c4|Seed Pearl
e6|da|d6|Light Watermelon Milk
e6|db|c4|Adobe White
e6|db|c7|Half Spanish White
e6|dd|be|Amish Bread
e6|dd|c5|Cloud Cream
e6|dd|c6|Irresistible Beige
e6|dd|cd|Light Light Rice
e6|dd|d2|Light Parchment Paper
e6|de|e6|Peekaboo
e6|de|ea|Hint of Prudence
e6|de|f0|Lingering Lilac
e6|df|c4|Horseradish
e6|df|d2|Canvas Cloth
e6|df|e7|Selago
e6|df|e8|Hint of Modesty
e6|e0|cc|Vanilla Love
e6|e0|d4|White Coffee
e6|e0|e0|Mountain Air
e6|e1|c7|Light Handmade Linen
e6|e2|00|Peridot
e6|e2|e4|Cooling Trend
e6|e3|d6|Trade Winds
e6|e3|d8|Narcomedusae
e6|e3|df|Arctic Cotton
e6|e4|d4|Satin Linen
e6|e4|e4|Grey Whisper
e6|e5|d3|Hint of Sandbank
e6|e5|dc|Silvery Moon
e6|e5|e4|Cold Morning
e6|e6|d8|Hint of Soft Kind
e6|e6|e7|Moon Lily
e6|e6|f1|Lavender Syrup
e6|e6|fa|Cyber Lavender
e6|e8|c5|More Mint
e6|e8|fa|Glitter
e6|e9|f9|Icy Lilac
e6|ea|e0|Hydrangea Floret
e6|ec|cc|Honeydew Melon
e6|ec|d6|Lime Meringue
e6|ef|cc|Light Budding Bloom
e6|f0|ea|Northern Lights
e6|f1|de|Hint of Tactile
e6|f2|a2|Dingy Sticky Note
e6|f2|c4|Freshman
e6|f2|ea|Bath Bubbles
e6|f9|f1|Soft Mint
e6|fd|f1|Mint Chiffon
e7|4a|33|Mandarin Red
e7|54|80|Heather Berry
e7|72|00|Thai Mango
e7|7b|75|Geraldine
e7|81|a6|Mangala Pink
e7|83|03|Master Round Yellow
e7|8b|90|Strawberry Ice
e7|8e|a5|Underwater Flare
e7|96|8b|Salmon Salt
e7|9d|b3|Always Rosey
e7|9e|88|Tonys Pink
e7|9e|a6|Strawberry Smoothie
e7|a9|95|Ageless Beauty
e7|aa|56|Jurassic Gold
e7|ac|cf|Pink Pearl
e7|b2|5d|Talâyi Gold
e7|b3|47|Aztec Glimmer
e7|b5|7f|Stormeye
e7|b6|c8|Hydrangea Pink
e7|bc|b4|Rose Fog
e7|bd|42|Brass Balls
e7|bf|7b|Deserted Path
e7|c0|84|Cassava Cake
e7|c0|ad|Retro Peach
e7|c2|6f|Sun Salutation
e7|c2|de|Sweet Alyssum
e7|c3|ab|Peach Beauty
e7|c3|ac|Marilyn Monroe
e7|c3|e7|Prom Corsage
e7|c6|30|Thai Temple
e7|c6|97|Electrum
e7|c9|a9|Manila
e7|c9|ca|Pink Spinel
e7|ca|c3|Tangy Taffy
e7|ce|b5|Malibu Dune
e7|ce|e3|Sweety Pie
e7|cf|8c|Alchemy
e7|cf|bd|Novelle Peach
e7|cf|c7|Silver Peony
e7|d1|a1|Italian Straw
e7|d2|a9|Morning Wheat
e7|d2|ad|Tuscan Bread
e7|d2|c8|Bizarre
e7|d3|91|Pineapple Slice
e7|d3|ad|Banana Crepe
e7|d3|b7|Dust Storm
e7|d5|ad|Caramelized Pears
e7|d5|c9|Woolly Beige
e7|d6|ed|First Lilac
e7|d7|ef|Pouty Purple
e7|d8|c7|Light China Doll
e7|d8|ea|Light Recuperate
e7|d9|b9|At The Beach
e7|d9|d4|Light Lip Gloss
e7|d9|db|Death Cap
e7|da|d7|Light Porcelain
e7|db|bf|Deserted Beach
e7|db|dd|Hint of Aroma
e7|db|e1|Hint of Bassinet
e7|dc|c1|Natural Radiance
e7|dc|cf|Light Shetland Lace
e7|dc|d9|Almost Mauve
e7|de|54|Goldvreneli 1882
e7|de|d7|Hint of Christobel
e7|df|e3|Lavender Twilight
e7|e0|ee|Hint of Purity
e7|e1|dd|Hint of Crushed Almond
e7|e1|de|Bridal Veil
e7|e1|e3|Misty Morn
e7|e2|d6|Crystal Haze
e7|e3|d6|Snowshoe Hare
e7|e3|db|Foggy Day
e7|e3|e7|Winter Orchid
e7|e4|de|Wild Sand
e7|e5|e8|White Lilac
e7|e6|e0|Willow Springs
e7|e6|ed|Cool Frost
e7|e7|e2|Arctic Fox
e7|e7|eb|Purple Crystal
e7|e9|d8|Hint of Medlar
e7|e9|e7|Blanc De Blanc
e7|ea|cb|Sylvan Green
e7|ea|e5|Feather White
e7|ec|e6|Bone Dust
e7|ee|e8|Rain Drop
e7|ee|ec|Kiss Me Kate
e7|ef|cf|Quiet Rain
e7|ef|e0|Mount Eden
e7|f0|c2|Green Glacier
e7|f0|f7|Clear Vision
e7|f2|de|Hint of Korila
e7|f2|e9|Dew
e7|fa|fa|Calm Waters
e7|fb|ec|Winter Mist
e7|fe|ff|Bubbles
e8|00|0d|KU Crimson
e8|39|29|Safflower Scarlet
e8|51|12|Retro Orange
e8|61|00|Spanish Orange
e8|68|00|Exuberance
e8|6e|ad|Amaranth
e8|70|3a|Celosia Orange
e8|81|a6|Aurora Pink
e8|8a|5b|Indiana Clay
e8|8a|76|Thundelarra
e8|8e|5a|Big Foot Feet
e8|99|be|Shocking
e8|a6|4e|Zucchini Flower
e8|a7|60|Apricot Sorbet
e8|a7|e2|Candy Floss
e8|aa|08|Filthy Brown
e8|af|45|Mì Chéng Honey
e8|af|49|Lion's Mane
e8|b4|47|Honey Glow
e8|b5|ce|Sweet Lilac
e8|b7|93|Gentle Doe
e8|b9|a5|Diva Rouge
e8|ba|bd|Wind Rose
e8|bc|50|Blockchain Gold
e8|bc|6d|Auric Armour Gold
e8|bc|95|Queen Conch Shell
e8|bd|45|Midas Touch
e8|c1|ab|Copper Blush
e8|c1|c2|Baby's Booties
e8|c3|be|Congo
e8|c3|c2|Pelican Feather
e8|c4|47|Liberator Gold
e8|c5|ae|Pinkham
e8|c5|c1|Friends
e8|c8|b8|Galveston Tan
e8|ca|c0|Au Naturel
e8|cc|d7|Queen Pink
e8|cd|9a|Chamois
e8|d0|a7|Chamomile
e8|d2|d6|Desert Mauve
e8|d2|e3|Sonora Rose
e8|d3|c7|Ash Plum
e8|d3|c9|Bare Beige
e8|d3|d1|Ash Cherry Blossom
e8|d4|a2|Hampton
e8|d7|20|Holy Grail
e8|d8|da|Hint of Frosted Sugar
e8|d9|ce|Malted Milk
e8|da|d1|Pigskin Puffball
e8|da|d6|Sea Anemone
e8|db|c5|Cream Wave
e8|db|dd|Hint of Bunny Soft
e8|dc|d5|Studio White
e8|dd|ae|Star Bright
e8|dd|c6|Heavy Cream
e8|dd|e2|Hint of Tinge Of Mauve
e8|de|c5|Adobe Sand
e8|de|ce|Stucco Tan
e8|de|db|Hint of Weathered Hide
e8|de|e3|Ethereal
e8|de|ea|Lilac Frost
e8|df|d8|Hint of Perk Up
e8|df|e4|Sakura Nezu
e8|df|ed|Hint of Oriental Blush
e8|e0|d5|Hint of Chintz
e8|e0|d8|Stone Harbour
e8|e1|d5|Dagger Moth
e8|e3|d9|Tofu
e8|e3|db|Mountain Grey
e8|e4|c9|Dirty White
e8|e4|d6|Guinea Pig White
e8|e5|ec|Iris Isle
e8|e6|d9|Prairie Winds
e8|e6|e8|Orchid Mist
e8|e7|d7|Hint of Clouds
e8|e8|d4|Green Iced Tea
e8|e8|d7|Vape Smoke
e8|e8|e8|Unicorn Silver
e8|e9|cc|Rare White Jade
e8|e9|cf|Light Lilylock
e8|e9|e4|Pegasus
e8|e9|e9|Snowbank
e8|ea|d5|Horned Lizard
e8|ea|e6|Pacific Pearl
e8|eb|e7|Windy Sky
e8|ec|c0|Olive Creed
e8|ec|db|Really Rain
e8|ec|ee|Icewind Dale
e8|ed|69|Honeysuckle
e8|ed|b0|Bottlebrush Blossom
e8|ee|e9|Gossamer Wings
e8|ef|db|Hint of Security
e8|ef|ec|White Bass
e8|ef|f8|First Snow
e8|f0|e2|Spearmint Stick
e8|f2|eb|Astronomer
e8|f3|e8|Aqua Spring
e8|f4|8c|Key Lime Water
e8|f4|d2|Light Green Veil
e8|f4|f7|Milky Way
e8|f5|fc|Kodama White
e8|f7|fd|Clear Skies
e8|ff|2a|Spoiled Egg
e9|36|a7|Pink Bite
e9|42|57|Clown Nose
e9|4f|58|Highlighter Red
e9|52|95|Tutuji Pink
e9|54|6b|Bara Red
e9|5c|20|Puffins Bill
e9|5c|4b|Opal Flame
e9|68|7e|Ambitious Rose
e9|69|2c|Deep Carrot Orange
e9|6a|97|Shadow Azalea Pink
e9|6e|00|Clementine
e9|74|51|Bloodletter
e9|75|51|Light Red Ochre
e9|78|6e|Pueblo Rose
e9|89|7e|Burnt Coral
e9|8c|3a|California
e9|96|7a|Kindleflame
e9|9e|56|Pumpkin Pie
e9|aa|91|Aloha Sunset
e9|ad|17|Sun Song
e9|ad|ca|Coral Cornsnake
e9|af|78|Yucatan
e9|b3|b4|Strawberry Yogurt
e9|b6|79|Paloma Tan
e9|b6|c1|Naked Light
e9|b7|a8|Porcelain Crab
e9|ba|81|Corvette
e9|bf|63|Crop Circle
e9|c2|a1|Toasted Coconut
e9|c3|cf|Parfait Pink
e9|c4|cc|Light Blush
e9|c6|8e|Norman Shaw Goldspar
e9|c9|cb|English Rose Bud
e9|ca|94|Golden West
e9|cb|2e|Soleil
e9|cb|4c|Snake Eyes
e9|cf|aa|Rum Custard
e9|cf|bb|English Scone
e9|cf|c8|Honeysweet
e9|d1|bf|Pastel Rose Tan
e9|d2|ac|Champagne
e9|d2|af|The Golden State
e9|d2|cc|Birthday Cake
e9|d2|ef|Lavender Princess
e9|d3|ba|Verona Beach
e9|d3|d5|Light Pink Pandora
e9|d4|a9|Canary Island
e9|d4|c3|Mother of Pearl
e9|d5|ad|Sandbank
e9|d6|6b|Arylide Yellow
e9|d6|6c|Hansa Yellow
e9|d6|b1|Duck Tail
e9|d7|ab|Beeswax
e9|d7|c0|Laguna Beach
e9|d8|c2|Floating Feather
e9|d9|a9|Sidecar
e9|d9|dc|Angelic Choir
e9|da|d2|Northern Beach
e9|db|be|Irish Cream
e9|db|c4|Golden Lotus
e9|db|d2|Crazy Horse Mountain
e9|db|de|Hint of Sprig Muslin
e9|db|df|Hint of Pelican Bill
e9|db|e0|Magic Moments
e9|dc|be|Double Pearl Lusta
e9|dc|d1|Linen White
e9|dd|c9|Scrolled Parchment
e9|df|cf|Vanilla Flower
e9|df|e5|Dainty Flower
e9|df|e8|Hint of Tender Touch
e9|e1|a7|Breath of Spring
e9|e1|d9|Spring Wood
e9|e1|df|Milk and Cookies
e9|e1|e8|Violet Vogue
e9|e2|d7|Crisp Muslin
e9|e2|db|Hint of Sago
e9|e3|d2|Alabaster Beauty
e9|e3|d3|Bud's Sails
e9|e3|d8|Moon Shell
e9|e3|da|Hint of Sandy Day
e9|e4|24|Birdie
e9|e4|d4|Ash White
e9|e4|ef|Modest Violet
e9|e5|d7|Beryllonite
e9|e5|d8|Stocking White
e9|e5|da|Whisper Grey
e9|e6|d4|Hint of Pistachio Tang
e9|e6|dc|Narvik
e9|e8|9b|Citrino
e9|e8|bb|Perfect Pear
e9|e9|d0|Magical Melon
e9|e9|d5|Hint of Ghostly Green
e9|e9|e1|Destroying Angels
e9|ea|c8|Green Essence
e9|ea|db|Really Light Green
e9|ea|e7|Arctic White
e9|ea|eb|Mourn Mountain Snow
e9|eb|de|Sterling Shadow
e9|ec|e4|Calm Breeze
e9|ec|f1|Solitude
e9|ed|bd|Spring Blossom
e9|ed|c0|Delicate Daisy
e9|ed|f1|Walls of Santorini
e9|ed|f6|Coconut White
e9|ee|eb|Snail Trail Silver
e9|f1|d0|Light Spring Shoot
e9|f1|ec|Silent Breath
e9|f3|dd|Hint of Greenette
e9|f3|e1|Herb Garden
e9|f6|e0|Hint of Fresh Lime
e9|f9|f5|Melting Glacier
e9|ff|db|Nyanza
ea|3c|53|Desire
ea|55|05|Jokaero Orange
ea|5a|79|Highlighter Pink
ea|66|76|Sunkist Coral
ea|67|59|Emberglow
ea|6a|0a|Epicurean Orange
ea|6b|6a|Porcelain Rose
ea|7e|5d|Roasted Sienna
ea|83|86|Apple Valley
ea|86|45|Flamenco
ea|90|73|Warm Welcome
ea|92|7a|Poodle Skirt Peach
ea|93|6e|La Terra
ea|95|75|Shell Coral
ea|9f|f6|VIC 20 Pink
ea|a0|07|Rowdy Orange
ea|a3|4b|Golden Koi
ea|aa|a2|Soft Salmon
ea|b5|65|Yellow Varnish
ea|b6|ad|Pensive Pink
ea|b7|6a|Harvest Gold
ea|b7|a8|Plushy Pink
ea|b8|52|Ronchi
ea|bd|5b|Tawny Daylily
ea|c7|cb|Oh So Pretty
ea|c8|53|Yellow Brick Road
ea|ca|cb|Petite Pink
ea|cc|4a|Festival
ea|ce|6a|Golden Sand
ea|ce|d4|Pink Pail
ea|d0|a9|Weathered Coral
ea|d1|51|New Gold
ea|d1|a6|Plaster Mix
ea|d1|da|Light In The Slip
ea|d2|a2|Pale Wood
ea|d3|a2|Tangent
ea|d3|ae|Summer Melon
ea|d3|e0|Light Favourite Lady
ea|d4|c4|Enjoy
ea|d4|e0|Light Pretty Pale
ea|d5|c7|Light Ellen
ea|d6|ce|Coral Cream
ea|d7|95|Tainted Gold
ea|d7|d5|Light Youth
ea|d8|bb|White Hot Chocolate
ea|d8|c1|Antique Parchment
ea|d9|4e|Meadowlark
ea|d9|cb|Shoreland
ea|da|c2|Pine Nut
ea|da|c6|Oatmeal Cookie
ea|dc|e2|Hint of Tip Toes
ea|dd|82|Day Glow
ea|dd|d7|Wistful Beige
ea|dd|e1|Mauve Wisp
ea|de|e4|Hint of Mauve Organdie
ea|df|ce|Dry Bone
ea|df|d0|Bobcat Whiskers
ea|df|d2|South Peak
ea|df|e8|Hint of Naked Pink
ea|e0|c8|Pearl
ea|e0|d4|Moroccan Moonlight
ea|e0|e8|Tiara Jewel
ea|e1|c8|Pearl Lusta
ea|e1|d6|Sharp-Rip Drill
ea|e2|d1|Brandied Pears
ea|e2|dc|Hint of Day Dreamer
ea|e2|dd|Hint of Subpoena
ea|e2|de|Hint of Raspberry Ice
ea|e2|df|Hint of Nut Milk
ea|e3|cd|Orange White
ea|e3|d2|Abilene Lace
ea|e3|d8|Indian Muslin
ea|e3|db|Fuzzy Unicorn
ea|e3|e0|Disappearing Memories
ea|e3|e9|Calm Tint
ea|e4|d6|Dry Sand
ea|e4|d8|Hint of Buff It
ea|e4|da|Hint of Male
ea|e4|dc|Pampas
ea|e5|83|Hippy
ea|e5|c5|Child of Heaven
ea|e5|d8|Hint of Grand Piano
ea|e6|cc|Light Flaxen Fair
ea|e6|d7|Little Lamb
ea|e6|d9|China White
ea|e7|da|Clear Sand
ea|e8|e4|Faded Grey
ea|e8|ec|Dandelion Floatie
ea|e9|e0|Polar Bear
ea|e9|e7|Glacial Ice
ea|ea|ae|Medium Goldenrod
ea|ea|cf|Palmito
ea|ea|db|Magical Stardust
ea|ea|ea|Vapor
ea|eb|af|Crisp
ea|ec|b9|Limited Lime
ea|ec|d3|Just Perfect
ea|ee|d7|Alligator Egg
ea|ee|d8|Blissful Serenity
ea|ee|da|Hint of Mountain Spring
ea|ee|de|Mental Note
ea|ee|ec|Moonlit Snow
ea|ef|ce|Cool Yellow
ea|ef|e5|Trellis
ea|f0|e0|Clarity
ea|f0|f0|Frosted Glass
ea|f2|f1|Warp Drive
ea|f3|d0|Light New Hope
ea|f3|e6|Glacier Ivy
ea|f4|fc|Moon White
ea|f7|c9|Snow Flurry
eb|2e|28|Krasnyi Red
eb|4c|42|Carmine Pink
eb|50|30|Burning Tomato
eb|54|06|Gold Red
eb|5c|34|Day Glow Orange
eb|60|81|Camellia Rose
eb|61|01|Shu Red
eb|61|23|Halloween Orange
eb|62|38|Teri-Gaki Persimmon
eb|7d|5d|Orange Daylily
eb|82|39|Snappy Happy
eb|89|31|Goblin Eyes
eb|8f|6f|Painted Clay
eb|95|52|Bronzed Flesh
eb|96|87|Blooming Dahlia
eb|9a|9d|Pink Floyd
eb|ad|a5|Joyful Poppy
eb|b3|b2|Pretty Pink
eb|b5|b3|Naked Rose
eb|b9|b3|Beauty Bush
eb|be|d3|Cherry Cordial
eb|c2|af|Zinnwaldite
eb|c7|9e|Pine Grain
eb|c8|81|Marzipan
eb|ca|70|Bee Pollen
eb|cc|b9|Scotchtone
eb|ce|d5|Ballet Slipper
eb|cf|89|Sundress
eb|cf|aa|Sheriff
eb|cf|c9|Cameo Peach
eb|d0|a4|Spice Is Nice
eb|d1|bb|Sun Kiss
eb|d1|cd|Cool Melon
eb|d2|d1|Raspberry Milk
eb|d4|ae|Givry
eb|d5|b7|Sugared Pears
eb|d8|4b|Longlure Frogfish
eb|d9|d0|Winter Peach
eb|da|b5|Cinnamon Milk
eb|da|c8|Sandpiper
eb|db|aa|Studio Cream
eb|db|c1|Clam Up
eb|db|ca|Chinese Hamster
eb|db|dd|Hint of Bunny Pink
eb|dc|b6|Jodhpurs
eb|dc|d7|Light Pink Marble
eb|de|31|Golden Fizz
eb|de|cc|Skeleton
eb|de|d7|Berry Frost
eb|de|db|Hint of Lavender Blush
eb|df|67|Celandine
eb|df|c0|Shell Haven
eb|df|cd|Light Bread Crumb
eb|df|ea|Angora Pink
eb|e0|c8|Light Gentle Touch
eb|e0|ca|Light Scallywag
eb|e0|cf|Light Figurine
eb|e1|a9|Steam Chestnut
eb|e1|c9|Basmati White
eb|e1|cb|Light Pollinate
eb|e1|ce|Bleach White
eb|e1|d4|Hint of Clay Pipe
eb|e2|cb|Better Than Beige
eb|e2|cf|Muscat Blanc
eb|e2|d2|Quarter Spanish White
eb|e2|de|Hint of Thought
eb|e2|e8|Dream Dust
eb|e3|c7|Star of Gold
eb|e3|d8|String of Pearls
eb|e3|de|Hint of Instant
eb|e4|be|Arctic Daisy
eb|e5|d0|Abbey White
eb|e5|d2|Always Almond
eb|e5|d5|Diffused Light
eb|e6|d7|Historic White
eb|e7|34|Lime Time
eb|e8|da|Fresh Linen
eb|e8|db|Enduring Ice
eb|e9|d8|Angelic Starlet
eb|eb|d7|Hint of Apple Cucumber
eb|eb|eb|Mercury
eb|ec|a7|Lemon Pepper
eb|ec|f0|Bright Grey
eb|ed|ee|Tropical Breeze
eb|ee|e8|Hurricane Mist
eb|ee|f3|Springtime Rain
eb|f0|d6|Plain and Simple
eb|f4|df|Morning Frost
eb|f5|de|Hint of Green Glint
eb|f5|f0|Shiroi White
eb|f6|f7|Indigo White
eb|f7|e4|Panache
eb|f8|ef|Soft Petals
ec|29|38|Imperial Red
ec|2c|25|Ken Masters Red
ec|2d|01|Tomato Red
ec|3b|83|Cerise Pink
ec|58|00|Poppy Flower
ec|63|1a|Ryza Dust
ec|6a|37|Mandarin Orange
ec|6d|51|Entan Red
ec|6d|71|Zahri Pink
ec|78|78|Siesta Rose
ec|82|54|Araigaki Orange
ec|93|5e|Muskmelon
ec|95|6c|Sawtooth Aak
ec|95|80|Presidio Peach
ec|9a|be|Begonia Pink
ec|9b|9d|River Rouge
ec|9d|c3|Be My Valentine
ec|9f|76|Mexican Standoff
ec|a6|ca|Elastic Pink
ec|aa|79|Apricot Nectar
ec|ae|58|Brass Trumpet
ec|b1|76|Middle Yellow Red
ec|b2|b3|Deeply Embarrassed
ec|ba|5d|Chandra Cream
ec|bc|b2|Peach Souffle
ec|bd|2c|Bright Sun
ec|bd|b0|Virgin Peach
ec|be|63|Bright Idea
ec|bf|9f|Madrid Beige
ec|bf|c9|Rose Melody
ec|c0|43|Sharp Yellow
ec|c0|83|Eldar Flesh
ec|c4|81|Gold Buff
ec|c5|df|Sweet Murmur
ec|c9|ca|Pink Cardoon
ec|ce|e5|Emilie's Dream
ec|d0|86|Punch of Yellow
ec|d0|a1|Suffragette Yellow
ec|d1|a5|Key Keeper
ec|d4|d2|Shangri La
ec|d5|40|Sandstorm
ec|d6|d6|Mauve Morn
ec|d8|b1|Hollywood Golden Age
ec|d9|b9|Porcelain Pink
ec|da|9e|Demeter
ec|db|d2|Pine Hutch
ec|db|d6|Light Pianissimo
ec|db|e0|Hint of Baby Tone
ec|dd|be|Rutabaga
ec|dd|d6|Light Blossom Time
ec|dd|e5|Hint of Blissful
ec|de|e5|Hint of Frozen Frappe
ec|df|ad|Very Cashmere
ec|df|ca|Light Raw Cotton
ec|df|d5|Hint of Mornington
ec|df|d6|Sablewood
ec|df|d8|Touchable
ec|e0|c4|Sailcloth
ec|e0|c6|Origami
ec|e0|cd|Asian Fusion
ec|e0|d6|Dallas Dust
ec|e1|d3|Platinum Ogon Koi
ec|e2|d4|Onion Powder
ec|e3|cc|Morocco Sand
ec|e3|e1|Cloudy Grey
ec|e4|ce|Summer Sandcastle
ec|e4|d2|Pogo Sands
ec|e4|dc|Stone Quarry
ec|e5|da|Soapstone
ec|e5|e1|Raindrops
ec|e6|78|Fresh Lemonade
ec|e6|7e|Texas
ec|e6|c8|Button Mushroom
ec|e6|d1|Xiàng Yá Bái Ivory
ec|e6|d5|Antique White
ec|e6|d7|Hint of Hog Bristle
ec|e6|dc|Hint of Parchment Paper
ec|e7|f2|Tranquil Eve
ec|e9|9b|Yellow Pear
ec|e9|dd|Swallow-Tailed Moth
ec|e9|e9|Poplar Kitten
ec|ea|be|White Asparagus
ec|ea|d0|Wrack White
ec|eb|bd|Pale Spring Bud
ec|eb|ce|Light Spring Fever
ec|eb|e5|Gin Tonic
ec|eb|ea|Lace Veil
ec|ec|da|Whispering Rain
ec|ec|dc|Amazon Mist
ec|ec|df|Ageless
ec|f0|da|Memoir
ec|f0|e5|Alaskan Mist
ec|f0|eb|Shooting Star
ec|f1|e2|Aloe Essence
ec|f1|ec|Spring Fog
ec|f3|d8|Hint of Budding Bloom
ec|f3|e1|White Mecca
ec|f3|f9|Insignia White
ec|f4|d2|Light Freshman
ec|f7|f7|Aijiro White
ec|fc|bd|Fall Green
ec|fc|ec|Spring White
ed|0a|3f|Red Ribbon
ed|0d|d9|Fuchsia
ed|1c|24|Red Pigment
ed|21|4d|Che Guevara Red
ed|29|39|Poppy Power
ed|2e|38|Allura Red
ed|4b|00|Kimchi
ed|77|77|Red Chalk
ed|7a|9e|Pink Carnation
ed|87|2d|Cadmium Orange
ed|91|21|Carrot Orange
ed|99|87|Whimsy
ed|9b|44|Cornucopia
ed|9c|a8|Peony
ed|a7|40|Acorn Squash
ed|aa|80|Orange Liqueur
ed|aa|86|Coral Dust
ed|af|9c|Salmon Run
ed|b0|6d|Evening Sunset
ed|b3|84|Rusty Sand
ed|b4|8f|Peach Nirvana
ed|b5|08|Rucksack Tan
ed|b8|56|Yellow Coneflower
ed|b8|c7|Chantilly
ed|b9|bd|Ballet Shoes
ed|bd|68|Mustard Sauce
ed|c2|83|Golden Hominy
ed|c5|58|Blonde Girl
ed|c7|b6|Spiced Orange
ed|c8|ff|Light Lilac
ed|c9|af|Desert Sand
ed|c9|d8|Candytuft
ed|cc|b3|Cashew Nut
ed|cd|c2|Pale Dogwood
ed|d0|ce|Crystal Pink
ed|d0|dd|Cradle Pink
ed|d1|a8|Souffle
ed|d1|d3|Short and Sweet
ed|d2|a3|Crossroads
ed|d2|a4|Dairy Cream
ed|d4|81|Beach House
ed|d5|9e|Sunlight
ed|d5|a6|Astra
ed|d5|c7|Blush Beige
ed|d8|c3|Canadian Pancake
ed|d8|d2|Fiesta
ed|d9|aa|Golden Fleece
ed|db|d7|Light Hugo
ed|db|da|Light Slightly Rose
ed|db|e8|Desert Dawn
ed|db|e9|Elfin Magic
ed|dc|c8|Almond
ed|dd|59|Aurora
ed|dd|e4|Hint of Elusive Mauve
ed|df|c9|Maybeck Muslin
ed|e0|e3|Barely Rose
ed|e1|a8|Turning Oakleaf
ed|e1|d1|White Pearl
ed|e2|ac|Chapel Wall
ed|e2|d4|Hint of China Doll
ed|e2|e0|Silica Sand
ed|e2|ee|Hint of Recuperate
ed|e3|df|Heart Stone
ed|e3|e0|Hint of Watermelon Milk
ed|e3|e7|Wink Pink
ed|e4|cc|Hidden Diary
ed|e4|cf|Water Chestnut
ed|e5|bc|Slices of Happy
ed|e5|e8|Lavender Pearl
ed|e6|b3|September Morn
ed|e6|cb|Banana Milkshake
ed|e6|d9|Hint of Light Rice
ed|e6|db|Whisper White
ed|e7|c8|Light Half And
ed|e7|d2|Instant Relief
ed|e7|d7|Hint of Ecru
ed|e7|e0|Desert Storm
ed|e7|e6|Flower Girl Dress
ed|e8|d7|Light Frost
ed|e8|dd|Yang Mist
ed|e9|ad|Wax Yellow
ed|e9|d4|Italian Lace
ed|e9|dd|Abstract White
ed|e9|df|Taj Mahal
ed|ea|dc|Wedded Bliss
ed|eb|9a|Pitapat
ed|eb|b4|Mystic Melon
ed|eb|e7|Silver Feather
ed|eb|ea|Dazzle Me
ed|ec|d4|Budding Fern
ed|ec|d7|Dusky Moon
ed|ec|e6|Commercial White
ed|ec|ec|Coronation
ed|ed|b7|Tender Yellow
ed|ed|c7|Honey Do
ed|ed|ed|White Edgar
ed|ee|c5|Oh Dahling
ed|ee|da|Hint of Lilylock
ed|ee|ef|White Whale
ed|ef|cb|Passionate Pause
ed|f0|de|Nursery Green
ed|f1|fe|Brilliant White
ed|f2|c3|Feijoa Flower
ed|f2|e0|Snowy Evergreen
ed|f2|f8|Aircraft White
ed|f4|eb|Apple Flower
ed|f5|dd|Hint of Green Veil
ed|fa|d9|Pastoral
ee|00|00|MVS Red
ee|00|33|Brake Light Trails
ee|00|ee|Piquant Pink
ee|11|33|Barberry
ee|17|2b|MicroProse Red
ee|20|4d|Red Crayon
ee|22|00|Hestia Red
ee|22|11|Prehistoric Meteor
ee|22|55|Strawberry Pop
ee|22|66|Mellow Melon
ee|33|00|Gran Torino Red
ee|33|11|Arcade Fire
ee|33|55|Radish Lips
ee|43|28|Heavy Orange
ee|44|00|Glowing Meteor
ee|44|55|Vineyard Autumn
ee|55|00|Cigarette Glow
ee|55|11|Orangealicious
ee|55|88|Power Peony
ee|58|51|Amour
ee|5c|6c|Calypso Coral
ee|62|37|Oranzhewyi Orange
ee|67|30|Basketball
ee|6b|8b|Cupid's Arrow
ee|6d|8a|Grapefruit Juice
ee|77|00|Mee-hua Sunset
ee|79|48|Ouni Red
ee|82|7c|Jinza Safflower
ee|82|ed|Lavender Magenta
ee|82|ee|Mamie Pink
ee|86|7d|Salmon Carpaccio
ee|88|00|Clear Orange
ee|88|11|Mimolette Orange
ee|88|33|Creole Sauce
ee|88|44|Zodiac Constellation
ee|88|cc|Blushed Bombshell
ee|91|8d|Sweet Pink
ee|99|77|Pochard Duck Head
ee|a0|a6|Pink Icing
ee|a3|72|Prairie Sun
ee|aa|cc|Waddles Pink
ee|aa|ff|Pink Sugar
ee|b1|5d|Cheater
ee|b1|92|Apricot Preserves
ee|b3|9e|Wax Flower
ee|b5|af|Mesa Rose
ee|bb|00|Philippine Golden Yellow
ee|bb|11|Goldfinger
ee|bb|44|Golden Glam
ee|bb|77|Yellow-Rumped Warbler
ee|bb|99|Caramel Powder
ee|bb|cb|Dark Nadeshiko
ee|bb|ee|Lovecloud
ee|bc|b8|Pink Sachet
ee|be|1b|Radiant Sunrise
ee|c0|51|Cream Can
ee|c1|72|Vietnamese Lantern
ee|c3|62|Tomorokoshi Yellow
ee|c4|be|Chintz Rose
ee|c5|ce|Soft Satin
ee|c6|57|Corn Bread
ee|c7|a2|Negroni
ee|c7|d6|Lily Legs
ee|c8|7c|Almond Cookie
ee|c8|d3|Pale Primrose
ee|c9|87|Ochre Revival
ee|c9|a6|Peaches 'n' Cream
ee|c9|aa|Caramel Ice
ee|cb|88|Bright Wood Grain
ee|cc|00|Wild Honey
ee|cc|24|Broom
ee|cc|55|Fish Finger
ee|cc|66|Fresh Straw
ee|cc|88|Spaghetti Monster
ee|cd|00|Ancient Yellow
ee|cf|fe|Rose Dragée
ee|d0|53|Venus
ee|d0|9d|Madera
ee|d0|ae|Autumn Blonde
ee|d1|cd|Rose Romantic
ee|d2|02|Safety Yellow
ee|d2|d7|Light Light Blush
ee|d3|cb|Fairy Pink
ee|d4|c8|Angel's Face
ee|d4|d9|Primrose Pink
ee|d5|b6|Sugar Shack
ee|d6|83|Gatsby Glitter
ee|d8|c2|Oak Shaving
ee|d9|b6|Savon de Provence
ee|d9|c4|Hen of the Woods
ee|d9|d1|Touch of Tan
ee|da|cb|Canyon Peach
ee|da|d1|Blushing Bride
ee|da|dd|Sweet Bianca
ee|da|e6|Mountain Heather
ee|dc|5b|Dull Yellow
ee|dc|82|Flax
ee|dc|df|Cupid's Revenge
ee|dd|33|Juicy Jackfruit
ee|dd|82|Light Goldenrod
ee|dd|aa|Creamy Ivory
ee|dd|bb|Salt Steppe
ee|dd|cc|Bare Bone
ee|dd|ee|Divine Dove
ee|dd|ff|Lavender Savor
ee|de|c7|Golden Retriever
ee|de|d8|Apricot Foam
ee|de|dd|Echoes of Love
ee|df|dd|Mannequin
ee|df|de|Soft Peach
ee|e0|b1|Cookies And Cream
ee|e1|eb|Heaven Sent
ee|e2|c9|Wedding Cake
ee|e2|d5|Siberian Fur
ee|e2|dd|Bridal Blush
ee|e2|e0|Hint of Porcelain
ee|e3|dd|Macadamia Nut
ee|e3|de|Hint of Lip Gloss
ee|e5|d4|Piano Keys
ee|e5|da|Hint of Shetland Lace
ee|e6|00|Titanium Yellow
ee|e6|db|Madonna Lily
ee|e7|8e|Yellow Iris
ee|e7|c8|Scotch Mist
ee|e7|dc|Pearls and Lace
ee|e7|dd|White Linen
ee|e8|aa|Pale Goldenrod
ee|e8|d9|Edelweiss
ee|e9|2d|Pika Yellow
ee|e9|d3|Hint of Handmade Linen
ee|e9|d8|Pearly Swirly
ee|e9|d9|Calcium Rock
ee|e9|dc|Cream Puff
ee|e9|f9|Bright Dusk
ee|ea|97|Elfin Yellow
ee|ea|dd|Horseradish Cream
ee|eb|e3|Broken White
ee|eb|e4|Carrara
ee|ed|db|Glittery Glow
ee|ed|df|Onion Skin
ee|ed|e4|Gypsum
ee|ed|ea|Snow Storm
ee|ee|00|Saint Seiya Gold
ee|ee|11|Robot Grendizer Gold
ee|ee|22|Herbery Honey
ee|ee|33|Delightful Dandelion
ee|ee|88|Pineapple Perfume
ee|ee|99|Golden Fragrance
ee|ee|aa|Pollen
ee|ee|bb|Schabziger Yellow
ee|ee|cc|Silkworm
ee|ee|dd|Coconut Aroma
ee|ee|ee|Super Silver
ee|ee|ff|Foundation White
ee|ef|df|Sugar Cane
ee|f0|ce|Light Olive Creed
ee|f0|d6|Morning Glow
ee|f0|e7|Fogtown
ee|f0|f3|Magnetic Grey
ee|f1|ea|Shadow White
ee|f2|93|Jonquil
ee|f3|d0|Light Green Glacier
ee|f3|e5|Saltpan
ee|f4|db|Hint of Spring Shoot
ee|f5|db|Hint of New Hope
ee|f9|c1|Kiwi Kiss
ee|ff|99|Metal Spark
ee|ff|a9|Hitchcock Milk
ee|ff|aa|Hawthorn Blossom
ee|ff|bb|Porcelain Earth
ee|ff|cc|Snow Drop
ee|ff|dd|Baby Tooth
ee|ff|ee|Snow White
ee|ff|ff|Aphrodite's Pearls
ef|1d|e7|Pink Pride
ef|30|38|Deep Carmine Pink
ef|39|39|Vivaldi Red
ef|40|26|Tomato
ef|8e|38|Sun
ef|8e|9f|Wonder Lust
ef|92|4a|Caramelized Orange
ef|95|48|Physalis
ef|95|ae|Illusion
ef|98|aa|Piggy
ef|9a|49|Question Mark Block
ef|9c|b5|Carnal Pink
ef|a6|aa|Quartz Pink
ef|a7|bf|Tickled Pink
ef|a8|4c|Egyptian Gold
ef|ab|93|Shishi Pink
ef|ac|73|Catalina Tile
ef|b4|35|Baklava
ef|b6|d8|Soft Cashmere
ef|bb|cc|Cameo Pink
ef|bc|de|Bordeaux Hint
ef|c0|fe|Light Lavender
ef|c1|b5|New Clay
ef|c4|7f|Polenta
ef|c4|bb|Peach Ash
ef|c5|b5|Brilliant Beige
ef|c6|00|Brilliant Impression
ef|c7|00|Beach Ball
ef|c7|be|Altered Pink
ef|c8|57|Dancing Daisy
ef|c8|7d|Mille-Feuille
ef|c9|aa|Peach A La Mode
ef|c9|b8|Pink Pieris
ef|cc|00|Munsell Yellow
ef|cc|44|Crushed Pineapple
ef|cc|7c|Mountain Maize
ef|cd|b4|Peach Darling
ef|cd|b8|Desert Field
ef|cd|cb|Kislev Flesh
ef|ce|a0|Crumble Topping
ef|cf|98|Sparkling Champagne
ef|cf|9b|Bright Clove
ef|cf|ba|Peach Puree
ef|cf|bc|Desert Mesa
ef|d0|d2|Nursery
ef|d2|d0|Marshmallow Magic
ef|d5|cf|Va Va Bloom
ef|d6|da|Pale Rose
ef|d7|ab|Cereal Flake
ef|d7|b3|Chai Tea Latte
ef|d9|a8|Bleached Bone
ef|db|a7|Tortilla
ef|db|cd|White Truffle
ef|dc|75|Yellow Cream
ef|dc|c3|Navajo
ef|dc|ca|Castle In The Clouds
ef|dc|d4|American Yorkshire
ef|dd|c3|Jakarta
ef|dd|df|Silk Sheets
ef|de|74|Lightning Bug
ef|de|75|Canary Feather
ef|de|cc|Toasted Oatmeal
ef|de|df|Hint of Pink Pandora
ef|df|cf|Dry Dune
ef|df|e7|Hint of Pretty Pale
ef|e0|c6|Thatched Roof
ef|e0|c9|Winter Lite
ef|e0|cd|Buttercream
ef|e0|d4|Toasted Marshmallow
ef|e0|d7|Ginger Cream
ef|e1|a7|French Vanilla
ef|e1|cd|Victorian Lace
ef|e1|d5|Siamese Kitten
ef|e1|e4|Pink Booties
ef|e2|c5|Blonde Curl
ef|e2|f2|Sheer Lavender
ef|e3|d2|Glazed Pears
ef|e3|d9|Almond Icing
ef|e4|cc|Someday
ef|e4|da|Sweet Gardenia
ef|e5|d4|Stone Pillar
ef|e5|d9|Pearl Dust
ef|e6|e1|Forever Faithful
ef|e6|e6|Whisper
ef|e7|df|Chickpea
ef|e8|bc|Chardonnay
ef|e8|dc|Sugar Soap
ef|e9|d9|Milk Paint
ef|e9|dd|Mawmaw's Pearls
ef|ea|de|Ivory Mist
ef|ea|e7|Lauren's Lace
ef|eb|db|Frank Lloyd White
ef|eb|de|Sanding Sugar
ef|eb|e3|Linen Ruffle
ef|eb|e7|White Alyssum
ef|ec|de|Rice Cake
ef|ec|e1|Acoustic White
ef|ec|ef|Violet Clues
ef|ed|d8|Hint of Flaxen Fair
ef|ed|ee|Essence of Violet
ef|ee|ef|Crystal Bell
ef|ef|e8|Star White
ef|f0|bf|Searchlight
ef|f0|c0|Missed
ef|f0|d3|Giggle
ef|f0|f0|Snowflake
ef|f1|9d|Leaf Bud
ef|f2|db|Fragile Fern
ef|f3|f0|Wind Chill
ef|f5|d1|Rice Flower
ef|f8|aa|Australian Mint
f0|00|00|Helvetia Red
f0|4e|45|Angry Flamingo
f0|53|1c|Fiery Glow
f0|5c|85|Watermelon Water
f0|62|2f|Exuberant Orange
f0|6f|ff|Ultra Pink
f0|72|27|Orange Zest
f0|74|27|Vivid Tangelo
f0|75|e6|Lián Hóng Lotus Pink
f0|7f|5e|Akakō Red
f0|80|80|Light Coral
f0|81|01|Rè Dài Chéng Orange
f0|83|00|Mikan Orange
f0|83|3a|Goku Orange
f0|84|97|Xoxo
f0|8f|90|Ikkonzome Pink
f0|90|56|Chinese Lantern
f0|90|8d|Pale Plum Blossom
f0|91|a9|Astilbe
f0|94|4d|Faded Orange
f0|a0|b6|Emperor's Children
f0|a0|d1|Violet Kiss
f0|a1|bf|Prism Pink
f0|b0|73|Orange Salmonberry
f0|b2|53|Casablanca
f0|b3|3c|Dairy Made
f0|b5|99|Crab Bisque
f0|b9|a9|Sweet Sheba
f0|b9|be|Purple Thorn
f0|bd|9e|Tan Temptation
f0|be|3a|Golden Mary
f0|c3|a7|Siesta
f0|c4|20|Moon Yellow
f0|c6|41|Buzz
f0|cf|a0|Cipollino
f0|d0|b0|Baby Breath
f0|d1|c8|Chic Peach
f0|d2|cf|Kobold Skin
f0|d5|55|Portica
f0|d5|a8|Straw Hat
f0|d5|ea|Infatuation
f0|d6|ca|Shy Cupid
f0|d6|dd|Pineberry
f0|d7|d7|Light Petite Pink
f0|d8|cc|Peach Dust
f0|dc|82|Buff
f0|dc|a0|Sun Deck
f0|dc|d7|Sweet Truffle
f0|dc|e3|Hint of In The Slip
f0|dd|b8|Limitless
f0|de|bd|Alabaster Gleam
f0|de|d3|Spice Cookie
f0|de|e0|Ballerina Silk
f0|de|e7|Hint of Favourite Lady
f0|df|bb|Dutch White
f0|df|cc|Pearled Ivory
f0|e0|d4|Hint of Ellen
f0|e0|dc|White Russian
f0|e1|30|Dandelion Tincture
f0|e1|c5|Champagne Bliss
f0|e1|cf|Berkshire Lace
f0|e1|df|Hint of Youth
f0|e2|bc|Clover Honey
f0|e2|c5|Creamy Gelato
f0|e2|d3|Agrodolce
f0|e3|c7|White Chocolate
f0|e4|83|Halakā Pīlā
f0|e4|b2|Butter Cookie
f0|e4|c6|Light Jodhpurs
f0|e5|c7|Paper Daisy
f0|e6|81|Light Khaki
f0|e6|8c|Cornflake
f0|e7|9d|Lemonade
f0|e7|a9|Pineapple Delight
f0|e7|d3|Lily White
f0|e7|d8|Parchment Paper
f0|e8|7d|Limelight
f0|e8|91|Lemon Flesh
f0|e8|d5|Hint of Gentle Touch
f0|e8|d7|Hint of Scallywag
f0|e8|d9|Angel Food
f0|e8|da|Hint of Figurine
f0|e8|dd|Percale
f0|e8|e0|Almond Roca
f0|e9|d1|Fuzzy Sheep
f0|e9|d6|Creamy White
f0|ea|d2|Golden Fog
f0|ea|d6|Eggshell
f0|ea|d7|Hint of Pollinate
f0|ea|da|Ivory Steam
f0|ea|e7|Sweet Cream
f0|ed|d1|Bright Laughter
f0|ed|d2|Whipped Citron
f0|ed|d6|Tambourine
f0|ed|db|Cake Batter
f0|ed|e5|Coconut Milk
f0|ee|e4|Marshmallow
f0|ee|e9|Cloud Dancer
f0|ee|eb|Magical Moonlight
f0|ef|e2|Cannoli Cream
f0|ef|eb|White Picket Fence
f0|f0|0f|Triforce Yellow
f0|f0|d9|Hint of Spring Fever
f0|f0|e0|Gorā White
f0|f1|ce|Menoth White Highlight
f0|f1|da|Tears of Joy
f0|f1|e1|Belyi White
f0|f2|0c|Huáng Sè Yellow
f0|f2|d2|Screaming Skull
f0|f5|90|Tidal
f0|f5|bb|Chiffon
f0|f6|dd|Hint of Freshman
f0|f7|c4|Fresh Grown
f0|f8|ff|Alice Blue
f0|fd|ed|Lime Slice
f0|ff|f0|Honeydew
f0|ff|f1|Azure Mist
f0|ff|ff|Vapour
f1|0c|45|Pinkish Red
f1|8a|ad|Sachet Pink
f1|91|72|Moegi Green
f1|91|9a|Wewak
f1|9b|7d|Cumquat Cream
f1|9c|bb|Amaranth Pink
f1|a1|41|Yáng Chéng Orange
f1|a1|77|Balinese Sunset
f1|a4|b7|Friend Flesh
f1|a7|fe|Rich Brilliant Lavender
f1|ac|8d|Salmon Slice
f1|b3|b6|Jaguar Rose
f1|b4|2f|Xanthous
f1|b5|cc|Bunny Cake
f1|bd|89|Apricot Cream
f1|bf|70|Buff Yellow
f1|bf|e2|Lavender Soap
f1|c3|c2|Channel
f1|c5|c2|Snowpink
f1|c6|ca|Rose Aspect
f1|c7|66|Butterblond
f1|c7|8e|Skullcrusher Brass
f1|c7|a1|Radome Tan
f1|c9|83|Bad Hair Day
f1|c9|cd|Feather Boa
f1|cc|2b|Golden Dream
f1|ce|b3|Alesan
f1|d2|c9|Texas Rose
f1|d3|ca|Cool Cantaloupe
f1|d3|d9|Cradle Pillow
f1|d4|c4|Melon Pink
f1|d5|ae|Fine Sand
f1|d6|bc|Pulled Taffy
f1|d7|9e|Splash
f1|d7|ce|Tan Whirl
f1|d7|d3|Light Flesh
f1|d9|a5|Upbeat
f1|da|7a|Sandy
f1|dc|a1|Hazy Moon
f1|dc|b7|Honey N Cream
f1|dd|a2|Honey Nectar
f1|dd|be|Dusty Ivory
f1|dd|cf|Champagne Pink
f1|dd|d8|Slightly Peach
f1|df|e9|Mellow Flower
f1|e0|db|Potpourri
f1|e1|b0|Bone White
f1|e2|c9|Light Porcelain Pink
f1|e2|de|Chantilly Lace
f1|e3|46|Golden Snitch
f1|e4|c8|Jefferson Cream
f1|e4|cb|Champagne Burst
f1|e4|d7|Uptown Taupe
f1|e4|dc|Winter Wedding
f1|e4|e1|Hint of Hugo
f1|e5|d7|Finest Silk
f1|e5|e0|Hint of Pink Marble
f1|e6|cc|Wax Poetic
f1|e6|d6|Elegant Ivory
f1|e6|de|Sea Salt
f1|e6|e0|Siesta Sands
f1|e7|40|Highlighter Yellow
f1|e7|82|Machine Oil
f1|e7|88|Sahara Sand
f1|e7|8c|Bright Khaki
f1|e7|d2|Vintage Lace
f1|e7|d5|Rice Bowl
f1|e7|db|French White
f1|e7|dc|Fair Maiden
f1|e8|ce|Light Shell Haven
f1|e8|d2|Imperial Ivory
f1|e8|d6|Hint of Raw Cotton
f1|e8|d8|String Ball
f1|e8|df|Gardenia
f1|e9|cf|Crescent Moon
f1|e9|d7|Antique Marble
f1|e9|dd|Vanilla Tan
f1|ea|d7|Half Pearl Lusta
f1|eb|c8|Natural Light
f1|eb|cd|Light Arctic Daisy
f1|eb|d9|Orchid White
f1|eb|da|Buttery White
f1|eb|ea|Charolais Cattle
f1|ec|ca|Ethereal Green
f1|ec|e2|Vanilla Milkshake
f1|ed|d4|Rum Swizzle
f1|ed|e0|Candlelit Beige
f1|ed|e5|Cow's Milk
f1|ee|e2|Blanc Cassé
f1|ee|e4|Atrium White
f1|ee|e5|The White in my Eye
f1|ee|eb|Snowy Mount
f1|f0|bf|Apple Slice
f1|f0|d6|Capri Cream
f1|f0|ef|Precious Pearls
f1|f1|c6|Spring Sun
f1|f1|e1|White Geranium
f1|f1|e6|Clear Yellow
f1|f2|d3|Mǔ Lì Bái Oyster
f1|f2|ee|Delicate White
f1|f3|3f|Off Yellow
f1|f3|da|Hint of Olive Creed
f1|f3|f2|Bái Sè White
f1|f3|f9|Boysenberry Shadow
f1|f4|d1|Light Feijoa Flower
f1|f5|db|Hint of Green Glacier
f1|f8|ec|Garden Dawn
f1|f8|fa|Distant Horizon
f1|f9|ec|Refined Mint
f1|fa|ea|White Sulfur
f1|fb|f1|Peaceful Rain
f1|fd|e9|Crème de Menthe
f1|ff|62|Lemon Pie
f1|ff|a8|Lemon Sherbet
f2|00|3c|Fresh Cut
f2|01|3f|Cherry Tomato
f2|44|33|Vermilion Bird
f2|5f|66|Dubarry
f2|66|6c|Usubeni Red
f2|85|00|Tangerine Skin
f2|8e|1c|Beer
f2|9c|b7|Harmonious Rose
f2|9e|8e|Blush
f2|9e|ab|Sweet 60
f2|a0|a1|Plum Blossom
f2|a3|7d|Coral Silk
f2|a3|bd|Pink Chalk
f2|a5|99|Wisley Pink
f2|a8|b8|Rozowyi Pink
f2|ab|15|Squash
f2|ab|46|Artisans Gold
f2|ad|62|Goldfish
f2|ae|b1|Brain Pink
f2|ae|b8|Exclusively Yours
f2|b4|00|American Yellow
f2|b8|ca|Berries n Cream
f2|b9|5f|Crunch
f2|ba|49|Maximum Yellow Red
f2|bb|b1|Ballerina Tears
f2|bd|85|Melon Balls
f2|c1|08|Tanned Leather
f2|c1|c0|Silver Strawberry
f2|c1|cb|Amaya
f2|c1|d1|Fairy Tale
f2|c4|a7|Flip-Flop
f2|c5|b2|Peach Temptation
f2|c6|a7|Citrus Sachet
f2|c8|80|Pale Sunshine
f2|ca|3b|Lemonade Stand
f2|cc|64|Bee Hall
f2|cd|bb|Watusi
f2|cf|dc|Ballerina
f2|cf|e0|Minimal Rose
f2|d0|82|Hollywood Starlet
f2|d0|c0|Indian Clay
f2|d1|78|Summertime
f2|d1|a0|Scalloped Oak
f2|d1|c4|Pale Coral
f2|d3|bc|Nude
f2|d4|df|Light Lily Legs
f2|d5|d4|French Bustle
f2|d6|ae|Corn Husk
f2|d7|e6|Samantha's Room
f2|d8|cd|Hint of Pink
f2|d9|30|Margarine
f2|db|d6|Rose Vapor
f2|db|d7|Pale Flesh
f2|db|db|Lover's Knot
f2|dd|d8|Cozy Cottage
f2|dd|e1|Hint of Light Blush
f2|de|a4|North Star
f2|de|bc|Cameo
f2|e0|c5|Cream Washed
f2|e0|d4|Pink Scallop
f2|e1|d2|Young Peach
f2|e1|dd|Bare Pink
f2|e2|a4|Sugar Cookie
f2|e2|e0|Petal Pink
f2|e3|b5|Light Worker
f2|e3|dc|Peach Tone
f2|e4|dd|Aubergine Flesh
f2|e4|e2|Hint of Slightly Rose
f2|e5|b4|Bad Moon Yellow
f2|e5|bf|Half Colonial White
f2|e5|e0|Hint of Pianissimo
f2|e6|dd|Fantasy
f2|e6|e1|Hint of Blossom Time
f2|e7|e7|Mont Blanc Peak
f2|e8|d7|Hint of Bread Crumb
f2|e8|da|Pristine
f2|e8|db|Euro Linen
f2|e9|bb|Sandy Shore
f2|e9|d3|White Fence
f2|e9|d5|Pearled Couscous
f2|e9|dc|Lotus Petal
f2|e9|de|Tangelo Cream
f2|ea|bf|Limesicle
f2|ea|cf|Candle Wax
f2|eb|d3|Candlewick
f2|eb|d6|Mesa Beige
f2|eb|dd|Painter's White
f2|eb|e1|Pale Ecru
f2|eb|e6|Fresh Dough
f2|ec|d9|Labrador
f2|ed|d7|Perfect Solution
f2|ed|dd|Quarter Pearl Lusta
f2|ed|e7|Valhallan Blizzard
f2|ed|ec|Vintage Porcelain
f2|ee|af|Fanlight
f2|ee|de|Queen Anne's Lace
f2|ef|cd|Blonde Beauty
f2|ef|dc|Glisten Green
f2|ef|e1|Coconut Butter
f2|f0|e6|Marble White
f2|f0|e7|Whipped Cream
f2|f0|e8|Cotton Field
f2|f1|d9|Hipster
f2|f1|dc|Hazy Grove
f2|f1|e6|Abaidh White
f2|f1|ed|Leukocyte White
f2|f2|7a|Sunny
f2|f2|b0|Patrinia Scabiosaefolia
f2|f2|e2|Storksbill White
f2|f2|ed|Cloud White
f2|f3|ce|Light Searchlight
f2|f3|cf|Light Missed
f2|f3|f4|Anti-Flash White
f2|f7|fd|Cotton Ball
f2|fa|ed|Winter Oasis
f3|47|23|Chinese Goldfish
f3|53|36|Benihi Red
f3|5b|53|Hot Coral
f3|61|96|Medium Pink
f3|69|44|Firecracker
f3|70|42|Chinese Orange
f3|77|4d|Coral Rose
f3|7a|48|Mandarin
f3|85|54|Autumn Sunset
f3|86|53|Crusta
f3|87|9c|Posy Petal
f3|92|a0|Cherry Foam
f3|94|9b|Primrose Garden
f3|95|39|Highlighter Orange
f3|98|00|Kin Gold
f3|99|98|Peach Burst
f3|a3|47|O'Brien Orange
f3|ac|b9|Baby Fish Mouth
f3|ad|63|Blazing Autumn
f3|ba|c9|Pink Grapefruit
f3|bb|ca|Orchid Pink
f3|bc|6b|Brasso
f3|c1|2c|Freesia
f3|c1|3a|Phellodendron Amurense
f3|c3|d8|Sweetheart
f3|c7|75|Orange Chocolate
f3|c8|c2|Sonia Rose
f3|ca|40|Softsun
f3|ca|cb|Blushing Senorita
f3|cf|64|Pale Buttercup
f3|d1|b3|Mission Courtyard
f3|d2|b2|Home Body
f3|d2|cf|Lady Pink
f3|d3|a1|Antique Wicker Basket
f3|d3|bf|Maiden's Blush
f3|d3|d9|Light Soft Satin
f3|d4|bf|Budding Peach
f3|d5|a1|Peach Patch
f3|d6|4f|Fresh Pineapple
f3|d7|b6|Pink Lady
f3|d8|e0|Brittany's Bow
f3|d9|d6|Scented Valentine
f3|da|e1|Fancy Pants
f3|db|d9|Hawaiian Shell
f3|dc|c6|Crisp Wonton
f3|dc|d8|Light Rose Romantic
f3|dd|3e|Golden Kiwi
f3|dd|cd|Peachtree
f3|de|a2|Roadster Yellow
f3|de|bc|Shimmering Champagne
f3|de|bf|Moondoggie
f3|de|d7|Light Fairy Pink
f3|df|b6|Belgian Waffle
f3|df|d4|Peach Shortcake
f3|df|d5|Light Angel's Face
f3|df|d7|Angel Wing
f3|df|db|Pallid Flesh
f3|df|e3|Candy Mix
f3|e0|ac|Double Cream
f3|e0|be|Vanilla Custard
f3|e0|d6|Marshmallow Cream
f3|e0|d8|Peachy Milk
f3|e0|db|Limoge Pink
f3|e2|c6|Honey Beige
f3|e2|dc|Brandy Alexander
f3|e3|d1|Peach Surprise
f3|e4|a7|Cymophane Yellow
f3|e4|b3|Meringue
f3|e4|d3|Cotton Club
f3|e4|d5|China Doll
f3|e5|ab|Vanilla
f3|e5|ac|Medium Champagne
f3|e5|c0|Milk Punch
f3|e5|cb|Marble Dust
f3|e5|dc|Fair Pink
f3|e5|dd|Champagne Ice
f3|e6|c9|Afterglow
f3|e7|79|Lemon Verbena
f3|e7|b4|Crème de la Crème
f3|e7|db|Alabaster
f3|e8|b8|Menoth White Base
f3|e9|cf|Spice Delight
f3|e9|e0|Scalloped Shell
f3|e9|f7|Perfume Haze
f3|ea|c3|Pear Sorbet
f3|ea|d2|Vanilla Wafer
f3|eb|a5|Shaded Sun
f3|ec|dc|Spun Cotton
f3|ec|e0|Egret
f3|ec|e7|Pale Lily
f3|ec|ea|Bunny Hop
f3|ed|d9|Satin Weave
f3|ed|de|Bone China
f3|ee|cd|Minimal
f3|ee|e7|Sugar Swizzle
f3|ef|cd|Clotted Cream
f3|f0|d6|Good Graces
f3|f0|d9|Hint of Arctic Daisy
f3|f0|e8|Latte Froth
f3|f1|e1|Ryu's Kimono
f3|f1|e6|Angel's Feather
f3|f1|f3|Aragonite White
f3|f2|e1|Desert Iguana
f3|f2|e8|Willowside
f3|f2|ea|Picket Fence
f3|f2|ed|Pearl White
f3|f3|d9|Shyness
f3|f3|e6|Cumulus
f3|f3|f2|Bleached Silk
f3|f4|d9|Praise the Sun
f3|f4|f4|Lighthouse
f3|f5|dc|Hint of Feijoa Flower
f3|f5|e9|Applemint Soda
f3|f9|e9|Bean Sprout
f4|00|a0|Hollywood Cerise
f4|00|a1|Fashion Fuchsia
f4|32|0c|Vermilion
f4|36|05|Orangish Red
f4|55|20|Scarlet Ibis
f4|68|60|Diluno Red
f4|73|27|Persimmon Orange
f4|76|33|Sea Nettle
f4|78|69|Melon Baby
f4|79|83|Momo Peach
f4|80|37|Sun Orange
f4|85|ac|Brown Knapweed
f4|89|3d|Hot Orange
f4|96|3a|Iceland Poppy
f4|98|ad|Flower Girl
f4|9a|c2|Pastel Magenta
f4|9f|35|Yellow Sea
f4|a3|4c|Troll Slayer Orange
f4|a3|84|Creamy Peach
f4|a4|60|Dark Flesh
f4|a6|a1|Roseberry
f4|a6|a3|Peaches N Cream
f4|ac|b6|Pink Blush
f4|af|cd|Changeling Pink
f4|b0|bb|Silly Puddy
f4|b3|c2|Ibis
f4|ba|94|Caramel Cream
f4|bb|ff|Brilliant Lavender
f4|bf|3a|Solar Power
f4|bf|c6|Strawberry Confection
f4|bf|ff|Electric Lavender
f4|c0|c6|Rose Reminder
f4|c1|c1|Princess Bride
f4|c2|6c|Hawker's Gold
f4|c2|9f|Almond Cream
f4|c2|c2|Cor-de-pele
f4|c3|c4|Strawberry Cream
f4|c4|30|Saffron
f4|c4|d0|In the Pink
f4|c5|4b|Eyelash Viper
f4|c6|c3|English Rose
f4|c8|d5|Mountain Laurel
f4|c8|db|British Rose
f4|c9|6c|Cornsilk Yellow
f4|c9|b1|Bellini
f4|ce|c5|Pearl Blush
f4|ce|d8|Lover's Retreat
f4|d0|54|Maize
f4|d0|a4|Tequila
f4|d1|b9|Only Yesterday
f4|d4|d6|Light Rose Aspect
f4|d8|1c|Ripe Lemon
f4|d8|c6|Vanilla Cream
f4|d9|c5|Sour Patch Peach
f4|d9|c8|Melon Ice
f4|da|f1|Grape Taffy
f4|db|4f|Gilded
f4|db|d9|Fresco
f4|db|dc|Light Precious Pink
f4|dc|c1|Buenos Aires
f4|dc|dc|Light Nursery
f4|dd|a5|Cutlery Polish
f4|dd|db|Light Marshmallow Magic
f4|de|bf|Peach Dip
f4|de|cb|Pecan Sandie
f4|de|d3|Ambrosia Salad
f4|de|d9|Pink Chablis
f4|de|de|Heavenly Pink
f4|df|cd|Petal Dust
f4|e0|bb|Butter Up
f4|e1|c5|Barium
f4|e1|e6|Blush Tint
f4|e2|d4|Peach Everlasting
f4|e2|d6|Alyssa
f4|e2|e1|Hint of Petite Pink
f4|e3|b5|Anise Flower
f4|e3|df|Pearly Flesh
f4|e4|b3|Smooth As Corn Silk
f4|e4|cf|Spun Jute
f4|e4|e0|Rockabye Baby
f4|e4|e5|Gaiety
f4|e5|c5|Sausalito
f4|e5|dd|Polo Tan
f4|e5|e7|First Impression
f4|e6|ce|Animal Cracker
f4|e7|ce|Magnolia Blossom
f4|e8|d1|Golden Mushroom
f4|e8|e1|Jasmine Flower
f4|e9|ea|Crystal Clear
f4|ea|d5|Hint of Porcelain Pink
f4|ea|e4|Sauvignon
f4|ea|f0|Snow Plum
f4|eb|bc|Skeleton Bone
f4|eb|d0|Crisp Candlelight
f4|eb|d3|Janna
f4|eb|d4|Hint of Jodhpurs
f4|ec|c2|Transparent Beige
f4|ec|d7|Lucky Duck
f4|ec|db|White Blossom
f4|ee|ba|Sarawak White Pepper
f4|ee|d1|Palest of Lemon
f4|ee|da|Hint of Shell Haven
f4|ee|dc|Spice Ivory
f4|ee|e0|Bechamel
f4|ef|c1|Almond Oil
f4|ef|c3|Banana Pudding
f4|ef|e0|Bianca
f4|ef|e2|Cream Cheese Frosting
f4|ef|ee|Angel Feather
f4|f0|9b|Portofino
f4|f0|d2|Oyster Cracker
f4|f0|da|Lotus Flower
f4|f0|de|Combed Cotton
f4|f0|e1|Daydreaming
f4|f0|e3|Trite White
f4|f0|e6|Romance
f4|f0|e8|Antique Paper
f4|f0|ec|Isabelline
f4|f1|e8|Wishful White
f4|f1|eb|Pearl Sugar
f4|f2|d3|Lime Blossom
f4|f2|e2|Pale View
f4|f2|e9|Snow Globe
f4|f2|ea|Dove's Wing
f4|f2|f4|White Convulvulus
f4|f3|cd|Light Apple Slice
f4|f3|e0|Full Moon
f4|f4|f0|Classic Chalk
f4|f5|f0|Bright White
f4|f6|ec|Angraecum Orchid
f4|f7|ee|Grass Valley
f5|04|c9|Mademoiselle Pink
f5|05|4f|Pink Red
f5|59|31|Hot Embers
f5|69|91|Light Crimson
f5|6c|73|Sugar Coral
f5|7f|4f|Rich Gardenia
f5|7f|8e|Strawberry Pink
f5|8f|84|Ibis Wing
f5|a2|a1|Candy Heart Pink
f5|a9|94|Pretty Primrose
f5|b1|a2|First Date
f5|b1|aa|Sango Pink
f5|b2|c5|Cupid
f5|b3|bc|Powder Rose
f5|b3|ce|Fulgrim Pink
f5|b4|bd|Squid Pink
f5|b7|84|Camel Hair Coat
f5|b7|99|Mandys Pink
f5|b8|95|Peach Quartz
f5|bc|1d|Golden Lock
f5|be|9d|Shrimp Boat
f5|be|c7|Almond Blossom
f5|bf|03|Golden
f5|bf|b2|Rustique
f5|c6|8b|Arts & Crafts Gold
f5|c7|1a|Deep Lemon
f5|c8|bb|Sweet Angel
f5|c9|9e|Sundown
f5|c9|da|Baby Steps
f5|cc|23|Turbo
f5|cd|82|Cherokee
f5|cd|d2|Pleasing Pink
f5|ce|9f|Granola
f5|ce|e6|Sparkling Pink
f5|d0|56|Stella
f5|d0|c9|Coral Candy
f5|d0|d6|Pink Cupcake
f5|d1|80|Soft Straw
f5|d1|c8|Cloud Pink
f5|d2|97|Beeswing
f5|d2|ac|Pekin Chicken
f5|d5|65|Jīn Huáng Gold
f5|d5|c2|Dreamsicle
f5|d6|c6|Creme De Peche
f5|d6|d8|Light Feather Boa
f5|d7|52|Energy Yellow
f5|d7|af|Apricot Gelato
f5|d7|dc|Cherub
f5|d8|93|Poached
f5|d8|bb|Unbleached Calico
f5|dc|b4|Tahitian Sand
f5|de|ae|Milk Quartz
f5|de|b3|Gruyère Cheese
f5|de|c4|Sazerac
f5|de|d1|Canyonville
f5|de|e2|Hint of Soft Satin
f5|df|bc|Ginger Ale Fizz
f5|df|e7|Hint of Lily Legs
f5|e2|de|Floral Linen
f5|e3|26|Quinoline Yellow
f5|e3|e2|Delicacy
f5|e3|ea|Nina
f5|e4|de|Faded Light
f5|e5|ce|Celtic Linen
f5|e5|da|Butter Icing
f5|e5|dc|La Minute
f5|e5|e1|Hint of Rose Romantic
f5|e6|c4|Pipitschah
f5|e6|c9|Windham Cream
f5|e6|d3|Shortbread
f5|e6|de|Ancient Scroll
f5|e6|ea|Amour Frais
f5|e7|d2|Pita Bread
f5|e7|e3|Impure White
f5|e9|ca|Maiden Hair
f5|e9|d5|Mimosa
f5|e9|d9|Salt Box
f5|ea|e3|Spooled White
f5|ea|eb|Pampered Princess
f5|eb|d8|White Sand
f5|eb|e1|Tea Biscuit
f5|ec|d2|Winter White
f5|ec|dc|Modern Ivory
f5|ec|e7|Windmill
f5|ed|ae|Golden Straw
f5|ed|b2|Sunbeam
f5|ed|d6|Papyrus Paper
f5|ed|d7|Buttercream Frosting
f5|ee|c0|Wildcat Grey
f5|ee|c6|Silk Star
f5|ee|df|Vapor Trail
f5|ef|d6|Soft Cream
f5|ef|e8|Light Beige
f5|ef|eb|Hint of Red
f5|f0|d1|Summer Pear
f5|f1|71|Dolly
f5|f1|da|Cream Filling
f5|f1|de|Bumble Baby
f5|f3|ce|Moon Glow
f5|f3|f5|White Owl
f5|f4|c1|Cocoa Butter
f5|f5|cc|Sunny Mimosa
f5|f5|d9|Hint of Searchlight
f5|f5|da|Triforce Shine
f5|f5|dc|Holy White
f5|f5|f5|White Smoke
f5|f9|ad|Yellow Chalk
f5|f9|cb|Carla
f5|ff|fa|Mint Cream
f6|26|81|Pink Piano
f6|4a|8a|French Rose
f6|68|8e|Rosy Pink
f6|74|5f|Camellia
f6|8f|37|Fire Flower
f6|90|92|Fruity Licious
f6|90|9d|Geranium Pink
f6|9a|54|Torch Light
f6|a0|8c|Poppy Petal
f6|a0|9d|Young Crab
f6|ad|49|Koji Orange
f6|ad|c6|Nadeshiko Pink
f6|ae|78|Tacao
f6|b4|04|Midas Finger Gold
f6|b5|11|Spanish Yellow
f6|b5|b6|Precious Pink
f6|b8|94|Red Perfume
f6|b9|6b|Citrus Honey
f6|bc|77|Amber Dawn
f6|bf|bc|Rainbow
f6|c2|89|Sunburst
f6|ca|69|Golden Crest
f6|cb|ca|Happy Piglets
f6|cc|d7|Pink Lace
f6|ce|fc|Very Light Purple
f6|d1|55|Primrose Yellow
f6|d1|93|Maple Elixir
f6|d2|55|Yellow Mask
f6|d4|8d|Maybe Maui
f6|d5|59|Wake Me Up
f6|d6|7f|Jemima
f6|d7|6e|Forsythia Blossom
f6|d7|7f|Rapunzel
f6|d8|be|Sablé
f6|d8|d7|Frosted Tulip
f6|da|74|Golden Rays
f6|db|5d|Dilly Dally
f6|db|d3|Pink Sangria
f6|db|d8|Rose Water
f6|db|dd|Fairy Princess
f6|dd|ce|Light Maiden's Blush
f6|de|d5|Touch of Blush
f6|de|da|Remy
f6|df|9f|Aspen Yellow
f6|df|e0|Hint of Rose Aspect
f6|e0|a4|Sun Dust
f6|e0|a9|Visionary
f6|e1|99|Lemon Meringue
f6|e2|ce|Warm Fuzzies
f6|e2|d8|Flamingo Peach
f6|e2|ea|First Crush
f6|e2|ec|Pale Orchid Petal
f6|e3|b4|Flan
f6|e3|d3|Breakfast Biscuit
f6|e3|da|Provincial Pink
f6|e4|91|Beekeeper
f6|e4|d9|Cream Pink
f6|e4|e4|Hint of Precious Pink
f6|e5|b9|Gentle Glow
f6|e5|db|Sheer Pink
f6|e5|f6|Soft Lavender
f6|e6|c5|Melted Wax
f6|e6|cb|Magnolia Spray
f6|e6|e2|Pink Petal
f6|e6|e4|Hint of Marshmallow Magic
f6|e6|e5|Hint of Nursery
f6|e7|e1|Hint of Fairy Pink
f6|e8|d5|Bali Sand
f6|e8|df|Hint of Angel's Face
f6|e9|cf|Sawdust
f6|e9|ea|Princess Elle
f6|ea|d8|Total Recall
f6|eb|a1|Lazy Daisy
f6|eb|c8|Lemon Icing
f6|eb|d3|Shoelace Beige
f6|eb|d7|Old Pearls
f6|eb|e7|Ryn Flesh
f6|ec|d6|Wax Wing
f6|ed|cd|Blonde Shell
f6|ee|c0|Joyful
f6|ee|cd|Silk Sails
f6|ee|d5|Moonlight
f6|ee|df|Birch White
f6|ee|e2|Fuji Peak
f6|ee|ed|Necklace Pearl
f6|ef|c5|Fresh Honeydew
f6|ef|e1|Fresh Snow
f6|f1|c4|Yellowed Bone
f6|f1|d7|Yellow Diamond
f6|f1|e2|Whiskers
f6|f1|f4|Grim White
f6|f2|e5|Sun's Glory
f6|f4|93|Milan
f6|f4|ef|The Speed of Light
f6|f4|f1|White Chalk
f6|f4|f5|Cultured
f6|f4|f6|French Porcelain
f6|f5|13|Lager
f6|f5|d7|Hint of Yellow
f6|fd|fa|Everlasting Ice
f7|02|2a|Cherry Red
f7|0d|1a|Vivid Red
f7|46|8a|Lower Lip
f7|53|94|Pansy
f7|5c|75|Ponceau
f7|66|5a|Jinzamomi Pink
f7|74|64|Coral Quartz
f7|78|6b|Peach Echo
f7|7d|25|Ornery Tangerine
f7|7f|00|University of Tennessee Orange
f7|7f|be|Persian Pink
f7|80|58|Bonfire
f7|80|a1|Pink Sherbet
f7|87|9a|Strawberry Soap
f7|8c|5a|Barbarian Flesh
f7|8f|a7|Unripe Strawberry
f7|94|4a|Bronze Flesh
f7|94|5f|Brown Sand
f7|9a|12|DodgeRoll Gold
f7|a2|33|Lightning Yellow
f7|a2|70|Copper River
f7|a4|54|Ginger Milk
f7|a5|8b|Lugganath Orange
f7|b1|a6|Riviera Rose
f7|b2|73|Ratskin Flesh
f7|b4|5e|Tanned Flesh
f7|b7|18|Spectra Yellow
f7|b7|31|NYC Taxi
f7|b7|4e|Mango Margarita
f7|b7|68|Golden Cream
f7|b9|78|Rosy Skin
f7|bb|7d|Asagi Yellow
f7|bd|7b|Craggy Skin
f7|bd|8f|Persimmon Fade
f7|be|a2|Coral Blossom
f7|bf|be|Spanish Pink
f7|bf|c2|Candy Cane
f7|c0|70|Golden Opportunity
f7|c1|14|Wisteria Yellow
f7|c2|bf|Sugar Cane Dahlia
f7|c3|80|Elf Flesh
f7|c4|6c|Sunset Gold
f7|c5|a0|Shrimp Toast
f7|c6|6b|Yellow Currant
f7|c6|b1|Coral Bisque
f7|c8|c2|Seashell Pink
f7|c9|85|Elf Skintone
f7|ca|50|Go Bananas
f7|ca|c1|Rose Quartz
f7|cc|c4|Sidewalk Chalk Pink
f7|cc|cd|Kendall Rose
f7|cd|08|Tanned Skin
f7|cd|c7|Pink Salt
f7|ce|e0|Cherry Blossom
f7|cf|1b|Happy Daze
f7|cf|89|Facemark
f7|cf|8a|Elven Flesh
f7|d0|00|Empire Yellow
f7|d1|d1|Pink Dogwood
f7|d1|d4|Mary's Rose
f7|d3|84|Pixel Cream
f7|d4|8f|Flat Flesh
f7|d4|97|Pale Corn
f7|d5|60|Light Mustard
f7|d5|cc|Creole Pink
f7|d6|0d|Tau Light Ochre
f7|d6|cb|Fluffy Pink
f7|d7|88|Pancake
f7|d7|e2|Pink Frosting
f7|d8|c4|Porcelain Tan
f7|d9|17|Tartrazine
f7|d9|94|Rosy Highlight
f7|de|9d|Lemon Caipirinha
f7|df|af|Pasta
f7|df|d7|Cameo Rose
f7|e0|e1|Hint of Feather Boa
f7|e2|6b|Vanilla Pudding
f7|e5|a9|Gold Sand
f7|e5|b7|Barley White
f7|e5|d0|Follow the Leader
f7|e5|e6|Marshmallow Rose
f7|e6|c6|Flaxseed
f7|e7|dd|Grandma's Cameo
f7|e9|8e|Flavescent
f7|ea|b9|Banana Brulee
f7|ea|cf|Soft Candlelight
f7|eb|ac|Star-Studded
f7|ec|ca|Shiny Silk
f7|ec|d8|Ranier White
f7|ee|c8|Banana Split
f7|ee|cf|Morning Moon
f7|ee|db|Home Plate
f7|ef|d0|Belgian Blonde
f7|ef|d7|Banana Pie
f7|ef|dd|Cottage White
f7|ef|de|Phoenix Villa
f7|f0|db|Apricot White
f7|f0|e1|Lemon Sponge Cake
f7|f0|e2|Crème fraîche
f7|f1|e2|Swan White
f7|f2|d7|Breezy Beige
f7|f2|da|Lychee Pulp
f7|f2|dd|Tapering Light
f7|f2|e1|Alhambra Cream
f7|f4|da|Pineapple Sorbet
f7|f5|f6|Cascading White
f7|f7|f7|Lynx White
f7|f9|e9|Soft Silver
f7|fc|fe|Deutzia White
f8|38|00|Metroid Red
f8|48|1c|Reddish Orange
f8|58|98|Oleander Pink
f8|67|4f|Sango Red
f8|78|58|Adventure Island Pink
f8|78|f8|Princess Peach Pink
f8|7e|63|Slippery Salmon
f8|81|80|Shell Pink
f8|83|79|Coral Pink
f8|83|c2|Tea Rose
f8|93|30|Quince Jelly
f8|98|51|Holland Tulip
f8|a2|00|Mad For Mango
f8|a3|9d|Candlelight Peach
f8|a4|c0|Rogue Pink
f8|ac|8c|October Haze
f8|af|a9|Snow White Blush
f8|b4|38|Squash Blossom
f8|b4|c4|Love Spell
f8|b5|00|Waxy Corn
f8|b8|00|Blue Angels Yellow
f8|b8|62|Cochin Chicken
f8|b8|78|Mellow Apricot
f8|b8|f8|Sweet Slumber Pink
f8|b9|d4|Little Baby Girl
f8|bd|d9|Flamingo Feather
f8|bf|a8|Peach Parfait
f8|c1|9a|Cream Blush
f8|c2|75|Just Peachy
f8|c4|b4|Apricot Obsession
f8|c8|84|Tango Mango
f8|cc|9c|Apricot Ice Cream
f8|cd|aa|Allspice
f8|cd|c9|Veiled Rose
f8|ce|97|Impala
f8|cf|b4|Butterfly Wing
f8|d0|e7|Pink Lily
f8|d3|74|Summer Lily
f8|d5|68|Lighthouse Glow
f8|d5|b8|Tender Peach
f8|d6|64|Happy
f8|d7|7f|E. Honda Beige
f8|d7|be|Fresh Baked Bread
f8|d7|dd|Barely Pink
f8|d8|78|Golden Raspberry
f8|d9|9e|Phoenix Fossil
f8|db|c2|Alluring Gesture
f8|db|c4|Sweetness
f8|db|e0|Carousel Pink
f8|dc|6c|Goldfinch
f8|dc|a3|Clay Dust
f8|dc|aa|Custard Powder
f8|dd|74|Milky Yellow
f8|de|7e|Club-Mate
f8|de|7f|Mellow Yellow
f8|de|8d|Popcorn
f8|de|b8|Pastry
f8|de|d1|Gleaming Shells
f8|e0|e7|Pork Belly
f8|e1|ba|Curd
f8|e2|a9|Open Sesame
f8|e2|ca|Light Unbleached Calico
f8|e2|d9|Sly Shrimp
f8|e3|a4|Blended Fruit
f8|e4|7e|Yellow Dragon
f8|e4|e3|Tutu
f8|e6|c6|Gabriel's Torch
f8|e6|c8|Golden Buff
f8|e6|d9|Hint of Maiden's Blush
f8|e7|b7|Tamale Maize
f8|e8|c5|Foundation
f8|e9|c2|Barely Butter
f8|ea|97|Picasso
f8|ea|ca|Gin Fizz
f8|ea|df|Chardon
f8|eb|97|Calabash
f8|eb|dd|Bridal Heath
f8|ec|9e|Lemon Gelato
f8|ed|d7|Gracious
f8|ed|db|Island Spice
f8|ed|e0|Ambient Glow
f8|ee|d3|Light Foundation
f8|ee|e3|White Zin
f8|ee|e7|White Rabbit
f8|ee|f4|Sentimental Pink
f8|ef|d8|Hint of Soya
f8|f0|d8|Hint of Moo
f8|f2|d8|Hint of Wheaten White
f8|f2|dd|Tiger Moth
f8|f2|de|Hint of Foundation
f8|f3|c4|Corn Field
f8|f3|e3|Daisy White
f8|f3|f6|Abalone
f8|f4|ff|Sugar Crystal
f8|f5|e5|Diamond Dust
f8|f5|e9|Risotto
f8|f6|a8|Shalimar
f8|f6|d8|White Nectar
f8|f6|da|Hint of Seduction
f8|f6|df|Promenade
f8|f6|e6|Flickering Firefly
f8|f7|53|Pilsener
f8|f7|e6|Ivory Keys
f8|f8|e8|Photon White
f8|f8|f9|Zhēn Zhū Bái Pearl
f8|f8|ff|Ghost White
f8|f9|f5|Whitest White
f8|fa|ee|Enoki
f8|fb|f8|White Porcelain
f8|ff|73|Huáng Dì Yellow
f8|ff|f8|Touch of Mint
f9|00|6f|Radioactive Eggplant
f9|40|09|Chéng Hóng Sè Orange
f9|42|9e|Rose Bonbon
f9|4d|00|Tangelo
f9|5d|2d|Raw Sunset
f9|63|3b|Vermillion Orange
f9|65|31|Exotic Orange
f9|66|53|Rose Fusion
f9|67|14|Orange Tiger
f9|6d|7b|Fiery Flamingo
f9|72|72|Georgia Peach
f9|73|06|Fire Dragon Bright
f9|83|79|Congo Pink
f9|84|e5|Splash Of Grenadine
f9|84|ef|Light Fuchsia Pink
f9|90|0f|Jú Huáng Tangerine
f9|90|6f|Salmon Nigiri
f9|9a|7a|Upstream Salmon
f9|a3|aa|Simple Pink
f9|a4|8e|Coral Serenade
f9|a7|65|Candied Yams
f9|aa|7d|Orange Chiffon
f9|b5|00|Yellow Summer
f9|b8|2b|Hot Sun
f9|bb|59|Turbinado Sugar
f9|bc|08|Chocobo Feather
f9|bc|7d|Rich Honey
f9|bf|58|Saffron Mango
f9|c0|c4|Azalea Pink
f9|c0|ce|Tassel Flower
f9|c2|91|Melon Melody
f9|c2|cd|Rose Shadow
f9|c8|9b|Orpiment Yellow
f9|c9|82|Cheddar Chunk
f9|ce|d1|Pinktone
f9|d0|54|Kournikova
f9|d0|9f|Ginger Peach
f9|d3|be|Tuft Bush
f9|d5|93|Flower Hat Jellyfish
f9|d7|7e|Golden Glow
f9|d7|ee|Jacaranda
f9|d8|57|Lemon Zest
f9|d9|64|Sunbound
f9|d9|7b|Firelight
f9|d9|a0|Milky Maize
f9|da|a5|Stella Dora
f9|db|cf|Light Carob
f9|db|d2|Skinny Dip
f9|db|e2|Tootie Fruity
f9|e0|97|Butter Ridge
f9|e1|76|Sweet Corn
f9|e1|d4|Mette Penne
f9|e2|d0|Sandy Beach
f9|e2|e1|Bride's Blush
f9|e3|b4|Light and Low
f9|e4|96|Vis Vis
f9|e4|c1|Ivory Oats
f9|e4|c5|Egg Sour
f9|e4|c6|Derby
f9|e4|c8|Howdy Neighbor
f9|e4|e9|Pink Tutu
f9|e6|99|Summer's Heat
f9|e7|bf|Creamy Custard
f9|e7|c8|Light Pastry
f9|e7|f4|Cherry Pearl
f9|e8|ce|Peach Umbrella
f9|e8|e2|Wisp Pink
f9|e9|c9|Light Curd
f9|e9|d7|Hint of Unbleached Calico
f9|ea|cc|Light Soya
f9|eb|bf|Candle in the Wind
f9|eb|c5|White Currant
f9|eb|cc|Light Moo
f9|ec|b6|Easy On The Eyes
f9|ec|d1|Quinoa
f9|ed|e2|Alpaca Wool
f9|ed|e3|Sugar Dust
f9|ee|cb|Light Cream Cake
f9|ee|d6|Hint of Curd
f9|ee|dc|Creamy Cameo
f9|f0|e1|Desert Star
f9|f1|d7|Hint of Sand Diamond
f9|f1|dd|Hint of Flower Centre
f9|f2|d4|Hint of Solar
f9|f2|e7|Powdered
f9|f3|d5|Hint of Tinker Light
f9|f3|d7|Lemonwood Place
f9|f3|db|White Lightning
f9|f3|df|Tizzy
f9|f4|d4|Sweet Jasmine
f9|f4|d9|Hint of Ringlet
f9|f5|9f|Pale Prim
f9|f5|da|Hint of Cowardly Custard
f9|f6|de|Lemon Splash
f9|f7|de|Chilean Heath
f9|f8|ef|White Crest
f9|fd|d9|Apple Martini
f9|fe|e9|Herbal Tea
fa|1a|8e|Philippine Pink
fa|2a|55|Red Pink
fa|42|24|Strawberry Spinach Red
fa|5b|3d|Orange Soda
fa|5f|f7|Magenta Stream
fa|6e|79|Begonia
fa|7b|62|Akebono Dawn
fa|80|72|Smoked Salmon
fa|87|3d|Sunset Yellow
fa|8c|4f|Blaze
fa|8d|7c|Hot Calypso
fa|8e|99|Strawberry Shortcake
fa|92|58|Umezome Pink
fa|9a|85|Shān Hú Hóng Coral
fa|9d|49|Sunshade
fa|9d|5a|Tan Hide
fa|a7|6c|Trump Tan
fa|a9|45|Tōmorokoshi Corn
fa|ac|72|Orange Marmalade
fa|b7|5a|Amber Yellow
fa|bb|a9|Yahoo
fa|bf|14|Ukon Saffron
fa|bf|e4|Pretty in Pink
fa|c2|05|Orange Jelly
fa|c7|bf|Dress Up
fa|c8|c3|Gossamer Pink
fa|c8|ce|Rosey Afterglow
fa|cd|9e|Apricot Sherbet
fa|ce|6d|Bright Yarrow
fa|cf|58|Rubber Ducky
fa|cf|c1|Doll House
fa|cf|cc|Fairytale Dream
fa|d4|8b|Orange Chalk
fa|d6|a5|Prosecco
fa|d6|c5|Deep Champagne
fa|d6|e5|Sunset Pink
fa|d7|b0|Satin Latour
fa|d9|da|Light Pink Tone
fa|d9|dd|Bunny's Nose
fa|da|50|Royal Yellow
fa|da|5e|Dark Jonquil
fa|da|5f|Naples Yellow
fa|da|6a|Huáng Jīn Zhōu Gold
fa|da|dd|Sun Bleached Pink
fa|db|5e|Stil De Grain Yellow
fa|db|d7|Pink Lotus
fa|dc|97|Cooled Cream
fa|de|85|Sunshine
fa|df|ad|Peach Yellow
fa|df|c7|Peachade
fa|e1|95|Cheesy Grin
fa|e1|98|Sundaze
fa|e1|99|Pale Banana
fa|e2|ed|Spun Sugar
fa|e3|bc|Soya
fa|e3|e3|Hint of Pink Tone
fa|e4|32|Dhalsim's Yoga Flame
fa|e5|bf|Saturn
fa|e6|ca|Quiet Splendor
fa|e6|cc|Favored One
fa|e6|df|Bridesmaid
fa|e6|e5|Hint of Fairy Wings
fa|e7|b5|Banana Yogurt
fa|e8|ab|Lemon Candy
fa|e8|bc|Sand Diamond
fa|e8|e1|Rose Tan
fa|e9|e1|Hint of Passion Flower
fa|ea|cd|Spotlight
fa|ea|dd|Rosarian
fa|ea|e2|Dogwood
fa|eb|d7|Milk Tooth
fa|ec|d9|Ajo Lily
fa|ed|d2|Light Vanilla Frost
fa|ed|d5|Hint of Pastry
fa|ed|e3|Hint of First Love
fa|ee|66|Yellowish
fa|ee|cb|Light Sand Diamond
fa|ee|d9|Hint of French Vanilla
fa|ee|db|Antique Linen
fa|ee|de|Hint of Dedication
fa|f0|be|Blond
fa|f0|c9|Light Solar
fa|f0|cb|Light Wheaten White
fa|f0|cf|Lemon Sachet
fa|f0|da|Hint of Spanish Cream
fa|f0|db|White Lily
fa|f0|e6|Linen
fa|f1|c8|Light Tinker Light
fa|f1|cd|Light Ringlet
fa|f1|d7|Hint of Cream Cake
fa|f2|d1|Lemon Popsicle
fa|f2|e3|Whitewashed Fence
fa|f3|cf|Light Cowardly Custard
fa|f3|dc|Eternal White
fa|f3|dd|Hint of Vanilla Frost
fa|f3|e6|Milk Mustache
fa|f4|ce|Light Seduction
fa|f4|d4|Cotton Cloth
fa|f5|c3|Fine Linen
fa|f7|d6|Citrine White
fa|f7|e2|Diamond
fa|f7|eb|Van de Cane
fa|f7|f0|Milk Glass
fa|fa|37|Maximum Yellow
fa|fa|d2|Light Goldenrod Yellow
fa|fe|4b|Banana Mash
fb|00|81|Flickr Pink
fb|29|43|Strawberry
fb|4d|46|Tart Orange
fb|4f|14|Orioles Orange
fb|55|81|Warm Pink
fb|5f|fc|Violet Pink
fb|60|7f|Brink Pink
fb|7d|07|Pumpkin Orange
fb|7e|fd|Atomic Pink
fb|81|36|Beniukon Bronze
fb|8b|23|Flame Orange
fb|95|87|Adobe Avenue
fb|99|02|Jack-o
fb|9a|30|Pelican Pecker
fb|9b|82|Pouring Copper
fb|9f|93|Peach Amber
fb|a0|e3|Lavender Rose
fb|a5|2e|Carona
fb|aa|4c|Kumquat
fb|ab|60|Rajah
fb|ac|82|Apricot Wash
fb|ae|d2|Spaghetti Strap Pink
fb|b3|77|Market Melon
fb|b9|95|Beach Sand
fb|bd|af|Peach Melba
fb|be|99|Apricot Iced Tea
fb|c1|7b|Zing
fb|c8|5f|Samoan Sun
fb|cc|e7|Classic Rose
fb|ce|b1|Lips of Apricot
fb|d0|5c|Beach Party
fb|d3|d9|Pink Fluorite
fb|d4|9c|Paw Paw
fb|d5|a6|Tuscan
fb|d5|bd|Prairie Dune
fb|d6|d2|Just A Tease
fb|d7|cc|Cinderella
fb|d8|97|Golden Haze
fb|d8|c9|Scallop Shell
fb|da|e8|Cherry Flower
fb|dc|a8|Doodle
fb|dc|dc|Light Fairy Wings
fb|dd|24|Jubilation
fb|dd|7e|Wheat
fb|e0|dc|Satin Pink
fb|e1|98|April Sunshine
fb|e3|a1|Durango Dust
fb|e4|af|Khaki Core
fb|e5|73|Golden Glitter
fb|e5|bd|Moo
fb|e7|b2|Banana Mania
fb|e7|e6|Hint of Pink Tutu
fb|e8|70|Marigold Yellow
fb|e8|ce|Light French Vanilla
fb|e8|e0|Hint of Shell Tint
fb|e8|e2|Hint of Shy Girl
fb|e8|e4|Hint of Bleached Coral
fb|e9|ac|Lemon Rose
fb|e9|d8|Poppy Crepe
fb|e9|de|Hint of Camisole
fb|ea|b8|Solar
fb|ea|bd|Frozen Custard
fb|eb|50|Paris Daisy
fb|eb|9b|Drover
fb|eb|bb|Wheaten White
fb|eb|cf|Light Spanish Cream
fb|eb|d6|Moccasin
fb|ec|5d|Corn
fb|ec|5e|Maizena
fb|ec|c9|Flaxen
fb|ec|d3|Light Flower Centre
fb|ed|b8|Tinker Light
fb|ed|be|Ringlet
fb|ed|da|Mango Cheesecake
fb|ee|ac|Light Tan
fb|ee|e8|Rose White
fb|f0|73|Witch Haze
fb|f0|d6|Half Dutch White
fb|f1|c0|Cowardly Custard
fb|f1|c3|Amarillo Yellow
fb|f1|c8|Honeysuckle Vine
fb|f1|df|Soft Ivory
fb|f2|bf|Seduction
fb|f2|db|Barley Groats
fb|f3|d3|China Ivory
fb|f3|f1|Ivory Tower
fb|f4|da|Tulip Petals
fb|f4|e8|White Fever
fb|f6|de|Mini Cake
fb|f9|e1|Coconut Pulp
fb|fa|f5|Unbleached
fb|fb|4c|Biohazard Suit
fb|fb|e5|Clearview
fb|ff|0a|Hexos Palesun
fc|01|56|Sorx Red
fc|0e|34|Bright Scarlet
fc|0f|c0|CGA Pink
fc|26|47|Là Jiāo Hóng Red
fc|28|47|Medium Scarlet
fc|44|a3|Fioletowy Purple
fc|53|fc|Surati Pink
fc|5a|50|Algerian Coral
fc|5e|30|Circus
fc|64|2d|Dragon Fire
fc|6c|85|Ultra Red
fc|6d|84|Wild Watermelon
fc|74|fd|Electric Flamingo
fc|7a|b0|Erythrosine
fc|7d|64|Sunset Papaya
fc|80|a5|Pink Makeup
fc|82|4a|Sè Lèi Orange
fc|84|27|Fluorescent Red Orange
fc|84|5d|Pink Fire
fc|86|aa|Pinky
fc|89|ac|Tickle Me Pink
fc|8a|aa|Rock'n'Rose
fc|8e|ac|Flamingo Pink
fc|8f|9b|Conch Shell
fc|9e|21|Radiant Yellow
fc|a0|44|Double Dragon Skin
fc|a2|89|Papaya Punch
fc|a4|74|Usugaki Persimmon
fc|a7|16|California Girl
fc|b0|01|Yellow Orange
fc|b0|2f|Sunshine Surprise
fc|b0|57|Duckling
fc|b4|d5|Lavender Candy
fc|be|6a|California Peach
fc|c0|06|Marigold
fc|c2|00|Golden Poppy
fc|c6|2a|Golden Banner
fc|c7|92|Sicilian Villa
fc|c8|00|Himawari Yellow
fc|c9|b9|Ending Dawn
fc|c9|c7|Sunday Best
fc|ca|ac|Bleached Apricot
fc|d2|df|Creamy Strawberry
fc|d5|75|Tamago Egg
fc|d5|cf|Cosmos
fc|d7|ba|Gentle Caress
fc|d8|b5|Young Apricot
fc|d8|dc|Mexican Mudkip
fc|d9|17|Candlelight
fc|d9|3b|Dandelion Yellow
fc|d9|75|Golden Coin
fc|d9|c6|Quilt
fc|d9|c7|Camisole
fc|db|d2|Pippin
fc|df|39|Fluffy Duckling
fc|df|63|Here Comes the Sun
fc|df|8a|Daisy Desi
fc|df|a4|Honey Bee
fc|df|af|Apricot Mousse
fc|e0|81|Swedish Yellow
fc|e0|a8|Cake Dough
fc|e0|d6|Light Shell Tint
fc|e1|66|Xìng Huáng Yellow
fc|e2|82|Bursting Lemon
fc|e2|c4|Budder Skin
fc|e2|d4|Light Camisole
fc|e2|d7|Light Passion Flower
fc|e3|b3|Beach Towel
fc|e5|bf|Burnished Cream
fc|e5|c0|Spanish Cream
fc|e6|99|Lemon Delicious
fc|e6|db|Light First Love
fc|e7|9a|Twinkle Little Star
fc|e7|e4|Hint of Pink Clay
fc|e8|83|Sandworm
fc|e8|e3|Hint of Elusive
fc|e9|74|Hazelnut Turkish Delight
fc|e9|ad|Butter Fingers
fc|e9|b9|Solar Wind
fc|e9|d5|Light Dedication
fc|e9|d7|Serenade
fc|e9|df|Hint of Quilt
fc|ec|ad|Lemon Blast
fc|ec|d5|Go Go Glow
fc|ed|c5|Oasis Sand
fc|ed|e4|Vanilla Blush
fc|ee|ae|Custard Puff
fc|ef|01|Asfar Yellow
fc|ef|c1|Alexandria's Lighthouse
fc|f0|c2|Moonstruck
fc|f0|c5|Twinkle Twinkle
fc|f0|e5|Pale Wheat
fc|f1|bd|Drop of Lemon
fc|f2|b9|Dandelion Wine
fc|f2|df|Damask
fc|f4|c8|Spring Lily
fc|f6|79|Straw Gold
fc|f7|5e|Icterine
fc|f7|db|Light Mist
fc|f7|eb|Pearl Necklace
fc|f9|bd|Cashew Cheese
fc|fc|5d|Candy Corn
fc|fc|81|Yellowish Tan
fc|fc|cf|Morrow White
fc|fc|da|Pale Morning
fc|fc|de|Flayed One Flesh
fc|fd|74|Yellow Powder
fc|fd|fc|Emptiness
fc|ff|a4|Calamansi
fc|ff|f9|Ceramic
fd|00|4d|Folly
fd|02|02|Encarnado
fd|02|ff|Sixteen Million Pink
fd|0d|35|Torch Red
fd|0e|35|Rose Hip
fd|0f|35|Tractor Red
fd|3a|4a|Red Salsa
fd|3c|06|Fire Opal
fd|3f|92|French Fuchsia
fd|41|1e|Spiritstone Red
fd|46|59|Watermelon
fd|52|40|Ogre Odor
fd|58|00|Willpower Orange
fd|59|56|Grapefruit
fd|5b|78|Watermelon Candy
fd|5e|53|Sunset Orange
fd|6c|9e|French Pink
fd|6f|3b|Carrot
fd|79|8f|Carnation
fd|7c|6e|Hipster Salmon
fd|82|c3|Pink Orchid Mantis
fd|8b|60|After Burn
fd|8d|49|Orangish
fd|8f|79|Kissable
fd|97|8f|Lolly
fd|99|89|Chilly Spice
fd|a4|70|Hit Pink
fd|aa|48|Prison Jumpsuit
fd|ae|44|Safflower
fd|ae|45|My Sin
fd|b0|c0|Soft Pink
fd|b1|47|Butterscotch
fd|b2|ab|Peach Bud
fd|b9|15|Orange Yellow
fd|ba|c4|Pink Bubble Tea
fd|bc|b4|Melon Water
fd|c1|c5|Delhi Dance Pink
fd|c3|c6|Crystal Rose
fd|c8|38|Banana Boat
fd|cb|18|Goldenrod
fd|cc|37|Golden Marguerite
fd|d2|00|Yuzu Jam
fd|d4|c5|Georgia On My Mind
fd|d5|b1|Light Apricot
fd|d6|e5|Powder Pink
fd|d7|92|Evening Glow
fd|d7|ca|Shell Tint
fd|d7|d8|We Peep
fd|d7|e4|Pig Pink
fd|d8|78|Lemon Drop
fd|d9|b5|Sandy Tan
fd|db|6d|Hawkbit
fd|db|b6|Three Ring Circus
fd|dc|5c|Light Gold
fd|dd|b7|Spiked Apricot
fd|dd|e6|Fresh Piglet
fd|de|6c|Pale Gold
fd|de|a5|Bachimitsu Gold
fd|df|ae|Apple Custard
fd|df|da|Light Elusive
fd|e0|da|Light Shy Girl
fd|e0|dc|Light Bleached Coral
fd|e1|d4|Light Quilt
fd|e1|f0|Pale Blossom
fd|e3|36|Gorse
fd|e6|34|Zard Yellow
fd|e6|c6|Flower Centre
fd|e7|e3|Hint of Tea Party
fd|e8|82|Vacherin Cheese
fd|e8|9a|Pale Daffodil
fd|e8|d0|Pale Egg
fd|e9|10|Genoa Lemon
fd|e9|c5|Vanilla Frost
fd|e9|e0|Chablis
fd|ea|83|Citrus Punch
fd|ea|9f|Eggnog
fd|ec|c7|Senior Moment
fd|ed|c3|Nǎi Yóu Sè Cream
fd|ee|00|Aureolin
fd|ee|73|Sand Yellow
fd|ef|02|Hudson Bee
fd|ef|d3|Varden
fd|ef|db|Silkie Chicken
fd|ef|e9|Okra
fd|ef|f2|Pale Cherry Blossom
fd|f1|af|Paper Tiger
fd|f2|d1|Vanilla Ice
fd|f2|db|Antique Lace
fd|f3|e4|Early Snow
fd|f5|d7|Light of the Moon
fd|f5|e6|Old Lace
fd|f6|e7|Antique China
fd|f9|ef|White Heat
fd|fa|f1|White Desert
fd|fb|f8|Cool December
fd|fc|74|Old Laser Lemon
fd|fc|fa|Igloo
fd|fd|96|Pastel Yellow
fd|fd|fd|Brilliance
fd|fd|fe|Pale Grey
fd|ff|00|Lemon Glacier
fd|ff|38|Lichtenstein Yellow
fd|ff|52|Butter Cake
fd|ff|63|Canary
fd|ff|f5|Milk
fe|00|02|Fire Engine Red
fe|01|9a|Neon Pink
fe|01|b1|Bright Pink
fe|02|3c|Méi Gūi Hóng Red
fe|02|a2|Shocking Pink
fe|14|93|Fluorescent Pink
fe|27|12|Red October
fe|27|13|Red Riding Hood
fe|28|a2|Persian Rose
fe|2c|54|Reddish Pink
fe|2f|4a|Lightish Red
fe|41|64|Neon Fuchsia
fe|42|0f|Fēi Hóng Scarlet
fe|44|01|Orange Red
fe|46|a5|Barbie Pink
fe|48|6c|Infra Red
fe|4b|03|Blood Orange Juice
fe|4c|40|Dusk Orange
fe|4e|da|Purple Pizzazz
fe|54|a3|Brilliant Rose
fe|5a|1d|Giants Orange
fe|63|47|Nasturtium
fe|67|00|Blaze Orange
fe|6f|5e|Grapefruit Pulp
fe|74|38|Crayola Orange
fe|7b|7c|Forbidden Fruit
fe|82|8c|Camaron Pink
fe|83|cc|Angel Face Rose
fe|86|a4|Rosa
fe|8c|18|Carrot Curl
fe|97|73|Hibiscus Delight
fe|a0|51|Bittersweet
fe|a1|66|Papaya
fe|a4|64|Usukō
fe|a5|a2|Pink Dream
fe|a6|c8|Taffy Pink
fe|a7|bd|Amélie's Tutu
fe|a8|9f|Corally
fe|a9|93|Light Salmon
fe|aa|7b|Salmon Buff
fe|ab|9a|Pink Rose Bud
fe|ae|0d|Turmeric Root
fe|ae|a5|Apricot Blush
fe|b2|09|Saffron soufflé
fe|b3|08|Dithered Amber
fe|b5|52|Koromiko
fe|b8|7e|Go Go Mango
fe|ba|ad|Ripe Melon
fe|c3|82|Apricot Appeal
fe|c5|0c|Kazakhstan Flag Yellow
fe|c6|15|Orangina
fe|c6|5f|After Shock
fe|c9|ed|Rosy Maple Moth
fe|cb|00|Philippine Yellow
fe|cd|01|Tangerine Yellow
fe|cd|ac|Petticoat
fe|ce|5a|Casandora Yellow
fe|cf|24|Lemon Punch
fe|d0|fc|Pink Diamond
fe|d1|bd|Pale Peach Pink
fe|d2|a5|Affinity
fe|d4|50|Habanero Gold
fe|d5|5d|Minion Yellow
fe|d5|e9|Pink Currant
fe|d6|cc|Pale Jasper
fe|d7|77|Snapdragon
fe|d7|cf|Elusive
fe|d8|3a|Exploding Star
fe|d8|5d|Common Dandelion
fe|d8|b1|Light Orange
fe|db|b7|Pandora's Box
fe|dc|ad|Peach Bellini
fe|dc|c1|Karry
fe|dd|cb|Shironeri Silk
fe|dd|dd|Light Pink Tutu
fe|de|bc|Almondine
fe|df|00|Tibetan Yellow
fe|df|08|Dandelion
fe|df|dc|Light Pink Clay
fe|e0|a5|Cape Honey
fe|e0|da|Light Tea Party
fe|e2|b2|Sunstitch
fe|e2|be|Messinesi
fe|e2|c8|Dedication
fe|e5|cb|Sinner's City
fe|e6|dc|French Manicure
fe|e7|15|Blazing Yellow
fe|e8|d6|Macaroon Cream
fe|e8|f5|Dolomite Crystal
fe|e9|c4|Tiger Tail
fe|e9|d8|Blossom
fe|e9|da|Guiding Star
fe|ed|9a|Old Yella
fe|ed|ca|Biscuit
fe|ed|e0|Organic Fiber
fe|f0|68|Pale Ale
fe|f2|00|Christmas Yellow
fe|f2|63|Kihada Yellow
fe|f2|c7|Silent Ivory
fe|f2|dc|Xâkestari White
fe|f3|c3|Lazy Summer Day
fe|f5|db|Desert Lily
fe|f6|5b|Dodie Yellow
fe|f6|9e|Spaghetti
fe|f6|be|Yellow Yarn
fe|f9|d3|Focus on Light
fe|fc|7e|Limuyi Yellow
fe|fc|af|Parchment
fe|fd|fa|Lotion
fe|fe|22|Pressed Laser Lemon
fe|fe|33|Giraffe
fe|fe|66|Unmellow Yellow
fe|fe|cd|Ice Yellow
fe|fe|e0|Ceramite White
fe|fe|e7|Wedding Dress
fe|fe|fa|Baby Powder
fe|ff|0f|Sunblast Yellow
fe|ff|32|Bee Yellow
fe|ff|7f|Faded Yellow
fe|ff|ca|Bright Ecru
fe|ff|cc|Polyanthus Narcissus
fe|ff|e3|Skimmed Milk White
fe|ff|ea|Gaslight
fe|ff|fc|Whitewash
ff|00|00|Red
ff|00|01|Rainbow's Outer Rim
ff|00|0d|Bright Red
ff|00|22|Incision
ff|00|28|Ruddy
ff|00|33|Hornet Sting
ff|00|38|Carmine Red
ff|00|3f|Electric Crimson
ff|00|4d|Bloody Pico-8
ff|00|4f|Halt Red
ff|00|55|Red Light Neon
ff|00|6c|Vivid Raspberry
ff|00|7e|Pink Poison
ff|00|7f|Rose
ff|00|90|Pink Panther
ff|00|99|Big Bang Pink
ff|00|aa|Ms. Pac-Man Kiss
ff|00|cc|Hot Magenta
ff|00|ff|Magenta
ff|02|8d|Hot Pink
ff|03|3e|American Rose
ff|04|90|Electric Pink
ff|07|3a|Neon Red
ff|07|89|Strong Pink
ff|08|00|Candy Apple Red
ff|08|09|Hóng Sè Red
ff|08|e8|Bright Magenta
ff|09|ff|Rainbow's Inner Rim
ff|0f|0f|Red Alert
ff|11|00|Furious Red
ff|11|11|Spicy Red
ff|11|22|Superman Red
ff|11|ff|Fresh Neon Pink
ff|14|76|Pink Ink
ff|14|93|Secret Story
ff|1b|2d|Opera Red
ff|1c|ae|Spicy Pink
ff|1d|cd|Glamour Pink
ff|1d|ce|Kind Magenta
ff|20|52|Fly Agaric
ff|22|00|Redrum
ff|22|11|Janemba Red
ff|22|22|Red Stop
ff|24|00|Scarlet
ff|25|5c|Lingonberry
ff|26|00|Maraschino
ff|28|00|Ferrari Red
ff|2f|92|Unicorn Dust
ff|2f|eb|Maiden Pink
ff|33|33|Pelati
ff|33|99|Wild Strawberry
ff|33|cc|Razzle Dazzle Rose
ff|33|ff|Pink Overflow
ff|35|03|Electric Orange
ff|35|5e|Radical Red
ff|38|00|Coquelicot
ff|38|55|Sizzling Red
ff|3f|34|Red Orange
ff|40|40|Coral Red
ff|40|4c|Sunburnt Cyclops
ff|40|ff|Dried Magenta
ff|43|a4|Artificial Strawberry
ff|44|44|Tomato Frog
ff|44|66|Magic Potion
ff|44|ee|Actinic Light
ff|44|ff|Sicilia Bougainvillea
ff|45|00|Red Dit
ff|46|81|Sasquatch Socks
ff|47|4c|Blood Burst
ff|48|d0|Mat Dazzle Rose
ff|49|6c|Love Red
ff|4d|00|Phaser Beam
ff|4e|01|Magma
ff|4e|20|Ōtan Red
ff|4f|00|Aerospace Orange
ff|53|49|Red Orange Juice
ff|54|70|Fiery Rose
ff|55|00|Mystic Red
ff|55|55|Fluorescent Red
ff|55|99|Fuchsia Fever
ff|55|a3|Magenta Crayon
ff|55|aa|Pink Katydid
ff|55|ee|Pink Party
ff|55|ff|Ultimate Pink
ff|58|00|Molten Core
ff|5a|36|Portland Orange
ff|5b|00|Maximum Orange
ff|5c|cd|Light Deep Pink
ff|5f|00|Vivid Orange
ff|60|37|Toxic Orange
ff|61|63|Fusion Red
ff|63|1c|Brave Orange
ff|63|47|Bruschetta Tomato
ff|63|e9|Candy Pink
ff|66|00|Safety Orange
ff|66|11|Orange Piñata
ff|66|66|Pompelmo
ff|66|cc|Rose Pink
ff|66|ff|Pink Flamingo
ff|67|00|Burtuqali Orange
ff|69|61|Pastel Red
ff|69|af|Yíng Guāng Sè Pink
ff|69|b4|Girls Night Out
ff|6c|b5|Fěn Hóng Pink
ff|6d|3a|Smashed Pumpkin
ff|6e|3a|Orange Burst
ff|6e|4a|Outrageous Orange
ff|6e|c7|Nervous Neon Pink
ff|6f|01|Flush Orange
ff|6f|52|Orange Pink
ff|6f|61|Living Coral
ff|6f|fc|Strawberry Frosting
ff|6f|ff|Blush Pink
ff|70|34|Bright Orange
ff|71|24|Burning Orange
ff|71|4e|Often Orange
ff|72|4c|Pinkish Orange
ff|73|00|Philippine Orange
ff|74|20|Vibrant Orange
ff|75|0f|March Hare Orange
ff|75|18|Pumpkin
ff|75|38|Synthetic Pumpkin
ff|77|00|Lucky Orange
ff|77|77|Embarrassment
ff|77|a8|Pico-8 Pink
ff|77|aa|Raspberry Glaze
ff|77|ff|Fuchsia Pink
ff|78|55|Melon
ff|78|7b|Pink Glamour
ff|79|13|Orange Popsicle
ff|79|52|Rinsed-Out red
ff|79|6c|Salmon
ff|7a|00|Heat Wave
ff|7e|00|Shade of Amber
ff|7e|79|Salmon Sashimi
ff|7f|00|Orange Juice
ff|7f|49|Mythical Orange
ff|7f|50|Coral
ff|7f|6a|Fresh Salmon
ff|7f|a7|Carnation Pink
ff|80|50|Nārangī Orange
ff|80|ff|Light Magenta
ff|81|c0|Pink Tease
ff|82|43|Mango Tango
ff|82|ce|Pout Pink
ff|83|79|Orange Tea Rose
ff|84|49|Tangerine Dream
ff|85|52|Poached Rainbow Trout
ff|85|76|Fusion Coral
ff|85|cf|Princess Perfume
ff|85|ff|Bubble Gum
ff|86|56|Nectarine
ff|87|8d|Tulip
ff|88|12|Autumn Glory
ff|88|30|Bright Mango
ff|88|88|Red Mull
ff|88|ff|Darling Bud
ff|89|36|Kanzō Orange
ff|8a|4a|Valley of Fire
ff|8a|d8|Pink Delight
ff|8b|00|American Orange
ff|8c|00|Sun Crete
ff|8c|55|Paradise Bird
ff|8c|69|Salmon Orange
ff|8d|00|Bright Marigold
ff|8d|28|Instant Orange
ff|8d|86|Prime Pink
ff|8d|94|Salmon Rose
ff|8e|57|Fire Orange
ff|8f|00|Princeton Orange
ff|90|66|Pink Orange
ff|90|a2|Charming Cherry
ff|91|a4|Salmon Pink
ff|91|af|Schauss Pink
ff|92|ae|Baker-Miller Pink
ff|93|00|Tangerine
ff|94|08|Merin's Fire
ff|95|32|Energy Orange
ff|95|52|Encounter
ff|96|13|Cheese Please
ff|96|4f|Pastel Orange
ff|96|82|Orange Aura
ff|96|87|Desert Flower
ff|97|31|Orange Jewel
ff|97|5c|Rainbow Trout
ff|98|89|Mona Lisa
ff|98|99|American Pink
ff|99|00|Vitamin C
ff|99|11|Hephaestus Gold
ff|99|32|Deep Saffron
ff|99|33|Neon Carrot
ff|99|66|Atomic Tangerine
ff|99|80|Vivid Tangerine
ff|99|99|Light Salmon Pink
ff|99|cc|Pale Magenta Pink
ff|99|ff|Pinkalicious
ff|9a|45|Orange Hibiscus
ff|9a|8a|Peach Pink
ff|9b|87|Candy
ff|9b|aa|Salmon Tartare
ff|9c|68|Fresh Cantaloupe
ff|9e|4b|Tangerine Tango
ff|9e|76|Candyman
ff|9e|de|Rose Daphne
ff|9f|00|Mandarin Peel
ff|a0|00|Orange Peel
ff|a0|0a|Bonus Level
ff|a0|10|Zinnia
ff|a0|7a|Dwarven Flesh
ff|a0|89|Tangerine Cream
ff|a1|02|Vivid Orange Peel
ff|a1|68|Cloudberry
ff|a1|77|Butternut
ff|a1|80|Orchid Orange
ff|a2|4c|Exotic Flower
ff|a2|6b|Sharegaki Persimmon
ff|a2|aa|Strawberry Frappe
ff|a3|00|Pico Orange
ff|a3|43|Radiation Carrot
ff|a3|68|Mock Orange
ff|a3|73|Day At The Zoo
ff|a4|00|Yamabuki Gold
ff|a4|68|Baby Melon
ff|a4|74|Young Tangerine
ff|a5|00|Orange
ff|a5|65|Pale Incense
ff|a6|00|Cheese
ff|a6|2b|Mango
ff|a6|31|Tamago Orange
ff|a6|4f|Blazing Orange
ff|a6|c9|Dark Carnation Pink
ff|a7|00|Chrome Yellow
ff|a7|56|Pale Orange
ff|a8|12|Dark Tangerine
ff|a8|83|Peach Fizz
ff|a8|a6|Salmon Upstream
ff|a9|9d|Poised Peach
ff|aa|00|Flash of Orange
ff|aa|11|Delicious Mandarin
ff|aa|1d|Averland Sunset
ff|aa|4a|Five Star
ff|aa|55|Soul Side
ff|aa|66|Transparent Orange
ff|aa|aa|Fond de Teint
ff|aa|cc|Majin Bū Pink
ff|aa|ee|Pink Wink
ff|aa|ff|Jigglypuff
ff|ab|0f|Yellowish Orange
ff|ac|39|Blissful Orange
ff|ad|00|Fresh Squeezed
ff|ad|01|Mandarin Jelly
ff|ad|97|Pink Persimmon
ff|ad|98|Discreet Orange
ff|ad|c9|Heartfelt
ff|ae|42|Mandarin Sorbet
ff|ae|52|Alajuela Toad
ff|ae|bb|Poodle Skirt
ff|ae|c1|Baby's Blanket
ff|af|37|Ripe Pumpkin
ff|af|6b|Orange Fire
ff|af|75|Bloom
ff|af|a3|Amber Tide
ff|b0|00|Gold Fusion
ff|b0|66|Mango Salsa
ff|b0|77|Very Light Tangelo
ff|b0|7c|Peach
ff|b0|ac|Cornflower Lilac
ff|b1|62|Burning Flame
ff|b1|6d|Apricot
ff|b1|81|Peach Cobbler
ff|b1|9a|Pale Salmon
ff|b1|b0|Fancy Flamingo
ff|b2|00|Chinese Yellow
ff|b2|a5|Peach Pearl
ff|b2|d0|Pink Cattleya
ff|b3|00|UCLA Gold
ff|b3|47|Agrellan Badland
ff|b3|a7|Washed-Out Crimson
ff|b3|de|Light Hot Pink
ff|b4|37|Corona
ff|b4|8a|Coral Dusk
ff|b4|9b|Persicus
ff|b5|9a|Island Girl
ff|b5|9b|Peach Nectar
ff|b6|1e|Tōō Gold
ff|b6|53|Summer Orange
ff|b6|b4|Young Salmon
ff|b6|c1|Matt Pink
ff|b7|5f|Peanut Butter
ff|b7|c5|Cherry Blossom Pink
ff|b7|ce|Baby Pink
ff|b7|d5|Candy Bar
ff|b8|65|Warm Apricot
ff|b9|4e|Floral Leaf
ff|b9|5a|Cape Jasmine
ff|b9|7b|Macaroni and Cheese
ff|b9|89|Savannah Sun
ff|b9|b2|Mexican Milk
ff|ba|00|Selective Yellow
ff|ba|6f|Yellow Warbler
ff|ba|b0|Petula
ff|ba|cd|Tentacle Pink
ff|bb|00|Mantella Frog
ff|bb|31|Garuda Gold
ff|bb|72|Spiced Nectarine
ff|bb|7c|Buff Orange
ff|bb|8f|Fuzzy Peach
ff|bb|9e|Prairie Sunset
ff|bb|b4|Cherry Chip
ff|bb|bb|Hard Candy
ff|bb|dd|Pink Satin
ff|bb|ee|Pink Quartz
ff|bb|ff|Distilled Rose
ff|bc|00|Sunset Strip
ff|bc|35|Fall Gold
ff|bc|d9|Cotton Candy
ff|bd|2b|Brimstone
ff|bd|31|Vibrant Honey
ff|be|94|Sunset Cruise
ff|be|98|Happy Prawn
ff|be|c8|Love Affair
ff|bf|00|Amber
ff|bf|65|Sea Buckthorn
ff|bf|ab|Porcellana
ff|c0|6c|Simply Peachy
ff|c0|c6|Piglet
ff|c0|cb|Pink
ff|c1|2c|Not Yo Cheese
ff|c1|4b|Nârenji Orange
ff|c1|52|Golden Tainoi
ff|c1|cc|Blobfish
ff|c2|17|Happy Yipee
ff|c3|00|Lemon Chrome
ff|c3|24|Ripe Mango
ff|c3|55|Orange Delight
ff|c3|bf|Ladylike
ff|c3|c6|Pink and Sleek
ff|c4|0c|Mikado Yellow
ff|c4|ae|Gadabout
ff|c4|b2|Tropical Peach
ff|c4|bc|Impatiens Pink
ff|c4|dd|Sweet Romance
ff|c5|12|Sunflower
ff|c5|8a|Bundaberg Sand
ff|c5|bb|Your Pink
ff|c5|cb|Light Rose
ff|c5|d5|Sweet Serenade
ff|c6|32|Rise-N-Shine
ff|c6|6e|Pale Marigold
ff|c6|9e|Romantic
ff|c6|c4|Cinderella Pink
ff|c7|b0|Antique Coral
ff|c7|b9|Peach Fuzz
ff|c8|2a|Bumblebee
ff|c8|63|Honey Pot
ff|c8|78|Mead
ff|c8|7c|Beige Topaz
ff|c8|c2|The Bluff
ff|c9|43|Be Daring
ff|c9|46|Sunny Festival
ff|c9|c4|Hooked Mimosa
ff|c9|d3|Sweet Sixteen
ff|c9|d7|Flower Spell
ff|c9|dd|Cherry Blush
ff|ca|7d|Orange Glass
ff|ca|a4|Polly
ff|ca|c3|Caro
ff|cb|a2|Deep Peach
ff|cb|a4|Corn Kernel
ff|cb|a7|Peach Crayon
ff|cb|c4|Flesh
ff|cc|00|USC Gold
ff|cc|13|Confident Yellow
ff|cc|33|Sunglow
ff|cc|3a|Yellow Jacket
ff|cc|88|Bastard-amber
ff|cc|99|Peach Orange
ff|cc|aa|Peachy Pico
ff|cc|c8|Pretty Please
ff|cc|cb|Light Red
ff|cc|cc|Lusty-Gallant
ff|cc|dd|Linnet Egg Red
ff|cc|ee|Infra-White
ff|cc|ff|Sugar Chic
ff|cd|73|Grandis
ff|cd|9d|Melon Sprinkle
ff|cd|a8|Orenju Ogon Koi
ff|cd|af|Blushing Cherub
ff|ce|79|Apricot Glow
ff|ce|81|Egg Yolk Yellow
ff|ce|be|Powder Puff Pink
ff|cf|00|Fluorescent Orange
ff|cf|09|Bright Saffron
ff|cf|48|Sunglow Gecko
ff|cf|53|Melted Butter
ff|cf|60|Golden Moray Eel
ff|cf|65|Chickadee
ff|cf|73|Banana Bread
ff|cf|ab|Peach Juice
ff|cf|dc|Pale Pink
ff|cf|f1|Shampoo
ff|d1|00|Electric Glow
ff|d1|5c|Radler
ff|d1|af|Papaya Whip
ff|d1|df|Light Pink
ff|d2|9d|Dreams of Peach
ff|d2|a0|Apricot Fool
ff|d2|a9|Opalescent Coral
ff|d2|b9|Peachy Bon-Bon
ff|d2|c1|Simply Delicious
ff|d3|00|Yellow Tang
ff|d3|01|Inca Yellow
ff|d3|43|Python Yellow
ff|d3|cf|Girlie
ff|d4|00|Cyber Yellow
ff|d4|79|Cantaloupe
ff|d5|9a|Caramel Finish
ff|d5|a7|Nevada Morning
ff|d5|d1|Pink Clay
ff|d6|37|Flirtatious
ff|d6|62|Aspen Gold
ff|d6|78|Yuma Gold
ff|d6|7b|Salomie
ff|d6|9f|Fuzzy Navel
ff|d6|b8|Curtsy
ff|d6|d1|Bleached Coral
ff|d6|dd|No Need to Blush
ff|d7|00|Gold
ff|d7|89|Workout Routine
ff|d7|9d|August Morning
ff|d7|9f|Blushing Peach
ff|d7|a0|Frangipani
ff|d7|a5|Fresh Apricot
ff|d7|cf|Shy Girl
ff|d7|d0|Tea Party
ff|d8|00|School Bus Yellow
ff|d8|4d|Tuscan Sun
ff|d8|b1|Light Peach
ff|d8|dc|Satin Ribbon
ff|d8|f0|Sweet Sachet
ff|d9|0f|Simpsons Yellow
ff|d9|78|Spiced Butternut
ff|d9|a6|Speak To Me
ff|d9|aa|Peach Cider
ff|d9|d6|Forgotten Pink
ff|da|03|Sunflower Yellow
ff|da|29|Vibrant Yellow
ff|da|68|Golden Nectar
ff|da|b9|Peach Puff
ff|da|dc|Strawberry Blonde
ff|da|e8|Creamy Axolotl
ff|da|e9|Mimi Pink
ff|db|00|Sizzling Sunrise
ff|db|4f|Kuchinashi Yellow
ff|db|58|Yriel Yellow
ff|db|e5|Pink Perfume
ff|db|eb|Rose Glow
ff|dc|00|Summer Sun
ff|dc|41|Sunny Side Up
ff|dc|9e|South Shore Sun
ff|dc|b7|Peachy Sand
ff|dc|cc|Glazed Sugar
ff|dc|d2|Soft Orange Bloom
ff|dc|d6|Peach Schnapps
ff|dd|00|Super Saiyan
ff|dd|11|Gingerline
ff|dd|22|Gangsters Gold
ff|dd|49|Conifer Blossom
ff|dd|99|Butter Cupcake
ff|dd|9d|Valley Flower
ff|dd|aa|Sarcoline
ff|dd|b5|Tunisian Stone
ff|dd|bb|Christmas Rose
ff|dd|c7|Coral Kiss
ff|dd|ca|Unbleached Silk
ff|dd|cc|Carrara Marble
ff|dd|cd|Peaceful Peach
ff|dd|dd|Rose Tonic
ff|dd|ee|Transparent Pink
ff|dd|f4|Silky Pink
ff|dd|ff|Sugarpills
ff|de|34|Emoji Yellow
ff|de|7b|Banana Biscuit
ff|de|9c|Precious Nectar
ff|de|a6|Organza
ff|de|ad|Navajo White
ff|de|da|Peachy Keen
ff|df|00|Golden Yellow
ff|df|01|Canary Yellow
ff|df|22|Sun Yellow
ff|df|38|Banana Farm
ff|df|46|Gargoyle Gas
ff|df|bf|Very Pale Orange
ff|df|e5|Pink Pleasure
ff|df|e8|Baby Girl
ff|e0|78|Summer Daffodil
ff|e0|7b|Ripe Pineapple
ff|e0|cb|Autumn Bloom
ff|e1|35|Banana Yellow
ff|e1|a0|Yellow Geranium
ff|e1|a3|Midday Sun
ff|e2|62|Primrose Path
ff|e2|96|Hesperide Apple Gold
ff|e2|9b|Couscous
ff|e2|b5|Parachute Silk
ff|e2|c7|Wild Maple
ff|e3|02|Vivid Yellow
ff|e3|6e|Yellow Tan
ff|e3|9b|Creme Brulee
ff|e3|cb|Pale Apricot
ff|e3|f4|Bunny Tail
ff|e4|b5|Hopi Moccasin
ff|e4|c4|Bisque
ff|e4|c6|Satin Blush
ff|e4|cd|Lumber
ff|e4|e1|Misty Rose
ff|e5|36|Highlighter
ff|e5|9d|Hello Yellow
ff|e5|ad|Pale Peach
ff|e5|b4|Mouse Nose
ff|e5|bd|Peach Smoothie
ff|e5|ed|Early Blossom
ff|e5|ef|Sweetly
ff|e6|70|Shandy
ff|e6|c3|Neutral Peach
ff|e6|e2|Olm Pink
ff|e6|e4|Pink Theory
ff|e6|ec|Nosegay
ff|e6|f1|Cherubic
ff|e7|00|Demonic Yellow
ff|e7|37|Pac-Man
ff|e7|74|Banana Peel
ff|e7|9c|First Tulip
ff|e7|a3|Sun Drenched
ff|e7|d5|Mood Lighting
ff|e7|eb|Porcelain Skin
ff|e8|bd|Creamy Apricot
ff|e8|c3|Candle Glow
ff|e8|c7|Semolina Pudding
ff|e8|e5|Sheer Rosebud
ff|e8|f4|Fairy Dust
ff|e9|89|Quack Quack
ff|e9|c5|Chess Ivory
ff|e9|c7|Barely Peach
ff|e9|e1|Translucent Silk
ff|e9|eb|Pink Sparkle
ff|e9|ed|Rose Mochi
ff|ea|70|Fuzzy Duckling
ff|ea|ac|Yellow Canary
ff|ea|eb|Pink Lemonade
ff|eb|00|Middle Yellow
ff|eb|7e|Digital Yellow
ff|eb|cd|Blanched Almond
ff|eb|d1|Delightful Peach
ff|eb|ee|Just Pink Enough
ff|eb|f2|Fairy Wings
ff|ec|27|Pico Sun
ff|ec|47|Rape Blossoms
ff|ec|c2|Urnebes Beige
ff|ec|e0|Pink Glow
ff|ec|e5|Peach Breeze
ff|ec|e9|Rose Frost
ff|ed|a2|Baby Chick
ff|ed|bc|Colonial White
ff|ed|d5|Crushed Cashew
ff|ed|f8|Partial Pink
ff|ee|00|Sailor Moon Locks
ff|ee|01|Post Yellow
ff|ee|44|Hollandaise Yellow
ff|ee|66|Caduceus Gold
ff|ee|88|Spätzle Yellow
ff|ee|a5|Sour Lemon
ff|ee|aa|Transparent Yellow
ff|ee|bb|Gnocchi Beige
ff|ee|c2|Sun Kissed
ff|ee|cc|Milk Froth
ff|ee|d2|Radiant Glow
ff|ee|dd|Enokitake Mushroom
ff|ee|e0|Soft Coral
ff|ee|ee|White Gloss
ff|ee|ff|Lovely Euphoric Delight
ff|ef|00|Tweety
ff|ef|19|Níng Méng Huáng Lemon
ff|ef|bc|Aztec Aura
ff|ef|c1|Egg White
ff|ef|c2|Summer Hue
ff|ef|cb|Golden Impression
ff|ef|d5|Biogenic Sand
ff|ef|d6|Blank Canvas
ff|ef|dd|Delicate Seashell
ff|ef|f3|Powder Puff
ff|f0|00|Yellow Rose
ff|f0|05|Flat Yellow
ff|f0|9b|Daisy Chain
ff|f0|a4|Buttered Popcorn
ff|f0|c1|Crown Point Cream
ff|f0|c4|Rich Ivory
ff|f0|db|Peach Cream
ff|f0|df|Axolotl
ff|f0|e1|Sugar Glaze
ff|f0|e3|Rice Pudding
ff|f0|ea|Strawberry Dust
ff|f0|f5|Lavender Blush
ff|f1|cf|Bird's Child
ff|f1|d5|Candlestick Point
ff|f1|d8|Escargot
ff|f1|dc|Flickering Light
ff|f1|e8|Pico Ivory
ff|f1|f1|Sefid White
ff|f2|00|Dorn Yellow
ff|f2|a0|Sun Surprise
ff|f2|c2|Creamy Corn
ff|f2|d7|Coffee Cream
ff|f2|d9|Malibu Sun
ff|f2|de|Pale Pearl
ff|f2|e4|Doeskin
ff|f2|ef|Polished Pink
ff|f3|9a|Dark Cream
ff|f3|a1|Firefly Glow
ff|f3|d5|Hazelwood
ff|f3|f0|Soft Peach Mist
ff|f3|f4|Glimpse of Pink
ff|f4|4f|Yellow Cattleya
ff|f4|7c|Yellow Salmonberry
ff|f4|9c|Banana Cream
ff|f4|a1|Candle Flame
ff|f4|b9|Swiss Cheese
ff|f4|bb|Jasmine
ff|f4|dd|Stellar Light
ff|f4|e8|What's Left
ff|f4|eb|Ambrosia Ivory
ff|f4|f2|Very Light Pink
ff|f4|f3|Coy
ff|f5|be|Gentle Yellow
ff|f5|e4|Silky Tofu
ff|f5|ee|Seashell
ff|f6|00|Cadmium Yellow
ff|f6|01|Yellow Sunshine
ff|f6|b9|Glowlight
ff|f6|c2|Spring Buttercup
ff|f6|d7|Natural Wool
ff|f6|d9|White Beach
ff|f6|da|Ivory Charm
ff|f6|de|Seashell Peach
ff|f6|e9|Apricot Ice
ff|f7|00|Lemon
ff|f7|c4|Lemon Chiffon Pie
ff|f7|d8|Alluring Light
ff|f7|df|Sushi Rice
ff|f7|e7|Sheer Peach
ff|f7|ed|Pale Nectar
ff|f8|0a|Lahn Yellow
ff|f8|d1|Baja White
ff|f8|d5|Pale Rays
ff|f8|d7|Cotton Tail
ff|f8|d9|Supernova
ff|f8|da|Daystar
ff|f8|dc|Cornsilk
ff|f8|df|Beaming Sun
ff|f8|e1|Still Morning
ff|f8|e3|Pinch of Pearl
ff|f8|e4|Sweet Frosting
ff|f8|e7|Cosmic Latte
ff|f8|ee|Satin Purse
ff|f9|17|Sunny Yellow
ff|f9|d0|Pale
ff|f9|d8|Warm Light
ff|f9|dd|Bavarian Cream
ff|f9|e2|Snug Cottage
ff|f9|e4|Magnolia
ff|f9|e7|Down Feathers
ff|f9|ec|Day Lily
ff|fa|86|Aged Plastic Casing
ff|fa|bd|Break of Day
ff|fa|c0|Lemon Sorbet
ff|fa|c1|Twinkling Lights
ff|fa|cd|Lemon Chiffon
ff|fa|e5|Lead Glass
ff|fa|ec|Tuberose
ff|fa|f0|Floral White
ff|fa|fa|Snow
ff|fb|00|Lisbon Lemon
ff|fb|05|Flash Gitz Yellow
ff|fb|a8|Lemon Slice
ff|fb|c1|Ice Lemon
ff|fb|d7|Country Summer
ff|fb|e8|Blended Light
ff|fb|ee|Frosting Cream
ff|fb|f0|Vanilla Shake
ff|fb|f8|Eyeball
ff|fc|00|Electric Yellow
ff|fc|79|Banana
ff|fc|c4|Lemon Soap
ff|fc|d3|Creamed Butter
ff|fc|d7|Sweet Butter
ff|fc|da|Cheesecake
ff|fc|db|Rice Paper
ff|fc|e3|Fioletowyi Purple
ff|fc|e4|Cuddly Yarn
ff|fc|ec|Glamour White
ff|fc|ee|Sodium Silver
ff|fd|01|Bright Yellow
ff|fd|37|Sunshine Yellow
ff|fd|74|Butter Yellow
ff|fd|78|Custard
ff|fd|d0|Yellow Urn Orchid
ff|fd|d8|Pumpkin Seed
ff|fd|dd|Spring Heat
ff|fd|eb|Sparkling Cider
ff|fd|f2|Granulated Sugar
ff|fe|40|Sponge Cake
ff|fe|71|Super Banana
ff|fe|7a|Light Yellow
ff|fe|b6|Lamenters Yellow
ff|fe|c6|Golden Wash
ff|fe|d7|Poetic Yellow
ff|fe|d8|Lit
ff|fe|d9|Sun City
ff|fe|df|Sheer Sunlight
ff|fe|e4|Buttermilk
ff|fe|e6|Lemon Ice
ff|fe|ed|Luminary
ff|ff|00|Yellow
ff|ff|05|Dusky Yellow
ff|ff|11|Duckie Yellow
ff|ff|14|Yellow Submarine
ff|ff|22|Pedestrian Lemon
ff|ff|31|Daffodil
ff|ff|33|Deep Yellow
ff|ff|44|Peppy Pineapple
ff|ff|55|Pīlā Yellow
ff|ff|66|Laser Lemon
ff|ff|77|Hive
ff|ff|7e|Ecuadorian Banana
ff|ff|81|Butter
ff|ff|84|Pale Yellow
ff|ff|88|Pale Canary
ff|ff|99|Sunburst Yellow
ff|ff|aa|Ginger Lemon Tea
ff|ff|b2|VIC 20 Creme
ff|ff|b6|Creme
ff|ff|bb|Golden Hermes
ff|ff|bf|Very Pale Yellow
ff|ff|c2|Cream
ff|ff|cb|Old Ivory
ff|ff|cc|Conditioner
ff|ff|d4|Matt White
ff|ff|dd|Parmesan
ff|ff|e0|Winter Duvet
ff|ff|e3|Lamb's Wool
ff|ff|e4|Off White
ff|ff|e5|La Luna
ff|ff|e7|Cotton Puff
ff|ff|e8|Caster Sugar
ff|ff|e9|Ice Glow
ff|ff|ea|Northern Star
ff|ff|ec|Lemon Juice
ff|ff|ee|Eburnean
ff|ff|ef|Springtime Dew
ff|ff|f0|Ivory
ff|ff|ff|White
<<<END>>>
*/
}
