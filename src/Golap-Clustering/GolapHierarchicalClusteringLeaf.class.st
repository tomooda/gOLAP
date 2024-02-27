Class {
	#name : #GolapHierarchicalClusteringLeaf,
	#superclass : #GolapHierarchicalClusteringTree,
	#instVars : [
		'vertex'
	],
	#category : #'Golap-Clustering'
}

{ #category : #'instance creation' }
GolapHierarchicalClusteringLeaf class >> vertex: aGolapVertex score: aNumber [

	^ self new
		  setVertex: aGolapVertex score: aNumber;
		  yourself
]

{ #category : #testing }
GolapHierarchicalClusteringLeaf >> isLeaf [

	^ true
]

{ #category : #enumerating }
GolapHierarchicalClusteringLeaf >> leavesDo: aBlock [

	aBlock value: self
]

{ #category : #enumerating }
GolapHierarchicalClusteringLeaf >> nodesDo: aBlock [

	
]

{ #category : #accessing }
GolapHierarchicalClusteringLeaf >> oneVertex [

	^ vertex
]

{ #category : #printing }
GolapHierarchicalClusteringLeaf >> printOn: aStream [
	aStream nextPutAll: vertex name
]

{ #category : #private }
GolapHierarchicalClusteringLeaf >> setVertex: aGolapVertex score: aNumber [

	vertex := aGolapVertex.
	score := aNumber
]

{ #category : #accessing }
GolapHierarchicalClusteringLeaf >> trees [

	^ #(  )
]

{ #category : #accessing }
GolapHierarchicalClusteringLeaf >> vertex [

	^ vertex
]
