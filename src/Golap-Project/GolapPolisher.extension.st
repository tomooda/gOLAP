Extension { #name : 'GolapPolisher' }

{ #category : '*Golap-Project' }
GolapPolisher class >> fromJSON: aDictionary [

	^ self new
		  fromJSON: aDictionary;
		  yourself
]

{ #category : '*Golap-Project' }
GolapPolisher >> fromJSON: aDictionary [

	aDictionary
		at: 'polish-repeats' ifPresent: [ :bool | repeats := bool ];
		at: 'polish-additionThreshold'
		ifPresent: [ :number | additionThreshold := number ];
		at: 'polish-removalThreshold'
		ifPresent: [ :number | removalThreshold := number ];
		at: 'polish-minClusterSize'
		ifPresent: [ :int | minClusterSize := int ]
]

{ #category : '*Golap-Project' }
GolapPolisher >> toJSON: aDictionary [

	aDictionary
		at: 'polish-repeats' put: repeats;
		at: 'polish-additionThreshold' put: additionThreshold;
		at: 'polish-removalThreshold' put: removalThreshold;
		at: 'polish-minClusterSize' put: minClusterSize
]
