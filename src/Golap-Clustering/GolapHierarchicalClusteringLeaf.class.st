Class {
	#name : 'GolapHierarchicalClusteringLeaf',
	#superclass : 'GolapHierarchicalClusteringTree',
	#instVars : [
		'graphNode'
	],
	#category : 'Golap-Clustering-Core',
	#package : 'Golap-Clustering',
	#tag : 'Core'
}

{ #category : 'instance creation' }
GolapHierarchicalClusteringLeaf class >> node: aGolapNode score: aNumber [

	^ self new
		  setGraphNode: aGolapNode score: aNumber;
		  yourself
]

{ #category : 'enumerating' }
GolapHierarchicalClusteringLeaf >> childrenDo: aBlock [

	
]

{ #category : 'accessing' }
GolapHierarchicalClusteringLeaf >> graphNode [

	^ graphNode
]

{ #category : 'testing' }
GolapHierarchicalClusteringLeaf >> hasChild: aTree [

	^ false
]

{ #category : 'testing' }
GolapHierarchicalClusteringLeaf >> isLeaf [

	^ true
]

{ #category : 'enumerating' }
GolapHierarchicalClusteringLeaf >> leavesDo: aBlock [

	aBlock value: self
]

{ #category : 'enumerating' }
GolapHierarchicalClusteringLeaf >> nodesDo: aBlock [

	
]

{ #category : 'accessing' }
GolapHierarchicalClusteringLeaf >> oneGraphNode [

	^ graphNode
]

{ #category : 'printing' }
GolapHierarchicalClusteringLeaf >> printOn: aStream [
	aStream nextPutAll: graphNode name
]

{ #category : 'private' }
GolapHierarchicalClusteringLeaf >> setGraphNode: aGolapNode score: aNumber [

	graphNode := aGolapNode.
	score := aNumber
]

{ #category : 'accessing' }
GolapHierarchicalClusteringLeaf >> trees [

	^ #(  )
]
