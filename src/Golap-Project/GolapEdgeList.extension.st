Extension { #name : 'GolapEdgeList' }

{ #category : '*Golap-Project' }
GolapEdgeList >> asJSON [

	^ {
		  ('node-selection' -> nodeDropList selectedItem).
		  ('edge-selection'
		   -> (peerNodeList selectedItem ifNotNil: [ :edge |
					    {
						    edge node1 id.
						    edge node2 id } ])) } asDictionary
]

{ #category : '*Golap-Project' }
GolapEdgeList >> fromJSON: aDictionary [

	self updateNodeDropList.
	aDictionary
		at: 'node-selection'
		ifPresent: [ :object | nodeDropList selectItem: object ];
		at: 'edge-selection' ifPresent: [ :arrayOrNil |
				arrayOrNil ifNotNil: [
							| id1 id2 |
							id1 := arrayOrNil first.
							id2 := arrayOrNil second.
							(peerNodeList items
								 detect: [ :edge |
										 (edge node1 = id1 and: [ edge node2 = id2 ]) or: [
												 edge node1 = id1 and: [ edge node2 = id2 ] ] ]
								 ifNone: [ nil ]) ifNotNil: [ :edge |
									peerNodeList selectItem: edge ] ] ]
]
