Extension { #name : 'GolapEdgesAppearance' }

{ #category : '*Golap-Project' }
GolapEdgesAppearance >> asJSON [

	| json |
	json := Dictionary new.
	^ json
]

{ #category : '*Golap-Project' }
GolapEdgesAppearance >> fromJSON: aDictionary [

	self updateEvaluators.
	self updateFriend
]
