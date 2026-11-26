Extension { #name : 'OrderedDictionary' }

{ #category : '*Golap-Project' }
OrderedDictionary >> sameJSONAs: anObject [

	^ anObject sameJSONAsDictionary: dictionary
]

{ #category : '*Golap-Project' }
OrderedDictionary >> sameJSONAsDictionary: aDictionary [

	^ dictionary = aDictionary
]
