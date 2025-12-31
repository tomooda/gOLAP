Class {
	#name : 'GolapHierarchicalClusteringLeaf',
	#superclass : 'GolapHierarchicalClusteringTree',
	#instVars : [
		'id'
	],
	#category : 'Golap-Clustering-Core',
	#package : 'Golap-Clustering',
	#tag : 'Core'
}

{ #category : 'instance creation' }
GolapHierarchicalClusteringLeaf class >> id: anObject score: aNumber [

	^ self new
		  setId: anObject score: aNumber;
		  yourself
]

{ #category : 'enumerating' }
GolapHierarchicalClusteringLeaf >> atRank: anInteger do: aBlock [

	aBlock value: self
]

{ #category : 'enumerating' }
GolapHierarchicalClusteringLeaf >> childrenDo: aBlock [

	
]

{ #category : 'testing' }
GolapHierarchicalClusteringLeaf >> hasChild: aTree [

	^ false
]

{ #category : 'accessing' }
GolapHierarchicalClusteringLeaf >> id [

	^ id
]

{ #category : 'testing' }
GolapHierarchicalClusteringLeaf >> isEmpty [

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
GolapHierarchicalClusteringLeaf >> oneLeaf [

	^ self
]

{ #category : 'printing' }
GolapHierarchicalClusteringLeaf >> printOn: aStream [
	aStream nextPutAll: id
]

{ #category : 'accessing' }
GolapHierarchicalClusteringLeaf >> rank [

	^ 0
]

{ #category : 'accessing' }
GolapHierarchicalClusteringLeaf >> rank: anInteger [
]

{ #category : 'private' }
GolapHierarchicalClusteringLeaf >> removeAllBut: aCollection [

	
]

{ #category : 'private' }
GolapHierarchicalClusteringLeaf >> setId: anObject score: aNumber [

	id := anObject.
	score := aNumber
]

{ #category : 'accessing' }
GolapHierarchicalClusteringLeaf >> size [

	^ 1
]

{ #category : 'accessing' }
GolapHierarchicalClusteringLeaf >> sort [

	
]

{ #category : 'accessing' }
GolapHierarchicalClusteringLeaf >> trees [

	^ #(  )
]
