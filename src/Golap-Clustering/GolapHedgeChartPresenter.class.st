Class {
	#name : 'GolapHedgeChartPresenter',
	#superclass : 'GolapHierarchicalClusteringPresenter',
	#category : 'Golap-Clustering-Hedge',
	#package : 'Golap-Clustering',
	#tag : 'Hedge'
}

{ #category : 'private' }
GolapHedgeChartPresenter >> friendScoreBetween: aGolapNode1 and: aGolapNode2 [

	| golapModel edge score friend1 friend2 |
	golapModel := golap model.
	edge := aGolapNode1 edgeTo: aGolapNode2 ifAbsent: [ ^ nil ].
	score := golapModel valueAtEdge: edge.
	friend1 := 1.
	aGolapNode1 edgesDo: [ :edge1 |
		edge == edge1 ifFalse: [
			(golapModel valueAtEdge: edge1) > score ifTrue: [
				friend1 := friend1 + 1 ] ] ].
	friend2 := 1.
	aGolapNode2 edgesDo: [ :edge2 |
		edge == edge2 ifFalse: [
			(golapModel valueAtEdge: edge2) > score ifTrue: [
				friend2 := friend2 + 1 ] ] ].
	^ friend1 max: friend2
]

{ #category : 'accessing' }
GolapHedgeChartPresenter >> title [

	^ 'Hedge Chart'
]

{ #category : 'updating' }
GolapHedgeChartPresenter >> updateCanvas [

	| canvas markers terminals y ystep |
	canvas := self canvas.
	canvas shapes do: #remove.
	markers := golap allMarkerColors.
	terminals := OrderedCollection new: golap model nodes size.
	tree allLeaves doWithIndex: [ :leaf :index |
		| graphNode box |
		graphNode := leaf graphNode.
		box := RSBox new
			       position: index * 100 @ 0;
			       extent: 90 @ 90;
			       color: (self colorForNode: graphNode);
			       model: leaf;
			       yourself.
		box @ (GolapNodeInteraction on: self).
		terminals add: leaf -> box position.
		canvas addShape: box ].
	canvas shapes do: [ :box |
		box model isLeaf ifTrue: [
			| position |
			position := box position + (0 @ 50).
			markers do: [ :c |
				canvas addShape: (RSBox new
						 extent: 90 @ 30;
						 position: position;
						 color: ((box model graphNode hasMarker: c)
								  ifTrue: [ c ]
								  ifFalse: [ Color transparent ]);
						 model: (self markerModelForNode: box model graphNode color: c)).
				position := position + (0 @ 30) ] ] ].

	y := 0.
	ystep := terminals size * 100 * 0.4 / (tree maxDepth + 1).
	[ terminals notEmpty ] whileTrue: [
		| nextTerminals |
		y := y - ystep.
		nextTerminals := OrderedCollection new: terminals size.
		terminals do: [ :assoc |
			| node position |
			node := assoc key.
			position := assoc value.
			node parent ifNotNil: [ :parent |
				(nextTerminals notEmpty and: [ nextTerminals last key == parent ])
					ifFalse: [ nextTerminals add: parent -> OrderedCollection new ].
				nextTerminals last value add: node -> position ] ].
		terminals := OrderedCollection new: nextTerminals size.
		nextTerminals do: [ :assoc |
			| parent assocs parentPosition |
			parent := assoc key.
			assocs := assoc value value.
			parentPosition := ((assocs collect: #value) collect: #x) average
			                  @ y.
			assocs do: [ :a |
				| node position bezier |
				node := a key.
				position := a value.
				bezier := (RSBezier newFrom: position to: parentPosition)
					          model: node;
					          controlPoints: {
							          position.
							          (position x @ parentPosition y).
							          parentPosition };
					          capRound;
					          width:
						          ((self edgeWidthForScore: node score) * 4) ceiling;
					          color: Color gray;
					          yourself.
				bezier @ (GolapEdgeInteraction on: self).
				canvas addShape: bezier ].
			terminals add: parent -> parentPosition ] ].
	canvas @ (GolapCanvasController on: self).
	self zoomToFit
]
