Extension { #name : 'GolapNoMarker' }

{ #category : '*Golap-Project' }
GolapNoMarker >> asJSON [

	^ super asJSON
		  at: 'query' put: queryString;
		  yourself
]

{ #category : '*Golap-Project' }
GolapNoMarker >> fromJSON: aDictionary [

	aDictionary
		at: 'query'
		ifPresent: [ :string | queryString := string ]
]
