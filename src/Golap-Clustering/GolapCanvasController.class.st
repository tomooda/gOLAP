Class {
	#name : 'GolapCanvasController',
	#superclass : 'RSCanvasController',
	#instVars : [
		'presenter'
	],
	#category : 'Golap-Clustering-Core',
	#package : 'Golap-Clustering',
	#tag : 'Core'
}

{ #category : 'instance creation' }
GolapCanvasController class >> on: aGolapDandelionChartPresenter [

	^ self new
		  presenter: aGolapDandelionChartPresenter;
		  yourself
]

{ #category : 'hooks' }
GolapCanvasController >> clicked: event [
]

{ #category : 'hooks' }
GolapCanvasController >> contextMenu [

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
GolapCanvasController >> onShape: aShape [

	super onShape: aShape.
	aShape
		when: RSMouseLeftClick send: #clicked: to: self;
		when: RSMouseRightClick send: #rightClicked: to: self
]

{ #category : 'accessing' }
GolapCanvasController >> presenter: aGolapDandelionChartPresenter [

	presenter := aGolapDandelionChartPresenter
]

{ #category : 'hooks' }
GolapCanvasController >> rightClicked: event [

	self contextMenu openWithSpecAt: (presenter withAdapterDo: [ :a |
			 a widgetDo: [ :w | w activeHand position ] ])
]
