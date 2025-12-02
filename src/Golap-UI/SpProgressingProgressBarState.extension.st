Extension { #name : 'SpProgressingProgressBarState' }

{ #category : '*Golap-UI' }
SpProgressingProgressBarState >> customizeMorphicLabel: aLabelMorph [

	aLabelMorph contents: self progression value asString
]
