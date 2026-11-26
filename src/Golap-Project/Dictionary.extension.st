Extension { #name : 'Dictionary' }

{ #category : '*Golap-Project' }
Dictionary >> sameJSONAs: anObject [

	^ anObject sameJSONAsDictionary: self
]

{ #category : '*Golap-Project' }
Dictionary >> sameJSONAsDictionary: aDictionary [

	^ self = aDictionary
]
