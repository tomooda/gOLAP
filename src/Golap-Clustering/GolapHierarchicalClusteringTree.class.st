Class {
	#name : #GolapHierarchicalClusteringTree,
	#superclass : #Object,
	#instVars : [
		'parent',
		'score'
	],
	#category : #'Golap-Clustering'
}

{ #category : #'instance creation' }
GolapHierarchicalClusteringTree class >> friendsClusterFrom: aGolapModel depth: anInteger [

	| done edges rank trees |
	edges := OrderedCollection new: aGolapModel dataframe numberOfRows.
	done := IdentitySet new: aGolapModel vertices size.
	aGolapModel verticesDo: [ :vertex |
		done add: vertex.
		vertex basicEdgesAndVerticesDo: [ :edge :peer |
			(done includes: peer) ifFalse: [
				edges add: edge -> (aGolapModel valueAtEdge: edge) ] ] ].
	edges := edges sorted: #value.
	rank := 1.
	trees := aGolapModel vertices asArray collect: [ :vertex |
		         GolapHierarchicalClusteringLeaf
			         vertex: vertex
			         score: (aGolapModel valueAtVertex: vertex) ].
	anInteger timesRepeat: [ 
		
		
		
		 ]
]

{ #category : #controlling }
GolapHierarchicalClusteringTree >> ifNode: aBlock [
]

{ #category : #testing }
GolapHierarchicalClusteringTree >> includesVertex: aGolapVertex [

	self leavesDo: [ :leaf |
		leaf vertex == aGolapVertex ifTrue: [ ^ true ] ].
	^ false
]

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
GolapHierarchicalClusteringTree >> oneVertex [

	^ self subclassResponsibility
]

{ #category : #visualization }
GolapHierarchicalClusteringTree >> openSunburst [

	| markers sunburstBuilder bezierBuilder |
	markers := OrderedCollection new.
	self verticesDo: [ :vertex |
		vertex markers do: [ :color |
			(markers includes: color) ifFalse: [ markers add: color ] ] ].
	sunburstBuilder := RSSunburstBuilder new.
	sunburstBuilder
		sliceColor: [ :slice |
			slice model isLeaf
				ifTrue: [ Color lightGray ]
				ifFalse: [ Color transparent ] ];
		explore: self using: #trees;
		build.
	sunburstBuilder shapes do: [ :shape |
		shape model isLeaf ifTrue: [
			| radius |
			radius := shape externalRadius + 1.
			markers do: [ :color |
				(shape model vertex hasMarker: color)
					ifTrue: [
						sunburstBuilder canvas addShape: (shape copy
								 innerRadius: radius;
								 externalRadius: (radius := radius + 10);
								 color: color) ]
					ifFalse: [ radius := radius + 10 ] ] ] ].
	sunburstBuilder canvas @ RSCanvasController.
	sunburstBuilder shapes @ GolapLeafPopup.
	bezierBuilder := RSLineBuilder sunburstBezier.
	bezierBuilder
		color: Color black;
		capRound;
		canvas: sunburstBuilder canvas.
	(bezierBuilder connectFrom: #parent)
		do: [ :bezier |
			bezier width: 100.0 * bezier model value score / self score ];
		@ GolapNodePopupAndClick.
	sunburstBuilder canvas open maximize.
	^ sunburstBuilder
]

{ #category : #accessing }
GolapHierarchicalClusteringTree >> parent [

	^ parent
]

{ #category : #accessing }
GolapHierarchicalClusteringTree >> parent: aGolapHierarchicalClusteringNode [

	parent := aGolapHierarchicalClusteringNode
]

{ #category : #accessing }
GolapHierarchicalClusteringTree >> score [

	^ score
]

{ #category : #accessing }
GolapHierarchicalClusteringTree >> score: aNumber [

	score := aNumber
]

{ #category : #accessing }
GolapHierarchicalClusteringTree >> trees [

	^ self subclassResponsibility
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
