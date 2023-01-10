Class {
	#name : #GolapRenderer,
	#superclass : #Object,
	#instVars : [
		'golap',
		'visibleEdgeMinValue',
		'visibleEdgeMaxValue',
		'reallyVisibleEdges',
		'reallyVisibleVertices'
	],
	#category : #'Golap-UI-Graph'
}

{ #category : #'instance creation' }
GolapRenderer class >> on: aGolap [
	^ self new
		golap: aGolap;
		yourself
]

{ #category : #accessing }
GolapRenderer >> colorForEdge: aGolapEdge [
	| v |
	v := golap model valueAtEdge: aGolapEdge.
	v ifNil: [ ^ Color green ].
	((v between: visibleEdgeMinValue and: visibleEdgeMaxValue)
		or: [ (golap includesSelection: aGolapEdge vertex1)
				or: [ golap includesSelection: aGolapEdge vertex2 ] ])
		ifFalse: [ ^ nil ].
	^ golap colorForEdge: aGolapEdge
]

{ #category : #accessing }
GolapRenderer >> colorForVertex: aGolapVertex [
	^ golap colorForVertex: aGolapVertex
]

{ #category : #accessing }
GolapRenderer >> edgeScale [
	^ golap edgeScale
]

{ #category : #accessing }
GolapRenderer >> extentForLines: lines [
	^ (lines
		inject: 0
		into: [ :w :line | w max: (self font widthOfString: line) ])
		@ (lines size * self font height)
]

{ #category : #accessing }
GolapRenderer >> extentForName: aString [
	^ self extentForLines: (self nameIntoLines: aString)
]

{ #category : #accessing }
GolapRenderer >> font [
	^ golap ifNotNil: #font ifNil: [ TextStyle defaultFont ]
]

{ #category : #drawing }
GolapRenderer >> globalImage [
	^ self subclassResponsibility
]

{ #category : #drawing }
GolapRenderer >> globalImageAndMap [
	^ {self globalImage.
	self globalMap}
]

{ #category : #accessing }
GolapRenderer >> globalImageExtent [
	golap globalImagePane adapter
		ifNotNil: [ :w | 
			w widget
				ifNotNil: [ :pane | 
					pane extent isZero
						ifFalse: [ ^ pane extent ] ] ].
	^ 500 @ 500
]

{ #category : #drawing }
GolapRenderer >> globalMap [
	^ self subclassResponsibility
]

{ #category : #accessing }
GolapRenderer >> globalMapExtent [
	golap globalMapPane adapter
		ifNotNil: [ :w | 
			w widget
				ifNotNil: [ :pane | 
					pane extent isZero
						ifFalse: [ ^ pane extent ] ] ].
	^ 300 @ 200
]

{ #category : #accessing }
GolapRenderer >> golap [
	^ golap
]

{ #category : #accessing }
GolapRenderer >> golap: aGolap [
	golap := aGolap
]

{ #category : #'view manipulation' }
GolapRenderer >> layout [ 
	^ self subclassResponsibility 
]

{ #category : #accessing }
GolapRenderer >> modelDo: aBlock [
	golap ifNotNil: [ golap model ifNotNil: aBlock ]
]

{ #category : #'view manipulation' }
GolapRenderer >> moveImageOffset: aPoint [
	^ self subclassResponsibility
]

{ #category : #'view manipulation' }
GolapRenderer >> moveMapOffset: aPoint [
	^ self subclassResponsibility
]

{ #category : #accessing }
GolapRenderer >> nameIntoLines: aString [
	^ aString substrings: golap class nameEndOfLineDelimiter
]

{ #category : #enumerating }
GolapRenderer >> reallyVisibleVerticesDo: aBlock [

	reallyVisibleVertices ifNotNil: [ reallyVisibleVertices do: aBlock ]
]

{ #category : #'view manipulation' }
GolapRenderer >> resetZoom [
	^ self subclassResponsibility 
]

{ #category : #snapshot }
GolapRenderer >> snapshot [

	self snapshotStreamDo: [ :stream | self snapshotInto: stream ]
]

{ #category : #snapshot }
GolapRenderer >> snapshotInto: aStream [

	^ self subclassResponsibility
]

{ #category : #snapshot }
GolapRenderer >> snapshotStreamDo: aBlock [

	self subclassResponsibility
]

{ #category : #drawing }
GolapRenderer >> svg [
	^ self subclassResponsibility
]

{ #category : #private }
GolapRenderer >> updateVisibleEdgeThresholds [
	self
		modelDo: [ :model | 
			| min max connectedVertices |
			min := 0.0.
			max := 0.0.
			model
				ifNotNil: [ | d |
					d := (golap visibleEdges
						collect: [ :edge | model valueAtEdge: edge ]
						thenSelect: [ :value | value notNil and: [ value isNaN not ] ])
						asArray asSortedCollection.
					d
						ifNotEmpty: [ min := d
								at: ((d size - 1) * golap visibleEdgeMinPercentile value) rounded + 1.
							max := d
								at: ((d size - 1) * golap visibleEdgeMaxPercentile value) rounded + 1 ] ].
			visibleEdgeMaxValue := max.
			visibleEdgeMinValue := min.
			golap visibleEdgeMinPercentile
				label: 'min ' , visibleEdgeMinValue printString.
			golap visibleEdgeMaxPercentile
				label: 'max ' , visibleEdgeMaxValue printString.
			reallyVisibleEdges := golap visibleEdges
				select: [ :edge | 
					(model valueAtEdge: edge)
						ifNil: [ true ]
						ifNotNil: [ :v | v between: visibleEdgeMinValue and: visibleEdgeMaxValue ] ].
			connectedVertices := IdentitySet new: reallyVisibleEdges size.
			reallyVisibleEdges
				do: [ :edge | 
					connectedVertices
						add: edge vertex1;
						add: edge vertex2 ].
			reallyVisibleVertices := Array
				streamContents: [ :stream | 
					golap showsConnectedVertices
						ifTrue: [ stream nextPutAll: connectedVertices ].
					self
						verticesDo: [ :v | 
							(connectedVertices includes: v)
								ifFalse: [ v isIsolated
										ifTrue: [ golap showsIsolatedVertices
												ifTrue: [ stream nextPut: v ] ]
										ifFalse: [ golap showsHiddenConnectionVertices
												ifTrue: [ stream nextPut: v ] ] ] ] ] ]
]

{ #category : #accessing }
GolapRenderer >> vertexAtPoint: aPoint [
	^ self subclassResponsibility 
]

{ #category : #accessing }
GolapRenderer >> vertices [
	^ golap vertices
]

{ #category : #accessing }
GolapRenderer >> verticesDo: aBlock [
	golap verticesDo: aBlock
]

{ #category : #'view manipulation' }
GolapRenderer >> zoom: aNumber [
	^ self subclassResponsibility 
]

{ #category : #'view manipulation' }
GolapRenderer >> zoomCenter: aNumber [

	^ self subclassResponsibility
]

{ #category : #'view manipulation' }
GolapRenderer >> zoomIn [
	self zoom: 1.1
]

{ #category : #'view manipulation' }
GolapRenderer >> zoomInCenter [
	self zoomCenter: 1.1
]

{ #category : #'view manipulation' }
GolapRenderer >> zoomOut [
	self zoom: 1.1 reciprocal
]

{ #category : #'view manipulation' }
GolapRenderer >> zoomOutCenter [
	self zoomCenter: 1.1 reciprocal
]
