Class {
	#name : 'GolapHierarchicalClusteringCanvasController',
	#superclass : 'RSCanvasController',
	#instVars : [
		'presenter'
	],
	#category : 'Golap-Visualization-Clustering',
	#package : 'Golap-Visualization',
	#tag : 'Clustering'
}

{ #category : 'instance creation' }
GolapHierarchicalClusteringCanvasController class >> on: aGolapDandelionChartPresenter [

	^ self new
		  presenter: aGolapDandelionChartPresenter;
		  yourself
]

{ #category : 'hooks' }
GolapHierarchicalClusteringCanvasController >> clicked: event [
]

{ #category : 'hooks' }
GolapHierarchicalClusteringCanvasController >> contextMenu [

	^ presenter newMenu
		  addGroup: [ :group |
			  presenter tree parent ifNotNil: [ :parent |
					  group addItem: [ :item |
							  item
								  name: 'Undive';
								  action: [ presenter tree: parent ] ] ] ];
		  yourself
]

{ #category : 'hooks' }
GolapHierarchicalClusteringCanvasController >> onShape: aShape [

	super onShape: aShape.
	aShape
		when: RSMouseLeftClick send: #clicked: to: self;
		when: RSMouseRightClick send: #rightClicked: to: self
]

{ #category : 'accessing' }
GolapHierarchicalClusteringCanvasController >> presenter: aGolapDandelionChartPresenter [

	presenter := aGolapDandelionChartPresenter
]

{ #category : 'hooks' }
GolapHierarchicalClusteringCanvasController >> rightClicked: event [

	self contextMenu openWithSpecAtPointer
]
