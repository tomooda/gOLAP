Class {
	#name : 'GolapHierarchicalClusteringLeaf',
	#superclass : 'GolapHierarchicalClusteringTree',
	#instVars : [
		'node'
	],
	#category : 'Golap-Clustering-Core',
	#package : 'Golap-Clustering',
	#tag : 'Core'
}

{ #category : 'instance creation' }
GolapHierarchicalClusteringLeaf class >> node: aGolapNode score: aNumber [

	^ self new
		  setNode: aGolapNode score: aNumber;
		  yourself
]

{ #category : 'testing' }
GolapHierarchicalClusteringLeaf >> isLeaf [

	^ true
]

{ #category : 'enumerating' }
GolapHierarchicalClusteringLeaf >> leavesDo: aBlock [

	aBlock value: self
]

{ #category : 'accessing' }
GolapHierarchicalClusteringLeaf >> node [

	^ node
]

{ #category : 'enumerating' }
GolapHierarchicalClusteringLeaf >> nodesDo: aBlock [

	
]

{ #category : 'accessing' }
GolapHierarchicalClusteringLeaf >> oneNode [

	^ node
]

{ #category : 'printing' }
GolapHierarchicalClusteringLeaf >> printOn: aStream [
	aStream nextPutAll: node name
]

{ #category : 'private' }
GolapHierarchicalClusteringLeaf >> setNode: aGolapNode score: aNumber [

	node := aGolapNode.
	score := aNumber
]

{ #category : 'accessing' }
GolapHierarchicalClusteringLeaf >> trees [

	^ #(  )
]
