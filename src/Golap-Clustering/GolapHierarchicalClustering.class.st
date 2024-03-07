Class {
	#name : #GolapHierarchicalClustering,
	#superclass : #Object,
	#instVars : [
		'golapModel',
		'edges',
		'trees',
		'rank'
	],
	#category : #'Golap-Clustering'
}

{ #category : #'instance creation' }
GolapHierarchicalClustering class >> on: aGolapModel [

	^ self new
		  initializeWith: aGolapModel;
		  yourself
]

{ #category : #private }
GolapHierarchicalClustering >> computeTrees [

	| treeByVertex nextTreeMap |
	treeByVertex := IdentityDictionary new: golapModel vertices size.
	trees do: [ :tree |
		tree verticesDo: [ :vertex | treeByVertex at: vertex put: tree ] ].
	nextTreeMap := IdentityDictionary new: trees size.
	trees do: [ :tree |
		nextTreeMap
			at: tree
			put: (GolapHierarchicalClusteringNode with: tree) ].
	trees do: [ :tree |
		| doneVertices |
		doneVertices := (nextTreeMap at: tree) vertices asIdentitySet.
		tree verticesDo: [ :vertex |
			self friendsOf: vertex do: [ :friend |
				(doneVertices includes: friend) ifFalse: [
					| friendTree myNextTree obsoleteNextTree |
					friendTree := treeByVertex at: friend.
					myNextTree := nextTreeMap at: tree.
					obsoleteNextTree := nextTreeMap at: friendTree.
					obsoleteNextTree verticesDo: [ :v | doneVertices add: v ].
					myNextTree merge: obsoleteNextTree.
					(nextTreeMap keys select: [ :key |
						 (nextTreeMap at: key) == obsoleteNextTree ]) do: [ :key |
						nextTreeMap at: key put: myNextTree ] ] ] ] ].
	^ nextTreeMap values asIdentitySet asArray
]

{ #category : #enumerating }
GolapHierarchicalClustering >> friendsOf: aGolapVertex do: aBlock [

	| index |
	index := 1.
	rank timesRepeat: [
		| edge peer |
		[ (edges at: index) hasVertex: aGolapVertex ] whileFalse: [
			index := index + 1.
			index <= edges size ifFalse: [ ^ self ] ].
		edge := edges at: index.
		peer := edge peerOf: aGolapVertex.
		((1 to: index) inject: 0 into: [ :count :i |
			 ((edges at: i) hasVertex: peer)
				 ifTrue: [ count + 1 ]
				 ifFalse: [ count ] ]) <= rank ifTrue: [ aBlock value: peer ].
		index := index + 1.
		index <= edges size ifFalse: [ ^ self ] ]
]

{ #category : #initialization }
GolapHierarchicalClustering >> initializeWith: aGolapModel [

	| done |
	golapModel := aGolapModel.
	edges := OrderedCollection new: golapModel dataframe numberOfRows.
	done := IdentitySet new: golapModel vertices size.
	golapModel verticesDo: [ :vertex |
		done add: vertex.
		vertex basicEdgesAndVerticesDo: [ :edge :peer |
			(done includes: peer) ifFalse: [
				edges add: edge -> (golapModel valueAtEdge: edge) ] ] ].
	edges := (edges sorted: #value descending) collect: #key.
	rank := 1.
	trees := golapModel vertices asArray collect: [ :vertex |
		         GolapHierarchicalClusteringLeaf
			         vertex: vertex
			         score: (golapModel valueAtVertex: vertex) ]
]

{ #category : #visualization }
GolapHierarchicalClustering >> openSunburst [

	| sb tree |
	sb := GolapSunburstBuilder new.
	sb sliceColor: [ :slice |
		slice model isLeaf
			ifTrue: [ Color darkGray ]
			ifFalse: [ Color transparent ] ].
	sb
		explore: (tree := GolapHierarchicalClusteringNode withAll: trees)
		using: #trees.
	sb build.
	sb canvas @ RSCanvasController.
	sb shapes @ RSPopup.
	RSLineBuilder sunburstBezier
		width: 3;
		color: Color black;
		markerEnd: (RSEllipse new
				 size: 6;
				 color: Color white;
				 withBorder;
				 yourself);
		canvas: sb canvas;
		connectFrom: #parent.
	sb canvas shapes do: [ :shape |
		shape isLine ifTrue: [
			shape width: 100.0 * shape model value score / tree score ] ].
	sb canvas open.
	^ sb
]

{ #category : #accessing }
GolapHierarchicalClustering >> rank [

	^ rank
]

{ #category : #accessing }
GolapHierarchicalClustering >> rank: anInteger [

	rank := rank max: anInteger.
	trees := self computeTrees
]

{ #category : #enumerating }
GolapHierarchicalClustering >> verticesDo: aBlock [

	golapModel vertices valuesDo: aBlock
]
