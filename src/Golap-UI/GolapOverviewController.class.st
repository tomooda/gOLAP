Class {
	#name : 'GolapOverviewController',
	#superclass : 'RSCanvasController',
	#instVars : [
		'presenter'
	],
	#category : 'Golap-UI-Overview',
	#package : 'Golap-UI',
	#tag : 'Overview'
}

{ #category : 'initialization' }
GolapOverviewController >> defaultInteractions [
	"create a subclass of RSCanvasController and define your own custom interactions for your canvas"

	^ {
		  GolapOverviewZoomableCanvasInteraction.
		  RSScrollBarsCanvasInteraction.
		  RSSelectionInCanvasInteraction.
		  RSSearchInCanvasInteraction }
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
