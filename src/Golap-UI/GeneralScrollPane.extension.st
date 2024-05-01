Extension { #name : 'GeneralScrollPane' }

{ #category : '*Golap-UI' }
GeneralScrollPane >> hScrollbarInterval [

	"Answer the computed size of the thumb of the horizontal scrollbar."

	^ self scrollTarget width < 1
		  ifTrue: [ 1.0 ]
		  ifFalse: [ 
		  self scrollBounds width asFloat / self scrollTarget width min: 1.0 ]
]
