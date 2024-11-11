Class {
	#name : 'GolapRenderer',
	#superclass : 'Object',
	#instVars : [
		'golap',
		'visibleEdgeMinValue',
		'visibleEdgeMaxValue',
		'reallyVisibleEdges',
		'reallyVisibleNodes'
	],
	#category : 'Golap-UI-Graph',
	#package : 'Golap-UI',
	#tag : 'Graph'
}

{ #category : 'instance creation' }
GolapRenderer class >> on: aGolap [
	^ self new
		golap: aGolap;
		yourself
]

{ #category : 'accessing' }
GolapRenderer >> colorForEdge: aGolapEdge [
	| v |
	v := golap model valueAtEdge: aGolapEdge.
	v ifNil: [ ^ Color green ].
	((v between: visibleEdgeMinValue and: visibleEdgeMaxValue)
		or: [ (golap includesSelection: aGolapEdge node1)
				or: [ golap includesSelection: aGolapEdge node2 ] ])
		ifFalse: [ ^ nil ].
	^ golap colorForEdge: aGolapEdge
]

{ #category : 'accessing' }
GolapRenderer >> colorForNode: aGolapNode [
	^ golap colorForNode: aGolapNode
]

{ #category : 'accessing' }
GolapRenderer >> edgeScale [
	^ golap edgeScale
]

{ #category : 'accessing' }
GolapRenderer >> extentForLines: lines [
	^ (lines
		inject: 0
		into: [ :w :line | w max: (self font widthOfString: line) ])
		@ (lines size * self font height)
]

{ #category : 'accessing' }
GolapRenderer >> extentForName: aString [
	^ self extentForLines: (self nameIntoLines: aString)
]

{ #category : 'accessing' }
GolapRenderer >> font [
	^ golap ifNotNil: #font ifNil: [ TextStyle defaultFont ]
]

{ #category : 'drawing' }
GolapRenderer >> globalImage [
	^ self subclassResponsibility
]

{ #category : 'drawing' }
GolapRenderer >> globalImageAndMap [
	^ {self globalImage.
	self globalMap}
]

{ #category : 'accessing' }
GolapRenderer >> globalImageExtent [
	golap globalImagePane adapter
		ifNotNil: [ :w | 
			w widget
				ifNotNil: [ :pane | 
					pane extent isZero
						ifFalse: [ ^ pane extent ] ] ].
	^ 500 @ 500
]

{ #category : 'drawing' }
GolapRenderer >> globalMap [
	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapRenderer >> globalMapExtent [
	golap globalMapPane adapter
		ifNotNil: [ :w | 
			w widget
				ifNotNil: [ :pane | 
					pane extent isZero
						ifFalse: [ ^ pane extent ] ] ].
	^ 300 @ 200
]

{ #category : 'accessing' }
GolapRenderer >> golap [
	^ golap
]

{ #category : 'accessing' }
GolapRenderer >> golap: aGolap [
	golap := aGolap
]

{ #category : 'accessing' }
GolapRenderer >> isLockedNode: aGolapNode [

	^ false
]

{ #category : 'view manipulation' }
GolapRenderer >> layout [ 
	^ self subclassResponsibility 
]

{ #category : 'accessing' }
GolapRenderer >> layouter [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapRenderer >> lockNode: aGolapNode [

	
]

{ #category : 'accessing' }
GolapRenderer >> modelDo: aBlock [
	golap ifNotNil: [ golap model ifNotNil: aBlock ]
]

{ #category : 'view manipulation' }
GolapRenderer >> moveImageOffset: aPoint [
	^ self subclassResponsibility
]

{ #category : 'view manipulation' }
GolapRenderer >> moveMapOffset: aPoint [
	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapRenderer >> moveNode: aGolapNode to: aPoint [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapRenderer >> nameIntoLines: aString [
	^ aString substrings: golap class nameEndOfLineDelimiter
]

{ #category : 'accessing' }
GolapRenderer >> nodeAtPoint: aPoint [
	^ self subclassResponsibility 
]

{ #category : 'accessing' }
GolapRenderer >> nodes [
	^ golap nodes
]

{ #category : 'accessing' }
GolapRenderer >> nodesDo: aBlock [
	golap nodesDo: aBlock
]

{ #category : 'enumerating' }
GolapRenderer >> reallyVisibleNodes [

	^ reallyVisibleNodes
]

{ #category : 'enumerating' }
GolapRenderer >> reallyVisibleNodesDo: aBlock [

	reallyVisibleNodes ifNotNil: [ reallyVisibleNodes do: aBlock ]
]

{ #category : 'view manipulation' }
GolapRenderer >> resetZoom [
	^ self subclassResponsibility 
]

{ #category : 'snapshot' }
GolapRenderer >> snapshot [

	self snapshotStreamDo: [ :stream | self snapshotInto: stream ]
]

{ #category : 'snapshot' }
GolapRenderer >> snapshotInto: aStream [

	^ self subclassResponsibility
]

{ #category : 'snapshot' }
GolapRenderer >> snapshotStreamDo: aBlock [

	self subclassResponsibility
]

{ #category : 'drawing' }
GolapRenderer >> svg [
	^ self subclassResponsibility
]

{ #category : 'private' }
GolapRenderer >> updateVisibleEdgeThresholds [

	self modelDo: [ :model |
		| min max minFreq connectedNodes |
		min := 0.0.
		max := 0.0.
		minFreq := golap minFrequency.
		model ifNotNil: [
			| d |
			d := (golap visibleEdges
				      collect: [ :edge | model valueAtEdge: edge ]
				      thenSelect: [ :value |
				      value notNil and: [ value isNaN not ] ]) asArray
				     asSortedCollection.
			d ifNotEmpty: [
				min := d at:
					       (d size - 1 * golap visibleEdgeMinPercentile value)
						       rounded + 1.
				max := d at:
					       (d size - 1 * golap visibleEdgeMaxPercentile value)
						       rounded + 1 ] ].
		visibleEdgeMaxValue := max.
		visibleEdgeMinValue := min.
		golap visibleEdgeMinPercentile label:
			'min ' , visibleEdgeMinValue printString.
		golap visibleEdgeMaxPercentile label:
			'max ' , visibleEdgeMaxValue printString.
		reallyVisibleEdges := golap visibleEdges select: [ :edge |
			                      (edge node1 notNil and: [
				                       edge node1 x notNil and: [
					                       edge node2 y notNil and: [
						                       edge node2 notNil and: [
							                       edge node2 x notNil and: [
								                       edge node2 y notNil and: [
									                       (model valueAtNode: edge node1)
									                       >= minFreq and:
										                       (model valueAtNode: edge node2)
										                       > minFreq ] ] ] ] ] ]) and: [
				                      (model valueAtEdge: edge)
					                      ifNil: [ true ]
					                      ifNotNil: [ :v |
					                      v
						                      between: visibleEdgeMinValue
						                      and: visibleEdgeMaxValue ] ] ].
		connectedNodes := IdentitySet new: reallyVisibleEdges size.
		reallyVisibleEdges do: [ :edge |
			connectedNodes
				add: edge node1;
				add: edge node2 ].
		reallyVisibleNodes := Array streamContents: [ :stream |
			                      golap showsConnectedNodes ifTrue: [
				                      stream nextPutAll: connectedNodes ].
			                      self nodesDo: [ :v |
				                      (connectedNodes includes: v) ifFalse: [
					                      v isIsolated
						                      ifTrue: [
						                      golap showsIsolatedNodes ifTrue: [
							                      stream nextPut: v ] ]
						                      ifFalse: [
						                      golap showsHiddenConnectionNodes ifTrue: [
							                      stream nextPut: v ] ] ] ] ] ]
]

{ #category : 'view manipulation' }
GolapRenderer >> zoom: aNumber [
	^ self subclassResponsibility 
]

{ #category : 'view manipulation' }
GolapRenderer >> zoomCenter: aNumber [

	^ self subclassResponsibility
]

{ #category : 'view manipulation' }
GolapRenderer >> zoomIn [
	self zoom: 1.1
]

{ #category : 'view manipulation' }
GolapRenderer >> zoomInCenter [
	self zoomCenter: 1.1
]

{ #category : 'view manipulation' }
GolapRenderer >> zoomOut [
	self zoom: 1.1 reciprocal
]

{ #category : 'view manipulation' }
GolapRenderer >> zoomOutCenter [
	self zoomCenter: 1.1 reciprocal
]
