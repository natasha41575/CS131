# Name:		Natasha Sarkar
# # Email: 	nat41575@gmail.com
# # ID:    	904743795
#
#
#

default:
	kotlinc everyNth.kt -include-runtime -d everyNth.jar

check: default
	kotlin everyNth.jar

clean:
	rm -f everyNth.jar

dist:
	tar -cvzf hw6.tar.gz Makefile everyNth.kt
