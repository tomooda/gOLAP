Extension { #name : 'GolapDataAggregator' }

{ #category : '*Golap-Project' }
GolapDataAggregator >> asJSON [

	^ { (self tag -> self subtag) } asOrderedDictionary
]

{ #category : '*Golap-Project' }
GolapDataAggregator class >> fromJSON: aDictionary [

	self allSubclassesDo: [ :subclass |
		subclass isAbstract not ifTrue: [
			aDictionary
				at: subclass tag
				ifPresent: [ :subtag | ^ subclass fromSubtag: subtag ] ] ].
	^ nil
]
