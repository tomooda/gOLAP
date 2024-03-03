Class {
	#name : #GolapHierarchicalClusteringNode,
	#superclass : #GolapHierarchicalClusteringTree,
	#instVars : [
		'trees'
	],
	#category : #'Golap-Clustering'
}

{ #category : #'instance creation' }
GolapHierarchicalClusteringNode class >> with: aGolapHierarchicalClusteringTree [

	^ self withAll: { aGolapHierarchicalClusteringTree }
]

{ #category : #'instance creation' }
GolapHierarchicalClusteringNode class >> withAll: aCollectionOfGolapTree [

	^ self new
		  setTrees: aCollectionOfGolapTree;
		  yourself
]

{ #category : #adding }
GolapHierarchicalClusteringNode >> add: aGolapHierarchicalClusteringTree score: aNumber [

	trees add: aGolapHierarchicalClusteringTree.
	aGolapHierarchicalClusteringTree parent: self.
	score := score + aNumber
]

{ #category : #merging }
GolapHierarchicalClusteringNode >> empty [

	trees := Array new.
	score := 0
]

{ #category : #testing }
GolapHierarchicalClusteringNode >> isNode [

	^ true
]

{ #category : #enumerating }
GolapHierarchicalClusteringNode >> leavesDo: aBlock [

	trees do: [ :tree | tree leavesDo: aBlock ]
]

{ #category : #merging }
GolapHierarchicalClusteringNode >> merge: aGolapHierarchicalClusteringNode [

	trees := trees , aGolapHierarchicalClusteringNode trees.
	aGolapHierarchicalClusteringNode trees do: [ :tree |
		tree parent: self ].
	score := score + aGolapHierarchicalClusteringNode score.
	aGolapHierarchicalClusteringNode empty
]

{ #category : #enumerating }
GolapHierarchicalClusteringNode >> nodesDo: aBlock [

	aBlock value: self.
	trees do: [ :tree | tree nodesDo: aBlock ]
]

{ #category : #accessing }
GolapHierarchicalClusteringNode >> oneVertex [

	^ trees ifNotEmpty: [ :t | t first oneVertex ] ifEmpty: [ nil ]
]

{ #category : #printing }
GolapHierarchicalClusteringNode >> printOn: aStream [

	self vertices
		do: [ :vertex | aStream nextPutAll: vertex name ]
		separatedBy: [ aStream cr ]
]

{ #category : #private }
GolapHierarchicalClusteringNode >> setTrees: aCollectionOfGolapTree [

	trees := aCollectionOfGolapTree asArray.
	trees do: [ :tree | tree parent: self ].
	score := aCollectionOfGolapTree
		         inject: 0
		         into: [ :sum :tree | sum + tree score ]
]

{ #category : #accessing }
GolapHierarchicalClusteringNode >> trees [

	^ trees
]
