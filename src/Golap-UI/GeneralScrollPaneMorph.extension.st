Extension { #name : #GeneralScrollPaneMorph }

{ #category : #'*Golap-UI' }
GeneralScrollPaneMorph >> hScrollbarInterval [
	"Answer the computed size of the thumb of the horizontal scrollbar."
	
	^self scrollBounds width asFloat / (self scrollTarget width max: 1) min: 1.0.
]

{ #category : #'*Golap-UI' }
GeneralScrollPaneMorph >> vScrollbarInterval [
	"Answer the computed size of the thumb of the vertical scrollbar."
	
	^self scrollBounds height asFloat / (self scrollTarget height max: 1) min: 1.0.
]
