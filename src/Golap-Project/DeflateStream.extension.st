Extension { #name : 'DeflateStream' }

{ #category : '*Golap-Project' }
DeflateStream >> goodMatchLength [
	"Return the length that is considered to be a 'good' match.
	Higher values will result in better compression but take more time."
	^8 "this is fastest. Best compression = 258"
]

{ #category : '*Golap-Project' }
DeflateStream >> hashChainLength [
	"Return the max. number of hash chains to traverse.
	Higher values will result in better compression but take more time."
	^4 "this is the fastest. Best compression = 4096"
]
