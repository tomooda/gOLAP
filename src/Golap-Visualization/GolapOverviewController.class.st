Class {
	#name : 'GolapOverviewController',
	#superclass : 'RSCanvasController',
	#instVars : [
		'presenter'
	],
	#category : 'Golap-Visualization-Overview',
	#package : 'Golap-Visualization',
	#tag : 'Overview'
}

{ #category : 'initialization' }
GolapOverviewController >> defaultInteractions [
	"create a subclass of RSCanvasController and define your own custom interactions for your canvas"

	^ { GolapOverviewZoomableCanvasInteraction }
]

{ #category : 'accessing' }
GolapOverviewController >> presenter [

	^ presenter
]

{ #category : 'accessing' }
GolapOverviewController >> presenter: aGolapOverviewPresenter [

	presenter := aGolapOverviewPresenter.
	interactions do: [ :interaction |
			(interaction respondsTo: #presenter:) ifTrue: [
				interaction presenter: presenter ] ]
]

{ #category : 'hooks' }
GolapOverviewController >> renderLegendOn: aCanvas [
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
