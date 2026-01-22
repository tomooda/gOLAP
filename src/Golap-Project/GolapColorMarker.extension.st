Extension { #name : 'GolapColorMarker' }

{ #category : '*Golap-Project' }
GolapColorMarker >> asJSON [

	^ super asJSON
		  at: 'color' put: colorHexString;
		  at: 'query' put: queryString;
		  yourself
]

{ #category : '*Golap-Project' }
GolapColorMarker >> fromJSON: aDictionary [

	aDictionary
		at: 'color' ifPresent: [ :string | self colorHexString: string ];
		at: 'query' ifPresent: [ :string | queryString := string ]
]
