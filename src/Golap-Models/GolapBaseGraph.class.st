Class {
	#name : 'GolapBaseGraph',
	#superclass : 'Object',
	#instVars : [
		'nodes',
		'edges'
	],
	#category : 'Golap-Models-Base-Graph',
	#package : 'Golap-Models',
	#tag : 'Base-Graph'
}

{ #category : 'accessing' }
GolapBaseGraph >> edges [

	^ edges
]

{ #category : 'enumerating' }
GolapBaseGraph >> edgesDo: aBlock [

	edges do: aBlock
]

{ #category : 'initialization' }
GolapBaseGraph >> initialize [

	super initialize.
	nodes := Array new.
	edges := Array new
]

{ #category : 'accessing' }
GolapBaseGraph >> nodes [

	^ nodes
]

{ #category : 'enumerating' }
GolapBaseGraph >> nodesDo: aBlock [

	nodes do: aBlock
]

{ #category : 'accessing' }
GolapBaseGraph >> numberOfEdges [

	^ edges size
]

{ #category : 'accessing' }
GolapBaseGraph >> numberOfNodes [

	^ nodes size
]

{ #category : 'private' }
GolapBaseGraph >> readEdgeDataframe: edgeDataframe idColumn: aString and: anotherString [

	edges := Array streamContents: [ :stream |
			         edgeDataframe do: [ :row |
					         | node1 node2 |
					         node1 := row at: aString ifAbsent: [ nil ].
					         node2 := row at: anotherString ifAbsent: [ nil ].
					         (node1 notNil and: [
						          node2 notNil and: [ node1 ~~ node2 ] ]) ifTrue: [
						         stream nextPut:
							         (GolapBaseEdge node1: node1 node2: node2 data: row) ] ] ]
]

{ #category : 'private' }
GolapBaseGraph >> readNodeDataframe: nodeDataframe idColumn: aString nameColumn: anotherString [

	| newNodes |
	newNodes := Dictionary new: nodeDataframe size.
	nodeDataframe withIndexDo: [ :row :index |
			| id name |
			id := row at: aString ifAbsent: [ index ].
			name := (row at: anotherString ifAbsent: [ id ]) asString.
			newNodes
				at: id asString
				ifAbsentPut: [ GolapBaseNode id: id name: name data: row ] ].
	nodes := newNodes values asArray
]

{ #category : 'private' }
GolapBaseGraph >> readServerDataframe: aDataFrame [

	| newNodes newEdges |
	aDataFrame columnNames: (aDataFrame columnNames collect: [ :string |
				 (string includes: $%)
					 ifTrue: [ string copyFrom: 1 to: (string indexOf: $%) - 1 ]
					 ifFalse: [ string ] ]).
	newNodes := Dictionary new.
	newEdges := OrderedCollection new: aDataFrame size.
	aDataFrame do: [ :data |
			| id1 |
			id1 := data at: 'node1'.
			newNodes at: id1 ifAbsentPut: [
					GolapBaseNode
						id: id1 asString
						name: (data at: 'node1n')
						data: { ('frequency' -> (data at: 'frequency1')) } asDictionary ].
			(data at: 'node2') ifNotNil: [ :id2 |
					newNodes at: id2 ifAbsentPut: [
							GolapBaseNode
								id: id2 asString
								name: (data at: 'node2n')
								data:
								{ ('frequency' -> (data at: 'frequency2')) } asDictionary ].
					newEdges add: (GolapBaseEdge node1: id1 node2: id2 data: data) ] ].
	nodes := newNodes values asArray.
	edges := newEdges asArray
]
