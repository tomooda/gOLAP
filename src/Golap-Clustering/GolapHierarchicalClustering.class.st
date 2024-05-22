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

	| treeByNode nextTreeMap |
	treeByNode := IdentityDictionary new: golapModel nodes size.
	trees do: [ :tree |
		tree nodesDo: [ :node | treeByNode at: node put: tree ] ].
	nextTreeMap := IdentityDictionary new: trees size.
	trees do: [ :tree |
		nextTreeMap
			at: tree
			put: (GolapHierarchicalClusteringNode with: tree) ].
	trees do: [ :tree |
		| doneNodes |
		doneNodes := (nextTreeMap at: tree) nodes asIdentitySet.
		tree nodesDo: [ :node |
			self friendsOf: node do: [ :friend |
				(doneNodes includes: friend) ifFalse: [
					| friendTree myNextTree obsoleteNextTree |
					friendTree := treeByNode at: friend.
					myNextTree := nextTreeMap at: tree.
					obsoleteNextTree := nextTreeMap at: friendTree.
					obsoleteNextTree nodesDo: [ :v | doneNodes add: v ].
					myNextTree merge: obsoleteNextTree.
					(nextTreeMap keys select: [ :key |
						 (nextTreeMap at: key) == obsoleteNextTree ]) do: [ :key |
						nextTreeMap at: key put: myNextTree ] ] ] ] ].
	^ nextTreeMap values asIdentitySet asArray
]

{ #category : 'enumerating' }
GolapHierarchicalClustering >> friendsOf: aGolapNode do: aBlock [

	| index |
	index := 1.
	rank timesRepeat: [
		| edge peer |
		[ (edges at: index) hasNode: aGolapNode ] whileFalse: [
			index := index + 1.
			index <= edges size ifFalse: [ ^ self ] ].
		edge := edges at: index.
		peer := edge peerOf: aGolapNode.
		((1 to: index) inject: 0 into: [ :count :i |
			 ((edges at: i) hasNode: peer)
				 ifTrue: [ count + 1 ]
				 ifFalse: [ count ] ]) <= rank ifTrue: [ aBlock value: peer ].
		index := index + 1.
		index <= edges size ifFalse: [ ^ self ] ]
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

{ #category : 'enumerating' }
GolapHierarchicalClustering >> nodesDo: aBlock [

	golapModel nodes valuesDo: aBlock
]

{ #category : 'visualization' }
GolapHierarchicalClustering >> openSunburst [

	(GolapHierarchicalClusteringNode withAll: trees) openSunburst
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
