Class {
	#name : #GolapHierarchicalClusteringNode,
	#superclass : #GolapHierarchicalClusteringTree,
	#instVars : [
		'trees'
	],
	#category : #'Golap-Clustering'
}

{ #category : #'instance creation' }
GolapHierarchicalClusteringNode class >> withAll: aCollectionOfGolapTree [

	^ self new
		  setTrees: aCollectionOfGolapTree;
		  yourself
]

{ #category : #testing }
GolapHierarchicalClusteringNode >> isNode [

	^ true
]

{ #category : #enumerating }
GolapHierarchicalClusteringNode >> leavesDo: aBlock [

	trees do: [ :tree | tree leavesDo: aBlock ]
]

{ #category : #enumerating }
GolapHierarchicalClusteringNode >> nodesDo: aBlock [

	aBlock value: self.
	trees do: [ :tree | tree nodesDo: aBlock ]
]

{ #category : #private }
GolapHierarchicalClusteringNode >> setTrees: aCollectionOfGolapTree [

	trees := aCollectionOfGolapTree sorted: #score descending.
	score := aCollectionOfGolapTree
		         inject: 0
		         into: [ :sum :tree | sum + tree score ]
]

{ #category : #accessing }
GolapHierarchicalClusteringNode >> trees [

	^ trees
]
