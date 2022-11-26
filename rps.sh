#!/usr/bin/bash
get_player()
{
	local answer=""
	declare -a rps=("rock" "paper" "scisors")
	PS3="${1:-Player} please choose: " 
	while [[ -z "$answer" ]] ; do
		select answer in "${rps[@]}" ;
		do
			echo "$answer"
			break
		done
	done
}
get_computer()
{
	declare -a rps=("rock" "paper" "scisors")
	declare -i random=$(( RANDOM % 3 ))
	echo "${rps[random]}"
}
compare()
{
	local a="${1:? bad compare}"
	local b="${2:? bad compare}"

	# fast exit on draw
	
	[[ "$b" == "$a"    ]] &&  return 0 

	case $a in
		# rock is beaten by paper
		rock)
			[[ "$b" == "paper"   ]] && return 2
			;;
		# paper is beaten by scisors
		paper)
			[[ "$b" == "scisors" ]] && return 2
			;;
		# scisors is beaten by rock
		scisors)
			[[ "$b" == "rock" ]] && return 2
			;;
	esac
	return 1
	
}
main ()
{

	if (( players > 0 )) ; then

		for (( i=0 ; i < players ; i++ )) ; do
			pname="Player $(( i+1))"
			read -r -p "Enter name for player $pname : " name
			player_name[i]="${name:-$pname}"
		done
	fi

	declare -a player_val

	for i in 0 1 ; do
		if [[ "${player_name[$i]}" =~ "Computer" ]] ; then
			player_val[$i]=$(get_computer)
		else
			player_val[$i]=$(get_player "${player_name[$i]}" )
		fi
	done

	# compare returns 0 for a draw
	#                 1 if arg 1 wins
	#                 2 if arg 2 wins

	compare "${player_val[0]}" "${player_val[1]}" ; winner=$?

	for i in 0 1 ; do
		echo "${player_name[i]} chose ${player_val[i]}"
	done

	if [[ "$winner" == 0 ]] ; then
		printf "It was a draw\n"
	else
		printf "%s %s\n" "${player_name[winner -1]}" $"Won"
	fi
}


# Allow for multiplayer mode or for all computer players
declare -a player_name=("Computer_$(hostname)" "Computer_$(hostname)")

read -r -p "Enter number of human players: " players
[[ "${players/[[:alpha:]]}" != "${players}" ]] && players=3

while (( players < 0 || players > 2 )) ; do
	read -r -p "Enter valid number of human players(0-2): " players
	[[ "${players/[[:alpha:]]}" != "${players}" ]] && players=3
done

main "$players" "${player_name[0]}" "${player_name[1]}" 
