class_name CallableOnTick

var function : Callable
var tick : int

func is_good_tick(current_tick):
	return tick == current_tick
	
func call_function():
	function.call()
