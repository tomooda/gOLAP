Extension { #name : 'GolapPolisher' }

{ #category : '*Golap-Project' }
GolapPolisher >> asJSON [

	| json |
	json := OrderedDictionary new.
	self toJSON: json.
	^ json
]

{ #category : '*Golap-Project' }
GolapPolisher class >> fromJSON: aDictionary [

	^ self new
		  fromJSON: aDictionary;
		  yourself
]

{ #category : '*Golap-Project' }
GolapPolisher >> fromJSON: aDictionary [

	aDictionary
		at: 'polishToConverge'
		ifPresent: [ :bool | polishToConverge := bool ];
		at: 'fillerThreshold' ifPresent: [ :num | fillerThreshold := num ];
		at: 'burrThreshold' ifPresent: [ :num | burrThreshold := num ];
		at: 'minClusterSize' ifPresent: [ :int | minClusterSize := int ]
]

{ #category : '*Golap-Project' }
GolapPolisher >> toJSON: aDictionary [

	aDictionary
		at: 'polishToConverge' put: polishToConverge;
		at: 'fillerThreshold' put: fillerThreshold;
		at: 'burrThreshold' put: burrThreshold;
		at: 'minClusterSize' put: minClusterSize
]
