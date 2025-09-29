Class {
	#name : 'GolapPolishOverviewPresenter',
	#superclass : 'GolapOverviewPresenter',
	#category : 'Golap-UI-Overview',
	#package : 'Golap-UI',
	#tag : 'Overview'
}

{ #category : 'accessing' }
GolapPolishOverviewPresenter >> availableEdges [

	^ Array streamContents: [ :stream |
			  self golapModelDo: [ :golapModel |
					  golapModel
						  edgesDo: [ :edge | stream nextPut: edge ];
						  negativePolishEdgesDo: [ :edge | stream nextPut: edge ] ] ]
]
