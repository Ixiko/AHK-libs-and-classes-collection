#SingleInstance Force
CoordMode, ToolTip, Screen
SetBatchLines, -1

SmallText=
(
这是一个演示程序。
this is a demo.
1234567890
qwertyuiop[]
asdfghjkl;'
zxcvbnm,./
)

LargeText=
(
The largest, most advanced rover NASA has sent to another world touched down on Mars Thursday, after a 203-day journey traversing 293 million miles (472 million kilometers). Confirmation of the successful touchdown was announced in mission control at NASA’s Jet Propulsion Laboratory in Southern California at 3:55 p.m. EST (12:55 p.m. PST).

Packed with groundbreaking technology, the Mars 2020 mission launched July 30, 2020, from Cape Canaveral Space Force Station in Florida. The Perseverance rover mission marks an ambitious first step in the effort to collect Mars samples and return them to Earth.

“This landing is one of those pivotal moments for NASA, the United States, and space exploration globally – when we know we are on the cusp of discovery and sharpening our pencils, so to speak, to rewrite the textbooks,” said acting NASA Administrator Steve Jurczyk. “The Mars 2020 Perseverance mission embodies our nation’s spirit of persevering even in the most challenging of situations, inspiring, and advancing science and exploration. The mission itself personifies the human ideal of persevering toward the future and will help us prepare for human exploration of the Red Planet.”

About the size of a car, the 2,263-pound (1,026-kilogram) robotic geologist and astrobiologist will undergo several weeks of testing before it begins its two-year science investigation of Mars’ Jezero Crater. While the rover will investigate the rock and sediment of Jezero’s ancient lakebed and river delta to characterize the region’s geology and past climate, a fundamental part of its mission is astrobiology, including the search for signs of ancient microbial life. To that end, the Mars Sample Return campaign, being planned by NASA and ESA (European Space Agency), will allow scientists on Earth to study samples collected by Perseverance to search for definitive signs of past life using instruments too large and complex to send to the Red Planet.

“Because of today’s exciting events, the first pristine samples from carefully documented locations on another planet are another step closer to being returned to Earth,” said Thomas Zurbuchen, associate administrator for science at NASA. “Perseverance is the first step in bringing back rock and regolith from Mars. We don’t know what these pristine samples from Mars will tell us. But what they could tell us is monumental – including that life might have once existed beyond Earth.”

Some 28 miles (45 kilometers) wide, Jezero Crater sits on the western edge of Isidis Planitia, a giant impact basin just north of the Martian equator. Scientists have determined that 3.5 billion years ago the crater had its own river delta and was filled with water.

The power system that provides electricity and heat for Perseverance through its exploration of Jezero Crater is a Multi-Mission Radioisotope Thermoelectric Generator, or MMRTG. The U.S. Department of Energy (DOE) provided it to NASA through an ongoing partnership to develop power systems for civil space applications.

Equipped with seven primary science instruments, the most cameras ever sent to Mars, and its exquisitely complex sample caching system – the first of its kind sent into space – Perseverance will scour the Jezero region for fossilized remains of ancient microscopic Martian life, taking samples along the way.

“Perseverance is the most sophisticated robotic geologist ever made, but verifying that microscopic life once existed carries an enormous burden of proof,” said Lori Glaze, director of NASA’s Planetary Science Division. “While we’ll learn a lot with the great instruments we have aboard the rover, it may very well require the far more capable laboratories and instruments back here on Earth to tell us whether our samples carry evidence that Mars once harbored life.”
Paving the Way for Human Missions

“Landing on Mars is always an incredibly difficult task and we are proud to continue building on our past success,” said JPL Director Michael Watkins. “But, while Perseverance advances that success, this rover is also blazing its own path and daring new challenges in the surface mission. We built the rover not just to land but to find and collect the best scientific samples for return to Earth, and its incredibly complex sampling system and autonomy not only enable that mission, they set the stage for future robotic and crewed missions.”

The Mars Entry, Descent, and Landing Instrumentation 2 (MEDLI2) sensor suite collected data about Mars’ atmosphere during entry, and the Terrain-Relative Navigation system autonomously guided the spacecraft during final descent. The data from both are expected to help future human missions land on other worlds more safely and with larger payloads.

On the surface of Mars, Perseverance’s science instruments will have an opportunity to scientifically shine. Mastcam-Z is a pair of zoomable science cameras on Perseverance’s remote sensing mast, or head, that creates high-resolution, color 3D panoramas of the Martian landscape. Also located on the mast, the SuperCam uses a pulsed laser to study the chemistry of rocks and sediment and has its own microphone to help scientists better understand the property of the rocks, including their hardness.

Located on a turret at the end of the rover’s robotic arm, the Planetary Instrument for X-ray Lithochemistry (PIXL) and the Scanning Habitable Environments with Raman & Luminescence for Organics & Chemicals (SHERLOC) instruments will work together to collect data on Mars’ geology close-up. PIXL will use an X-ray beam and suite of sensors to delve into a rock’s elemental chemistry. SHERLOC’s ultraviolet laser and spectrometer, along with its Wide Angle Topographic Sensor for Operations and eNgineering (WATSON) imager, will study rock surfaces, mapping out the presence of certain minerals and organic molecules, which are the carbon-based building blocks of life on Earth.

The rover chassis is home to three science instruments, as well. The Radar Imager for Mars’ Subsurface Experiment (RIMFAX) is the first ground-penetrating radar on the surface of Mars and will be used to determine how different layers of the Martian surface formed over time. The data could help pave the way for future sensors that hunt for subsurface water ice deposits.

Also with an eye on future Red Planet explorations, the Mars Oxygen In-Situ Resource Utilization Experiment (MOXIE) technology demonstration will attempt to manufacture oxygen out of thin air – the Red Planet’s tenuous and mostly carbon dioxide atmosphere. The rover’s Mars Environmental Dynamics Analyzer (MEDA) instrument, which has sensors on the mast and chassis, will provide key information about present-day Mars weather, climate, and dust.

Currently attached to the belly of Perseverance, the diminutive Ingenuity Mars Helicopter is a technology demonstration that will attempt the first powered, controlled flight on another planet.

Project engineers and scientists will now put Perseverance through its paces, testing every instrument, subsystem, and subroutine over the next month or two. Only then will they deploy the helicopter to the surface for the flight test phase. If successful, Ingenuity could add an aerial dimension to exploration of the Red Planet in which such helicopters serve as a scouts or make deliveries for future astronauts away from their base.

Once Ingenuity’s test flights are complete, the rover’s search for evidence of ancient microbial life will begin in earnest.

“Perseverance is more than a rover, and more than this amazing collection of men and women that built it and got us here,” said John McNamee, project manager of the Mars 2020 Perseverance rover mission at JPL. “It is even more than the 10.9 million people who signed up to be part of our mission. This mission is about what humans can achieve when they persevere. We made it this far. Now, watch us go.”
)

Text:=LargeText
gosub, performance

Text:=SmallText
gosub, performance

ExitApp

performance:
	; 显示位置更新+动态内容 1782新 12211老
	计时()
	loop, 150
	{
		n+=2
		ellipsis:="`n"
		loop, % Mod(n,20)+1
			ellipsis.="."
		btt(Text ellipsis, n, n)
	}
	btt()
	计时()
ExitApp
	计时()
	loop, 50
	{
		n++
		ellipsis:="`n"
		loop, % Mod(n,20)+1
			ellipsis.="."
		ToolTip, %Text%%ellipsis%, %n%, %n%
	}
	ToolTip
	计时()
	; ---------------------------------


	; 显示位置更新+静态内容 40.42新 9685老
	计时()
	loop, 50
	{
		n++
		btt(Text, n, n)
	}
	btt()
	计时()

	计时()
	loop, 50
	{
		n++
		ToolTip, %Text%, %n%, %n%
	}
	ToolTip
	计时()
	; ---------------------------------


	; 显示位置固定+静态内容 5.67新 6356老
	计时()
	loop, 50
	{
		btt(Text,100,100)
	}
	btt()
	计时()

	计时()
	loop, 50
	{
		ToolTip, %Text%,100,100
	}
	ToolTip
	计时()
	; ---------------------------------
return

计时()
{
	Static
	if (CounterBefore="")
	{
		DllCall("QueryPerformanceFrequency", "Int64*", freq)
		, DllCall("QueryPerformanceCounter", "Int64*", CounterBefore)
	}
	else
	{
		DllCall("QueryPerformanceCounter", "Int64*", CounterAfter)
		, 耗时:=(CounterAfter - CounterBefore) / freq * 1000
		, CounterBefore:=""
		MsgBox, 4096, elapsed time, % Format("{1} ms`r`nOR`r`n{2} m {3} s", 耗时, Floor(耗时/1000/60), Round(Mod(耗时/1000,60)))
	}
}