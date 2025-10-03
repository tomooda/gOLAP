Class {
	#name : 'GolapOverviewZoomableCanvasInteraction',
	#superclass : 'RSAbstractControlCanvasInteraction',
	#instVars : [
		'presenter'
	],
	#category : 'Golap-Visualization-Overview',
	#package : 'Golap-Visualization',
	#tag : 'Overview'
}

{ #category : 'hooks' }
GolapOverviewZoomableCanvasInteraction >> onShape: aCanvas [

	aCanvas
		when: RSMouseDragStart send: #processMouseDragStart: to: self;
		when: RSMouseDragging send: #processMouseDragging: to: self;
		when: RSMouseDragEnd send: #processMouseDragEnd: to: self;
		when: RSMouseWheelEvent send: #processMouseWheelEvent: to: self;
		when: RSKeyDown send: #processKeyDown: to: self
]

{ #category : 'accessing' }
GolapOverviewZoomableCanvasInteraction >> presenter [

	^ presenter
]

{ #category : 'accessing' }
GolapOverviewZoomableCanvasInteraction >> presenter: aGolapOverviewPresenter [

	presenter := aGolapOverviewPresenter
]

{ #category : 'event processing' }
GolapOverviewZoomableCanvasInteraction >> processKeyDown: evt [

	| keyName |
	keyName := evt keyName.
	keyName = #I ifTrue: [ ^ presenter zoomInAt: evt position ].
	keyName = #O ifTrue: [ ^ presenter zoomOutAt: evt position ].
	keyName = #LEFT ifTrue: [ ^ presenter move: -10.0 @ 0.0 ].
	keyName = #RIGHT ifTrue: [ ^ presenter move: 10.0 @ 0.0 ].
	keyName = #UP ifTrue: [ ^ presenter move: 0.0 @ -10.0 ].
	keyName = #DOWN ifTrue: [ ^ presenter move: 0.0 @ 10.0 ].
	keyName = #SPACE ifTrue: [ ^ presenter zoomToFit ]
]

{ #category : 'event processing' }
GolapOverviewZoomableCanvasInteraction >> processMouseDragEnd: evt [

	
]

{ #category : 'event processing' }
GolapOverviewZoomableCanvasInteraction >> processMouseDragStart: evt [

	self removeRectanglesFor: evt canvas
]

{ #category : 'event processing' }
GolapOverviewZoomableCanvasInteraction >> processMouseDragging: evt [

	presenter move: evt step
]

{ #category : 'event processing' }
GolapOverviewZoomableCanvasInteraction >> processMouseWheelEvent: evt [

	evt isUp ifTrue: [ ^ presenter zoomInAt: evt position ].
	evt isDown ifTrue: [ ^ presenter zoomOutAt: evt position ]
]

{ #category : 'rendering' }
GolapOverviewZoomableCanvasInteraction >> renderLegendOn: legend [

	legend
		defaultTitle: '操作説明';
		text: 'マウスホイール, I, O' description: 'ズームイン/ズームアウト';
		text: 'マウスドラッグ, ←, →, ↑ or ↓' description: '視点移動';
		text: 'スペース' description: '視点・ズームをリセット'.
	GolapOverviewNodeInteraction new renderLegendOn: legend.
	GolapOverviewEdgeInteraction new renderLegendOn: legend
]
