class_name Chart extends Resource
## Stores information about a track's chart.

## The track this chart is for.
@export var track:AudioStream

## Format the chart with two parts; a list of bools saying whether there's
## A single hit on a beat, and a separate where every bool is an alternating
## Start and end position/

@export var hits:PackedInt64Array
@export var holds:PackedInt64Array

## Reading bits from the packed array.
#print("PACKING BYTE ARRAY")
#var ba := PackedInt64Array([-1])
#
# Each int
#for i in range(ba.size()):
	#
	#print("BIT ", i, " -> ", ba.get(i))
	#
	#var string := ""
	#var index := 1
	# Each bit in the int
	#for j in range(63):
		#string += str(clamp(ba.get(i) & index, 0, 1))
		#
		#index *= 2
	#print(string)
#pass
