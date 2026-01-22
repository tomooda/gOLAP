Extension { #name : 'GolapEdge' }

{ #category : '*Golap-Project' }
GolapEdge >> asJSON [

	^ {
		  ('node1' -> self node1 id).
		  ('node2' -> self node2 id).
		  ('data' -> self data) } asOrderedDictionary
]
