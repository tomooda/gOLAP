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
		tree idsDo: [ :id |
			treeByNode at: (golapModel nodeAt: id) put: tree ] ].
	nextTreeMap := IdentityDictionary new: trees size.
	trees do: [ :tree |
		nextTreeMap
			at: tree
			put: (GolapHierarchicalClusteringNode with: tree rank: rank) ].
	trees do: [ :tree |
		| doneIds |
		doneIds := (nextTreeMap at: tree) asArray asIdentitySet.
		tree idsDo: [ :id |
			self friendsOf: (golapModel nodeAt: id) do: [ :friend |
				(doneIds includes: friend id) ifFalse: [
					| friendTree myNextTree obsoleteNextTree |
					friendTree := treeByNode at: friend.
					myNextTree := nextTreeMap at: tree.
					obsoleteNextTree := nextTreeMap at: friendTree.
					obsoleteNextTree idsDo: [ :obsoleteId | doneIds add: obsoleteId ].
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
	trees := golapModel nodes asArray
		         reject: #isIsolated
		         thenCollect: [ :node |
			         GolapHierarchicalClusteringLeaf
				         id: node id
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
