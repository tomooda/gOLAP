Extension { #name : 'GolapBaseEdge' }

{ #category : '*Golap-Project' }
GolapBaseEdge >> asJSON [

	^ {
		  ('node1' -> node1).
		  ('node2' -> node2).
		  ('data' -> data) } asOrderedDictionary
]

{ #category : '*Golap-Project' }
GolapBaseEdge class >> fromJSON: aDictionary [

	^ self new
		  fromJSON: aDictionary;
		  yourself
]

{ #category : '*Golap-Project' }
GolapBaseEdge >> fromJSON: aDictionary [

	node1 := aDictionary at: 'node1'.
	node2 := aDictionary at: 'node2'.
	data := aDictionary at: 'data'
]
