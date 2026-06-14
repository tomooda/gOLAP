Class {
	#name : 'GolapNodeMerge',
	#superclass : 'Object',
	#instVars : [
		'roots',
		'merges'
	],
	#category : 'Golap-Models-Graph',
	#package : 'Golap-Models',
	#tag : 'Graph'
}

{ #category : 'initialization' }
GolapNodeMerge >> initialize [

	super initialize.
	roots := Set new.
	merges := Dictionary new
]

{ #category : 'accessing' }
GolapNodeMerge >> leavesAt: aString [

	^ Array streamContents: [ :stream |
		  self leavesAt: aString do: [ :id | stream nextPut: id ] ]
]

{ #category : 'accessing' }
GolapNodeMerge >> leavesAt: aString do: aBlock [

	| agenda done |
	agenda := OrderedCollection with: aString.
	done := Set new.
	[ agenda notEmpty ] whileTrue: [
			| node |
			node := agenda removeLast.
			(done includes: node) ifFalse: [
					done add: node.
					merges
						at: node
						ifPresent: [ :nodes | agenda addAll: nodes ]
						ifAbsent: [ aBlock value: node ] ] ]
]

{ #category : 'merging' }
GolapNodeMerge >> merge: aCollectionOfString into: aString [

	merges at: aString put: (Set withAll: aCollectionOfString).
	aCollectionOfString do: [ :node | roots remove: node ifAbsent: [ ] ].
	roots add: aString.
	^ aString
]

{ #category : 'accessing' }
GolapNodeMerge >> rootsAt: aString [

	^ Array streamContents: [ :stream |
		  self rootsAt: aString do: [ :id | stream nextPut: id ] ]
]

{ #category : 'accessing' }
GolapNodeMerge >> rootsAt: aString do: aBlock [

	| agenda done present |
	agenda := OrderedCollection with: aString.
	done := Set new.
	present := false.
	[ agenda notEmpty ] whileTrue: [
			| node |
			node := agenda removeLast.
			(done includes: node) ifFalse: [
					done add: node.
					(roots includes: node) ifTrue: [
							present := true.
							aBlock value: node ].
					merges keysAndValuesDo: [ :merged :contents |
						(contents includes: node) ifTrue: [ agenda addLast: merged ] ] ] ].
	present ifFalse: [ aBlock value: aString ]
]

{ #category : 'merging' }
GolapNodeMerge >> unmerge: aString [

	merges at: aString ifPresent: [ :contents |
			merges removeKey: aString ifAbsent: [ ].
			contents asArray ifNotEmpty: [ :nodes |
					merges valuesDo: [ :otherNodes |
							(otherNodes includes: aString) ifTrue: [
									otherNodes
										remove: aString ifAbsent: [ ];
										addAll: nodes ] ].
					(roots includes: aString) ifTrue: [
							nodes
								select: [ :node | merges includesKey: node ]
								thenDo: [ :node | roots add: node ] ] ] ].
	roots remove: aString ifAbsent: [ ].
	^ aString
]

{ #category : 'merging' }
GolapNodeMerge >> unmergeAll [

	merges removeAll.
	roots removeAll
]
