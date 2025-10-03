Class {
	#name : 'GolapHeatmapRowLabelInteraction',
	#superclass : 'RSInteraction',
	#instVars : [
		'presenter',
		'golapModel'
	],
	#category : 'Golap-Visualization-Clustering',
	#package : 'Golap-Visualization',
	#tag : 'Clustering'
}

{ #category : 'hooks' }
GolapHeatmapRowLabelInteraction >> clicked: event [

	event shape model ifNotNil: [ :pair |
			| node |
			node := pair second.
			(presenter golap includesSelection: node)
				ifTrue: [ presenter golap unselect: node ]
				ifFalse: [ presenter golap select: node ] ]
]

{ #category : 'accessing' }
GolapHeatmapRowLabelInteraction >> golapModel [

	^ golapModel
]

{ #category : 'accessing' }
GolapHeatmapRowLabelInteraction >> golapModel: aGolapModel [

	golapModel := aGolapModel
]

{ #category : 'hooks' }
GolapHeatmapRowLabelInteraction >> onShape: aShape [

	aShape model ifNotNil: [
			aShape
				when: RSMouseLeftClick send: #clicked: to: self;
				when: RSMouseRightClick send: #rightClicked: to: self ]
]

{ #category : 'accessing' }
GolapHeatmapRowLabelInteraction >> presenter [

	^ presenter
]

{ #category : 'accessing' }
GolapHeatmapRowLabelInteraction >> presenter: aGolapClusteredHeatmapPresenter [

	presenter := aGolapClusteredHeatmapPresenter
]

{ #category : 'hooks' }
GolapHeatmapRowLabelInteraction >> rightClicked: event [

	event shape model ifNotNil: [
			(presenter menuForNode: event shape model second)
				openWithSpecAtPointer ]
]
