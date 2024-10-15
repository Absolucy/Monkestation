/datum/particle_weather/wonderland
	name = "Wonderland"
	display_name = "Wonderland"
	desc = "????????"
	particle_effect_type = /particles/weather/wonderland

/particles/weather/wonderland
	icon_state             = list("spark"=5, "spiral"=1)

	gradient               = list(0,"#54d832",1,"#1f2720",2,"#aad607",3,"#5f760d",4,"#484b3f","loop")
	color                  = 0
	color_change		   = generator("num",-5,5)
	position               = generator("box", list(-500,-256,0), list(500,500,0))
	gravity                = list(-5 -1, 0.1)
	drift                  = generator("circle", 0, 5) // Some random movement for variation
	friction               = 0.3  // shed 30% of velocity and drift every 0.1s
	//Weather effects, max values
	max_spawning           = 80
	min_spawning           = 20
	wind                   = 10
