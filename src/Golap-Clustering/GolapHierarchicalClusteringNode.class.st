Class {
	#name : 'GolapHierarchicalClusteringNode',
	#superclass : 'GolapHierarchicalClusteringTree',
	#instVars : [
		'trees',
		'rank'
	],
	#category : 'Golap-Clustering-Core',
	#package : 'Golap-Clustering',
	#tag : 'Core'
}

{ #category : 'instance creation' }
GolapHierarchicalClusteringNode class >> with: aGolapHierarchicalClusteringTree [

	^ self withAll: { aGolapHierarchicalClusteringTree }
]

{ #category : 'instance creation' }
GolapHierarchicalClusteringNode class >> with: aGolapHierarchicalClusteringTree rank: anInteger [

	^ self withAll: { aGolapHierarchicalClusteringTree } rank: anInteger
]

{ #category : 'instance creation' }
GolapHierarchicalClusteringNode class >> withAll: aCollectionOfGolapTree [

	^ self new
		  setTrees: aCollectionOfGolapTree;
		  yourself
]

{ #category : 'instance creation' }
GolapHierarchicalClusteringNode class >> withAll: aCollectionOfGolapTree rank: anInteger [

	^ self new
		  setTrees: aCollectionOfGolapTree;
		  rank: anInteger;
		  yourself
]

{ #category : 'adding' }
GolapHierarchicalClusteringNode >> add: aGolapHierarchicalClusteringTree score: aNumber [

	trees add: aGolapHierarchicalClusteringTree.
	aGolapHierarchicalClusteringTree parent: self.
	score := score + aNumber
]

{ #category : 'enumerating' }
GolapHierarchicalClusteringNode >> childrenDo: aBlock [

	^ trees do: aBlock
]

{ #category : 'merging' }
GolapHierarchicalClusteringNode >> empty [

	trees := Array new.
	score := 0
]

{ #category : 'testing' }
GolapHierarchicalClusteringNode >> hasChild: aTree [

	^ trees includes: aTree
]

{ #category : 'controlling' }
GolapHierarchicalClusteringNode >> ifNode: aBlock [

	aBlock cull: self
]

{ #category : 'testing' }
GolapHierarchicalClusteringNode >> isEmpty [

	^ trees isEmpty
]

{ #category : 'testing' }
GolapHierarchicalClusteringNode >> isNode [

	^ true
]

{ #category : 'enumerating' }
GolapHierarchicalClusteringNode >> leavesDo: aBlock [

	trees do: [ :tree | tree leavesDo: aBlock ]
]

{ #category : 'merging' }
GolapHierarchicalClusteringNode >> merge: aGolapHierarchicalClusteringNode [

	trees := trees , aGolapHierarchicalClusteringNode trees.
	aGolapHierarchicalClusteringNode trees do: [ :tree |
		tree parent: self ].
	score := score + aGolapHierarchicalClusteringNode score.
	aGolapHierarchicalClusteringNode empty
]

{ #category : 'enumerating' }
GolapHierarchicalClusteringNode >> nodesDo: aBlock [

	aBlock value: self.
	trees do: [ :tree | tree nodesDo: aBlock ]
]

{ #category : 'accessing' }
GolapHierarchicalClusteringNode >> oneGraphNode [

	^ trees ifNotEmpty: [ :t | t first oneGraphNode ] ifEmpty: [ nil ]
]

{ #category : 'printing' }
GolapHierarchicalClusteringNode >> printOn: aStream [

	self graphNodes
		do: [ :node | aStream nextPutAll: node name ]
		separatedBy: [ aStream cr ]
]

{ #category : 'accessing' }
GolapHierarchicalClusteringNode >> rank [

	^ rank
]

{ #category : 'accessing' }
GolapHierarchicalClusteringNode >> rank: anInteger [

	rank := anInteger
]

{ #category : 'private' }
GolapHierarchicalClusteringNode >> removeAllBut: aCollectionOfGolapNode [

	trees := trees reject: [ :tree |
		         tree isLeaf
			         ifTrue: [
			         (aCollectionOfGolapNode includes: tree graphNode) not ]
			         ifFalse: [
				         tree
					         removeAllBut: aCollectionOfGolapNode;
					         isEmpty ] ].
	score := trees
		         inject: 0
		         into: [ :subtotal :tree | subtotal + tree score ]
]

{ #category : 'private' }
GolapHierarchicalClusteringNode >> setTrees: aCollectionOfGolapTree [

	trees := aCollectionOfGolapTree asArray.
	trees do: [ :tree | tree parent: self ].
	score := aCollectionOfGolapTree
		         inject: 0
		         into: [ :sum :tree | sum + tree score ]
]

{ #category : 'accessing' }
GolapHierarchicalClusteringNode >> size [

	^ trees inject: 0 into: [ :subtotal :tree | subtotal + tree size ]
]

{ #category : 'accessing' }
GolapHierarchicalClusteringNode >> trees [

	^ trees
]
