Class {
	#name : 'GolapEdgeList',
	#superclass : 'SpPresenter',
	#instVars : [
		'golap',
		'nodeDropList',
		'peerNodeList'
	],
	#classVars : [
		'EmptyImage',
		'ImageRepositoryUrl'
	],
	#category : 'Golap-UI-Graph',
	#package : 'Golap-UI',
	#tag : 'Graph'
}

{ #category : 'layout' }
GolapEdgeList class >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: #nodeDropList expand: false;
		  add: #peerNodeList;
		  yourself
]

{ #category : 'accessing' }
GolapEdgeList >> golap [

	^ golap
]

{ #category : 'accessing' }
GolapEdgeList >> golap: aGolap [

	golap := aGolap
]

{ #category : 'initialization' }
GolapEdgeList >> initializePresenters [

	nodeDropList := self newDropList
		                startWithSelection;
		                display: [ :node | node name ];
		                whenSelectedItemChangedDo: [
			                self updatePeerNodeList ];
		                yourself.
	peerNodeList := self newTable
		                beMultipleSelection;
		                disableSearch;
		                addColumn: (SpStringTableColumn new
				                 width: 80;
				                 evaluated: [ :edge |
					                 golap simpleStringFor:
							                 (golap model valueAtEdge: edge) ]);
		                addColumn:
			                (SpStringTableColumn new evaluated: [ :edge |
				                 self selectedNode
					                 ifNotNil: [ :node |
					                 (edge peerOf: node)
						                 ifNotNil: #name
						                 ifNil: [ '-' ] ]
					                 ifNil: [ '-' ] ]);
		                whenSelectionChangedDo: [
		                self peerNodeSelectionChanged ];
		                contextMenu: [ self peerNodeListMenu ];
		                yourself
]

{ #category : 'updating' }
GolapEdgeList >> modelChanged [

	self updateNodeDropList
]

{ #category : 'menus' }
GolapEdgeList >> peerNodeListMenu [

	nodeDropList selectedItem ifNotNil: [ :node |
		peerNodeList selectedItem ifNotNil: [ :edge |
			^ golap globalImageMenu: (edge peerOf: node) ] ].
	^ self newMenu
]

{ #category : 'updating' }
GolapEdgeList >> peerNodeSelectionChanged [

	nodeDropList selectedItem ifNotNil: [ :node |
		golap selections:
			(peerNodeList selectedItems collect: [ :edge | edge peerOf: node ])
			, (golap selections copyWithoutAll:
					 (peerNodeList items collect: [ :edge | edge peerOf: node ])) ]
]

{ #category : 'accessing' }
GolapEdgeList >> selectedNode [

	^ [ nodeDropList selectedItem ]
		  on: SubscriptOutOfBounds
		  do: [ :ex | ex return: nil ]
]

{ #category : 'updating' }
GolapEdgeList >> updateNodeDropList [

	| selection selections |
	selection := nodeDropList selectedItem.
	selections := golap selections.
	nodeDropList items: selections.
	(selections includes: selection)
		ifTrue: [ nodeDropList selectItem: selection ]
		ifFalse: [ selections ifNotEmpty: [ nodeDropList selectIndex: 1 ] ]
]

{ #category : 'updating' }
GolapEdgeList >> updatePeerNodeList [

	self selectedNode
		ifNotNil: [ :node |
			| edges |
			edges := node edges.
			peerNodeList
				items: edges
				selectItems:
				(edges select: [ :edge |
					 golap includesSelection: (edge peerOf: node) ]) ]
		ifNil: [ peerNodeList items: #(  ) ]
]
