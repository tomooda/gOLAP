Class {
	#name : 'GolapMinimumSpanningTree',
	#superclass : 'Object',
	#instVars : [
		'forest',
		'ranks'
	],
	#category : 'Golap-Models-Analysis',
	#package : 'Golap-Models',
	#tag : 'Analysis'
}

{ #category : 'operations' }
GolapMinimumSpanningTree >> minimumSpanningTreeFrom: anArrayOfEdges [

	| edges result |
	edges := anArrayOfEdges sorted: #third ascending.
	forest := IdentityDictionary new.
	ranks := IdentityDictionary new.
	result := OrderedCollection new.
	edges do: [ :edge |
			self parentAt: edge first ifAbsentPut: [ edge first ].
			self parentAt: edge second ifAbsentPut: [ edge second ].
			self rankAt: edge first ifAbsentPut: [ 0 ].
			self rankAt: edge second ifAbsentPut: [ 0 ] ].
	edges do: [ :edge |
			| u v |
			u := edge first.
			v := edge second.

			(self rootAt: u) = (self rootAt: v) ifFalse: [
					result add: edge.
					self union: u with: v ].
			result size = (forest size - 1) ifTrue: [ ^ result ] ].
	^ result
]

{ #category : 'accessing' }
GolapMinimumSpanningTree >> parentAt: anObject [

	^ forest at: anObject
]

{ #category : 'accessing' }
GolapMinimumSpanningTree >> parentAt: anObject ifAbsentPut: aBlock [

	^ forest at: anObject ifAbsentPut: aBlock
]

{ #category : 'accessing' }
GolapMinimumSpanningTree >> parentAt: anObject put: anotherObject [

	^ forest at: anObject put: anotherObject
]

{ #category : 'accessing' }
GolapMinimumSpanningTree >> rankAt: anObject [

	^ ranks at: anObject
]

{ #category : 'accessing' }
GolapMinimumSpanningTree >> rankAt: anObject ifAbsentPut: aBlock [

	^ ranks at: anObject ifAbsentPut: aBlock
]

{ #category : 'accessing' }
GolapMinimumSpanningTree >> rankAt: anObject put: anInteger [

	^ ranks at: anObject put: anInteger
]

{ #category : 'accessing' }
GolapMinimumSpanningTree >> rootAt: anObject [

	| parent |
	parent := self parentAt: anObject.
	^ parent == anObject
		  ifTrue: [ anObject ]
		  ifFalse: [ self parentAt: anObject put: (self rootAt: parent) ]
]

{ #category : 'accessing' }
GolapMinimumSpanningTree >> union: node1 with: node2 [

	| root1 root2 rank1 rank2 |
	root1 := self rootAt: node1.
	root2 := self rootAt: node2.
	root1 == root2 ifTrue: [ ^ self ].
	rank1 := self rankAt: root1.
	rank2 := self rankAt: root2.
	rank1 < rank2
		ifTrue: [ self parentAt: root1 put: root2 ]
		ifFalse: [
				self parentAt: root2 put: root1.
				rank1 = rank2 ifTrue: [ self rankAt: root1 put: rank1 + 1 ] ]
]
