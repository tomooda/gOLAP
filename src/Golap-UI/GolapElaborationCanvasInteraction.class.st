Class {
	#name : 'GolapElaborationCanvasInteraction',
	#superclass : 'RSAbstractControlCanvasInteraction',
	#instVars : [
		'presenter'
	],
	#category : 'Golap-UI-Elaboration',
	#package : 'Golap-UI',
	#tag : 'Elaboration'
}

{ #category : 'hooks' }
GolapElaborationCanvasInteraction >> onShape: aCanvas [

	aCanvas
		when: RSMouseDragStart send: #processMouseDragStart: to: self;
		when: RSMouseDragging send: #processMouseDragging: to: self;
		when: RSMouseDragEnd send: #processMouseDragEnd: to: self;
		when: RSMouseWheelEvent send: #processMouseWheelEvent: to: self;
		when: RSKeyDown send: #processKeyDown: to: self
]

{ #category : 'accessing' }
GolapElaborationCanvasInteraction >> presenter [

	^ presenter
]

{ #category : 'accessing' }
GolapElaborationCanvasInteraction >> presenter: aGolapElaborationPresenter [

	presenter := aGolapElaborationPresenter
]

{ #category : 'event processing' }
GolapElaborationCanvasInteraction >> processKeyDown: evt [

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
GolapElaborationCanvasInteraction >> processMouseDragEnd: evt [

	
]

{ #category : 'event processing' }
GolapElaborationCanvasInteraction >> processMouseDragStart: evt [

	self removeRectanglesFor: evt canvas
]

{ #category : 'event processing' }
GolapElaborationCanvasInteraction >> processMouseDragging: evt [

	presenter move: evt step
]

{ #category : 'event processing' }
GolapElaborationCanvasInteraction >> processMouseWheelEvent: evt [

	evt isUp ifTrue: [ ^ presenter zoomInAt: evt position ].
	evt isDown ifTrue: [ ^ presenter zoomOutAt: evt position ]
]

{ #category : 'rendering' }
GolapElaborationCanvasInteraction >> renderLegendOn: legend [

	legend
		defaultTitle: '操作説明';
		text: 'マウスホイール, I, O' description: 'ズームイン/ズームアウト';
		text: 'マウスドラッグ, ←, →, ↑ or ↓' description: '視点移動';
		text: 'スペース' description: '視点・ズームをリセット'.
	GolapElaborationNodeInteraction new renderLegendOn: legend.
	GolapElaborationEdgeInteraction new renderLegendOn: legend
]
