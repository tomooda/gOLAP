Extension { #name : 'GolapNodeMerge' }

{ #category : '*Golap-Project' }
GolapNodeMerge >> asJSON [

	| json |
	json := Dictionary new.
	self toJSON: json.
	^ json
]

{ #category : '*Golap-Project' }
GolapNodeMerge >> fromJSON: aDictionary [

	merges := aDictionary
		          at: 'merges'
		          ifPresent: [ :json |
				          (json associations collect: [ :assoc |
					           assoc key -> assoc value asSet ]) asDictionary ]
		          ifAbsent: [ Dictionary new ].
	roots := aDictionary
		         at: 'merges-roots'
		         ifPresent: #asSet
		         ifAbsent: [ Set new ]
]

{ #category : '*Golap-Project' }
GolapNodeMerge >> toJSON: aDictionary [

	aDictionary
		at: 'merges'
		put:
			(merges keys sorted collect: [ :key |
				 key -> (merges at: key) sorted ]) asOrderedDictionary.
	aDictionary at: 'merges-roots' put: roots sorted
]
