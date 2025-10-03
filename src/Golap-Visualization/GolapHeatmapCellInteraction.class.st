Class {
	#name : 'GolapHeatmapCellInteraction',
	#superclass : 'RSPopup',
	#instVars : [
		'presenter',
		'golapModel'
	],
	#category : 'Golap-Visualization-Clustering',
	#package : 'Golap-Visualization',
	#tag : 'Clustering'
}

{ #category : 'hooks' }
GolapHeatmapCellInteraction >> clicked: event [

	event shape model ifNotNil: [ :triple |
			| node1 node2 |
			node1 := triple second.
			node2 := triple third.
			((presenter golap includesSelection: node1) and: [
				 presenter golap includesSelection: node2 ])
				ifTrue: [
						presenter golap
							unselect: node1;
							unselect: node2 ]
				ifFalse: [
						presenter golap
							select: node1;
							select: node2 ] ]
]

{ #category : 'hooks' }
GolapHeatmapCellInteraction >> createPopupFor: aShape event: event [

	| popupShape edge columnNode rowNode shapes |
	edge := aShape model first.
	columnNode := aShape model second.
	rowNode := aShape model third.
	shapes := Array streamContents: [ :stream |
			          columnNode photoimage ifNotNil: [ :form |
				          stream nextPut: (RSBitmap new form: form) ].
			          stream nextPut: (RSLabel new text: columnNode name).
			          stream nextPut: (RSLabel new text: '&').
			          stream nextPut: (RSLabel new text: rowNode name).
			          rowNode photoimage ifNotNil: [ :form |
				          stream nextPut: (RSBitmap new form: form) ].
			          edge ifNotNil: [
					          stream nextPut: (RSLabel new text:
							           'value: '
							           , (golapModel valueAtEdge: edge) printString) ] ].
	RSVerticalLineLayout new
		alignCenter;
		on: shapes.
	shapes := shapes asShape.
	popupShape := {
		              (RSBox new
			               extent:
				               shapes encompassingRectangle extent + (10 @ 10);
			               color: (Color gray: 0.9);
			               position: shapes encompassingRectangle center).
		              shapes } asShape.
	popupShape isFixed: true.
	self translatePopup: popupShape event: event.
	event canvas addShape: popupShape.
	^ popupShape
]

{ #category : 'accessing' }
GolapHeatmapCellInteraction >> golapModel [

	^ golapModel
]

{ #category : 'accessing' }
GolapHeatmapCellInteraction >> golapModel: aGolapModel [

	golapModel := aGolapModel
]

{ #category : 'hooks' }
GolapHeatmapCellInteraction >> onShape: aShape [

	aShape model ifNotNil: [
			super onShape: aShape.
			aShape
				when: RSMouseLeftClick send: #clicked: to: self;
				when: RSMouseRightClick send: #rightClicked: to: self ]
]

{ #category : 'accessing' }
GolapHeatmapCellInteraction >> presenter [

	^ presenter
]

{ #category : 'accessing' }
GolapHeatmapCellInteraction >> presenter: aGolapClusteredHeatmapPresenter [

	presenter := aGolapClusteredHeatmapPresenter
]

{ #category : 'hooks' }
GolapHeatmapCellInteraction >> rightClicked: event [

	event shape model ifNotNil: [
		(presenter cellMenuFor: event shape) openWithSpecAtPointer ]
]
