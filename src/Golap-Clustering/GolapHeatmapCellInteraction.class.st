Class {
	#name : 'GolapHeatmapCellInteraction',
	#superclass : 'RSPopup',
	#instVars : [
		'presenter'
	],
	#category : 'Golap-Clustering-Heatmap',
	#package : 'Golap-Clustering',
	#tag : 'Heatmap'
}

{ #category : 'hooks' }
GolapHeatmapCellInteraction >> clicked: event [

	| triple node1 node2 |
	triple := event shape model.
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
					select: node2 ]
]

{ #category : 'hooks' }
GolapHeatmapCellInteraction >> onShape: aShape [

	super onShape: aShape.
	aShape
		when: RSMouseLeftClick send: #clicked: to: self;
		when: RSMouseRightClick send: #rightClicked: to: self
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

	(presenter cellMenuFor: event shape) openWithSpecAtPointer
]
