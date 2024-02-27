Class {
	#name : #GolapHierarchicalClusteringTree,
	#superclass : #Object,
	#instVars : [
		'score'
	],
	#category : #'Golap-Clustering'
}

{ #category : #testing }
GolapHierarchicalClusteringTree >> isLeaf [

	^ false
]

{ #category : #testing }
GolapHierarchicalClusteringTree >> isNode [

	^ false
]

{ #category : #enumerating }
GolapHierarchicalClusteringTree >> leavesDo: aBlock [

	^ self subclassResponsibility
]

{ #category : #enumerating }
GolapHierarchicalClusteringTree >> nodesDo: aBlock [

	^ self subclassResponsibility
]

{ #category : #accessing }
GolapHierarchicalClusteringTree >> score [

	^ score
]

{ #category : #accessing }
GolapHierarchicalClusteringTree >> vertices [

	^ Array streamContents: [ :stream |
		  self verticesDo: [ :vertex | stream nextPut: vertex ] ]
]

{ #category : #enumerating }
GolapHierarchicalClusteringTree >> verticesDo: aBlock [

	self leavesDo: [ :leaf | leaf vertex ifNotNil: aBlock ]
]
