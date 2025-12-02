Class {
	#name : 'GolapHierarchicalClustering',
	#superclass : 'Object',
	#instVars : [
		'golapModel',
		'edges',
		'trees',
		'rank'
	],
	#category : 'Golap-Clustering-Core',
	#package : 'Golap-Clustering',
	#tag : 'Core'
}

{ #category : 'instance creation' }
GolapHierarchicalClustering class >> on: aGolapModel [

	^ self new
		  initializeWith: aGolapModel;
		  yourself
]

{ #category : 'private' }
GolapHierarchicalClustering >> computeTrees [

	| treeByNode nextTreeMap stream odds evens |
	treeByNode := IdentityDictionary new: golapModel nodes size.
	trees do: [ :tree |
		tree graphNodesDo: [ :node | treeByNode at: node put: tree ] ].
	nextTreeMap := IdentityDictionary new: trees size.
	trees do: [ :tree |
		nextTreeMap
			at: tree
			put: (GolapHierarchicalClusteringNode with: tree rank: rank) ].
	trees do: [ :tree |
		| doneNodes |
		doneNodes := (nextTreeMap at: tree) graphNodes asIdentitySet.
		tree graphNodesDo: [ :node |
			self friendsOf: node do: [ :friend |
				(doneNodes includes: friend) ifFalse: [
					| friendTree myNextTree obsoleteNextTree |
					friendTree := treeByNode at: friend.
					myNextTree := nextTreeMap at: tree.
					obsoleteNextTree := nextTreeMap at: friendTree.
					obsoleteNextTree graphNodesDo: [ :v | doneNodes add: v ].
					myNextTree merge: obsoleteNextTree.
					(nextTreeMap keys select: [ :key |
						 (nextTreeMap at: key) == obsoleteNextTree ]) do: [ :key |
						nextTreeMap at: key put: myNextTree ] ] ] ] ].
	stream := (nextTreeMap values asIdentitySet asArray sorted:
		           #score descending) readStream.
	odds := OrderedCollection new: (nextTreeMap size / 2) ceiling.
	evens := OrderedCollection new: (nextTreeMap size / 2) ceiling.
	[ stream atEnd ] whileFalse: [
		odds add: stream next.
		stream atEnd ifFalse: [ evens add: stream next ] ].
	^ evens reverse , odds
]

{ #category : 'enumerating' }
GolapHierarchicalClustering >> friendsOf: aGolapNode do: aBlock [

	aGolapNode edgesDo: [ :edge |
		(golapModel rankAtEdge: edge) <= rank ifTrue: [
			aBlock value: (edge peerOf: aGolapNode) ] ]
]

{ #category : 'enumerating' }
GolapHierarchicalClustering >> graphNodesDo: aBlock [

	golapModel nodes valuesDo: aBlock
]

{ #category : 'initialization' }
GolapHierarchicalClustering >> initializeWith: aGolapModel [

	| done |
	golapModel := aGolapModel.
	edges := OrderedCollection new.
	done := IdentitySet new: golapModel nodes size.
	golapModel nodesDo: [ :node |
		done add: node.
		node basicEdgesAndNodesDo: [ :edge :peer |
			(done includes: peer) ifFalse: [
				edges add: edge -> (golapModel valueAtEdge: edge) ] ] ].
	edges := (edges sorted: #value descending) collect: #key.
	rank := 1.
	trees := golapModel nodes asArray collect: [ :node |
		         GolapHierarchicalClusteringLeaf
			         node: node
			         score: (golapModel valueAtNode: node) ]
]

{ #category : 'accessing' }
GolapHierarchicalClustering >> rank [

	^ rank
]

{ #category : 'accessing' }
GolapHierarchicalClustering >> rank: anInteger [

	rank := rank max: anInteger.
	trees := self computeTrees
]

{ #category : 'accessing' }
GolapHierarchicalClustering >> tree [

	^ GolapHierarchicalClusteringNode withAll: trees
]
