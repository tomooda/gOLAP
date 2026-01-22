Extension { #name : 'GolapNode' }

{ #category : '*Golap-Project' }
GolapNode >> asJSON [

	^ {
		  ('id' -> self id).
		  ('name' -> self name).
		  ('data' -> self data) } asOrderedDictionary
]

{ #category : '*Golap-Project' }
GolapNode class >> fromJSON: aDictionary [

	^ self new fromJSON: aDictionary
]

{ #category : '*Golap-Project' }
GolapNode >> fromJSON: aDictionary [

	aDictionary
		at: 'data'
		ifPresent: [ :dict |
			data := DataSeries withKeys: dict keys values: dict values ];
		at: 'name' ifPresent: [ :json | self name: json ];
		at: 'id' ifPresent: [ :json | self id: json ]
]
