#!/usr/bin/perl

## Version 2.5 removes all 2.4 features, and instead adds some sickness stuff ##
## Version 2.3 added lineages, and tightened up the herd stuff ##
## Version 2.2 is where I try to add some 'herd mentality features' ##

#use warnings;
use strict;
use Statistics::R;
my $R = Statistics::R->new();

## Program defaults ##
my ($max_days,$max_x,$max_y,$day,$current_id,$image) = (2500,1000,1000,1,1,0);

## Grass species attributes ##
my ($g_start,$g_disperse,$g_disperse_chance,$g_seeds,$g_seed_age,$g_growth,$g_seed_days,$g_max_species,$g_death,$g_disease_chance) = (250,100,150,15,25,1,25,1500,100,1000);
my ($grass_alive,$dead_grass,$current_grass,$eaten_grass,$g_repositioned);
$grass_alive = $dead_grass = $current_grass = $eaten_grass = $g_repositioned = 0;

## Grass individual arrays ##
my (%g_living,@g_x,@g_y,@g_age,@g_parent,@g_last_seed,@g_lineage,@g_disease);

## Prey species attributes ##
my ($p_start,$p_vision,$p_lookout,$p_disperse,$p_baby_age,$p_last_baby,$p_baby_number,$p_full,$p_starve,$p_fullbaby,$p_max_species,$p_death,$p_disperse_chance,$p_sickdeath,$p_spread) = (25,35,15,25,50,75,3,85,25,60,1250,175,15,10,5); ## max usually ~125
my ($prey_alive,$dead_prey,$total_prey,$current_prey,$starved_prey,$prey_babies,$eaten_prey,$p_repositioned,$p_sickdead);
$prey_alive = $dead_prey = $current_prey = $starved_prey = $prey_babies = $eaten_prey = $p_repositioned = $p_sickdead = 0;

## Prey individual arrays ##
my (%p_living,%p_sick,@p_x,@p_y,@p_age,@p_parent,@p_weight,@p_fullness,@p_lastbaby,@p_lineage,@p_foodfound,@p_wander,@p_disease);

## Predator species attributes ##
my ($w_start,$w_vision,$w_disperse,$w_baby_age,$w_last_baby,$w_baby_number,$w_full,$w_starve,$w_fullbaby,$w_max_species,$w_death,$w_disperse_chance,$w_eatdays) = (10,30,25,75,75,2,80,25,85,30,350,10,3); ## max usually ~25
my ($wolf_alive,$dead_wolf,$total_wolf,$current_wolf,$starved_wolf,$wolf_babies);
$wolf_alive = $dead_wolf = $current_wolf = $starved_wolf = $wolf_babies = 0;

## Predator individual arrays ##
my (%w_living,@w_x,@w_y,@w_age,@w_parent,@w_weight,@w_fullness,@w_lastbaby,@w_lastate,@w_lineage);

## Starting species ##
while ($current_grass < $g_start) {
	my $start_x = int(rand($max_x));
	my $start_y = int(rand($max_y));
	$g_living{$current_id} = "grass"; 
	$g_x[$current_id] = $start_x;
  $g_y[$current_id] = $start_y;
	$g_age[$current_id] = int(rand(100));
	$g_parent[$current_id] = 0;
	$g_lineage[$current_id] = 0;
	$g_last_seed[$current_id] = 0;
	$g_disease[$current_id] = int(rand($g_disease_chance));
	$current_id++;
  $current_grass++;
}

while ($current_prey < $p_start) {
	my $start_x = int(rand($max_x));
	my $start_y = int(rand($max_y));
	$p_living{$current_id} = "prey"; 
	$p_x[$current_id] = $start_x;
  $p_y[$current_id] = $start_y;
	$p_age[$current_id] = int(rand($p_death));
	$p_parent[$current_id] = 0;
	$p_lineage[$current_id] = 0;
	$p_weight[$current_id] = 100;
	$p_fullness[$current_id] = 100;
	$p_lastbaby[$current_id] = 0;
	$p_wander[$current_id] = int((rand($p_disperse + 10)) - (($p_disperse + 5)/2)); ## This adds a preference to move in a direction for a species, in case it is ever the leader of a herd ##
	$current_id++;
  $current_prey++;	
}

while ($current_wolf < $w_start) {
	my $start_x = int(rand($max_x));
	my $start_y = int(rand($max_y));
	$w_living{$current_id} = "wolf"; 
	$w_x[$current_id] = $start_x;
  $w_y[$current_id] = $start_y;
	$w_age[$current_id] = int(rand($w_death));
	$w_parent[$current_id] = 0;
	$w_lineage[$current_id] = 0;
	$w_weight[$current_id] = 100;
	$w_fullness[$current_id] = 100;
	$w_lastbaby[$current_id] = 0;
	$w_lastate[$current_id] = 0;
	$current_id++;
  $current_wolf++;	
}

print STDERR "DAY\tGRASS\tPREY\tWOLF\n";

## Day loop ##
while ($day < $max_days) {

	## Grass first ##
	my $diseased_grass = 0;
	foreach my $grass (sort keys %g_living) {
		if ($g_disease[$grass] == 1) {
			$diseased_grass++;
		}
	}
	
	my (@grassa,@grassb,@diseasegrassa,@diseasegrassb);
	my $grass_total = scalar keys %g_living;
	my $prey_total = scalar keys %p_living;
	my $wolf_total = scalar keys %w_living;
	print "***$day\t$grass_total\t$diseased_grass\t$prey_total\t$wolf_total\n";
	
	if (int(rand(3)) == 1) {
		$g_living{$current_id} = "grass";
		$g_x[$current_id] = int(rand($max_x));
    $g_y[$current_id] = int(rand($max_y));
		$g_age[$current_id] = 0;
		$g_parent[$current_id] = 0;
		$g_lineage[$current_id] = "0";
		$g_last_seed[$current_id] = $day;
		$g_disease[$current_id] = int(rand($g_disease_chance));
		$current_id++;  
  }
	
	foreach my $grass (sort keys %g_living) {
		## Grow older ##
		$g_age[$grass]++;
		
		## Die if too old ##
		if ($g_age[$grass] > $g_death) {
			delete $g_living{$grass};
			$dead_grass++;
			$g_lineage[$grass] = "$g_lineage[$grass]\,d$day=OLD";
		}
		
		## Spring up randomly if out of bounds ##
		elsif (($g_x[$grass] > $max_x) || ($g_y[$grass] > $max_y) 
           || ($g_x[$grass] < 0) || ($g_y[$grass] < 0)) {

			$g_x[$grass] = int(rand($max_x));
			$g_y[$grass] = int(rand($max_y));
			$g_repositioned++;
		}
		
		## Else if greater than a certain age, then maybe spread ##
		else {

			my $should_it_disperse = int(rand($g_disperse_chance));
			if (($should_it_disperse == 1) && ($g_age[$grass] > $g_seed_age) 
          && ($grass_total < $g_max_species) 
          && (($day - $g_last_seed[$grass]) > $g_seed_days)) {

				my $seeds_to_disperse = int(rand($g_seeds));
				my $seeds_dispersed = 0;

				while ($seeds_dispersed < $seeds_to_disperse) {
					my $newx = $g_x[$grass] + int(rand($g_disperse) - ($g_disperse/2));
					my $newy = $g_y[$grass] + int(rand($g_disperse) - ($g_disperse/2));
					$g_living{$current_id} = "grass";
					$g_x[$current_id] = $newx;
          $g_y[$current_id] = $newy;
					$g_age[$current_id] = 0;
					$g_parent[$current_id] = $grass;
					$g_lineage[$current_id] = "$g_lineage[$grass]\,d$day=$grass";
					$g_last_seed[$current_id] = $day;
					$g_disease[$current_id] = int(rand($g_disease_chance));
					$current_id++;
          $current_grass++;
          $seeds_dispersed++;
        }
        $g_last_seed[$grass] = $day;
			}

			if ($g_disease[$grass] == 1) {
				push(@diseasegrassa,$g_x[$grass]);
				push(@diseasegrassb,$g_y[$grass]);
			} else {
				push(@grassa,$g_x[$grass]);
				push(@grassb,$g_y[$grass]);
			}
		}
	}
	
	## Now do the prey shit ##
	
	my (@preya,@preyb,@sickpreya,@sickpreyb);
	$grass_total = scalar keys %g_living;
	$prey_total = scalar keys %p_living;
	$wolf_total = scalar keys %w_living;
	
	foreach my $prey (sort keys %p_living) {
		## Grow older ##
		$p_age[$prey]++;

		## Die if the prey has been sick for too long ##
		if (($day - $p_disease[$prey] > $p_sickdeath) && ($p_disease[$prey] ne '')) {
			delete $p_living{$prey};
			delete $p_sick{$prey};
			print "\t$prey just died of a horrible stomach ache\n";
			
			## And make all the grass around it sick ##
			foreach my $grass (sort keys %g_living) {
				if ((($g_x[$grass] - $p_x[$prey]) < $p_spread) && (($p_x[$prey] - $g_x[$grass]) < $p_spread)) {
					if ((($g_y[$grass] - $p_y[$prey]) < $p_spread) && (($p_y[$prey] - $g_y[$grass]) < $p_spread)) {
						$g_disease[$grass] = 1;
					}
				}
			}
			$p_sickdead++;
		}
		
		## Grow in size, and get a little less full ##
		$p_weight[$prey] = ($p_weight[$prey] + ($p_weight[$prey] * 0.005));
		$p_fullness[$prey] = $p_fullness[$prey] * 0.989;
		$p_foodfound[$prey] = 'no';
		
	## Death decision tree ##
		
		## Die if too old ##
		if ($p_age[$prey] > $p_death) {
			delete $p_living{$prey};
			delete $p_sick{$prey};
			$dead_prey++;
			$p_lineage[$prey] = "$p_lineage[$prey]\,d$day=OLD";
			print "\tPrey $prey got too old, and died\n";
		}
		
		## Pop up on the other side if out of bounds ##
		elsif (($p_x[$prey] > $max_x) || ($p_y[$prey] > $max_y) || ($p_x[$prey] < 0) || ($p_y[$prey] < 0)) {
			if ($p_x[$prey] > $max_x) {
				$p_x[$prey] = $p_x[$prey] - $max_x;
			}
			if ($p_y[$prey] > $max_y) {
				$p_y[$prey] = $p_y[$prey] - $max_y;
			}
			if ($p_x[$prey] < 0) {
				$p_x[$prey] = $p_x[$prey] + $max_x;
			}
			if ($p_y[$prey] < 0) {
				$p_y[$prey] = $p_y[$prey] + $max_y;
			}
			$p_repositioned++;
		}
		
		## Die if too hungry ##
		elsif ($p_fullness[$prey] < $p_starve) {
			delete $p_living{$prey};
			delete $p_sick{$prey};
			$starved_prey++;
			$p_lineage[$prey] = "$p_lineage[$prey]\,d$day=STARVED";
			print "\tPrey $prey got too hungry, and died\n";
		}
		
	## Food decision tree ##
		else {
			$wolf_total = scalar keys %w_living;
			$grass_total = scalar keys %g_living;
		
			## Add searching for predator here ##
			my $wolf_present = 0; my $wolf_search = 0;
			while (($wolf_present == 0) && ($wolf_search < $wolf_total)) {
				foreach my $wolf (sort keys %w_living) {
					if ((($w_x[$wolf] - $p_x[$prey]) < $p_lookout) && (($p_x[$prey] - $w_x[$wolf]) < $p_lookout)) {
						if ((($w_y[$wolf] - $p_y[$prey]) < $p_lookout) && (($p_y[$prey] - $w_y[$wolf]) < $p_lookout)) {
							$wolf_present = $wolf;
						}
					}
					$wolf_search++;
				}
			}
			
			## Is there food near by ##
			my $food_present = 0; my $grass_search = 0; my $disease = 0;
			while (($food_present == 0) && ($grass_search < $grass_total)) {
				foreach my $grass (sort keys %g_living) {
					if ((($g_x[$grass] - $p_x[$prey]) < $p_vision) && (($p_x[$prey] - $g_x[$grass]) < $p_vision)) {
						if ((($g_y[$grass] - $p_y[$prey]) < $p_vision) && (($p_y[$prey] - $g_y[$grass]) < $p_vision)) {
							$food_present = $grass;
							$disease = $g_disease[$grass];
							$p_foodfound[$prey] = 'yes';   ## Flag that this animal has found food recently ##
						}
					}
					$grass_search++;
				}
			}
			## Decide whether to run or eat ##
			
			if ($wolf_present != 0) {
				## Run away ##
					if ($w_x[$wolf_present] > $p_x[$prey]) {
						$p_x[$prey] = $p_x[$prey] - int(rand(20));
					} else {
						$p_x[$prey] = $p_x[$prey] + int(rand(20));
					}
					if ($w_y[$wolf_present] > $p_y[$prey]) {
						$p_y[$prey] = $p_y[$prey] - int(rand(20));
					} else {
						$p_y[$prey] = $p_y[$prey] + int(rand(20));
					}
					
			} elsif ($food_present != 0) {

				#print "Animal $prey should eat $food_present! Animal is $p_fullness[$prey] hungry\n";

				## If animal is hungry, eat ##
				
				if ($p_fullness[$prey] < $p_full) {
					#print "\tanimal $prey will eat $food_present!\n";
					#print "current fullness = $p_fullness[$prey]";
					my $fullness_gain = 7.5;
#					my $fullness_gain = 50*($g_age[$food_present]/$p_weight[$prey]);
					$p_fullness[$prey] = $p_fullness[$prey] + $fullness_gain;
					
				## Get sick if the grass is sick ##
					if ($disease == 1) {
						$p_disease[$prey] = $day;
						print "\tPrey $prey just ate some diseased grass and got sick\n";
						$p_sick{$prey} = 'sick';
					}
				
				## Take over the x,y coordinates of the grass eaten, since the prey needs to move there ##
					$p_x[$prey] = $g_x[$food_present];
					$p_y[$prey] = $g_y[$food_present];
					delete $g_living{$food_present};
					$g_lineage[$current_id] = "$g_lineage[$food_present]\,d$day=EATEN";
					$eaten_grass++;
				}
				
				## Otherwise, inch towards the food ##
				else {
					$p_x[$prey] = ($p_x[$prey] + $p_x[$prey] + $g_x[$food_present]) / 3;
					$p_y[$prey] = ($p_y[$prey] + $p_y[$prey] + $g_y[$food_present]) / 3;
				}
				
			}
			
			## But, if there is no food, then you better move, sucka!! Move towards an older prey, so they have less chance of being eaten ##
			else {

				my $prey_present = 0; my $prey_search = 0; my $prey_amount = scalar keys %p_living;
				while (($prey_present == 0) && ($prey_search < $prey_amount)) {
					foreach my $close_prey (keys %p_living) {
						if ((($p_x[$close_prey] - $p_x[$prey]) < $p_vision) && (($p_x[$prey] - $p_x[$close_prey]) < $p_vision)){
							if ((($p_y[$close_prey] - $p_y[$prey]) < $p_vision) && (($p_y[$prey] - $p_y[$close_prey]) < $p_vision)){
								if ($p_foodfound[$close_prey] eq 'yes') {
									$prey_present = $close_prey;
								} elsif (($close_prey > $prey) && ($close_prey != $prey)) {
									$prey_present = $close_prey;
								}
							}
						}
						$prey_search++;
					}
				}
				if ($prey_present > 0) {
					$p_x[$prey] = $p_x[$prey_present] + int(rand(10) - (5));
					$p_y[$prey] = $p_y[$prey_present] + int(rand(10) - (5));
				} else {
					$p_x[$prey] = ($p_x[$prey] + int(rand($p_disperse) - ($p_disperse/2))) + $p_wander[$current_id];
					$p_y[$prey] = ($p_y[$prey] + int(rand($p_disperse) - ($p_disperse/2))) + $p_wander[$current_id];
					
				}
			}
		}

		## If sick, make everyone around you sick ##
		if ($p_disease[$prey] ne '') {
			foreach my $close_prey (keys %p_living) {
				if ((($p_x[$close_prey] - $p_x[$prey]) < $p_spread) && (($p_x[$prey] - $p_x[$close_prey]) < $p_spread) && ($close_prey ne $prey) && ($p_sick{$close_prey} ne 'sick')){
					if ((($p_y[$close_prey] - $p_y[$prey]) < $p_spread) && (($p_y[$prey] - $p_y[$close_prey]) < $p_spread)) {
						$p_disease[$close_prey] = $day;
						$p_sick{$close_prey} = 'sick';
						print "\tPrey $prey just made $close_prey sick\n";
					}
				}
			}
		}
		
		
	## Baby decision tree ##
		my $should_it_have_a_baby = int(rand($p_disperse_chance));
		if (($prey_total < $p_max_species) && ($should_it_have_a_baby == 1) && (($day - $p_lastbaby[$prey]) > $p_last_baby) && ($p_fullness[$prey] > $p_fullbaby) && ($p_age[$prey] > $p_baby_age)) {
			my $babies_to_have = int(rand($p_baby_number));
			my $babies_had = 0;
			while ($babies_had < $babies_to_have) {
				my $newx = $p_x[$prey] + int(rand($p_disperse) - ($p_disperse/2));
				my $newy = $p_y[$prey] + int(rand($p_disperse) - ($p_disperse/2));
				$p_living{$current_id} = "prey"; 
				$p_x[$current_id] = $newx; $p_y[$current_id] = $newy;
				$p_age[$current_id] = 0;
				$p_parent[$current_id] = $prey;
				$p_lineage[$current_id] = "$p_lineage[$prey]\,d$day=$prey";
				$p_weight[$current_id] = 100;
				$p_fullness[$current_id] = 100;
				$p_lastbaby[$current_id] = $day;
				$current_id++;$current_prey++;$prey_babies++;$babies_had++;
			}
			if ($babies_to_have == 0) {
				##
			} elsif ($babies_to_have == 1) {
				print "\tPrey $prey just had $babies_to_have baby\n";
			} else {
				print "\tPrey $prey just had $babies_to_have babies\n";
			}
		}
	
		## Only add to the graph if it isn't sick ##	
		if ($p_disease[$prey] eq '') {
			push(@preya,$p_x[$prey]);
			push(@preyb,$p_y[$prey]);
		}
	}

	## Here goes the predator stuff ##
	my (@wolfa,@wolfb);
	$grass_total = scalar keys %g_living;
	$prey_total = scalar keys %p_living;
	$wolf_total = scalar keys %w_living;
	
	foreach my $wolf (sort keys %w_living) {
		## Grow older ##
		$w_age[$wolf]++;
		
		## Grow in size, and get a little less full ##
		$w_weight[$wolf] = ($w_weight[$wolf] + ($w_weight[$wolf] * 0.01));
		$w_fullness[$wolf] = $w_fullness[$wolf] * 0.995;
		
	## Death decision tree ##
		
		## Die if too old ##
		if ($w_age[$wolf] > $w_death) {
			delete $w_living{$wolf};
			$dead_wolf++;
			$w_lineage[$wolf] = "$w_lineage[$wolf]\,d$day=OLD";
			print "\tPredator $wolf just died from old age\n";
		}
		
		## Move to the middle if out of bounds, and bring a blade of grass with it ##
		elsif (($w_x[$wolf] > $max_x) || ($w_y[$wolf] > $max_y) || ($w_x[$wolf] < 0) || ($w_y[$wolf] < 0)) {
			$w_x[$wolf] = $max_x/2;
			$w_y[$wolf] = $max_y/2;
			$g_living{$current_id} = "grass";
			$g_x[$current_id] = $max_x/2; $g_y[$current_id] = $max_y/2;
			$g_age[$current_id] = 0;
			$g_parent[$current_id] = 0;
			$g_lineage[$current_id] = 0;
			$g_last_seed[$current_id] = $day;
			$g_disease[$current_id] = int(rand($g_disease_chance));
			$current_id++; 
		}
		
		## Die if too hungry ##
		elsif ($w_fullness[$wolf] < $w_starve) {
			delete $w_living{$wolf};
			$starved_wolf++;
			$w_lineage[$wolf] = "$w_lineage[$wolf]\,d$day=STARVED";
			print "\tPredator $wolf just died from hunger\n";
		}
	
	## Food decision tree ##
		else {
			$prey_total = scalar keys %p_living;
			## Search for food to eat ##
			my $food_present = 0; my $prey_search = 0;
			while (($food_present == 0) && ($prey_search < $prey_total)) {
				foreach my $prey (sort keys %p_living) {
					if ((($p_x[$prey] - $w_x[$wolf]) < $w_vision) && (($w_x[$wolf] - $p_x[$prey]) < $w_vision)){
						if ((($p_y[$prey] - $w_y[$wolf]) < $w_vision) && (($w_y[$wolf] - $p_y[$prey]) < $w_vision)){
							$food_present = $prey;
						}
					}
					$prey_search++;
				}
			}
			
			if ((($day - $w_lastate[$wolf]) > $w_eatdays) && ($food_present > 0)) {
				#print "animal $prey should eat $food_present! animal is $p_fullness[$prey] hungry\n";

				## If animal is hungry, eat ##
				if ($w_fullness[$wolf] < $w_full) {
					$w_fullness[$wolf] = 100;
					$w_lastate[$wolf] = $day;
				
				## Take over the x,y coordinates of the prey eaten, since the predator needs to move there ##
					$w_x[$wolf] = $p_x[$food_present];
					$w_y[$wolf] = $p_y[$food_present];
					delete $p_living{$food_present};
					delete $p_sick{$food_present};
					$p_lineage[$current_id] = "$p_lineage[$food_present]\,d$day=EATEN";
					print "\tPredator $wolf just ate prey $food_present\n";
					$eaten_prey++;
				}
				
				## Otherwise, move a little closer, by a fourth the distance ##
				$w_x[$wolf] = (($w_x[$wolf] + $w_x[$wolf] + $w_x[$wolf] + $p_x[$food_present]) / 4);
				$w_y[$wolf] = (($w_y[$wolf] + $w_y[$wolf] + $w_y[$wolf] + $p_y[$food_present]) / 4);
			}
			
			## But, if there is no food, then you better move, sucka!! #
			else {
				$w_x[$wolf] = ($w_x[$wolf] + int(rand($w_disperse) - ($w_disperse/2)));
				$w_y[$wolf] = ($w_y[$wolf] + int(rand($w_disperse) - ($w_disperse/2)));
			}
		}

	## Baby decision tree ##
		my $should_it_have_a_baby = int(rand($w_disperse_chance));
		if (($wolf_total < $w_max_species) && ($should_it_have_a_baby == 1) && (($day - $w_lastbaby[$wolf]) > $w_last_baby) && ($w_fullness[$wolf] > $w_fullbaby) && ($w_age[$wolf] > $w_baby_age)) {
			my $babies_to_have = int(rand($w_baby_number));
			my $babies_had = 0;
			while ($babies_had < $babies_to_have) {
				my $newx = $w_x[$wolf] + int(rand($w_disperse) - ($w_disperse/2));
				my $newy = $w_y[$wolf] + int(rand($w_disperse) - ($w_disperse/2));
				$w_living{$current_id} = "wolf"; 
				$w_x[$current_id] = $newx; $w_y[$current_id] = $newy;
				$w_age[$current_id] = 0;
				$w_parent[$current_id] = $wolf;
				$w_lineage[$current_id] = "$w_lineage[$wolf]\,d$day=$wolf";
				$w_weight[$current_id] = 100;
				$w_fullness[$current_id] = 100;
				$w_lastbaby[$current_id] = $day;
				$current_id++;$current_wolf++;$wolf_babies++;$babies_had++;
				#print "$prey had baby # $current_id\n";
			}
			if ($babies_to_have == 0) {
				##
			} elsif ($babies_to_have == 1) {
				print "\tPredator $wolf just had $babies_to_have baby\n";
			} else {
				print "\tPredator $wolf just had $babies_to_have babies\n";
			}		
		}
	
	
	
		push(@wolfa,$w_x[$wolf]);
		push(@wolfb,$w_y[$wolf]);
	}
	foreach my $sick (sort keys %p_sick) {
		push(@sickpreya,$p_x[$sick]);
		push(@sickpreyb,$p_y[$sick]);
	}
	## Running totals ##
	$prey_total = scalar keys %p_living;
	$wolf_total = scalar keys %w_living;
	
	if ($image == 1) { ## Can add "modulus" component if necessary ##
		if (($prey_total != 0) || ($wolf_total != 0)) {
    		$R->run(qq`jpeg(file = "jpg/$day.jpg",width = $max_x, height = $max_y)`);
			$R->set('grassx', \@grassa);
       		$R->set('grassy', \@grassb);
       		$R->run(qq`plot(grassx,grassy,pch = 3, cex = 1,col="green",ylim=c(0,$max_y),xlim=c(0,$max_x),main="$day")`);
       		$R->set('preyx', \@preya);
	        $R->set('preyy', \@preyb);
			$R->run(q`points(preyx,preyy,pch = 9, cex = .6,col="blue")`);
	        $R->set('wolfx', \@wolfa);
	        $R->set('wolfy', \@wolfb);
	        $R->run(q`points(wolfx,wolfy,pch = 9, cex = .6,col="red")`);
	        $R->set('sickx', \@sickpreya);
	        $R->set('sicky', \@sickpreyb);
	        $R->run(q`points(sickx,sicky,pch = 4, cex = 1.5,col="black")`);
			$R->set('diseasex', \@diseasegrassa);
			$R->set('diseasey', \@diseasegrassb);
	        $R->run(q`points(diseasex,diseasey,pch = 3, cex = 1.5,col="red")`);
			$R->run(q`dev.off()`);
		}
    }
	$day++;
}

## Some final stats ##
print STDERR "\nDEAD GRASS=$dead_grass\nPREY DEAD OF OLD AGE=$dead_prey\nEATEN GRASS=$eaten_grass\nSTARVED PREY=$starved_prey\nPREY BABIES=$prey_babies\nREPOSITIONED PREY=$p_repositioned\nREPOSITIONED GRASS=$g_repositioned\nPREY EATEN=$eaten_prey\nPREY SICK DEATH=$p_sickdead\n";

#foreach my $prey (sort keys %p_living) {
#	print "BUNNY = $prey\t$p_lineage[$prey]\n";
#}

#foreach my $wolf (sort keys %w_living) {
#	print "WOLF = $wolf\t$w_lineage[$wolf]\n";
#}

#foreach my $prey (@p_lineage) {
#	if ($prey ne '') {
#		print "BUNNY=$prey\n";
#	}
#}

#foreach my $wolf (@w_lineage) {
#	if ($wolf ne '') {
#		print "WOLF=$wolf\n";
#	}
#}
