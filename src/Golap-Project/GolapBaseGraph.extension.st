Extension { #name : 'GolapBaseGraph' }

{ #category : '*Golap-Project' }
GolapBaseGraph >> asJSON [

	| json |
	json := Dictionary new.
	self toJSON: json.
	^ json
]

{ #category : '*Golap-Project' }
GolapBaseGraph class >> fromJSON: aDictionary [

	^ self new
		  fromJSON: aDictionary;
		  yourself
]

{ #category : '*Golap-Project' }
GolapBaseGraph >> fromJSON: aDictionary [

	aDictionary
		at: 'nodes' ifPresent: [ :array |
			nodes := array collect: [ :json | GolapBaseNode fromJSON: json ] ];
		at: 'edges' ifPresent: [ :array |
			edges := array collect: [ :json | GolapBaseEdge fromJSON: json ] ]
]

{ #category : '*Golap-Project' }
GolapBaseGraph >> toJSON: aDictionary [

	aDictionary
		at: 'nodes' put: (nodes collect: #asJSON);
		at: 'edges' put: (edges collect: #asJSON)
]
