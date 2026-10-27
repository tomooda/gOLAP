Class {
	#name : 'GolapBinaryHeapNode',
	#superclass : 'Object',
	#traits : 'TComparable',
	#classTraits : 'TComparable classTrait',
	#instVars : [
		'id',
		'priority',
		'left',
		'right',
		'parent',
		'nodes'
	],
	#category : 'Golap-Models-Analysis',
	#package : 'Golap-Models',
	#tag : 'Analysis'
}

{ #category : 'instance creation' }
GolapBinaryHeapNode class >> priority: aMagnitude id: anObject nodes: aDictionary [

	^ self new
		  priority: aMagnitude;
		  id: anObject;
		  nodes: aDictionary;
		  yourself
]

{ #category : 'instance creation' }
GolapBinaryHeapNode class >> withAll: anArrayOfAssociation [

	^ anArrayOfAssociation
		  ifNotEmpty: [
				  | mp nodes |
				  mp := Dictionary new: anArrayOfAssociation size.
				  nodes := (anArrayOfAssociation collect: [ :assoc | self priority: assoc value id: assoc key nodes: mp ]) sorted.
				  nodes doWithIndex: [ :node :i |
						  | leftIdx rightIdx |
						  leftIdx := 2 * i.
						  rightIdx := 2 * i + 1.
						  leftIdx <= nodes size ifTrue: [ node left: (nodes at: leftIdx) ].
						  rightIdx <= nodes size ifTrue: [ node right: (nodes at: rightIdx) ].
						  i > 1 ifTrue: [ node parent: (nodes at: i // 2) ].
						  mp at: node id put: node ].
				  nodes at: 1 ]
		  ifEmpty: [ nil ]
]

{ #category : 'comparing' }
GolapBinaryHeapNode >> < aComparable [
	"Answer whether the receiver is less than the argument."

	^ priority < aComparable priority or: [ priority = aComparable priority and: [ id < aComparable id ] ]
]

{ #category : 'comparing' }
GolapBinaryHeapNode >> = aComparable [
	"Compare the receiver with the argument and answer with true if the
	receiver is equal to the argument. Otherwise answer false."

	^ id = aComparable id
]

{ #category : 'accessing' }
GolapBinaryHeapNode >> id [

	^ id
]

{ #category : 'accessing' }
GolapBinaryHeapNode >> id: anObject [

	id := anObject
]

{ #category : 'accessing' }
GolapBinaryHeapNode >> left [

	^ left
]

{ #category : 'accessing' }
GolapBinaryHeapNode >> left: aGolapBinaryHeapNode [

	left := aGolapBinaryHeapNode
]

{ #category : 'accessing' }
GolapBinaryHeapNode >> nodeAt: anObject ifPresent: presentBlock [

	^ nodes at: anObject ifPresent: presentBlock
]

{ #category : 'accessing' }
GolapBinaryHeapNode >> nodes [

	^ nodes
]

{ #category : 'accessing' }
GolapBinaryHeapNode >> nodes: aDictionary [

	nodes := aDictionary
]

{ #category : 'accessing' }
GolapBinaryHeapNode >> parent [

	^ parent
]

{ #category : 'accessing' }
GolapBinaryHeapNode >> parent: aGolapBinaryHeapNode [

	parent := aGolapBinaryHeapNode
]

{ #category : 'operations' }
GolapBinaryHeapNode >> pop [

	| node theId next root |
	theId := id.
	root := self.
	node := self siftDown.
	next := node left ifNil: [ node right ].
	self == node
		ifTrue: [
				root := next.
				next ifNotNil: [ next parent: nil ] ]
		ifFalse: [
				| p |
				p := node parent.
				p left == node
					ifTrue: [ p left: next ]
					ifFalse: [ p right: next ].
				next ifNotNil: [ next parent: p ] ].
	nodes removeKey: theId.
	^ root
]

{ #category : 'printing' }
GolapBinaryHeapNode >> printOn: aStream [

	aStream nextPutAll: 'Heap(id: ' , id printString , ', priority: ' , priority printString , ')'
]

{ #category : 'accessing' }
GolapBinaryHeapNode >> priority [

	^ priority
]

{ #category : 'accessing' }
GolapBinaryHeapNode >> priority: anInteger [

	priority := anInteger
]

{ #category : 'accessing' }
GolapBinaryHeapNode >> right [

	^ right
]

{ #category : 'accessing' }
GolapBinaryHeapNode >> right: aGolapBinaryHeapNode [

	right := aGolapBinaryHeapNode
]

{ #category : 'operations' }
GolapBinaryHeapNode >> siftDown [

	| node |
	node := self.
	[ node left notNil and: [ node right notNil ] ] whileTrue: [
			| next |
			next := node left min: node right.
			node
				id: next id;
				priority: next priority.
			nodes at: node id put: node.
			node := next ].
	^ node
]

{ #category : 'operations' }
GolapBinaryHeapNode >> updatePriorityWith: aBlock [

	| theId node newPriority parentNode |
	node := self.
	newPriority := aBlock cull: node priority.
	theId := id.

	[
		parentNode := node parent.
		parentNode notNil and: [
			newPriority < parentNode priority or: [ newPriority = parentNode priority and: [ theId < parentNode id ] ] ] ] whileTrue: [
			node priority: parentNode priority.
			node id: parentNode id.
			nodes at: node id put: node.
			node := parentNode ].

	node priority: newPriority.
	node id: theId.
	nodes at: theId put: node
]
