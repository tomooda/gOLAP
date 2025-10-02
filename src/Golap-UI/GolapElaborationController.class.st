Class {
	#name : 'GolapElaborationController',
	#superclass : 'RSCanvasController',
	#instVars : [
		'presenter'
	],
	#category : 'Golap-UI-Elaboration',
	#package : 'Golap-UI',
	#tag : 'Elaboration'
}

{ #category : 'initialization' }
GolapElaborationController >> defaultInteractions [
	"create a subclass of RSCanvasController and define your own custom interactions for your canvas"

	^ { GolapOverviewZoomableCanvasInteraction }
]

{ #category : 'accessing' }
GolapElaborationController >> presenter [

	^ presenter
]

{ #category : 'accessing' }
GolapElaborationController >> presenter: aGolapElaborationPresenter [

	presenter := aGolapElaborationPresenter.
	interactions do: [ :interaction |
			(interaction respondsTo: #presenter:) ifTrue: [
				interaction presenter: presenter ] ]
]

{ #category : 'hooks' }
GolapElaborationController >> renderLegendOn: aCanvas [
	| lb |
	self shouldShowLegend ifFalse: [ ^ self ].
	lb := RSLegend new
		container: aCanvas;
		yourself.
	lb defaultTitle fontSize: 12.
	lb defaultLabel fontSize: 10.
	lb defaultBoldText fontSize: 10.
	lb legendDo: [ :l |
		l
			border: RSBorder new;
			color: (Color white alpha: 0.8);
			padding: 10.
		].
	lb title: '操作説明'.
	self interactions do: [ :int | int renderLegendOn: lb ].
	lb onDemand: 'ヘルプ'.
	lb build
]
