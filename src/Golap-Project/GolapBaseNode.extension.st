Extension { #name : 'GolapBaseNode' }

{ #category : '*Golap-Project' }
GolapBaseNode >> asJSON [

	^ {
		  ('id' -> self id).
		  ('name' -> self name).
		  ('data' -> self data) } asOrderedDictionary
]

{ #category : '*Golap-Project' }
GolapBaseNode class >> fromJSON: aDictionary [

	^ self new
		  fromJSON: aDictionary;
		  yourself
]

{ #category : '*Golap-Project' }
GolapBaseNode >> fromJSON: aDictionary [

	aDictionary
		at: 'data'
		ifPresent: [ :dict |
			data := DataSeries withKeys: dict keys values: dict values ];
		at: 'name' ifPresent: [ :json | self name: json ];
		at: 'id' ifPresent: [ :json | self id: json ]
]
