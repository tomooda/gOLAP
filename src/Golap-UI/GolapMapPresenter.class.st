Class {
	#name : 'GolapMapPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'roassal',
		'golap'
	],
	#category : 'Golap-UI-Graph',
	#package : 'Golap-UI',
	#tag : 'Graph'
}

{ #category : 'accessing' }
GolapMapPresenter >> canvas [

	^ roassal canvas
]

{ #category : 'enumerating' }
GolapMapPresenter >> golapModelDo: aBlock [

	^ golap ifNotNil: [ golap model ifNotNil: aBlock ]
]

{ #category : 'instance creation' }
GolapMapPresenter >> newLabelFor: aGolapNode [

	^ RSLabel new
		  text: aGolapNode name;
		  yourself
]

{ #category : 'updating' }
GolapMapPresenter >> updateCanvas [

	self canvas shapes copy do: #remove.
	self canvas color: Color white.
	self golapModelDo: [ :golapModel |
			golapModel nodesDo: [ :node |
					node x ifNotNil: [ :x |
							node y ifNotNil: [ :y |
									| shape |
									shape := self newLabelFor: node.
									shape position: x @ y.
									self canvas add: shape ] ] ].
			self zoomToFit ]
]

{ #category : 'operations' }
GolapMapPresenter >> zoomToFit [

	self canvas
		zoomToFit;
		signalUpdate
]
