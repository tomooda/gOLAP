Class {
	#name : 'GolapNoMarker',
	#superclass : 'GolapAbstractMarker',
	#instVars : [
		'queryString',
		'nodes'
	],
	#category : 'Golap-UI-Graph',
	#package : 'Golap-UI',
	#tag : 'Graph'
}

{ #category : 'accessing' }
GolapNoMarker >> activatedIn: aGolapItemList [

	self updateNodeListIn: aGolapItemList
]

{ #category : 'adding-removing' }
GolapNoMarker >> addNode: aGolapNode [

	^ nil
]

{ #category : 'snapshot' }
GolapNoMarker >> asJSON [

	^ super asJSON
		  at: 'query' put: queryString;
		  yourself
]

{ #category : 'accessing' }
GolapNoMarker >> color [

	^ nil
]

{ #category : 'snapshot' }
GolapNoMarker >> fromJSON: aDictionary [

	aDictionary
		at: 'query'
		ifPresent: [ :string | queryString := string ]
]

{ #category : 'accessing' }
GolapNoMarker >> icon [

	^ nil
]

{ #category : 'testing' }
GolapNoMarker >> includesNodeId: anObject [

	^ nodes includes: anObject
]

{ #category : 'initialization' }
GolapNoMarker >> initialize [

	super initialize.
	queryString := ''.
	nodes := Set new
]

{ #category : 'accessing' }
GolapNoMarker >> queryString [

	^ queryString
]

{ #category : 'accessing' }
GolapNoMarker >> queryString: aString in: aGolapItemList [

	queryString := aString trim.
	self updateNodesIn: aGolapItemList.
	self updateNodeListIn: aGolapItemList
]

{ #category : 'adding-removing' }
GolapNoMarker >> removeNode: aGolapNode [

	^ nil
]

{ #category : 'updating' }
GolapNoMarker >> updateIn: aGolapItemList [

	self updateNodesIn: aGolapItemList
]

{ #category : 'updating' }
GolapNoMarker >> updateNodeListIn: aGolapItemList [

	aGolapItemList modelDo: [ :model |
			aGolapItemList nodeList
				items: (nodes asSortedCollection:
						 [ :id | model valueAtNode: (model nodeAt: id) ] descending)
				selectItems: aGolapItemList nodeList selectedItems ]
]

{ #category : 'updating' }
GolapNoMarker >> updateNodesIn: aGolapItemList [

	aGolapItemList modelDo: [ :model |
			nodes := queryString
				         ifNotEmpty: [ :query |
						         | regexs |
						         regexs := self regexesFor: query trim.
						         (model nodes
							          select: [ :node |
									          | name |
									          name := node name.
									          (regexs anySatisfy: [ :regex | regex matches: name ])
										          and: [ aGolapItemList showsNode: node ] ]
							          thenCollect: #id) asSet ]
				         ifEmpty: [
						         (model nodes
							          select: [ :node | aGolapItemList showsNode: node ]
							          thenCollect: #id) asSet ] ]
]
