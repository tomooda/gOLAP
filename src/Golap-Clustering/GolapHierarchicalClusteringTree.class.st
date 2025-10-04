Class {
	#name : 'GolapHierarchicalClusteringTree',
	#superclass : 'Object',
	#instVars : [
		'parent',
		'score'
	],
	#category : 'Golap-Clustering-Core',
	#package : 'Golap-Clustering',
	#tag : 'Core'
}

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> allLeaves [

	^ Array streamContents: [ :stream |
		  self leavesDo: [ :leaf | stream nextPut: leaf ] ]
]

{ #category : 'converting' }
GolapHierarchicalClusteringTree >> asArray [

	^ self graphNodes
]

{ #category : 'enumerating' }
GolapHierarchicalClusteringTree >> atRank: anInteger do: aBlock [

	^ self subclassResponsibility
]

{ #category : 'enumerating' }
GolapHierarchicalClusteringTree >> childrenDo: aBlock [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> depth [

	| depth node |
	depth := 1.
	node := parent.
	[ node notNil ] whileTrue: [
		node := node parent.
		depth := depth + 1 ].
	^ depth
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> graphNodeId [

	^ self oneGraphNode id
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> graphNodes [

	^ Array streamContents: [ :stream |
		  self graphNodesDo: [ :node | stream nextPut: node ] ]
]

{ #category : 'enumerating' }
GolapHierarchicalClusteringTree >> graphNodesDo: aBlock [

	self leavesDo: [ :leaf | leaf graphNode ifNotNil: aBlock ]
]

{ #category : 'testing' }
GolapHierarchicalClusteringTree >> hasChild: aTree [

	^ self subclassResponsibility
]

{ #category : 'testing' }
GolapHierarchicalClusteringTree >> ifEmpty: aFullBlockClosure [

	self isEmpty ifTrue: aFullBlockClosure
]

{ #category : 'controlling' }
GolapHierarchicalClusteringTree >> ifNode: aBlock [
]

{ #category : 'testing' }
GolapHierarchicalClusteringTree >> isEmpty [

	^ self subclassResponsibility
]

{ #category : 'testing' }
GolapHierarchicalClusteringTree >> isLeaf [

	^ false
]

{ #category : 'testing' }
GolapHierarchicalClusteringTree >> isNode [

	^ false
]

{ #category : 'enumerating' }
GolapHierarchicalClusteringTree >> leaves [

	^ Array streamContents: [ :stream |
		  self leavesDo: [ :leafNode | stream nextPut: leafNode ] ]
]

{ #category : 'enumerating' }
GolapHierarchicalClusteringTree >> leavesDo: aBlock [

	^ self subclassResponsibility
]

{ #category : 'enumerating' }
GolapHierarchicalClusteringTree >> leavesWithIndexDo: aBlock [

	| index |
	index := 0.
	self leavesDo: [ :leaf |
		aBlock cull: leaf cull: (index := index + 1) ]
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> maxDepth [

	^ self allLeaves
		  ifNotEmpty: [ :leaves | (leaves collect: #depth) max ]
		  ifEmpty: [ 0 ]
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> mean [

	self ifEmpty: [ ^ 0 ].
	^ self score / self size
]

{ #category : 'enumerating' }
GolapHierarchicalClusteringTree >> nodesDo: aBlock [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> oneGraphNode [

	^ self oneLeaf ifNotNil: #graphNode
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> oneLeaf [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> parent [

	^ parent
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> parent: aGolapHierarchicalClusteringNode [

	parent := aGolapHierarchicalClusteringNode
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> parentAtRank: anInteger [

	self rank >= anInteger ifTrue: [ ^ self ].
	self parent ifNil: [ ^ self ].
	^ self parent parentAtRank: anInteger
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> rank [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> rank: anInteger [

	^ self subclassResponsibility
]

{ #category : 'private' }
GolapHierarchicalClusteringTree >> removeAllBut: aCollectionOfGolapNode [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> score [

	^ score
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> score: aNumber [

	score := aNumber
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> size [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> sort [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> trees [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> treesAtRank: anInteger [

	^ Array streamContents: [ :stream |
		  self atRank: anInteger do: [ :tree | stream nextPut: tree ] ]
]
