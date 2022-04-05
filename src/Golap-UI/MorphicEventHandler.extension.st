Extension { #name : #MorphicEventHandler }

{ #category : #'*Golap-UI' }
MorphicEventHandler >> mouseWheel: event fromMorph: sourceMorph [
	^self notifyMorphsOfEvent: event ofType: #mouseWheel from: sourceMorph
]
