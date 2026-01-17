Class {
	#name : 'GolapFTTableMorph',
	#superclass : 'FTTableMorph',
	#instVars : [
		'contentWidth'
	],
	#category : 'Golap-UI-Spec',
	#package : 'Golap-UI',
	#tag : 'Spec'
}

{ #category : 'private' }
GolapFTTableMorph >> containerFullWidth [

	^ container
		  ifNotNil: [
				  | origin |
				  origin := bounds origin x.
				  (container submorphs collect: [ :m | m bounds right ])
					  ifNotEmpty: [ :ws | ws max - bounds origin x * 2 ]
					  ifEmpty: [ self width ] ]
		  ifNil: [ self width ]
]

{ #category : 'private' }
GolapFTTableMorph >> contentWidth: aNumber [

	contentWidth := contentWidth
		                ifNotNil: [ contentWidth max: aNumber ]
		                ifNil: [ aNumber ]
]

{ #category : 'private' }
GolapFTTableMorph >> horizontalScrollBarValue: aNumber [

	self changed
]

{ #category : 'private' }
GolapFTTableMorph >> offsetByHorizontalScroll [

	^ (horizontalScrollBar notNil and: [ contentWidth notNil ])
		  ifTrue: [ contentWidth negated * horizontalScrollBar value @ 0 ]
		  ifFalse: [ 0 @ 0 ]
]
