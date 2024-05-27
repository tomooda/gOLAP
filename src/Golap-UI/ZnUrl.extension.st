Extension { #name : 'ZnUrl' }

{ #category : '*Golap-UI' }
ZnUrl >> retrieveBinaryContents [
	"Download and return the resource that I refer to.
	This will typically return a String or a ByteArray.
	If something goes wrong, an exception will be signalled."

	" 'http://zn.stfx.eu/zn/numbers.txt' asZnUrl retrieveContents. "

	^ self performOperation: #retrieveBinaryContents
]
