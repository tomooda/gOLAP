Class {
	#name : 'GolapColorMarker',
	#superclass : 'GolapAbstractMarker',
	#instVars : [
		'colorHexString',
		'queryString',
		'nodes',
		'icon'
	],
	#category : 'Golap-UI-Graph',
	#package : 'Golap-UI',
	#tag : 'Graph'
}

{ #category : 'accessing' }
GolapColorMarker class >> colorHexString: aString [

	^ self new
		  colorHexString: aString;
		  yourself
]

{ #category : 'accessing' }
GolapColorMarker >> activatedIn: aGolapItemList [

	self updateNodeListIn: aGolapItemList
]

{ #category : 'adding-removing' }
GolapColorMarker >> addNode: aGolapNode [

	| patterns regexs |
	patterns := (queryString substrings: ',')
		            collect: #trim
		            thenSelect: #notEmpty.
	regexs := patterns collect: [ :pattern | self regexFor: pattern ].
	(regexs anySatisfy: [ :regex | regex matches: aGolapNode name ])
		ifFalse: [ patterns := patterns copyWith: aGolapNode name ].
	queryString := ',' join: patterns.
	nodes add: aGolapNode id.
	^ aGolapNode
]

{ #category : 'snapshot' }
GolapColorMarker >> asJSON [

	^ super asJSON
		  at: 'color' put: colorHexString;
		  at: 'query' put: queryString;
		  yourself
]

{ #category : 'accessing' }
GolapColorMarker >> color [

	^ Color fromHexString: colorHexString
]

{ #category : 'accessing' }
GolapColorMarker >> colorHexString [

	^ colorHexString
]

{ #category : 'accessing' }
GolapColorMarker >> colorHexString: aString [

	colorHexString = aString ifFalse: [
			| canvas |
			colorHexString := aString.
			icon ifNil: [ icon := Form extent: 16 @ 16 depth: 32 ].
			canvas := icon getCanvas.
			canvas fillColor: Color transparent.
			self color ifNotNil: [ :color |
				canvas frameOval: (1 @ 1 corner: 14 @ 14) width: 2 color: color ] ]
]

{ #category : 'snapshot' }
GolapColorMarker >> fromJSON: aDictionary [

	aDictionary
		at: 'color' ifPresent: [ :string | self colorHexString: string ];
		at: 'query' ifPresent: [ :string | queryString := string ]
]

{ #category : 'accessing' }
GolapColorMarker >> icon [

	^ icon
]

{ #category : 'testing' }
GolapColorMarker >> includesNodeId: anObject [

	^ nodes includes: anObject
]

{ #category : 'initialize' }
GolapColorMarker >> initialize [

	super initialize.
	queryString := ''.
	nodes := Set new
]

{ #category : 'testing' }
GolapColorMarker >> isColorMarker [

	^ true
]

{ #category : 'enumerating' }
GolapColorMarker >> nodeIdsDo: aBlock [

	nodes do: aBlock
]

{ #category : 'accessing' }
GolapColorMarker >> queryString [

	^ queryString
]

{ #category : 'accessing' }
GolapColorMarker >> queryString: aString in: aGolapItemList [

	queryString := aString trim.
	self updateNodesIn: aGolapItemList.
	self updateNodeListIn: aGolapItemList
]

{ #category : 'adding-removing' }
GolapColorMarker >> removeNode: aGolapNode [

	| patterns |
	patterns := (queryString substrings: ',')
		            collect: #trim
		            thenSelect: #notEmpty.
	patterns := patterns copyWithout: aGolapNode name.
	queryString := ',' join: patterns.
	nodes remove: aGolapNode id ifAbsent: [ ].
	^ aGolapNode
]

{ #category : 'updating' }
GolapColorMarker >> updateIn: aGolapItemList [

	self updateNodesIn: aGolapItemList
]

{ #category : 'updating' }
GolapColorMarker >> updateNodeListIn: aGolapItemList [

	aGolapItemList modelDo: [ :model |
			aGolapItemList nodeList
				items: (nodes asSortedCollection:
						 [ :id | model valueAtNode: (model nodeAt: id) ] descending)
				selectItems: (aGolapItemList golap selections collect: #id) ]
]

{ #category : 'updating' }
GolapColorMarker >> updateNodesIn: aGolapItemList [

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
				         ifEmpty: [ Set new ] ]
]
