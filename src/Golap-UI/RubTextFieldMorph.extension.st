Extension { #name : #RubTextFieldMorph }

{ #category : #'*Golap-UI' }
RubTextFieldMorph >> acceptDroppingMorph: aMorph event: evt [
	^ self model acceptDropBlock
		cull: (aMorph)
		cull: nil
		cull: nil
]

{ #category : #'*Golap-UI' }
RubTextFieldMorph >> wantsDroppedMorph: aMorph event: event [
	^ true
]
