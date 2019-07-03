fun <T: Any> everyNth(L: List<T>, N: Int): List<T> {
	if (N == 0) {
		return listOf<T>()
	}

	@Suppress("UNCHECKED_CAST")
	var array: Array<T> = arrayOfNulls<Any?>(L.size / N) as Array<T>
	var x = 0
	for (i in N-1..(L.size-1) step N) {
		array.set(x, L.get(i))
		x = x + 1
	}
	
	return array.toList()
}


fun main(args : Array<String>) {
	var list = listOf<Int>()
	assert( (listOf<Int>()).equals(everyNth(list, 0)) )
	println("TEST 1 SUCCESS")

	list = listOf<Int>(1)
        assert( (listOf<Int>()).equals(everyNth(list, 5)) )
        println("TEST 2 SUCCESS")

	list = listOf<Int>(1, 2, 3, 4)
	assert( (listOf<Int>(2,4)).equals(everyNth(list, 2)) )
 	println("TEST 3 SUCCESS")

	var list2 = listOf<String>("potato", "rotato", "totato")
	assert( (listOf<String>("rotato")).equals(everyNth(list2, 2)) )
	println("TEST 4 SUCCESS")

	assert( (listOf<String>("totato")).equals(everyNth(list2, 3)) )
	println("TEST 5 SUCCESS")

	assert( (list2).equals(everyNth(list2, 1)) )
	println("TEST 6 SUCCESS")
}
