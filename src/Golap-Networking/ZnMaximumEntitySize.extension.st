Extension { #name : #ZnMaximumEntitySize }

{ #category : #'*Golap-Networking' }
ZnMaximumEntitySize >> default [
	"By default, allow for entities of up to 16 Mb to be read from streams"
	
	^ 256 * 1024 * 1024
]
